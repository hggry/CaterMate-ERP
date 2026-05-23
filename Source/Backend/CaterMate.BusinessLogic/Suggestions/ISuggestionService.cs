using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Suggestions;

public interface ISuggestionService
{
    Task<DishSuggestionsResponse> GetMenuSuggestionsAsync(int orderId);
}
