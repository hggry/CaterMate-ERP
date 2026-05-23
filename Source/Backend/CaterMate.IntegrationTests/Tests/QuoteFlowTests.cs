using System.Net;
using System.Net.Http.Json;

namespace CaterMate.IntegrationTests.Tests;

[TestFixture]
public class QuoteFlowTests
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
    public async Task GenerateQuote_ReturnsCorrectTotalsAndVat()
    {
        var menuItemId = await Helpers.CreateMenuItemAsync(_client, "Schnitzel", "Hauptgang", 20.00m);
        var orderId = await Helpers.CreateOrderAsync(_client, guestCount: 10, menuItemIds: [menuItemId]);

        var response = await _client.PostAsync($"/api/orders/{orderId}/quote", null);
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));

        var quote = await response.Content.ReadFromJsonAsync<QuoteResponse>();
        Assert.That(quote, Is.Not.Null);
        Assert.That(quote!.positions, Has.Count.EqualTo(1));

        // 10 persons × 20 = 200 net + 200 adminFee = 400 totalNet
        Assert.That(quote.totalNet, Is.EqualTo(400m));
        // VAT: 200 × 10% = 20
        Assert.That(quote.totalVat, Is.EqualTo(20m));
        Assert.That(quote.totalGross, Is.EqualTo(420m));
    }

    [Test]
    public async Task GenerateQuote_AlcoholicDrink_Has20PctVat()
    {
        var menuItemId = await Helpers.CreateMenuItemAsync(_client, "Bier", "Getränk (alkoholisch)", 5.00m);
        var orderId = await Helpers.CreateOrderAsync(_client, guestCount: 10, menuItemIds: [menuItemId]);

        var response = await _client.PostAsync($"/api/orders/{orderId}/quote", null);
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));

        var quote = await response.Content.ReadFromJsonAsync<QuoteResponse>();
        Assert.That(quote, Is.Not.Null);

        // 10 × 5 = 50 net, VAT = 50 × 20% = 10
        Assert.That(quote!.positions[0].vatRate, Is.EqualTo(0.20m));
        Assert.That(quote.totalVat, Is.EqualTo(10m));
    }

    [Test]
    public async Task UpdateQuote_PersistsChanges()
    {
        var menuItemId = await Helpers.CreateMenuItemAsync(_client, "Pasta", "Hauptgang", 15.00m);
        var orderId = await Helpers.CreateOrderAsync(_client, guestCount: 5, menuItemIds: [menuItemId]);

        await _client.PostAsync($"/api/orders/{orderId}/quote", null);
        var getResponse = await _client.GetAsync($"/api/orders/{orderId}/quote");
        var quote = await getResponse.Content.ReadFromJsonAsync<QuoteResponse>();
        Assert.That(quote, Is.Not.Null);

        // Update quantity via PUT — we send the same positions with changed quantity
        var updatedPositions = quote!.positions.Select(p => new { p.menuItemId, p.menuItemName, quantity = 8, p.unitPrice, p.vatRate }).ToList();
        var putResponse = await _client.PutAsJsonAsync($"/api/orders/{orderId}/quote", new
        {
            id = quote.id,
            orderId,
            positions = updatedPositions,
            adminFee = quote.adminFee,
            profitMargin = quote.profitMargin,
            totalNet = quote.totalNet,
            totalVat = quote.totalVat,
            totalGross = quote.totalGross,
            createdAt = quote.createdAt
        });
        Assert.That(putResponse.StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var updated = await putResponse.Content.ReadFromJsonAsync<QuoteResponse>();
        Assert.That(updated!.positions[0].quantity, Is.EqualTo(8));
    }

    private record QuoteResponse(
        int id, int orderId, List<QuotePositionResponse> positions,
        decimal adminFee, decimal profitMargin, decimal totalNet, decimal totalVat,
        decimal totalGross, DateTime createdAt);

    private record QuotePositionResponse(
        int menuItemId, string menuItemName, int quantity,
        decimal unitPrice, decimal totalNet, decimal vatRate, decimal vatAmount, decimal totalGross);
}
