using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Stock;

public interface IIngredientService
{
    Task<IEnumerable<IngredientDto>> GetAllAsync();
    Task<IngredientDto> GetByIdAsync(int id);
    Task<IngredientDto> CreateAsync(CreateIngredientRequest request);
    Task<IngredientDto> UpdateAsync(int id, UpdateIngredientRequest request);
    Task DeleteAsync(int id);
}
