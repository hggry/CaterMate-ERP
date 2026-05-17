using CaterMate.BusinessLogic.Stock;
using CaterMate.DTOs.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CaterMate.API.Controllers;

[ApiController]
[Route("api/ingredients")]
[Authorize]
public class IngredientsController : ControllerBase
{
    private readonly IIngredientService _ingredientService;

    public IngredientsController(IIngredientService ingredientService) => _ingredientService = ingredientService;

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var items = await _ingredientService.GetAllAsync();
        return Ok(items);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var item = await _ingredientService.GetByIdAsync(id);
        return Ok(item);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateIngredientRequest request)
    {
        var item = await _ingredientService.CreateAsync(request);
        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateIngredientRequest request)
    {
        var item = await _ingredientService.UpdateAsync(id, request);
        return Ok(item);
    }
}
