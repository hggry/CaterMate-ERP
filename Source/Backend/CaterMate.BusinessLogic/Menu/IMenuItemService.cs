using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Menu;

public interface IMenuItemService
{
    Task<IEnumerable<MenuItemDto>> GetAllAsync(string? category);
    Task<MenuItemDto> GetByIdAsync(int id);
    Task<MenuItemDto> CreateAsync(CreateMenuItemRequest request);
    Task<MenuItemDto> UpdateAsync(int id, UpdateMenuItemRequest request);
    Task DeleteAsync(int id);
}
