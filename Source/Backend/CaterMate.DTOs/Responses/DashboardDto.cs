namespace CaterMate.DTOs.Responses;

public class DashboardDto
{
    public Dictionary<string, int> OrdersByStatus { get; set; } = [];
    public List<RevenueByMonthDto> RevenueByMonth { get; set; } = [];
    public List<GuestsByMonthDto> GuestsByMonth { get; set; } = [];
    public List<TopCustomerDto> TopCustomers { get; set; } = [];
    public DashboardKpisDto Kpis { get; set; } = new();
}
