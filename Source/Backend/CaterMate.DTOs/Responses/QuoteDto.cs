namespace CaterMate.DTOs.Responses;

public class QuoteDto
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public List<QuotePositionDto> Positions { get; set; } = [];
    public decimal AdminFee { get; set; }
    public decimal ProfitMargin { get; set; }
    public decimal TotalNet { get; set; }
    public decimal TotalVat { get; set; }
    public decimal TotalGross { get; set; }
    public DateTime CreatedAt { get; set; }
}
