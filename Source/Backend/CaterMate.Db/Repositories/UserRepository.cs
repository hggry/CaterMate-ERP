using Dapper;
using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public class UserRepository : IUserRepository
{
    private readonly DapperContext _context;

    private const string SelectByUsername = "SELECT * FROM Users WHERE Username = @Username";
    private const string SelectCount = "SELECT COUNT(*) FROM Users";
    private const string Insert = "INSERT INTO Users (Username, PasswordHash) VALUES (@Username, @PasswordHash)";

    public UserRepository(DapperContext context) => _context = context;

    public async Task<UserEntity?> GetByUsernameAsync(string username)
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<UserEntity>(SelectByUsername, new { Username = username });
    }

    public async Task<bool> AnyExistsAsync()
    {
        using var conn = _context.CreateConnection();
        var count = await conn.ExecuteScalarAsync<int>(SelectCount);
        return count > 0;
    }

    public async Task CreateAsync(string username, string passwordHash)
    {
        using var conn = _context.CreateConnection();
        await conn.ExecuteAsync(Insert, new { Username = username, PasswordHash = passwordHash });
    }
}
