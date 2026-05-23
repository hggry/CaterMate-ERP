using CaterMate.BusinessLogic.Analytics;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CaterMate.API.Controllers;

[ApiController]
[Route("api/dashboard")]
[Authorize]
public class DashboardController : ControllerBase
{
    private readonly IDashboardService _dashboardService;

    public DashboardController(IDashboardService dashboardService) => _dashboardService = dashboardService;

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var dto = await _dashboardService.GetAsync();
        return Ok(dto);
    }
}
