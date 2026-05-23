using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;

namespace CaterMate.IntegrationTests;

public class TestFactory : WebApplicationFactory<Program>
{
    public const string TestConnectionString =
        "Server=localhost;Port=3306;Database=catermate_test;User ID=catermate_user;Password=catermate_dev_password;CharSet=utf8mb4;";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Test");
        builder.ConfigureAppConfiguration((_, config) =>
        {
            config.AddJsonFile("appsettings.Test.json", optional: false);
            config.AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["ConnectionStrings:DefaultConnection"] = TestConnectionString,
                ["JWT_SECRET"] = "catermate_test_jwt_secret_min32chars_fixed",
                ["JWT_ISSUER"] = "catermate",
                ["SEED_ADMIN_USERNAME"] = "test_admin",
                ["SEED_ADMIN_PASSWORD"] = "test_admin_password",
                ["VERWALTUNGSPAUSCHALE"] = "200",
                ["N8N_WEBHOOK_INCOMING_URL"] = "",
                ["N8N_API_KEY"] = "test_n8n_key",
            });
        });
    }
}
