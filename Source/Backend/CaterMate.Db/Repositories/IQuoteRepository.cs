using CaterMate.Db.Entities;

namespace CaterMate.Db.Repositories;

public interface IQuoteRepository
{
    Task<QuoteEntity?> GetByOrderIdAsync(int orderId);
    Task<IEnumerable<QuotePositionEntity>> GetPositionsAsync(int quoteId);
    Task<int> CreateAsync(QuoteEntity quote, IEnumerable<QuotePositionEntity> positions);
    Task UpdateAsync(QuoteEntity quote, IEnumerable<QuotePositionEntity> positions);
    Task<bool> ExistsByOrderIdAsync(int orderId);
    Task DeleteByOrderIdAsync(int orderId);
}
