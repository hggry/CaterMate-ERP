using Dapper;
using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public class CompanySettingsRepository : ICompanySettingsRepository
{
    private readonly DapperContext _context;

    private const string Select = "SELECT * FROM CompanySettings WHERE Id = 1 LIMIT 1";

    private const string Upsert = @"
        INSERT INTO CompanySettings
            (Id, CompanyName, Street, PostalCode, City, Country, Phone, Email, Website,
             VatId, TaxNumber, Iban, Bic, BankName, CommercialRegNo, CommercialCourt, AccentColor)
        VALUES
            (1, @CompanyName, @Street, @PostalCode, @City, @Country, @Phone, @Email, @Website,
             @VatId, @TaxNumber, @Iban, @Bic, @BankName, @CommercialRegNo, @CommercialCourt, @AccentColor)
        ON DUPLICATE KEY UPDATE
            CompanyName     = VALUES(CompanyName),
            Street          = VALUES(Street),
            PostalCode      = VALUES(PostalCode),
            City            = VALUES(City),
            Country         = VALUES(Country),
            Phone           = VALUES(Phone),
            Email           = VALUES(Email),
            Website         = VALUES(Website),
            VatId           = VALUES(VatId),
            TaxNumber       = VALUES(TaxNumber),
            Iban            = VALUES(Iban),
            Bic             = VALUES(Bic),
            BankName        = VALUES(BankName),
            CommercialRegNo = VALUES(CommercialRegNo),
            CommercialCourt = VALUES(CommercialCourt),
            AccentColor     = VALUES(AccentColor)";

    private const string UpdateLogo = "UPDATE CompanySettings SET LogoPath = @Path WHERE Id = 1";

    public CompanySettingsRepository(DapperContext context) => _context = context;

    public async Task<CompanySettingsEntity?> GetAsync()
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<CompanySettingsEntity>(Select);
    }

    public async Task UpsertAsync(CompanySettingsEntity entity)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(Upsert, entity);
    }

    public async Task UpdateLogoPathAsync(string? path)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(UpdateLogo, new { Path = path });
    }
}
