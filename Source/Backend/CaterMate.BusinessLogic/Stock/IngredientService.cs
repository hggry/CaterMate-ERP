using CaterMate.Db.Entities;
using CaterMate.Db.Repositories;
using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Stock;

public class IngredientService : IIngredientService
{
    private readonly IIngredientRepository _repo;
    private readonly IMenuItemRepository _menuItemRepo;

    public IngredientService(IIngredientRepository repo, IMenuItemRepository menuItemRepo)
    {
        _repo = repo;
        _menuItemRepo = menuItemRepo;
    }

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

    public async Task DeleteAsync(int id)
    {
        _ = await _repo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Ingredient {id} not found");

        if (await _menuItemRepo.IsIngredientInBomAsync(id))
            throw new InvalidOperationException("Zutat wird in einer Stückliste verwendet und kann nicht gelöscht werden.");

        await _repo.DeleteAsync(id);
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
