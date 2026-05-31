using CaterMate.BusinessLogic.Pdf;
using CaterMate.BusinessLogic.Settings;
using CaterMate.Db.Entities;
using CaterMate.Db.Repositories;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Procurement;

public class PurchaseListService : IPurchaseListService
{
    private readonly IPurchaseListRepository _repo;
    private readonly IOrderRepository _orderRepo;
    private readonly IMenuItemRepository _menuItemRepo;
    private readonly IIngredientRepository _ingredientRepo;
    private readonly IPdfService _pdfService;
    private readonly ICompanySettingsService _companySettings;

    private const decimal SafetyMargin = 0.10m;

    public PurchaseListService(
        IPurchaseListRepository repo,
        IOrderRepository orderRepo,
        IMenuItemRepository menuItemRepo,
        IIngredientRepository ingredientRepo,
        IPdfService pdfService,
        ICompanySettingsService companySettings)
    {
        _repo = repo;
        _orderRepo = orderRepo;
        _menuItemRepo = menuItemRepo;
        _ingredientRepo = ingredientRepo;
        _pdfService = pdfService;
        _companySettings = companySettings;
    }

    public async Task CreateForOrderAsync(int orderId)
    {
        // Rebuild from scratch on re-confirmation (e.g. after a reopen + menu change),
        // so the list always reflects the current menu selection.
        if (await _repo.ExistsByOrderIdAsync(orderId))
            await _repo.DeleteByOrderIdAsync(orderId);

        var order = await _orderRepo.GetByIdAsync(orderId)
            ?? throw new KeyNotFoundException($"Order {orderId} not found");

        var menuItems = await _orderRepo.GetAssignedMenuItemsAsync(orderId);
        var ingredientDict = (await _ingredientRepo.GetAllAsync()).ToDictionary(i => i.Id);

        var aggregated = new Dictionary<int, decimal>();
        foreach (var item in menuItems)
        {
            var effectiveCount = item.AssignedCount ?? order.GuestCount;
            var bom = await _menuItemRepo.GetBillOfMaterialsAsync(item.Id);
            foreach (var entry in bom)
                aggregated[entry.IngredientId] = aggregated.GetValueOrDefault(entry.IngredientId) + entry.QuantityPerPerson * effectiveCount;
        }

        var listEntity = new PurchaseListEntity
        {
            OrderId = orderId,
            SafetyMargin = SafetyMargin
        };

        var items = aggregated
            .Where(kv => ingredientDict.ContainsKey(kv.Key))
            .Select(kv =>
            {
                var ingredient = ingredientDict[kv.Key];
                return new PurchaseListItemEntity
                {
                    IngredientId = kv.Key,
                    IngredientName = ingredient.Name,
                    RequiredQuantity = kv.Value * (1 + SafetyMargin),
                    Unit = ingredient.Unit,
                    Category = ingredient.Category ?? "",
                    IsDone = false
                };
            })
            .ToList();

        await _repo.CreateAsync(listEntity, items);
    }

    public async Task<PurchaseListDto> GetByOrderIdAsync(int orderId)
    {
        var list = await _repo.GetByOrderIdAsync(orderId)
            ?? throw new KeyNotFoundException($"Keine Einkaufsliste für Auftrag {orderId} gefunden.");
        var items = await _repo.GetItemsAsync(list.Id);

        var groups = items
            .GroupBy(i => i.Category ?? "")
            .OrderBy(g => g.Key)
            .Select(g => new PurchaseGroupDto
            {
                Category = g.Key,
                Items = g.Select(i => new PurchaseListItemDto
                {
                    Id = i.Id,
                    IngredientId = i.IngredientId,
                    IngredientName = i.IngredientName,
                    RequiredQuantity = i.RequiredQuantity,
                    Unit = i.Unit,
                    IsDone = i.IsDone
                }).ToList()
            })
            .ToList();

        return new PurchaseListDto
        {
            Id = list.Id,
            OrderId = list.OrderId,
            SafetyMargin = list.SafetyMargin,
            Groups = groups
        };
    }

    public async Task UpdateItemAsync(int itemId, bool isDone)
    {
        if (!await _repo.ItemExistsAsync(itemId))
            throw new KeyNotFoundException($"PurchaseListItem {itemId} not found");

        await _repo.UpdateItemIsDoneAsync(itemId, isDone);
    }

    public async Task<byte[]> GetPdfBytesAsync(int orderId)
    {
        var dto = await GetByOrderIdAsync(orderId);
        var order = await _orderRepo.GetByIdAsync(orderId)
            ?? throw new KeyNotFoundException($"Order {orderId} not found");
        var company = await _companySettings.GetAsync();
        return _pdfService.GeneratePurchaseListPdf(dto, order.GuestCount, company);
    }
}
