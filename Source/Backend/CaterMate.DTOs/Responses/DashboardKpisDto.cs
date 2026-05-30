namespace CaterMate.DTOs.Responses;

public class DashboardKpisDto
{
    public decimal RevenueThisMonth { get; set; }
    public decimal RevenueThisYear { get; set; }
    public decimal AvgOrderValue { get; set; }
    public decimal OpenQuoteValue { get; set; }
}
