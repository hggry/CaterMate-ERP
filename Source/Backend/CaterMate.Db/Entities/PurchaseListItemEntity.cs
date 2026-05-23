namespace CaterMate.Db.Entities;

public class PurchaseListItemEntity
{
    public int Id { get; set; }
    public int PurchaseListId { get; set; }
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = "";
    public decimal RequiredQuantity { get; set; }
    public string Unit { get; set; } = "";
    public string? Category { get; set; }
    public bool IsDone { get; set; }
}
