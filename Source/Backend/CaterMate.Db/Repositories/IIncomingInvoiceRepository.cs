using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public interface IIncomingInvoiceRepository
{
    Task<int> CreateAsync(IncomingInvoiceEntity entity);
    Task<IncomingInvoiceEntity?> GetByIdAsync(int id);
    Task<IEnumerable<IncomingInvoiceEntity>> GetAllInvoicesAsync();
    Task<IEnumerable<IncomingInvoiceSuggestionEntity>> GetSuggestionsByInvoiceIdAsync(int invoiceId);
    Task<IEnumerable<IncomingInvoiceSuggestionEntity>> GetAllSuggestionsAsync();
    Task<IncomingInvoiceSuggestionEntity?> GetSuggestionByIdAsync(int suggestionId);
    Task SaveSuggestionsAsync(int invoiceId, IEnumerable<IncomingInvoiceSuggestionEntity> suggestions);
    Task UpdateSuggestionDecisionAsync(int suggestionId, bool accepted);
    Task DeleteSuggestionAsync(int suggestionId);
    Task UpdateIngredientPriceAsync(int ingredientId, decimal newPrice);
}
