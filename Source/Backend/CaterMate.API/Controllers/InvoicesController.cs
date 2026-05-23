using CaterMate.BusinessLogic.Invoicing;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CaterMate.API.Controllers;

[ApiController]
[Route("api/orders/{orderId:int}/invoice")]
[Authorize]
public class InvoicesController : ControllerBase
{
    private readonly IInvoiceService _invoiceService;

    public InvoicesController(IInvoiceService invoiceService) => _invoiceService = invoiceService;

    [HttpPost]
    public async Task<IActionResult> Create(int orderId)
    {
        var dto = await _invoiceService.CreateAsync(orderId);
        return CreatedAtAction(nameof(Get), new { orderId }, dto);
    }

    [HttpGet]
    public async Task<IActionResult> Get(int orderId)
    {
        var dto = await _invoiceService.GetByOrderIdAsync(orderId);
        return Ok(dto);
    }

    [HttpGet("pdf")]
    public async Task<IActionResult> GetPdf(int orderId)
    {
        var invoice = await _invoiceService.GetByOrderIdAsync(orderId);
        var bytes = await _invoiceService.GetPdfBytesAsync(orderId);
        return File(bytes, "application/pdf", $"Rechnung_{invoice.InvoiceNumber}.pdf");
    }
}
