namespace CaterMate.DTOs.Responses;

public class PurchaseListDto
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public decimal SafetyMargin { get; set; }
    public List<PurchaseGroupDto> Groups { get; set; } = [];
}
