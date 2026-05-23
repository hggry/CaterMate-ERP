using Dapper;
using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public class IncomingInvoiceRepository : IIncomingInvoiceRepository
{
    private readonly DapperContext _context;

    private const string Insert = @"
        INSERT INTO IncomingInvoices (FilePath, Status) VALUES (@FilePath, @Status);
        SELECT LAST_INSERT_ID();";
    private const string SelectById = "SELECT * FROM IncomingInvoices WHERE Id = @Id LIMIT 1";
    private const string SelectSuggestions = "SELECT * FROM IncomingInvoiceSuggestions WHERE IncomingInvoiceId = @InvoiceId";
    private const string InsertSuggestion = @"
        INSERT INTO IncomingInvoiceSuggestions (IncomingInvoiceId, IngredientId, IngredientName, CurrentPrice, SuggestedPrice)
        VALUES (@IncomingInvoiceId, @IngredientId, @IngredientName, @CurrentPrice, @SuggestedPrice)";
    private const string UpdateStatus = "UPDATE IncomingInvoices SET Status = @Status, ProcessedAt = NOW() WHERE Id = @Id";
    private const string UpdateDecision = "UPDATE IncomingInvoiceSuggestions SET Accepted = @Accepted WHERE Id = @Id";
    private const string UpdateIngredientPrice = "UPDATE Ingredients SET PurchasePricePerUnit = @Price WHERE Id = @Id";

    public IncomingInvoiceRepository(DapperContext context) => _context = context;

    public async Task<int> CreateAsync(IncomingInvoiceEntity entity)
    {
        using var conn = _context.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(Insert, entity);
    }

    public async Task<IncomingInvoiceEntity?> GetByIdAsync(int id)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<IncomingInvoiceEntity>(SelectById, new { Id = id });
    }

    public async Task<IEnumerable<IncomingInvoiceSuggestionEntity>> GetSuggestionsByInvoiceIdAsync(int invoiceId)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryAsync<IncomingInvoiceSuggestionEntity>(SelectSuggestions, new { InvoiceId = invoiceId });
    }

    public async Task SaveSuggestionsAsync(int invoiceId, IEnumerable<IncomingInvoiceSuggestionEntity> suggestions)
    {
        using var conn = _context.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        foreach (var s in suggestions)
        {
            s.IncomingInvoiceId = invoiceId;
            await conn.ExecuteAsync(InsertSuggestion, s, tx);
        }
        await conn.ExecuteAsync(UpdateStatus, new { Status = "Ready", Id = invoiceId }, tx);
        tx.Commit();
    }

    public async Task UpdateSuggestionDecisionAsync(int suggestionId, bool accepted)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(UpdateDecision, new { Id = suggestionId, Accepted = accepted });
    }

    public async Task UpdateIngredientPriceAsync(int ingredientId, decimal newPrice)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(UpdateIngredientPrice, new { Id = ingredientId, Price = newPrice });
    }
}
