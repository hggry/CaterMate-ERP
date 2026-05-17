using System.ComponentModel.DataAnnotations;

namespace CaterMate.DTOs.Requests;

public class UpdateIngredientRequest
{
    [Required] public string Name { get; set; } = "";
    [Required] public string Unit { get; set; } = "";
    [Range(0, double.MaxValue)] public decimal PurchasePricePerUnit { get; set; }
    public string? Category { get; set; }
}
