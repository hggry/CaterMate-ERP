using CaterMate.Db.Entities;
using CaterMate.Db.Repositories;
using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Stock;

public class IngredientService : IIngredientService
{
    private readonly IIngredientRepository _repo;

    public IngredientService(IIngredientRepository repo) => _repo = repo;

    public async Task<IEnumerable<IngredientDto>> GetAllAsync()
    {
        var items = await _repo.GetAllAsync();
        return items.Select(MapToDto);
    }

    public async Task<IngredientDto> GetByIdAsync(int id)
    {
        var item = await _repo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Ingredient {id} not found");
        return MapToDto(item);
    }

    public async Task<IngredientDto> CreateAsync(CreateIngredientRequest request)
    {
        var entity = new IngredientEntity
        {
            Name = request.Name,
            Unit = request.Unit,
            PurchasePricePerUnit = request.PurchasePricePerUnit,
            Category = request.Category
        };
        var id = await _repo.CreateAsync(entity);
        return await GetByIdAsync(id);
    }

    public async Task<IngredientDto> UpdateAsync(int id, UpdateIngredientRequest request)
    {
        var existing = await _repo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Ingredient {id} not found");

        existing.Name = request.Name;
        existing.Unit = request.Unit;
        existing.PurchasePricePerUnit = request.PurchasePricePerUnit;
        existing.Category = request.Category;

        await _repo.UpdateAsync(existing);
        return await GetByIdAsync(id);
    }

    private static IngredientDto MapToDto(IngredientEntity e) =>
        new()
        {
            Id = e.Id,
            Name = e.Name,
            Unit = e.Unit,
            PurchasePricePerUnit = e.PurchasePricePerUnit,
            Category = e.Category,
            CreatedAt = e.CreatedAt,
            UpdatedAt = e.UpdatedAt
        };
}
