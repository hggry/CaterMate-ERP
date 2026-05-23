using Dapper;

namespace CaterMate.Db.Repositories;

public class DashboardRepository : IDashboardRepository
{
    private readonly DapperContext _context;

    private const string OrdersByStatus = "SELECT Status, COUNT(*) AS Cnt FROM Orders GROUP BY Status";
    private const string RevenueByMonth = @"
        SELECT DATE_FORMAT(CreatedAt, '%Y-%m') AS Month, SUM(TotalGross) AS TotalGross
        FROM Invoices
        GROUP BY Month
        ORDER BY Month DESC
        LIMIT 12";
    private const string TopCustomers = @"
        SELECT c.Name AS CustomerName, COUNT(DISTINCT o.Id) AS OrderCount, COALESCE(SUM(i.TotalGross), 0) AS TotalRevenue
        FROM Customers c
        JOIN Orders o ON o.CustomerId = c.Id
        LEFT JOIN Invoices i ON i.OrderId = o.Id
        GROUP BY c.Id, c.Name
        ORDER BY TotalRevenue DESC
        LIMIT @Top";

    public DashboardRepository(DapperContext context) => _context = context;

    public async Task<Dictionary<string, int>> GetOrdersByStatusAsync()
    {
        using var conn = _context.CreateConnection();
        var rows = await conn.QueryAsync(OrdersByStatus);
        return rows.ToDictionary(r => (string)r.Status, r => (int)r.Cnt);
    }

    public async Task<IEnumerable<(string Month, decimal TotalGross)>> GetRevenueByMonthAsync()
    {
        using var conn = _context.CreateConnection();
        var rows = await conn.QueryAsync(RevenueByMonth);
        return rows.Select(r => ((string)r.Month, (decimal)r.TotalGross));
    }

    public async Task<IEnumerable<(string CustomerName, int OrderCount, decimal TotalRevenue)>> GetTopCustomersAsync(int top = 5)
    {
        using var conn = _context.CreateConnection();
        var rows = await conn.QueryAsync(TopCustomers, new { Top = top });
        return rows.Select(r => ((string)r.CustomerName, (int)r.OrderCount, (decimal)r.TotalRevenue));
    }
}
