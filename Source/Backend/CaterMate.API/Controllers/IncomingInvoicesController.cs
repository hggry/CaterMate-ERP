using CaterMate.BusinessLogic.IncomingInvoices;
using CaterMate.DTOs.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CaterMate.API.Controllers;

[ApiController]
[Route("api/incoming-invoices")]
[Authorize]
public class IncomingInvoicesController : ControllerBase
{
    private readonly IIncomingInvoiceService _service;

    public IncomingInvoicesController(IIncomingInvoiceService service) => _service = service;

    [HttpPost]
    public async Task<IActionResult> Upload(IFormFile file)
    {
        var dto = await _service.UploadAsync(file);
        return CreatedAtAction(nameof(GetSuggestions), new { id = dto.Id }, dto);
    }

    [HttpGet("{id:int}/suggestions")]
    public async Task<IActionResult> GetSuggestions(int id)
    {
        var suggestions = await _service.GetSuggestionsAsync(id);
        return Ok(suggestions);
    }

    [HttpPost("{id:int}/confirm")]
    public async Task<IActionResult> Confirm(int id, [FromBody] ConfirmSuggestionsRequest request)
    {
        await _service.ConfirmAsync(id, request);
        return NoContent();
    }
}
