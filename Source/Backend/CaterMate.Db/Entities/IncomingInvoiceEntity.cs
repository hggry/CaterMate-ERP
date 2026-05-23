namespace CaterMate.Db.Entities;

public class IncomingInvoiceEntity
{
    public int Id { get; set; }
    public string FilePath { get; set; } = "";
    public string Status { get; set; } = "Pending";
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
}
