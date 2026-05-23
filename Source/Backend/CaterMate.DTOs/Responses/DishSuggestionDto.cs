namespace CaterMate.DTOs.Responses;

public class DishSuggestionDto
{
    public int MenuItemId { get; set; }
    public string MenuItemName { get; set; } = "";
    public string Reason { get; set; } = "";
}
