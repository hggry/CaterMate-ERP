using CaterMate.API.Filters;
using CaterMate.BusinessLogic.Orders;
using CaterMate.DTOs.Requests;
using Microsoft.AspNetCore.Mvc;

namespace CaterMate.API.Controllers;

[ApiController]
[Route("api/n8n")]
[ServiceFilter(typeof(N8nApiKeyAuthFilter))]
public class N8nController : ControllerBase
{
    private readonly IOrderService _orderService;

    public N8nController(IOrderService orderService) => _orderService = orderService;

    [HttpPost("orders")]
    public async Task<IActionResult> CreateOrder([FromBody] N8nCreateOrderRequest request)
    {
        var order = await _orderService.CreateFromN8nAsync(request);
        return Created($"/api/orders/{order.Id}", order);
    }
}
