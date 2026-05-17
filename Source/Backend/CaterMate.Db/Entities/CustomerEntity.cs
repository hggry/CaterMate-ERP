namespace CaterMate.Db.Entities;

public class CustomerEntity
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string? Phone { get; set; }
    public DateTime CreatedAt { get; set; }
}
