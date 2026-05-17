namespace CaterMate.DTOs.Responses;

public class MenuItemDto
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string Category { get; set; } = "";
    public decimal SalesPricePerPerson { get; set; }
    public decimal PurchaseCostPerPerson { get; set; }
    public string? Allergens { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<BillOfMaterialsItemDto> BillOfMaterials { get; set; } = new();
}

public class BillOfMaterialsItemDto
{
    public int IngredientId { get; set; }
    public decimal QuantityPerPerson { get; set; }
}
