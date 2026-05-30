namespace CaterMate.Db.Repositories;

public interface IDashboardRepository
{
    Task<Dictionary<string, int>> GetOrdersByStatusAsync();
    Task<IEnumerable<(string Month, decimal TotalGross)>> GetRevenueByMonthAsync();
    Task<IEnumerable<(string Month, int Guests)>> GetGuestsByMonthAsync();
    Task<IEnumerable<(string CustomerName, int OrderCount, decimal TotalRevenue)>> GetTopCustomersAsync(int top = 5);
    Task<(decimal RevenueThisMonth, decimal RevenueThisYear, decimal AvgOrderValue, decimal OpenQuoteValue)> GetKpisAsync();
}
