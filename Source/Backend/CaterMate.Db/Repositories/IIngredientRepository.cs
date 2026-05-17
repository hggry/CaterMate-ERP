using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public interface IIngredientRepository
{
    Task<IEnumerable<IngredientEntity>> GetAllAsync();
    Task<IngredientEntity?> GetByIdAsync(int id);
    Task<int> CreateAsync(IngredientEntity ingredient);
    Task UpdateAsync(IngredientEntity ingredient);
}
