using MySqlConnector;

namespace CaterMate.Db;

public class DapperContext
{
    private readonly string _connectionString;

    public DapperContext(string connectionString)
    {
        _connectionString = connectionString;
    }

    public MySqlConnection CreateConnection() => new MySqlConnection(_connectionString);
}
