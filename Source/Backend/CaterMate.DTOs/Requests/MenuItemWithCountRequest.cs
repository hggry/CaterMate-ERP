namespace CaterMate.DTOs.Requests;

public class MenuItemWithCountRequest
{
    public int MenuItemId { get; set; }
    // Explicit portion count; null means "full guest count".
    public int? Count { get; set; }
}
