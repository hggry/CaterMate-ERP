using CaterMate.BusinessLogic.Pdf;
using CaterMate.Db.Entities;
using CaterMate.Db.Repositories;
using CaterMate.DTOs.Responses;
using Microsoft.Extensions.Configuration;

namespace CaterMate.BusinessLogic.Quotes;

public class QuoteService : IQuoteService
{
    private readonly IQuoteRepository _quoteRepo;
    private readonly IOrderRepository _orderRepo;
    private readonly ICustomerRepository _customerRepo;
    private readonly IPdfService _pdfService;
    private readonly decimal _adminFee;

    public QuoteService(
        IQuoteRepository quoteRepo,
        IOrderRepository orderRepo,
        ICustomerRepository customerRepo,
        IPdfService pdfService,
        IConfiguration config)
    {
        _quoteRepo = quoteRepo;
        _orderRepo = orderRepo;
        _customerRepo = customerRepo;
        _pdfService = pdfService;
        _adminFee = decimal.TryParse(config["VERWALTUNGSPAUSCHALE"], out var fee) ? fee : 200m;
    }

    public async Task<QuoteDto> GenerateAsync(int orderId)
    {
        var order = await _orderRepo.GetByIdAsync(orderId)
            ?? throw new KeyNotFoundException($"Order {orderId} not found");

        if (await _quoteRepo.ExistsByOrderIdAsync(orderId))
            throw new InvalidOperationException("Für diesen Auftrag existiert bereits ein Angebot.");

        var menuItems = (await _orderRepo.GetAssignedMenuItemsAsync(orderId)).ToList();
        var positions = BuildPositions(menuItems, order.GuestCount);

        var totalNet = positions.Sum(p => p.TotalNet) + _adminFee;
        var totalVat = positions.Sum(p => p.VatAmount);

        var quoteEntity = new QuoteEntity
        {
            OrderId = orderId,
            AdminFee = _adminFee,
            ProfitMarginRate = 0.15m,
            TotalNet = totalNet,
            TotalVat = totalVat,
            TotalGross = totalNet + totalVat
        };

        await _quoteRepo.CreateAsync(quoteEntity, positions);
        return await GetByOrderIdAsync(orderId);
    }

    public async Task<QuoteDto> GetByOrderIdAsync(int orderId)
    {
        var quote = await _quoteRepo.GetByOrderIdAsync(orderId)
            ?? throw new KeyNotFoundException($"Kein Angebot für Auftrag {orderId} gefunden.");
        var positions = await _quoteRepo.GetPositionsAsync(quote.Id);
        return MapToDto(quote, positions);
    }

    public async Task<QuoteDto> UpdateAsync(int orderId, QuoteDto dto)
    {
        var quote = await _quoteRepo.GetByOrderIdAsync(orderId)
            ?? throw new KeyNotFoundException($"Kein Angebot für Auftrag {orderId} gefunden.");

        var positions = dto.Positions.Select(p => new QuotePositionEntity
        {
            QuoteId = quote.Id,
            MenuItemId = p.MenuItemId,
            MenuItemName = p.MenuItemName,
            Quantity = p.Quantity,
            UnitPrice = p.UnitPrice,
            TotalNet = p.Quantity * p.UnitPrice,
            VatRate = p.VatRate,
            VatAmount = p.Quantity * p.UnitPrice * p.VatRate,
            TotalGross = p.Quantity * p.UnitPrice * (1 + p.VatRate)
        }).ToList();

        quote.TotalNet = positions.Sum(p => p.TotalNet) + quote.AdminFee;
        quote.TotalVat = positions.Sum(p => p.VatAmount);
        quote.TotalGross = quote.TotalNet + quote.TotalVat;

        await _quoteRepo.UpdateAsync(quote, positions);
        return await GetByOrderIdAsync(orderId);
    }

    public async Task<byte[]> GetPdfBytesAsync(int orderId)
    {
        var dto = await GetByOrderIdAsync(orderId);
        var order = await _orderRepo.GetByIdAsync(orderId)
            ?? throw new KeyNotFoundException($"Order {orderId} not found");
        var customer = await _customerRepo.GetByIdAsync(order.CustomerId);
        return _pdfService.GenerateQuotePdf(dto, customer?.Name ?? "", order.EventDate);
    }

    private static List<QuotePositionEntity> BuildPositions(IEnumerable<MenuItemEntity> menuItems, int guestCount) =>
        menuItems.Select(item =>
        {
            var vatRate = item.Category == "Getränk (alkoholisch)" ? 0.20m : 0.10m;
            var totalNet = item.SalesPricePerPerson * guestCount;
            var vatAmount = totalNet * vatRate;
            return new QuotePositionEntity
            {
                MenuItemId = item.Id,
                MenuItemName = item.Name,
                Quantity = guestCount,
                UnitPrice = item.SalesPricePerPerson,
                TotalNet = totalNet,
                VatRate = vatRate,
                VatAmount = vatAmount,
                TotalGross = totalNet + vatAmount
            };
        }).ToList();

    private static QuoteDto MapToDto(QuoteEntity quote, IEnumerable<QuotePositionEntity> positions) =>
        new()
        {
            Id = quote.Id,
            OrderId = quote.OrderId,
            AdminFee = quote.AdminFee,
            ProfitMargin = quote.ProfitMarginRate,
            TotalNet = quote.TotalNet,
            TotalVat = quote.TotalVat,
            TotalGross = quote.TotalGross,
            CreatedAt = quote.CreatedAt,
            Positions = positions.Select(p => new QuotePositionDto
            {
                MenuItemId = p.MenuItemId,
                MenuItemName = p.MenuItemName,
                Quantity = p.Quantity,
                UnitPrice = p.UnitPrice,
                TotalNet = p.TotalNet,
                VatRate = p.VatRate,
                VatAmount = p.VatAmount,
                TotalGross = p.TotalGross
            }).ToList()
        };
}
