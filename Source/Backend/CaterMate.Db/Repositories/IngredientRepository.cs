using Dapper;
using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public class IngredientRepository : IIngredientRepository
{
    private readonly DapperContext _context;

    private const string SelectAll = "SELECT * FROM Ingredients ORDER BY Category, Name";
    private const string SelectById = "SELECT * FROM Ingredients WHERE Id = @Id";
    private const string Insert = @"
        INSERT INTO Ingredients (Name, Unit, PurchasePricePerUnit, Category)
        VALUES (@Name, @Unit, @PurchasePricePerUnit, @Category);
        SELECT LAST_INSERT_ID();";
    private const string Update = @"
        UPDATE Ingredients SET
            Name = @Name, Unit = @Unit,
            PurchasePricePerUnit = @PurchasePricePerUnit, Category = @Category
        WHERE Id = @Id";
    private const string Delete = "DELETE FROM Ingredients WHERE Id = @Id";

    public IngredientRepository(DapperContext context) => _context = context;

    public async Task<IEnumerable<IngredientEntity>> GetAllAsync()
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryAsync<IngredientEntity>(SelectAll);
    }

    public async Task<IngredientEntity?> GetByIdAsync(int id)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<IngredientEntity>(SelectById, new { Id = id });
    }

    public async Task<int> CreateAsync(IngredientEntity ingredient)
    {
        using var conn = _context.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(Insert, ingredient);
    }

    public async Task UpdateAsync(IngredientEntity ingredient)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(Update, ingredient);
    }

    public async Task DeleteAsync(int id)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(Delete, new { Id = id });
    }
}
