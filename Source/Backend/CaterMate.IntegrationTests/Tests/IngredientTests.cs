using System.Net;
using System.Net.Http.Json;

namespace CaterMate.IntegrationTests.Tests;

[TestFixture]
public class IngredientTests
{
    private TestFactory _factory = null!;
    private HttpClient _client = null!;

    [OneTimeSetUp]
    public async Task OneTimeSetUp()
    {
        _factory = new TestFactory();
        var token = await Helpers.GetTokenAsync(_factory.CreateClient());
        _client = Helpers.CreateAuthenticatedClient(_factory, token);
    }

    [TearDown]
    public async Task TearDown() => await Helpers.CleanupAsync("all");

    [OneTimeTearDown]
    public void OneTimeTearDown()
    {
        _client.Dispose();
        _factory.Dispose();
    }

    [Test]
    public async Task DeleteIngredient_NotInBOM_Returns204()
    {
        var ingredientId = await Helpers.CreateIngredientAsync(_client, "Löschbare-Zutat");

        var response = await _client.DeleteAsync($"/api/ingredients/{ingredientId}");
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
    }

    [Test]
    public async Task DeleteIngredient_InBOM_Returns409()
    {
        var ingredientId = await Helpers.CreateIngredientAsync(_client, "BOM-Zutat");
        var menuItemId = await Helpers.CreateMenuItemAsync(_client, "BOM-Gericht", "Hauptgang", 10.00m);

        await _client.PutAsJsonAsync($"/api/menu-items/{menuItemId}", new
        {
            Name = "BOM-Gericht",
            Category = "Hauptgang",
            SalesPricePerPerson = 10.00m,
            PurchaseCostPerPerson = 4.00m,
            BillOfMaterials = new[] { new { IngredientId = ingredientId, QuantityPerPerson = 0.1m } }
        });

        var response = await _client.DeleteAsync($"/api/ingredients/{ingredientId}");
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
    }
}
