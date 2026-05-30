using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;
using Microsoft.AspNetCore.Http;

namespace CaterMate.BusinessLogic.IncomingInvoices;

public interface IIncomingInvoiceService
{
    Task<IncomingInvoiceDto> UploadAsync(IFormFile file);
    Task<IEnumerable<IncomingInvoiceDto>> GetAllInvoicesAsync();
    Task<IEnumerable<PriceSuggestionDto>> GetSuggestionsAsync(int id);
    Task<IEnumerable<PriceSuggestionDto>> GetAllSuggestionsAsync();
    Task ConfirmAsync(int id, ConfirmSuggestionsRequest request);
    Task AcceptSuggestionAsync(int suggestionId);
    Task DiscardSuggestionAsync(int suggestionId);
    Task SaveFromN8nAsync(int id, N8nSaveSuggestionsRequest request);
}
