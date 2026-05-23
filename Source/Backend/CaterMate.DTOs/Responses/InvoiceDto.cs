namespace CaterMate.DTOs.Responses;

public class InvoiceDto
{
    public int Id { get; set; }
    public string InvoiceNumber { get; set; } = "";
    public int OrderId { get; set; }
    public string CustomerName { get; set; } = "";
    public DateTime IssueDate { get; set; }
    public DateTime DueDate { get; set; }
    public List<QuotePositionDto> Positions { get; set; } = [];
    public decimal TotalNet { get; set; }
    public decimal TotalVat { get; set; }
    public decimal TotalGross { get; set; }
}
