using System.Net;
using System.Net.Http.Json;

namespace CaterMate.IntegrationTests.Tests;

[TestFixture]
public class PurchaseListFlowTests
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
    public async Task ConfirmOrder_AutoCreatesPurchaseList_AndSetsStatusInBeschaffung()
    {
        var ingredientId = await Helpers.CreateIngredientAsync(_client, "Testmehl");
        var menuItemId = await Helpers.CreateMenuItemAsync(_client, "Testgericht", "Hauptgang", 15.00m);

        // Assign ingredient to menu item BOM
        await _client.PutAsJsonAsync($"/api/menu-items/{menuItemId}", new
        {
            Name = "Testgericht",
            Category = "Hauptgang",
            SalesPricePerPerson = 15.00m,
            PurchaseCostPerPerson = 6.00m,
            BillOfMaterials = new[] { new { IngredientId = ingredientId, QuantityPerPerson = 0.2m } }
        });

        var orderId = await Helpers.CreateOrderAsync(_client, guestCount: 10, menuItemIds: [menuItemId]);

        // Advance status to AngebotErstellt first
        await _client.PostAsync($"/api/orders/{orderId}/quote", null);
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "Geprüft" });
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "AngebotErstellt" });

        // PATCH Bestätigt — triggers auto-create PurchaseList + transition to InBeschaffung
        var response = await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "Bestätigt" });
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var order = await response.Content.ReadFromJsonAsync<OrderResponse>();
        Assert.That(order!.status, Is.EqualTo("InBeschaffung"));

        var listResponse = await _client.GetAsync($"/api/orders/{orderId}/purchase-list");
        Assert.That(listResponse.StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var list = await listResponse.Content.ReadFromJsonAsync<PurchaseListResponse>();
        Assert.That(list, Is.Not.Null);
        Assert.That(list!.groups, Is.Not.Empty);
    }

    [Test]
    public async Task PurchaseListItem_ToggleIsDone()
    {
        var ingredientId = await Helpers.CreateIngredientAsync(_client, "Testöl");
        var menuItemId = await Helpers.CreateMenuItemAsync(_client, "Ölspeise", "Hauptgang", 12.00m);
        await _client.PutAsJsonAsync($"/api/menu-items/{menuItemId}", new
        {
            Name = "Ölspeise", Category = "Hauptgang",
            SalesPricePerPerson = 12.00m, PurchaseCostPerPerson = 4.00m,
            BillOfMaterials = new[] { new { IngredientId = ingredientId, QuantityPerPerson = 0.1m } }
        });
        var orderId = await Helpers.CreateOrderAsync(_client, guestCount: 5, menuItemIds: [menuItemId]);
        await _client.PostAsync($"/api/orders/{orderId}/quote", null);
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "Geprüft" });
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "AngebotErstellt" });
        await _client.PatchAsJsonAsync($"/api/orders/{orderId}", new { status = "Bestätigt" });

        var listResponse = await _client.GetAsync($"/api/orders/{orderId}/purchase-list");
        var list = await listResponse.Content.ReadFromJsonAsync<PurchaseListResponse>();
        var itemId = list!.groups[0].items[0].id;

        var patchResponse = await _client.PatchAsJsonAsync($"/api/purchase-list-items/{itemId}", new { isDone = true });
        Assert.That(patchResponse.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));

        var updatedList = await _client.GetAsync($"/api/orders/{orderId}/purchase-list");
        var updated = await updatedList.Content.ReadFromJsonAsync<PurchaseListResponse>();
        Assert.That(updated!.groups[0].items[0].isDone, Is.True);
    }

    private record OrderResponse(string status);
    private record PurchaseListResponse(int id, int orderId, decimal safetyMargin, List<PurchaseGroupResponse> groups);
    private record PurchaseGroupResponse(string category, List<PurchaseListItemResponse> items);
    private record PurchaseListItemResponse(int id, int ingredientId, string ingredientName, decimal requiredQuantity, string unit, bool isDone);
}
