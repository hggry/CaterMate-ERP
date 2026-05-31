using CaterMate.BusinessLogic.Pdf;
using CaterMate.BusinessLogic.Settings;
using CaterMate.Db.Entities;
using CaterMate.Db.Repositories;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Invoicing;

public class InvoiceService : IInvoiceService
{
    private readonly IInvoiceRepository _invoiceRepo;
    private readonly IOrderRepository _orderRepo;
    private readonly IQuoteRepository _quoteRepo;
    private readonly ICustomerRepository _customerRepo;
    private readonly IPdfService _pdfService;
    private readonly ICompanySettingsService _companySettings;

    public InvoiceService(
        IInvoiceRepository invoiceRepo,
        IOrderRepository orderRepo,
        IQuoteRepository quoteRepo,
        ICustomerRepository customerRepo,
        IPdfService pdfService,
        ICompanySettingsService companySettings)
    {
        _invoiceRepo = invoiceRepo;
        _orderRepo = orderRepo;
        _quoteRepo = quoteRepo;
        _customerRepo = customerRepo;
        _pdfService = pdfService;
        _companySettings = companySettings;
    }

    public async Task<InvoiceDto> CreateAsync(int orderId)
    {
        var order = await _orderRepo.GetByIdAsync(orderId)
            ?? throw new KeyNotFoundException($"Order {orderId} not found");

        if (order.Status != "Durchgeführt")
            throw new InvalidOperationException("Rechnung kann nur für Aufträge im Status 'Durchgeführt' erstellt werden.");

        var quote = await _quoteRepo.GetByOrderIdAsync(orderId)
            ?? throw new InvalidOperationException("Kein Angebot vorhanden. Rechnung kann nicht erstellt werden.");

        var customer = await _customerRepo.GetByIdAsync(order.CustomerId);
        var quotePositions = await _quoteRepo.GetPositionsAsync(quote.Id);
        var invoiceNumber = await _invoiceRepo.GetNextInvoiceNumberAsync(DateTime.Today.Year);

        var invoiceEntity = new InvoiceEntity
        {
            OrderId = orderId,
            InvoiceNumber = invoiceNumber,
            CustomerName = customer?.Name ?? "",
            IssueDate = DateTime.Today,
            DueDate = DateTime.Today.AddDays(14),
            TotalNet = quote.TotalNet,
            TotalVat = quote.TotalVat,
            TotalGross = quote.TotalGross
        };

        var positions = quotePositions.Select(p => new InvoicePositionEntity
        {
            MenuItemId = p.MenuItemId,
            MenuItemName = p.MenuItemName,
            Quantity = p.Quantity,
            UnitPrice = p.UnitPrice,
            TotalNet = p.TotalNet,
            VatRate = p.VatRate,
            VatAmount = p.VatAmount,
            TotalGross = p.TotalGross
        }).ToList();

        await _invoiceRepo.CreateAsync(invoiceEntity, positions);

        return await GetByOrderIdAsync(orderId);
    }

    public async Task<InvoiceDto> GetByOrderIdAsync(int orderId)
    {
        var invoice = await _invoiceRepo.GetByOrderIdAsync(orderId)
            ?? throw new KeyNotFoundException($"Keine Rechnung für Auftrag {orderId} gefunden.");
        var positions = await _invoiceRepo.GetPositionsAsync(invoice.Id);
        return MapToDto(invoice, positions);
    }

    public async Task<byte[]> GetPdfBytesAsync(int orderId)
    {
        var dto = await GetByOrderIdAsync(orderId);
        var company = await _companySettings.GetAsync();
        return _pdfService.GenerateInvoicePdf(dto, company);
    }

    private static InvoiceDto MapToDto(InvoiceEntity invoice, IEnumerable<InvoicePositionEntity> positions) =>
        new()
        {
            Id = invoice.Id,
            InvoiceNumber = invoice.InvoiceNumber,
            OrderId = invoice.OrderId,
            CustomerName = invoice.CustomerName,
            IssueDate = invoice.IssueDate,
            DueDate = invoice.DueDate,
            TotalNet = invoice.TotalNet,
            TotalVat = invoice.TotalVat,
            TotalGross = invoice.TotalGross,
            Positions = positions.Select(p => new QuotePositionDto
            {
                MenuItemId = p.MenuItemId,
                MenuItemName = p.MenuItemName,
                Quantity = p.Quantity,
                UnitPrice = p.UnitPrice,
                TotalNet = p.TotalNet,
                VatRate = p.VatRate,
                VatAmount = p.VatAmount,
                TotalGross = p.TotalGross,
                MenuItemCategory = p.MenuItemCategory,
            }).ToList()
        };
}
