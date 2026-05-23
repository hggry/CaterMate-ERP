using System.Net.Http.Json;
using MySqlConnector;

namespace CaterMate.IntegrationTests;

public static class Helpers
{
    public static async Task<string> GetTokenAsync(HttpClient client)
    {
        var response = await client.PostAsJsonAsync("/api/auth/login", new
        {
            Username = "test_admin",
            Password = "test_admin_password"
        });
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<TokenResponse>();
        return result!.Token;
    }

    public static HttpClient CreateAuthenticatedClient(TestFactory factory, string token)
    {
        var client = factory.CreateClient();
        client.DefaultRequestHeaders.Authorization =
            new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
        return client;
    }

    public static async Task<int> CreateIngredientAsync(HttpClient client, string name = "Test-Zutat")
    {
        var response = await client.PostAsJsonAsync("/api/ingredients", new
        {
            Name = name,
            Unit = "kg",
            PurchasePricePerUnit = 5.00m,
            Category = "Test"
        });
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<IdResponse>();
        return result!.Id;
    }

    public static async Task<int> CreateMenuItemAsync(HttpClient client, string name = "Test-Gericht",
        string category = "Hauptgang", decimal salesPrice = 20.00m, string? allergens = null)
    {
        var response = await client.PostAsJsonAsync("/api/menu-items", new
        {
            Name = name,
            Category = category,
            SalesPricePerPerson = salesPrice,
            PurchaseCostPerPerson = 8.00m,
            Allergens = allergens,
            BillOfMaterials = Array.Empty<object>()
        });
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<IdResponse>();
        return result!.Id;
    }

    public static async Task<int> CreateOrderAsync(HttpClient client, int guestCount = 10,
        decimal? budget = null, string? allergies = null, int[]? menuItemIds = null)
    {
        var response = await client.PostAsJsonAsync("/api/orders", new
        {
            CustomerName = "Test Kunde",
            CustomerPhone = "+43123456789",
            EventDate = DateTime.UtcNow.AddDays(30),
            EventType = "Business",
            Location = "Wien",
            GuestCount = guestCount,
            Budget = budget,
            Allergies = allergies
        });
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<IdResponse>();
        var orderId = result!.Id;

        if (menuItemIds?.Length > 0)
        {
            await client.PatchAsJsonAsync($"/api/orders/{orderId}", new
            {
                AssignedMenuItemIds = menuItemIds
            });
        }

        return orderId;
    }

    public static async Task CleanupAsync(string tablesToDelete)
    {
        await using var conn = new MySqlConnection(TestFactory.TestConnectionString);
        await conn.OpenAsync();
        // Delete in correct FK order
        var tables = new[]
        {
            "IncomingInvoiceSuggestions", "IncomingInvoices",
            "InvoicePositions", "Invoices",
            "PurchaseListItems", "PurchaseLists",
            "QuotePositions", "Quotes",
            "OrderMenuItems", "Orders",
            "MenuItemIngredients", "MenuItems",
            "Ingredients",
            "Customers",
            "Users"
        };
        await using var tx = await conn.BeginTransactionAsync();
        await using (var cmd = conn.CreateCommand())
        {
            cmd.Transaction = tx;
            cmd.CommandText = "SET FOREIGN_KEY_CHECKS = 0";
            await cmd.ExecuteNonQueryAsync();
        }
        foreach (var table in tables)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = $"DELETE FROM `{table}`";
            await cmd.ExecuteNonQueryAsync();
        }
        await using (var cmd = conn.CreateCommand())
        {
            cmd.Transaction = tx;
            cmd.CommandText = "SET FOREIGN_KEY_CHECKS = 1";
            await cmd.ExecuteNonQueryAsync();
        }
        await tx.CommitAsync();
    }

    private record TokenResponse(string Token);
    private record IdResponse(int Id);
}
