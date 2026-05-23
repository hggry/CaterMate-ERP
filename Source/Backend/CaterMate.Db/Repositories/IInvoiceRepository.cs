using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public interface IInvoiceRepository
{
    Task<InvoiceEntity?> GetByOrderIdAsync(int orderId);
    Task<IEnumerable<InvoicePositionEntity>> GetPositionsAsync(int invoiceId);
    Task<int> CreateAsync(InvoiceEntity invoice, IEnumerable<InvoicePositionEntity> positions);
    Task<string> GetNextInvoiceNumberAsync(int year);
}
