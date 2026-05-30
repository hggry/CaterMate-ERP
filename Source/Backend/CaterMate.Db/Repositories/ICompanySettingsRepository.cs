using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public interface ICompanySettingsRepository
{
    Task<CompanySettingsEntity?> GetAsync();
    Task UpsertAsync(CompanySettingsEntity entity);
    Task UpdateLogoPathAsync(string? path);
}
