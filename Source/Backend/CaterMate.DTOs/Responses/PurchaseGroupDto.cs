namespace CaterMate.DTOs.Responses;

public class PurchaseGroupDto
{
    public string Category { get; set; } = "";
    public List<PurchaseListItemDto> Items { get; set; } = [];
}
