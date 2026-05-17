using System.ComponentModel.DataAnnotations;

namespace CaterMate.DTOs.Requests;

public class CreateOrderRequest
{
    [Required] public string CustomerName { get; set; } = "";
    public string? CustomerPhone { get; set; }
    [Required] public DateTime EventDate { get; set; }
    public string? EventType { get; set; }
    [Required] public string Location { get; set; } = "";
    [Range(1, 5000)] public int GuestCount { get; set; }
    public decimal? Budget { get; set; }
    public string? SpecialWishes { get; set; }
    public string? Allergies { get; set; }
}
