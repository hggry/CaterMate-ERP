using System.ComponentModel.DataAnnotations;

namespace CaterMate.DTOs.Requests;

public class CreateMenuItemRequest
{
    [Required] public string Name { get; set; } = "";
    [Required] public string Category { get; set; } = "";
    [Range(0.01, double.MaxValue)] public decimal SalesPricePerPerson { get; set; }
    [Range(0, double.MaxValue)] public decimal PurchaseCostPerPerson { get; set; }
    public string? Allergens { get; set; }
    public BillOfMaterialsItemRequest[]? BillOfMaterials { get; set; }
}

public class BillOfMaterialsItemRequest
{
    [Range(1, int.MaxValue)] public int IngredientId { get; set; }
    [Range(0.001, double.MaxValue)] public decimal QuantityPerPerson { get; set; }
}
