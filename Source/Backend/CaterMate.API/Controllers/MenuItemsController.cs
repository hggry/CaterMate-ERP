using CaterMate.BusinessLogic.Menu;
using CaterMate.DTOs.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CaterMate.API.Controllers;

[ApiController]
[Route("api/menu-items")]
[Authorize]
public class MenuItemsController : ControllerBase
{
    private readonly IMenuItemService _menuItemService;

    public MenuItemsController(IMenuItemService menuItemService) => _menuItemService = menuItemService;

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? category)
    {
        var items = await _menuItemService.GetAllAsync(category);
        return Ok(items);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var item = await _menuItemService.GetByIdAsync(id);
        return Ok(item);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateMenuItemRequest request)
    {
        var item = await _menuItemService.CreateAsync(request);
        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateMenuItemRequest request)
    {
        var item = await _menuItemService.UpdateAsync(id, request);
        return Ok(item);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _menuItemService.DeleteAsync(id);
        return NoContent();
    }
}
