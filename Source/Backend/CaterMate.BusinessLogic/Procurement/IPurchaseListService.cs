using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Procurement;

public interface IPurchaseListService
{
    Task CreateForOrderAsync(int orderId);
    Task<PurchaseListDto> GetByOrderIdAsync(int orderId);
    Task UpdateItemAsync(int itemId, bool isDone);
    Task<byte[]> GetPdfBytesAsync(int orderId);
}
