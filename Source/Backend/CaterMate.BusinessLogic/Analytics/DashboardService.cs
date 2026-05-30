using CaterMate.Db.Repositories;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Analytics;

public class DashboardService : IDashboardService
{
    private readonly IDashboardRepository _repo;

    public DashboardService(IDashboardRepository repo) => _repo = repo;

    public async Task<DashboardDto> GetAsync()
    {
        var ordersByStatus = await _repo.GetOrdersByStatusAsync();
        var revenueByMonth = await _repo.GetRevenueByMonthAsync();
        var guestsByMonth = await _repo.GetGuestsByMonthAsync();
        var topCustomers = await _repo.GetTopCustomersAsync();
        var kpis = await _repo.GetKpisAsync();

        return new DashboardDto
        {
            OrdersByStatus = ordersByStatus,
            RevenueByMonth = revenueByMonth.Select(r => new RevenueByMonthDto
            {
                Month = r.Month,
                TotalGross = r.TotalGross
            }).ToList(),
            GuestsByMonth = guestsByMonth.Select(g => new GuestsByMonthDto
            {
                Month = g.Month,
                Guests = g.Guests
            }).ToList(),
            TopCustomers = topCustomers.Select(c => new TopCustomerDto
            {
                CustomerName = c.CustomerName,
                OrderCount = c.OrderCount,
                TotalRevenue = c.TotalRevenue
            }).ToList(),
            Kpis = new DashboardKpisDto
            {
                RevenueThisMonth = kpis.RevenueThisMonth,
                RevenueThisYear = kpis.RevenueThisYear,
                AvgOrderValue = kpis.AvgOrderValue,
                OpenQuoteValue = kpis.OpenQuoteValue
            }
        };
    }
}
