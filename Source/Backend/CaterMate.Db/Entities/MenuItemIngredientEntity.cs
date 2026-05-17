namespace CaterMate.Db.Entities;

public class MenuItemIngredientEntity
{
    public int Id { get; set; }
    public int MenuItemId { get; set; }
    public int IngredientId { get; set; }
    public decimal QuantityPerPerson { get; set; }
}
