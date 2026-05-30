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

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var invoices = await _service.GetAllInvoicesAsync();
        return Ok(invoices);
    }

    [HttpGet("{id:int}/suggestions")]
    public async Task<IActionResult> GetSuggestions(int id)
    {
        var suggestions = await _service.GetSuggestionsAsync(id);
        return Ok(suggestions);
    }

    [HttpGet("suggestions")]
    public async Task<IActionResult> GetAllSuggestions()
    {
        var suggestions = await _service.GetAllSuggestionsAsync();
        return Ok(suggestions);
    }

    [HttpPost("suggestions/{id:int}/accept")]
    public async Task<IActionResult> AcceptSuggestion(int id)
    {
        await _service.AcceptSuggestionAsync(id);
        return NoContent();
    }

    [HttpPost("suggestions/{id:int}/discard")]
    public async Task<IActionResult> DiscardSuggestion(int id)
    {
        await _service.DiscardSuggestionAsync(id);
        return NoContent();
    }

    [HttpPost("{id:int}/confirm")]
    public async Task<IActionResult> Confirm(int id, [FromBody] ConfirmSuggestionsRequest request)
    {
        await _service.ConfirmAsync(id, request);
        return NoContent();
    }
}
