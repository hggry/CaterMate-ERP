using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public interface IPurchaseListRepository
{
    Task<PurchaseListEntity?> GetByOrderIdAsync(int orderId);
    Task<IEnumerable<PurchaseListItemEntity>> GetItemsAsync(int purchaseListId);
    Task<int> CreateAsync(PurchaseListEntity list, IEnumerable<PurchaseListItemEntity> items);
    Task UpdateItemIsDoneAsync(int itemId, bool isDone);
    Task<bool> ExistsByOrderIdAsync(int orderId);
    Task<bool> ItemExistsAsync(int itemId);
    Task DeleteByOrderIdAsync(int orderId);
}
