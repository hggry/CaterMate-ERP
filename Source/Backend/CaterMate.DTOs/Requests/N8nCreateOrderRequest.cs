using System.ComponentModel.DataAnnotations;

namespace CaterMate.DTOs.Requests;

public class N8nCreateOrderRequest
{
    [Required] public N8nCustomerDto Customer { get; set; } = null!;
    public List<N8nOrderMenuItemDto> OrderMenuItems { get; set; } = [];
    [Required, Range(1, 5000)] public int GuestCount { get; set; }
    public decimal? Budget { get; set; }
    public string? DishWishes { get; set; }
    public string? SpecialWishes { get; set; }
    public string? Allergies { get; set; }
    [Required] public DateTime Date { get; set; }
    public TimeSpan? Time { get; set; }
    public string? EventType { get; set; }
    public string? Location { get; set; }
}

public class N8nCustomerDto
{
    [Required] public string Name { get; set; } = string.Empty;
    public string? Tel { get; set; }
    public long? TelegramChatId { get; set; }
}

public class N8nOrderMenuItemDto
{
    [Required] public int MenuItemId { get; set; }
    public string? Name { get; set; }
    public string? Category { get; set; }
    public int? Count { get; set; }
    public decimal? PricePerPerson { get; set; }
    public decimal? TotalPrice { get; set; }
}
