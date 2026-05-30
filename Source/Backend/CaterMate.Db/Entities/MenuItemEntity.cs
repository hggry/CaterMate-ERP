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

    // Per-order portion count from the OrderMenuItems join table; null for manually
    // assigned items without an explicit count (callers fall back to GuestCount).
    public int? AssignedCount { get; set; }
}
