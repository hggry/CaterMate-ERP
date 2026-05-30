using CaterMate.BusinessLogic.Orders;
using CaterMate.BusinessLogic.Suggestions;
using CaterMate.DTOs.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CaterMate.API.Controllers;

[ApiController]
[Route("api/orders")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;
    private readonly ISuggestionService _suggestionService;

    public OrdersController(IOrderService orderService, ISuggestionService suggestionService)
    {
        _orderService = orderService;
        _suggestionService = suggestionService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] string? status,
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to)
    {
        var orders = await _orderService.GetAllAsync(status, from, to);
        return Ok(orders);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var order = await _orderService.GetByIdAsync(id);
        return Ok(order);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateOrderRequest request)
    {
        var order = await _orderService.CreateAsync(request);
        return CreatedAtAction(nameof(GetById), new { id = order.Id }, order);
    }

    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateOrderRequest request)
    {
        var order = await _orderService.UpdateAsync(id, request);
        return Ok(order);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _orderService.DeleteAsync(id);
        return NoContent();
    }

    [HttpPost("{id:int}/reopen")]
    public async Task<IActionResult> Reopen(int id)
    {
        var order = await _orderService.ReopenAsync(id);
        return Ok(order);
    }

    [HttpPost("{id:int}/cancel")]
    public async Task<IActionResult> Cancel(int id)
    {
        var order = await _orderService.CancelAsync(id);
        return Ok(order);
    }

    [HttpGet("{id:int}/suggestions")]
    public async Task<IActionResult> GetSuggestions(int id)
    {
        var result = await _suggestionService.GetMenuSuggestionsAsync(id);
        return Ok(result);
    }
}
