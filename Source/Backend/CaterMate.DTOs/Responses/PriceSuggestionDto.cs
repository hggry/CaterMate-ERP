namespace CaterMate.DTOs.Responses;

public class PriceSuggestionDto
{
    public int Id { get; set; }
    public int IncomingInvoiceId { get; set; }
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = "";
    public decimal CurrentPrice { get; set; }
    public decimal SuggestedPrice { get; set; }
    public bool? Accepted { get; set; }
}
