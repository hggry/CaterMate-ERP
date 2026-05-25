using Dapper;
using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public class CustomerRepository : ICustomerRepository
{
    private readonly DapperContext _context;

    private const string SelectByPhone = "SELECT * FROM Customers WHERE Phone = @Phone LIMIT 1";
    private const string SelectById = "SELECT * FROM Customers WHERE Id = @Id";
    private const string Insert = "INSERT INTO Customers (Name, Phone) VALUES (@Name, @Phone); SELECT LAST_INSERT_ID();";
    private const string Update = "UPDATE Customers SET Name = @Name, Phone = @Phone WHERE Id = @Id";

    public CustomerRepository(DapperContext context) => _context = context;

    public async Task<int> UpsertByPhoneAsync(string name, string? phone)
    {
        using var conn = _context.CreateConnection();

        if (!string.IsNullOrWhiteSpace(phone))
        {
            var existing = await conn.QueryFirstOrDefaultAsync<CustomerEntity>(SelectByPhone, new { Phone = phone });
            if (existing != null)
                return existing.Id;
        }

        return await conn.ExecuteScalarAsync<int>(Insert, new { Name = name, Phone = phone });
    }

    public async Task<CustomerEntity?> GetByIdAsync(int id)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<CustomerEntity>(SelectById, new { Id = id });
    }

    public async Task UpdateAsync(int id, string name, string? phone)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(Update, new { Id = id, Name = name, Phone = phone });
    }
}
