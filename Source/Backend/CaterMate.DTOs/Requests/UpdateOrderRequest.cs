namespace CaterMate.DTOs.Requests;

public class UpdateOrderRequest
{
    public string? Status { get; set; }
    // Simple ID-only update (no per-item counts).
    public int[]? AssignedMenuItemIds { get; set; }
    // Full update with per-item portion counts; takes priority over AssignedMenuItemIds.
    public MenuItemWithCountRequest[]? AssignedMenuItemsWithCounts { get; set; }
    public string? CustomerName { get; set; }
    public string? CustomerPhone { get; set; }
    public DateTime? EventDate { get; set; }
    public int? GuestCount { get; set; }
    public string? EventType { get; set; }
    public string? Location { get; set; }
    public decimal? Budget { get; set; }
    public string? SpecialWishes { get; set; }
    public string? Allergies { get; set; }
    public string? DishWishes { get; set; }
}
