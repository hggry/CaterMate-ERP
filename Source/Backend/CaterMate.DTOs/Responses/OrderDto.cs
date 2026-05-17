namespace CaterMate.DTOs.Responses;

public class OrderDto
{
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public string CustomerName { get; set; } = "";
    public string? CustomerPhone { get; set; }
    public DateTime EventDate { get; set; }
    public string? EventType { get; set; }
    public string Location { get; set; } = "";
    public int GuestCount { get; set; }
    public decimal? Budget { get; set; }
    public string? SpecialWishes { get; set; }
    public string? Allergies { get; set; }
    public string Status { get; set; } = "";
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public List<AssignedMenuItemDto> AssignedMenuItems { get; set; } = new();
}

public class AssignedMenuItemDto
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string Category { get; set; } = "";
    public decimal SalesPricePerPerson { get; set; }
}
