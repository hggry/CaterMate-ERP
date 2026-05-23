using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Analytics;

public interface IDashboardService
{
    Task<DashboardDto> GetAsync();
}
