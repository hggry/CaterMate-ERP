namespace CaterMate.Db.Entities;

public class QuoteEntity
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public decimal AdminFee { get; set; }
    public decimal ProfitMarginRate { get; set; } = 0.15m;
    public decimal TotalNet { get; set; }
    public decimal TotalVat { get; set; }
    public decimal TotalGross { get; set; }
    public DateTime CreatedAt { get; set; }
}
