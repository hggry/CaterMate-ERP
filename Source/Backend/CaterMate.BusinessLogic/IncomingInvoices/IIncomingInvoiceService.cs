using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;
using Microsoft.AspNetCore.Http;

namespace CaterMate.BusinessLogic.IncomingInvoices;

public interface IIncomingInvoiceService
{
    Task<IncomingInvoiceDto> UploadAsync(IFormFile file);
    Task<IEnumerable<PriceSuggestionDto>> GetSuggestionsAsync(int id);
    Task ConfirmAsync(int id, ConfirmSuggestionsRequest request);
    Task SaveFromN8nAsync(int id, N8nSaveSuggestionsRequest request);
}
