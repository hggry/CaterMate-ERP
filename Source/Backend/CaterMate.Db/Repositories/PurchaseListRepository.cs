using Dapper;
using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public class PurchaseListRepository : IPurchaseListRepository
{
    private readonly DapperContext _context;

    private const string SelectByOrderId = "SELECT * FROM PurchaseLists WHERE OrderId = @OrderId LIMIT 1";
    private const string SelectItems = "SELECT * FROM PurchaseListItems WHERE PurchaseListId = @PurchaseListId";
    private const string ExistsByOrderId = "SELECT COUNT(*) FROM PurchaseLists WHERE OrderId = @OrderId";
    private const string ItemExists = "SELECT COUNT(*) FROM PurchaseListItems WHERE Id = @Id";
    private const string InsertList = @"
        INSERT INTO PurchaseLists (OrderId, SafetyMargin) VALUES (@OrderId, @SafetyMargin);
        SELECT LAST_INSERT_ID();";
    private const string InsertItem = @"
        INSERT INTO PurchaseListItems (PurchaseListId, IngredientId, IngredientName, RequiredQuantity, Unit, Category, IsDone)
        VALUES (@PurchaseListId, @IngredientId, @IngredientName, @RequiredQuantity, @Unit, @Category, @IsDone)";
    private const string UpdateIsDone = "UPDATE PurchaseListItems SET IsDone = @IsDone WHERE Id = @Id";
    private const string DeleteItemsByOrder =
        "DELETE pli FROM PurchaseListItems pli JOIN PurchaseLists pl ON pl.Id = pli.PurchaseListId WHERE pl.OrderId = @OrderId";
    private const string DeleteListByOrder = "DELETE FROM PurchaseLists WHERE OrderId = @OrderId";

    public PurchaseListRepository(DapperContext context) => _context = context;

    public async Task<PurchaseListEntity?> GetByOrderIdAsync(int orderId)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<PurchaseListEntity>(SelectByOrderId, new { OrderId = orderId });
    }

    public async Task<IEnumerable<PurchaseListItemEntity>> GetItemsAsync(int purchaseListId)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryAsync<PurchaseListItemEntity>(SelectItems, new { PurchaseListId = purchaseListId });
    }

    public async Task<bool> ExistsByOrderIdAsync(int orderId)
    {
        using var conn = _context.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(ExistsByOrderId, new { OrderId = orderId }) > 0;
    }

    public async Task<bool> ItemExistsAsync(int itemId)
    {
        using var conn = _context.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(ItemExists, new { Id = itemId }) > 0;
    }

    public async Task<int> CreateAsync(PurchaseListEntity list, IEnumerable<PurchaseListItemEntity> items)
    {
        using var conn = _context.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        var listId = await conn.ExecuteScalarAsync<int>(InsertList, list, tx);
        foreach (var item in items)
        {
            item.PurchaseListId = listId;
            await conn.ExecuteAsync(InsertItem, item, tx);
        }
        tx.Commit();
        return listId;
    }

    public async Task UpdateItemIsDoneAsync(int itemId, bool isDone)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(UpdateIsDone, new { Id = itemId, IsDone = isDone });
    }

    public async Task DeleteByOrderIdAsync(int orderId)
    {
        using var conn = _context.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        await conn.ExecuteAsync(DeleteItemsByOrder, new { OrderId = orderId }, tx);
        await conn.ExecuteAsync(DeleteListByOrder, new { OrderId = orderId }, tx);
        tx.Commit();
    }
}
