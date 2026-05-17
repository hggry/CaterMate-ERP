namespace CaterMate.Db.Entities;

public class MenuItemEntity
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string Category { get; set; } = "";
    public decimal SalesPricePerPerson { get; set; }
    public decimal PurchaseCostPerPerson { get; set; }
    public string? Allergens { get; set; }
    public DateTime CreatedAt { get; set; }
}
