using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Quotes;

public interface IQuoteService
{
    Task<QuoteDto> GenerateAsync(int orderId);
    Task<QuoteDto> GetByOrderIdAsync(int orderId);
    Task<QuoteDto> UpdateAsync(int orderId, QuoteDto dto);
    Task<byte[]> GetPdfBytesAsync(int orderId);
}
