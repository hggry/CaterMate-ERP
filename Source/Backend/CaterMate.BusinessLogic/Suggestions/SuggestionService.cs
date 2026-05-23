using CaterMate.Db.Repositories;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Suggestions;

public class SuggestionService : ISuggestionService
{
    private readonly IOrderRepository _orderRepo;
    private readonly IMenuItemRepository _menuItemRepo;

    public SuggestionService(IOrderRepository orderRepo, IMenuItemRepository menuItemRepo)
    {
        _orderRepo = orderRepo;
        _menuItemRepo = menuItemRepo;
    }

    public async Task<DishSuggestionsResponse> GetMenuSuggestionsAsync(int orderId)
    {
        var order = await _orderRepo.GetByIdAsync(orderId)
            ?? throw new KeyNotFoundException($"Order {orderId} not found");

        var assignedIds = (await _orderRepo.GetAssignedMenuItemsAsync(orderId))
            .Select(m => m.Id)
            .ToHashSet();

        var orderAllergens = (order.Allergies ?? "")
            .Split([',', ';', ' '], StringSplitOptions.RemoveEmptyEntries)
            .Select(a => a.Trim().ToLowerInvariant())
            .ToHashSet();

        var allItems = await _menuItemRepo.GetAllAsync(null);

        var suggestions = allItems
            .Where(m => !assignedIds.Contains(m.Id))
            .Where(m => !HasAllergenConflict(m.Allergens, orderAllergens))
            .Where(m => !order.Budget.HasValue || m.SalesPricePerPerson * order.GuestCount <= order.Budget)
            .Take(5)
            .Select(m => new DishSuggestionDto
            {
                MenuItemId = m.Id,
                MenuItemName = m.Name,
                Reason = BuildReason(m.Category, order.EventType)
            })
            .ToList();

        return new DishSuggestionsResponse { Suggestions = suggestions };
    }

    private static bool HasAllergenConflict(string? itemAllergens, HashSet<string> orderAllergens) =>
        orderAllergens.Count > 0 &&
        !string.IsNullOrEmpty(itemAllergens) &&
        orderAllergens.Any(a => itemAllergens.Contains(a, StringComparison.OrdinalIgnoreCase));

    private static string BuildReason(string category, string? eventType)
    {
        var parts = new List<string>();
        if (!string.IsNullOrEmpty(category))
            parts.Add($"Kategorie: {category}");
        if (!string.IsNullOrEmpty(eventType))
            parts.Add($"passend für {eventType}");
        parts.Add("keine bekannten Allergene");
        return string.Join(", ", parts);
    }
}
