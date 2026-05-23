namespace CaterMate.DTOs.Responses;

public class TopCustomerDto
{
    public string CustomerName { get; set; } = "";
    public int OrderCount { get; set; }
    public decimal TotalRevenue { get; set; }
}
