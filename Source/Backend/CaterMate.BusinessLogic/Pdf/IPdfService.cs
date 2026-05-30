using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Pdf;

public interface IPdfService
{
    byte[] GenerateQuotePdf(QuoteDto quote, string customerName, DateTime eventDate, CompanySettingsDto company);
    byte[] GeneratePurchaseListPdf(PurchaseListDto purchaseList, int guestCount, CompanySettingsDto company);
    byte[] GenerateInvoicePdf(InvoiceDto invoice, CompanySettingsDto company);
}
