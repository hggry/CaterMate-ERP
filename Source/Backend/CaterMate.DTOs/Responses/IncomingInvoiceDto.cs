namespace CaterMate.DTOs.Responses;

public class IncomingInvoiceDto
{
    public int Id { get; set; }
    public string Status { get; set; } = "";
    public string? FileName { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
}
