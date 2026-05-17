using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public interface IOrderRepository
{
    Task<IEnumerable<OrderEntity>> GetAllAsync(string? status, DateTime? from, DateTime? to);
    Task<OrderEntity?> GetByIdAsync(int id);
    Task<IEnumerable<MenuItemEntity>> GetAssignedMenuItemsAsync(int orderId);
    Task<int> CreateAsync(OrderEntity order);
    Task UpdateAsync(OrderEntity order);
    Task UpdateStatusAsync(int id, string status);
    Task SetMenuItemsAsync(int orderId, IEnumerable<int> menuItemIds);
    Task DeleteAsync(int id);
    Task<bool> ExistsAsync(int id);
}
