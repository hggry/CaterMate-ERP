namespace CaterMate.DTOs.Responses;

public class QuotePositionDto
{
    public int MenuItemId { get; set; }
    public string MenuItemName { get; set; } = "";
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalNet { get; set; }
    public decimal VatRate { get; set; }
    public decimal VatAmount { get; set; }
    public decimal TotalGross { get; set; }
}
