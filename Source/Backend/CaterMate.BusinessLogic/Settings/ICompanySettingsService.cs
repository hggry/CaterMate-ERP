using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;
using Microsoft.AspNetCore.Http;

namespace CaterMate.BusinessLogic.Settings;

public interface ICompanySettingsService
{
    Task<CompanySettingsDto> GetAsync();
    Task<CompanySettingsDto> UpdateAsync(UpdateCompanySettingsRequest request);
    Task<CompanySettingsDto> UpdateLogoAsync(IFormFile file);
    Task<byte[]?> GetLogoBytesAsync();
}
