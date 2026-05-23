using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Invoicing;

public interface IInvoiceService
{
    Task<InvoiceDto> CreateAsync(int orderId);
    Task<InvoiceDto> GetByOrderIdAsync(int orderId);
    Task<byte[]> GetPdfBytesAsync(int orderId);
}
