using CaterMate.Db.Entities;
using CaterMate.Db.Repositories;
using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Menu;

public class MenuItemService : IMenuItemService
{
    private readonly IMenuItemRepository _menuItemRepo;

    public MenuItemService(IMenuItemRepository menuItemRepo) => _menuItemRepo = menuItemRepo;

    public async Task<IEnumerable<MenuItemDto>> GetAllAsync(string? category)
    {
        var items = await _menuItemRepo.GetAllAsync(category);
        var result = new List<MenuItemDto>();
        foreach (var item in items)
        {
            var bom = await _menuItemRepo.GetBillOfMaterialsAsync(item.Id);
            result.Add(MapToDto(item, bom));
        }
        return result;
    }

    public async Task<MenuItemDto> GetByIdAsync(int id)
    {
        var item = await _menuItemRepo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"MenuItem {id} not found");
        var bom = await _menuItemRepo.GetBillOfMaterialsAsync(id);
        return MapToDto(item, bom);
    }

    public async Task<MenuItemDto> CreateAsync(CreateMenuItemRequest request)
    {
        var entity = new MenuItemEntity
        {
            Name = request.Name,
            Category = request.Category,
            SalesPricePerPerson = request.SalesPricePerPerson,
            PurchaseCostPerPerson = request.PurchaseCostPerPerson,
            Allergens = request.Allergens
        };

        var id = await _menuItemRepo.CreateAsync(entity);

        if (request.BillOfMaterials?.Length > 0)
            await _menuItemRepo.SetBillOfMaterialsAsync(id,
                request.BillOfMaterials.Select(b => (b.IngredientId, b.QuantityPerPerson)));

        return await GetByIdAsync(id);
    }

    public async Task<MenuItemDto> UpdateAsync(int id, UpdateMenuItemRequest request)
    {
        var existing = await _menuItemRepo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"MenuItem {id} not found");

        existing.Name = request.Name;
        existing.Category = request.Category;
        existing.SalesPricePerPerson = request.SalesPricePerPerson;
        existing.PurchaseCostPerPerson = request.PurchaseCostPerPerson;
        existing.Allergens = request.Allergens;

        await _menuItemRepo.UpdateAsync(existing);

        if (request.BillOfMaterials != null)
            await _menuItemRepo.SetBillOfMaterialsAsync(id,
                request.BillOfMaterials.Select(b => (b.IngredientId, b.QuantityPerPerson)));

        return await GetByIdAsync(id);
    }

    public async Task DeleteAsync(int id)
    {
        if (await _menuItemRepo.GetByIdAsync(id) == null)
            throw new KeyNotFoundException($"MenuItem {id} not found");

        if (await _menuItemRepo.IsUsedInActiveOrderAsync(id))
            throw new InvalidOperationException("Menüartikel ist einem aktiven Auftrag zugeordnet und kann nicht gelöscht werden.");

        await _menuItemRepo.DeleteAsync(id);
    }

    private static MenuItemDto MapToDto(MenuItemEntity item, IEnumerable<MenuItemIngredientEntity> bom) =>
        new()
        {
            Id = item.Id,
            Name = item.Name,
            Category = item.Category,
            SalesPricePerPerson = item.SalesPricePerPerson,
            PurchaseCostPerPerson = item.PurchaseCostPerPerson,
            Allergens = item.Allergens,
            CreatedAt = item.CreatedAt,
            BillOfMaterials = bom.Select(b => new BillOfMaterialsItemDto
            {
                IngredientId = b.IngredientId,
                QuantityPerPerson = b.QuantityPerPerson
            }).ToList()
        };
}
