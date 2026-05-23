using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Pdf;

public interface IPdfService
{
    byte[] GenerateQuotePdf(QuoteDto quote, string customerName, DateTime eventDate);
    byte[] GeneratePurchaseListPdf(PurchaseListDto purchaseList, int guestCount);
    byte[] GenerateInvoicePdf(InvoiceDto invoice);
}
