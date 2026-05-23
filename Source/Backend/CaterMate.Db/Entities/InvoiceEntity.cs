namespace CaterMate.Db.Entities;

public class InvoiceEntity
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public string InvoiceNumber { get; set; } = "";
    public string CustomerName { get; set; } = "";
    public DateTime IssueDate { get; set; }
    public DateTime DueDate { get; set; }
    public decimal TotalNet { get; set; }
    public decimal TotalVat { get; set; }
    public decimal TotalGross { get; set; }
    public DateTime CreatedAt { get; set; }
}
