using CaterMate.BusinessLogic.Settings;
using CaterMate.DTOs.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CaterMate.API.Controllers;

[ApiController]
[Route("api/company-settings")]
[Authorize]
public class CompanySettingsController : ControllerBase
{
    private readonly ICompanySettingsService _service;

    public CompanySettingsController(ICompanySettingsService service) => _service = service;

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var dto = await _service.GetAsync();
        return Ok(dto);
    }

    [HttpPut]
    public async Task<IActionResult> Update([FromBody] UpdateCompanySettingsRequest request)
    {
        var dto = await _service.UpdateAsync(request);
        return Ok(dto);
    }

    [HttpPost("logo")]
    public async Task<IActionResult> UploadLogo(IFormFile file)
    {
        var dto = await _service.UpdateLogoAsync(file);
        return Ok(dto);
    }

    [HttpGet("logo")]
    public async Task<IActionResult> GetLogo()
    {
        var bytes = await _service.GetLogoBytesAsync();
        if (bytes is null) return NotFound();
        return File(bytes, "image/png");
    }
}
