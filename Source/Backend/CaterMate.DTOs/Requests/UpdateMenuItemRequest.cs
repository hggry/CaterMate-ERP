using System.ComponentModel.DataAnnotations;

namespace CaterMate.DTOs.Requests;

public class UpdateMenuItemRequest
{
    [Required] public string Name { get; set; } = "";
    [Required] public string Category { get; set; } = "";
    [Range(0.01, double.MaxValue)] public decimal SalesPricePerPerson { get; set; }
    [Range(0, double.MaxValue)] public decimal PurchaseCostPerPerson { get; set; }
    public string? Allergens { get; set; }
    public BillOfMaterialsItemRequest[]? BillOfMaterials { get; set; }
}
