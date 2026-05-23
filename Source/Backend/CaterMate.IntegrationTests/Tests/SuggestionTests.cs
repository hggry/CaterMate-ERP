using System.Net;
using System.Net.Http.Json;

namespace CaterMate.IntegrationTests.Tests;

[TestFixture]
public class SuggestionTests
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
    public async Task GetSuggestions_FiltersAllergens()
    {
        // Create a menu item with a known allergen
        await Helpers.CreateMenuItemAsync(_client, "Nuss-Gericht", "Hauptgang", 20.00m, allergens: "Nüsse");
        // Create a safe item
        await Helpers.CreateMenuItemAsync(_client, "Sicheres-Gericht", "Hauptgang", 15.00m, allergens: null);

        var orderId = await Helpers.CreateOrderAsync(_client, guestCount: 10, allergies: "Nüsse");

        var response = await _client.GetAsync($"/api/orders/{orderId}/suggestions");
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var result = await response.Content.ReadFromJsonAsync<SuggestionsResponse>();
        Assert.That(result, Is.Not.Null);

        var suggestedNames = result!.suggestions.Select(s => s.menuItemName).ToList();
        Assert.That(suggestedNames, Does.Not.Contain("Nuss-Gericht"));
        Assert.That(suggestedNames, Does.Contain("Sicheres-Gericht"));
    }

    [Test]
    public async Task GetSuggestions_RespectsBudget()
    {
        // Expensive item: 50 × 10 persons = 500 (over budget of 300)
        await Helpers.CreateMenuItemAsync(_client, "Teures-Gericht", "Hauptgang", 50.00m);
        // Affordable item: 20 × 10 = 200 (under budget of 300)
        await Helpers.CreateMenuItemAsync(_client, "Günstiges-Gericht", "Hauptgang", 20.00m);

        var orderId = await Helpers.CreateOrderAsync(_client, guestCount: 10, budget: 300m);

        var response = await _client.GetAsync($"/api/orders/{orderId}/suggestions");
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var result = await response.Content.ReadFromJsonAsync<SuggestionsResponse>();
        var suggestedNames = result!.suggestions.Select(s => s.menuItemName).ToList();

        Assert.That(suggestedNames, Does.Not.Contain("Teures-Gericht"));
        Assert.That(suggestedNames, Does.Contain("Günstiges-Gericht"));
    }

    private record SuggestionsResponse(List<DishSuggestionItem> suggestions);
    private record DishSuggestionItem(int menuItemId, string menuItemName, string reason);
}
