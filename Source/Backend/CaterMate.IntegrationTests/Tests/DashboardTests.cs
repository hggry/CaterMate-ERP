using System.Net;
using System.Net.Http.Json;

namespace CaterMate.IntegrationTests.Tests;

[TestFixture]
public class DashboardTests
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
    public async Task Dashboard_ReturnsOrdersByStatus()
    {
        await Helpers.CreateOrderAsync(_client, guestCount: 5);
        await Helpers.CreateOrderAsync(_client, guestCount: 3);

        var response = await _client.GetAsync("/api/dashboard");
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var dashboard = await response.Content.ReadFromJsonAsync<DashboardResponse>();
        Assert.That(dashboard, Is.Not.Null);
        Assert.That(dashboard!.ordersByStatus, Contains.Key("Neu"));
        Assert.That(dashboard.ordersByStatus["Neu"], Is.GreaterThanOrEqualTo(2));
    }

    private record DashboardResponse(
        Dictionary<string, int> ordersByStatus,
        List<object> revenueByMonth,
        List<object> topCustomers);
}
