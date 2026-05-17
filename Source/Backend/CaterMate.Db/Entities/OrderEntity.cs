namespace CaterMate.Db.Entities;

public class OrderEntity
{
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public DateTime EventDate { get; set; }
    public string? EventType { get; set; }
    public string Location { get; set; } = "";
    public int GuestCount { get; set; }
    public decimal? Budget { get; set; }
    public string? SpecialWishes { get; set; }
    public string? Allergies { get; set; }
    public string Status { get; set; } = "Neu";
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
