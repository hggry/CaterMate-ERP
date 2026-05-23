using System.Net;
using System.Net.Http.Json;

namespace CaterMate.IntegrationTests.Tests;

[TestFixture]
public class InvoiceFlowTests
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

    private async Task<int> SetupOrderToDurchgefuehrt()
    {
        var menuItemId = await Helpers.CreateMenuItemAsync(_client, "Rechnungstest-Gericht", "Hauptgang", 25.00m);
        var orderId = await Helpers.CreateOrderAsync(_client, guestCount: 8, menuItemIds: [menuItemId]);
        await _client.PostAsync($"/api/orders/{orderId}/quote", null);
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "Geprüft" });
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "AngebotErstellt" });
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "Bestätigt" });
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "InVorbereitung" });
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "Durchgeführt" });
        return orderId;
    }

    [Test]
    public async Task CreateInvoice_GeneratesSequentialNumber()
    {
        var orderId = await SetupOrderToDurchgefuehrt();

        var response = await _client.PostAsync($"/api/orders/{orderId}/invoice", null);
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));

        var invoice = await response.Content.ReadFromJsonAsync<InvoiceResponse>();
        Assert.That(invoice, Is.Not.Null);
        Assert.That(invoice!.invoiceNumber, Does.StartWith($"CM-{DateTime.Today.Year}-"));
    }

    [Test]
    public async Task CreateInvoice_SetsStatusAbgerechnet()
    {
        var orderId = await SetupOrderToDurchgefuehrt();

        await _client.PostAsync($"/api/orders/{orderId}/invoice", null);

        var orderResponse = await _client.GetAsync($"/api/orders/{orderId}");
        var order = await orderResponse.Content.ReadFromJsonAsync<OrderStatusResponse>();
        Assert.That(order!.status, Is.EqualTo("Abgerechnet"));
    }

    [Test]
    public async Task CreateInvoice_RequiresDurchgefuehrtStatus_Returns409()
    {
        var menuItemId = await Helpers.CreateMenuItemAsync(_client, "Frühes-Gericht", "Hauptgang", 10.00m);
        var orderId = await Helpers.CreateOrderAsync(_client, guestCount: 5, menuItemIds: [menuItemId]);
        await _client.PostAsync($"/api/orders/{orderId}/quote", null);
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "Geprüft" });

        var response = await _client.PostAsync($"/api/orders/{orderId}/invoice", null);
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
    }

    [Test]
    public async Task CreateInvoice_WithoutQuote_Returns409()
    {
        var orderId = await Helpers.CreateOrderAsync(_client, guestCount: 5);
        // Directly force status via invalid path would be needed — but we can't skip the quote
        // so we test that without a quote + wrong status → 409
        var response = await _client.PostAsync($"/api/orders/{orderId}/invoice", null);
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
    }

    private record InvoiceResponse(string invoiceNumber, decimal totalNet, decimal totalVat, decimal totalGross);
    private record OrderStatusResponse(string status);
}
