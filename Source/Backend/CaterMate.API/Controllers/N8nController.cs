using CaterMate.API.Filters;
using CaterMate.BusinessLogic.IncomingInvoices;
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
    private readonly IIncomingInvoiceService _incomingInvoiceService;

    public N8nController(IOrderService orderService, IIncomingInvoiceService incomingInvoiceService)
    {
        _orderService = orderService;
        _incomingInvoiceService = incomingInvoiceService;
    }

    [HttpPost("orders")]
    public async Task<IActionResult> CreateOrder([FromBody] N8nCreateOrderRequest request)
    {
        var order = await _orderService.CreateFromN8nAsync(request);
        return Created($"/api/orders/{order.Id}", order);
    }

    [HttpPost("incoming-invoices/{id:int}/suggestions")]
    public async Task<IActionResult> SaveIncomingInvoiceSuggestions(int id, [FromBody] N8nSaveSuggestionsRequest request)
    {
        await _incomingInvoiceService.SaveFromN8nAsync(id, request);
        return NoContent();
    }
}
