using Dapper;
using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public class MenuItemRepository : IMenuItemRepository
{
    private readonly DapperContext _context;

    private const string SelectAll = @"
        SELECT * FROM MenuItems
        WHERE (@Category IS NULL OR Category = @Category)
        ORDER BY Category, Name";

    private const string SelectById = "SELECT * FROM MenuItems WHERE Id = @Id";

    private const string SelectBom = @"
        SELECT mii.*, i.Name AS IngredientName, i.Unit, i.Category AS IngredientCategory
        FROM MenuItemIngredients mii
        INNER JOIN Ingredients i ON i.Id = mii.IngredientId
        WHERE mii.MenuItemId = @MenuItemId";

    private const string Insert = @"
        INSERT INTO MenuItems (Name, Category, SalesPricePerPerson, PurchaseCostPerPerson, Allergens)
        VALUES (@Name, @Category, @SalesPricePerPerson, @PurchaseCostPerPerson, @Allergens);
        SELECT LAST_INSERT_ID();";

    private const string Update = @"
        UPDATE MenuItems SET
            Name = @Name, Category = @Category,
            SalesPricePerPerson = @SalesPricePerPerson, PurchaseCostPerPerson = @PurchaseCostPerPerson,
            Allergens = @Allergens
        WHERE Id = @Id";

    private const string DeleteBom = "DELETE FROM MenuItemIngredients WHERE MenuItemId = @MenuItemId";
    private const string InsertBomItem = "INSERT INTO MenuItemIngredients (MenuItemId, IngredientId, QuantityPerPerson) VALUES (@MenuItemId, @IngredientId, @QuantityPerPerson)";

    private const string Delete = "DELETE FROM MenuItems WHERE Id = @Id";

    private const string CheckActiveOrders = @"
        SELECT COUNT(*) FROM OrderMenuItems omi
        INNER JOIN Orders o ON o.Id = omi.OrderId
        WHERE omi.MenuItemId = @MenuItemId
          AND o.Status NOT IN ('Durchgeführt', 'Abgerechnet')";

    public MenuItemRepository(DapperContext context) => _context = context;

    public async Task<IEnumerable<MenuItemEntity>> GetAllAsync(string? category)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryAsync<MenuItemEntity>(SelectAll, new { Category = category });
    }

    public async Task<MenuItemEntity?> GetByIdAsync(int id)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<MenuItemEntity>(SelectById, new { Id = id });
    }

    public async Task<IEnumerable<MenuItemIngredientEntity>> GetBillOfMaterialsAsync(int menuItemId)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryAsync<MenuItemIngredientEntity>(SelectBom, new { MenuItemId = menuItemId });
    }

    public async Task<int> CreateAsync(MenuItemEntity menuItem)
    {
        using var conn = _context.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(Insert, menuItem);
    }

    public async Task UpdateAsync(MenuItemEntity menuItem)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(Update, menuItem);
    }

    public async Task SetBillOfMaterialsAsync(int menuItemId, IEnumerable<(int IngredientId, decimal QuantityPerPerson)> items)
    {
        using var conn = _context.CreateConnection();
        await conn.OpenAsync();
        using var tx = await conn.BeginTransactionAsync();
        await conn.ExecuteAsync(DeleteBom, new { MenuItemId = menuItemId }, tx);
        foreach (var (ingredientId, qty) in items)
            await conn.ExecuteAsync(InsertBomItem, new { MenuItemId = menuItemId, IngredientId = ingredientId, QuantityPerPerson = qty }, tx);
        await tx.CommitAsync();
    }

    public async Task DeleteAsync(int id)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(Delete, new { Id = id });
    }

    public async Task<bool> IsUsedInActiveOrderAsync(int menuItemId)
    {
        using var conn = _context.CreateConnection();
        var count = await conn.ExecuteScalarAsync<int>(CheckActiveOrders, new { MenuItemId = menuItemId });
        return count > 0;
    }
}
