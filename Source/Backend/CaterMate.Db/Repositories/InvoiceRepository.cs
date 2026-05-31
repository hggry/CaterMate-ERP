using Dapper;
using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public class InvoiceRepository : IInvoiceRepository
{
    private readonly DapperContext _context;

    private const string SelectByOrderId = "SELECT * FROM Invoices WHERE OrderId = @OrderId LIMIT 1";
    private const string SelectPositions = @"
        SELECT ip.*, mi.Category AS MenuItemCategory
        FROM InvoicePositions ip
        LEFT JOIN MenuItems mi ON mi.Id = ip.MenuItemId
        WHERE ip.InvoiceId = @InvoiceId";
    private const string MaxSeq = "SELECT MAX(CAST(SUBSTRING(InvoiceNumber, 9) AS UNSIGNED)) FROM Invoices WHERE InvoiceNumber LIKE @Pattern";
    private const string InsertInvoice = @"
        INSERT INTO Invoices (OrderId, InvoiceNumber, CustomerName, IssueDate, DueDate, TotalNet, TotalVat, TotalGross)
        VALUES (@OrderId, @InvoiceNumber, @CustomerName, @IssueDate, @DueDate, @TotalNet, @TotalVat, @TotalGross);
        SELECT LAST_INSERT_ID();";
    private const string InsertPosition = @"
        INSERT INTO InvoicePositions (InvoiceId, MenuItemId, MenuItemName, Quantity, UnitPrice, TotalNet, VatRate, VatAmount, TotalGross)
        VALUES (@InvoiceId, @MenuItemId, @MenuItemName, @Quantity, @UnitPrice, @TotalNet, @VatRate, @VatAmount, @TotalGross)";

    public InvoiceRepository(DapperContext context) => _context = context;

    public async Task<InvoiceEntity?> GetByOrderIdAsync(int orderId)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<InvoiceEntity>(SelectByOrderId, new { OrderId = orderId });
    }

    public async Task<IEnumerable<InvoicePositionEntity>> GetPositionsAsync(int invoiceId)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryAsync<InvoicePositionEntity>(SelectPositions, new { InvoiceId = invoiceId });
    }

    public async Task<string> GetNextInvoiceNumberAsync(int year)
    {
        using var conn = _context.CreateConnection();
        var pattern = $"CM-{year}-%";
        var maxSeq = await conn.ExecuteScalarAsync<int?>(MaxSeq, new { Pattern = pattern }) ?? 0;
        return $"CM-{year}-{(maxSeq + 1):D4}";
    }

    public async Task<int> CreateAsync(InvoiceEntity invoice, IEnumerable<InvoicePositionEntity> positions)
    {
        using var conn = _context.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        var invoiceId = await conn.ExecuteScalarAsync<int>(InsertInvoice, invoice, tx);
        foreach (var p in positions)
        {
            p.InvoiceId = invoiceId;
            await conn.ExecuteAsync(InsertPosition, p, tx);
        }
        tx.Commit();
        return invoiceId;
    }
}
