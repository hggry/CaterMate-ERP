using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Orders;

public interface IOrderService
{
    Task<IEnumerable<OrderDto>> GetAllAsync(string? status, DateTime? from, DateTime? to);
    Task<OrderDto> GetByIdAsync(int id);
    Task<OrderDto> CreateAsync(CreateOrderRequest request);
    Task<OrderDto> CreateFromN8nAsync(N8nCreateOrderRequest request);
    Task<OrderDto> UpdateAsync(int id, UpdateOrderRequest request);
    Task<OrderDto> ReopenAsync(int id);
    Task<OrderDto> CancelAsync(int id);
    Task DeleteAsync(int id);
}
