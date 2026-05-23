using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public interface IMenuItemRepository
{
    Task<IEnumerable<MenuItemEntity>> GetAllAsync(string? category);
    Task<MenuItemEntity?> GetByIdAsync(int id);
    Task<IEnumerable<MenuItemIngredientEntity>> GetBillOfMaterialsAsync(int menuItemId);
    Task<int> CreateAsync(MenuItemEntity menuItem);
    Task UpdateAsync(MenuItemEntity menuItem);
    Task SetBillOfMaterialsAsync(int menuItemId, IEnumerable<(int IngredientId, decimal QuantityPerPerson)> items);
    Task DeleteAsync(int id);
    Task<bool> IsUsedInActiveOrderAsync(int menuItemId);
    Task<bool> IsIngredientInBomAsync(int ingredientId);
}
