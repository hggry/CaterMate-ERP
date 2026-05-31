using CaterMate.Db.Entities;
using CaterMate.Db.Repositories;
using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;
using Microsoft.AspNetCore.Http;

namespace CaterMate.BusinessLogic.Settings;

public class CompanySettingsService : ICompanySettingsService
{
    private readonly ICompanySettingsRepository _repo;
    private const string UploadDir = "/app/uploads";
    private static readonly string[] AllowedExtensions = [".png", ".jpg", ".jpeg", ".webp"];

    public CompanySettingsService(ICompanySettingsRepository repo) => _repo = repo;

    public async Task<CompanySettingsDto> GetAsync()
    {
        var entity = await _repo.GetAsync();
        return entity is null ? new CompanySettingsDto() : MapToDto(entity);
    }

    public async Task<CompanySettingsDto> UpdateAsync(UpdateCompanySettingsRequest request)
    {
        var existing = await _repo.GetAsync();
        var entity = new CompanySettingsEntity
        {
            CompanyName     = request.CompanyName,
            Street          = request.Street?.Trim(),
            PostalCode      = request.PostalCode?.Trim(),
            City            = request.City?.Trim(),
            Country         = request.Country?.Trim(),
            Phone           = request.Phone?.Trim(),
            Email           = request.Email?.Trim(),
            Website         = request.Website?.Trim(),
            VatId           = request.VatId?.Trim(),
            TaxNumber       = request.TaxNumber?.Trim(),
            Iban            = request.Iban?.Trim(),
            Bic             = request.Bic?.Trim(),
            BankName        = request.BankName?.Trim(),
            CommercialRegNo = request.CommercialRegNo?.Trim(),
            CommercialCourt = request.CommercialCourt?.Trim(),
            AccentColor     = request.AccentColor?.Trim(),
            // Preserve existing logo path.
            LogoPath        = existing?.LogoPath,
        };
        await _repo.UpsertAsync(entity);
        return await GetAsync();
    }

    public async Task<CompanySettingsDto> UpdateLogoAsync(IFormFile file)
    {
        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!AllowedExtensions.Contains(ext))
            throw new InvalidOperationException($"Ungültiges Dateiformat. Erlaubt: {string.Join(", ", AllowedExtensions)}");

        if (file.Length > 2 * 1024 * 1024)
            throw new InvalidOperationException("Logo darf maximal 2 MB groß sein.");

        Directory.CreateDirectory(UploadDir);

        // Delete old logo if it exists.
        var existing = await _repo.GetAsync();
        if (existing?.LogoPath != null && File.Exists(existing.LogoPath))
            File.Delete(existing.LogoPath);

        var fileName = $"logo_{DateTimeOffset.UtcNow.ToUnixTimeSeconds()}{ext}";
        var filePath = Path.Combine(UploadDir, fileName);

        await using (var stream = File.Create(filePath))
            await file.CopyToAsync(stream);

        await _repo.UpdateLogoPathAsync(filePath);
        return await GetAsync();
    }

    public async Task<byte[]?> GetLogoBytesAsync()
    {
        var entity = await _repo.GetAsync();
        if (entity?.LogoPath is null || !File.Exists(entity.LogoPath))
            return null;
        return await File.ReadAllBytesAsync(entity.LogoPath);
    }

    private static CompanySettingsDto MapToDto(CompanySettingsEntity e) => new()
    {
        CompanyName     = e.CompanyName,
        Street          = e.Street,
        PostalCode      = e.PostalCode,
        City            = e.City,
        Country         = e.Country,
        Phone           = e.Phone,
        Email           = e.Email,
        Website         = e.Website,
        VatId           = e.VatId,
        TaxNumber       = e.TaxNumber,
        Iban            = e.Iban,
        Bic             = e.Bic,
        BankName        = e.BankName,
        CommercialRegNo = e.CommercialRegNo,
        CommercialCourt = e.CommercialCourt,
        AccentColor     = e.AccentColor,
        HasLogo         = e.LogoPath != null && File.Exists(e.LogoPath),
    };
}
