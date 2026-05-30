using CaterMate.BusinessLogic.Quotes;
using CaterMate.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CaterMate.API.Controllers;

[ApiController]
[Route("api/orders/{orderId:int}/quote")]
[Authorize]
public class QuotesController : ControllerBase
{
    private readonly IQuoteService _quoteService;

    public QuotesController(IQuoteService quoteService) => _quoteService = quoteService;

    [HttpPost]
    public async Task<IActionResult> Generate(int orderId)
    {
        var dto = await _quoteService.GenerateAsync(orderId);
        return CreatedAtAction(nameof(Get), new { orderId }, dto);
    }

    [HttpGet]
    public async Task<IActionResult> Get(int orderId)
    {
        var dto = await _quoteService.GetByOrderIdAsync(orderId);
        return Ok(dto);
    }

    [HttpPut]
    public async Task<IActionResult> Update(int orderId, [FromBody] QuoteDto dto)
    {
        var result = await _quoteService.UpdateAsync(orderId, dto);
        return Ok(result);
    }

    [HttpGet("pdf")]
    public async Task<IActionResult> GetPdf(int orderId)
    {
        var bytes = await _quoteService.GetPdfBytesAsync(orderId);
        return File(bytes, "application/pdf", $"Angebot_{orderId}.pdf");
    }

    [HttpPost("send")]
    public async Task<IActionResult> SendToCustomer(int orderId)
    {
        await _quoteService.SendToCustomerAsync(orderId);
        return NoContent();
    }
}
