using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public interface IUserRepository
{
    Task<UserEntity?> GetByUsernameAsync(string username);
    Task<bool> AnyExistsAsync();
    Task CreateAsync(string username, string passwordHash);
}
