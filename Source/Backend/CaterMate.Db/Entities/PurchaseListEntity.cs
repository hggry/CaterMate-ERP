namespace CaterMate.Db.Entities;

public class PurchaseListEntity
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public decimal SafetyMargin { get; set; } = 0.10m;
    public DateTime CreatedAt { get; set; }
}
