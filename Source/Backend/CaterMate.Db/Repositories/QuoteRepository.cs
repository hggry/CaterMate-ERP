using Dapper;
using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public class QuoteRepository : IQuoteRepository
{
    private readonly DapperContext _context;

    private const string SelectByOrderId = "SELECT * FROM Quotes WHERE OrderId = @OrderId LIMIT 1";
    private const string SelectPositions = "SELECT * FROM QuotePositions WHERE QuoteId = @QuoteId";
    private const string ExistsByOrderId = "SELECT COUNT(*) FROM Quotes WHERE OrderId = @OrderId";
    private const string InsertQuote = @"
        INSERT INTO Quotes (OrderId, AdminFee, ProfitMarginRate, TotalNet, TotalVat, TotalGross)
        VALUES (@OrderId, @AdminFee, @ProfitMarginRate, @TotalNet, @TotalVat, @TotalGross);
        SELECT LAST_INSERT_ID();";
    private const string InsertPosition = @"
        INSERT INTO QuotePositions (QuoteId, MenuItemId, MenuItemName, Quantity, UnitPrice, TotalNet, VatRate, VatAmount, TotalGross)
        VALUES (@QuoteId, @MenuItemId, @MenuItemName, @Quantity, @UnitPrice, @TotalNet, @VatRate, @VatAmount, @TotalGross)";
    private const string UpdateQuote = @"
        UPDATE Quotes SET AdminFee=@AdminFee, ProfitMarginRate=@ProfitMarginRate,
            TotalNet=@TotalNet, TotalVat=@TotalVat, TotalGross=@TotalGross
        WHERE Id=@Id";
    private const string DeletePositions = "DELETE FROM QuotePositions WHERE QuoteId = @QuoteId";
    private const string DeletePositionsByOrder =
        "DELETE qp FROM QuotePositions qp JOIN Quotes q ON q.Id = qp.QuoteId WHERE q.OrderId = @OrderId";
    private const string DeleteQuoteByOrder = "DELETE FROM Quotes WHERE OrderId = @OrderId";

    public QuoteRepository(DapperContext context) => _context = context;

    public async Task<QuoteEntity?> GetByOrderIdAsync(int orderId)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<QuoteEntity>(SelectByOrderId, new { OrderId = orderId });
    }

    public async Task<IEnumerable<QuotePositionEntity>> GetPositionsAsync(int quoteId)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryAsync<QuotePositionEntity>(SelectPositions, new { QuoteId = quoteId });
    }

    public async Task<bool> ExistsByOrderIdAsync(int orderId)
    {
        using var conn = _context.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(ExistsByOrderId, new { OrderId = orderId }) > 0;
    }

    public async Task<int> CreateAsync(QuoteEntity quote, IEnumerable<QuotePositionEntity> positions)
    {
        using var conn = _context.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        var quoteId = await conn.ExecuteScalarAsync<int>(InsertQuote, quote, tx);
        foreach (var p in positions)
        {
            p.QuoteId = quoteId;
            await conn.ExecuteAsync(InsertPosition, p, tx);
        }
        tx.Commit();
        return quoteId;
    }

    public async Task UpdateAsync(QuoteEntity quote, IEnumerable<QuotePositionEntity> positions)
    {
        using var conn = _context.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        await conn.ExecuteAsync(UpdateQuote, quote, tx);
        await conn.ExecuteAsync(DeletePositions, new { QuoteId = quote.Id }, tx);
        foreach (var p in positions)
        {
            p.QuoteId = quote.Id;
            await conn.ExecuteAsync(InsertPosition, p, tx);
        }
        tx.Commit();
    }

    public async Task DeleteByOrderIdAsync(int orderId)
    {
        using var conn = _context.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        await conn.ExecuteAsync(DeletePositionsByOrder, new { OrderId = orderId }, tx);
        await conn.ExecuteAsync(DeleteQuoteByOrder, new { OrderId = orderId }, tx);
        tx.Commit();
    }
}
