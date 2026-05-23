using CaterMate.BusinessLogic.Procurement;
using CaterMate.DTOs.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CaterMate.API.Controllers;

[ApiController]
[Authorize]
public class PurchaseListsController : ControllerBase
{
    private readonly IPurchaseListService _purchaseListService;

    public PurchaseListsController(IPurchaseListService purchaseListService) =>
        _purchaseListService = purchaseListService;

    [HttpGet("api/orders/{orderId:int}/purchase-list")]
    public async Task<IActionResult> GetByOrderId(int orderId)
    {
        var dto = await _purchaseListService.GetByOrderIdAsync(orderId);
        return Ok(dto);
    }

    [HttpGet("api/orders/{orderId:int}/purchase-list/pdf")]
    public async Task<IActionResult> GetPdf(int orderId)
    {
        var bytes = await _purchaseListService.GetPdfBytesAsync(orderId);
        return File(bytes, "application/pdf", $"Einkaufsliste_{orderId}.pdf");
    }

    [HttpPatch("api/purchase-list-items/{itemId:int}")]
    public async Task<IActionResult> UpdateItem(int itemId, [FromBody] UpdatePurchaseListItemRequest request)
    {
        await _purchaseListService.UpdateItemAsync(itemId, request.IsDone);
        return NoContent();
    }
}
