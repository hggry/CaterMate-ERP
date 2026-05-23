namespace CaterMate.DTOs.Responses;

public class PurchaseListItemDto
{
    public int Id { get; set; }
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = "";
    public decimal RequiredQuantity { get; set; }
    public string Unit { get; set; } = "";
    public bool IsDone { get; set; }
}
