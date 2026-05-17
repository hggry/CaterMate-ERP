using Dapper;
using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public class OrderRepository : IOrderRepository
{
    private readonly DapperContext _context;

    private const string SelectAll = @"
        SELECT o.* FROM Orders o
        WHERE (@Status IS NULL OR o.Status = @Status)
          AND (@From IS NULL OR o.EventDate >= @From)
          AND (@To IS NULL OR o.EventDate <= @To)
        ORDER BY o.CreatedAt DESC";

    private const string SelectById = "SELECT * FROM Orders WHERE Id = @Id";

    private const string SelectAssignedMenuItems = @"
        SELECT m.* FROM MenuItems m
        INNER JOIN OrderMenuItems omi ON omi.MenuItemId = m.Id
        WHERE omi.OrderId = @OrderId";

    private const string Insert = @"
        INSERT INTO Orders (CustomerId, EventDate, EventType, Location, GuestCount, Budget, SpecialWishes, Allergies, Status)
        VALUES (@CustomerId, @EventDate, @EventType, @Location, @GuestCount, @Budget, @SpecialWishes, @Allergies, @Status);
        SELECT LAST_INSERT_ID();";

    private const string Update = @"
        UPDATE Orders SET
            EventDate = @EventDate, EventType = @EventType, Location = @Location,
            GuestCount = @GuestCount, Budget = @Budget, SpecialWishes = @SpecialWishes,
            Allergies = @Allergies
        WHERE Id = @Id";

    private const string UpdateStatus = "UPDATE Orders SET Status = @Status WHERE Id = @Id";

    private const string DeleteMenuItems = "DELETE FROM OrderMenuItems WHERE OrderId = @OrderId";
    private const string InsertMenuItem = "INSERT INTO OrderMenuItems (OrderId, MenuItemId) VALUES (@OrderId, @MenuItemId)";

    private const string Delete = "DELETE FROM Orders WHERE Id = @Id";
    private const string Exists = "SELECT COUNT(*) FROM Orders WHERE Id = @Id";

    public OrderRepository(DapperContext context) => _context = context;

    public async Task<IEnumerable<OrderEntity>> GetAllAsync(string? status, DateTime? from, DateTime? to)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryAsync<OrderEntity>(SelectAll, new { Status = status, From = from, To = to });
    }

    public async Task<OrderEntity?> GetByIdAsync(int id)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<OrderEntity>(SelectById, new { Id = id });
    }

    public async Task<IEnumerable<MenuItemEntity>> GetAssignedMenuItemsAsync(int orderId)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryAsync<MenuItemEntity>(SelectAssignedMenuItems, new { OrderId = orderId });
    }

    public async Task<int> CreateAsync(OrderEntity order)
    {
        using var conn = _context.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(Insert, order);
    }

    public async Task UpdateAsync(OrderEntity order)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(Update, order);
    }

    public async Task UpdateStatusAsync(int id, string status)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(UpdateStatus, new { Id = id, Status = status });
    }

    public async Task SetMenuItemsAsync(int orderId, IEnumerable<int> menuItemIds)
    {
        using var conn = _context.CreateConnection();
        await conn.OpenAsync();
        using var tx = await conn.BeginTransactionAsync();
        await conn.ExecuteAsync(DeleteMenuItems, new { OrderId = orderId }, tx);
        foreach (var menuItemId in menuItemIds)
            await conn.ExecuteAsync(InsertMenuItem, new { OrderId = orderId, MenuItemId = menuItemId }, tx);
        await tx.CommitAsync();
    }

    public async Task DeleteAsync(int id)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(Delete, new { Id = id });
    }

    public async Task<bool> ExistsAsync(int id)
    {
        using var conn = _context.CreateConnection();
        var count = await conn.ExecuteScalarAsync<int>(Exists, new { Id = id });
        return count > 0;
    }
}
