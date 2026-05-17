namespace CaterMate.Db.Entities;

public class OrderMenuItemEntity
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int MenuItemId { get; set; }
}
