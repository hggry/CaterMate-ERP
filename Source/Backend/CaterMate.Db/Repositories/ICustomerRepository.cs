using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public interface ICustomerRepository
{
    Task<int> UpsertByPhoneAsync(string name, string? phone);
    Task<CustomerEntity?> GetByIdAsync(int id);
}
