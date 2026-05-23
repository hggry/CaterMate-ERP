using CaterMate.DTOs.Responses;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace CaterMate.BusinessLogic.Pdf;

public class PdfService : IPdfService
{
    public byte[] GenerateQuotePdf(QuoteDto quote, string customerName, DateTime eventDate)
    {
        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.DefaultTextStyle(x => x.FontSize(10));

                page.Header().Column(col =>
                {
                    col.Item().Text("CaterMate – Angebot").Bold().FontSize(18);
                    col.Item().Text($"Kunde: {customerName}");
                    col.Item().Text($"Veranstaltungsdatum: {eventDate:dd.MM.yyyy}");
                    col.Item().Text($"Erstellt am: {quote.CreatedAt:dd.MM.yyyy}");
                });

                page.Content().PaddingTop(10).Column(col =>
                {
                    col.Item().Table(table =>
                    {
                        table.ColumnsDefinition(cols =>
                        {
                            cols.RelativeColumn(4);
                            cols.RelativeColumn(1);
                            cols.RelativeColumn(2);
                            cols.RelativeColumn(2);
                            cols.RelativeColumn(2);
                            cols.RelativeColumn(2);
                        });

                        table.Header(header =>
                        {
                            header.Cell().Text("Bezeichnung").Bold();
                            header.Cell().Text("Menge").Bold();
                            header.Cell().AlignRight().Text("EP (€)").Bold();
                            header.Cell().AlignRight().Text("Netto (€)").Bold();
                            header.Cell().AlignRight().Text("MwSt.").Bold();
                            header.Cell().AlignRight().Text("Brutto (€)").Bold();
                        });

                        foreach (var pos in quote.Positions)
                        {
                            table.Cell().Text(pos.MenuItemName);
                            table.Cell().Text(pos.Quantity.ToString());
                            table.Cell().AlignRight().Text(pos.UnitPrice.ToString("F2"));
                            table.Cell().AlignRight().Text(pos.TotalNet.ToString("F2"));
                            table.Cell().AlignRight().Text($"{pos.VatRate * 100:F0}%");
                            table.Cell().AlignRight().Text(pos.TotalGross.ToString("F2"));
                        }

                        table.Cell().ColumnSpan(3).Text("Verwaltungspauschale").Italic();
                        table.Cell().AlignRight().Text(quote.AdminFee.ToString("F2")).Italic();
                        table.Cell();
                        table.Cell();
                    });

                    col.Item().PaddingTop(10).AlignRight().Column(totals =>
                    {
                        totals.Item().Text($"Netto gesamt: {quote.TotalNet:F2} €");
                        totals.Item().Text($"MwSt. gesamt: {quote.TotalVat:F2} €");
                        totals.Item().Text($"Brutto gesamt: {quote.TotalGross:F2} €").Bold().FontSize(12);
                    });
                });

                page.Footer().AlignCenter().Text(x =>
                {
                    x.CurrentPageNumber();
                    x.Span(" / ");
                    x.TotalPages();
                });
            });
        }).GeneratePdf();
    }

    public byte[] GeneratePurchaseListPdf(PurchaseListDto purchaseList, int guestCount)
    {
        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.DefaultTextStyle(x => x.FontSize(10));

                page.Header().Column(col =>
                {
                    col.Item().Text("CaterMate – Einkaufsliste").Bold().FontSize(18);
                    col.Item().Text($"Auftrag #{purchaseList.OrderId} | {guestCount} Personen | Sicherheitsaufschlag: {purchaseList.SafetyMargin * 100:F0}%");
                });

                page.Content().PaddingTop(10).Column(col =>
                {
                    foreach (var group in purchaseList.Groups)
                    {
                        col.Item().PaddingTop(8).Text(group.Category).Bold().FontSize(11);
                        col.Item().Table(table =>
                        {
                            table.ColumnsDefinition(cols =>
                            {
                                cols.RelativeColumn(5);
                                cols.RelativeColumn(2);
                                cols.RelativeColumn(1);
                            });

                            table.Header(header =>
                            {
                                header.Cell().Text("Zutat").Bold();
                                header.Cell().AlignRight().Text("Menge").Bold();
                                header.Cell().Text("Einheit").Bold();
                            });

                            foreach (var item in group.Items)
                            {
                                table.Cell().Text(item.IngredientName);
                                table.Cell().AlignRight().Text(item.RequiredQuantity.ToString("F2"));
                                table.Cell().Text(item.Unit);
                            }
                        });
                    }
                });

                page.Footer().AlignCenter().Text(x =>
                {
                    x.CurrentPageNumber();
                    x.Span(" / ");
                    x.TotalPages();
                });
            });
        }).GeneratePdf();
    }

    public byte[] GenerateInvoicePdf(InvoiceDto invoice)
    {
        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.DefaultTextStyle(x => x.FontSize(10));

                page.Header().Column(col =>
                {
                    col.Item().Text("CaterMate – Rechnung").Bold().FontSize(18);
                    col.Item().Text($"Rechnungsnummer: {invoice.InvoiceNumber}").Bold();
                    col.Item().Text($"Kunde: {invoice.CustomerName}");
                    col.Item().Text($"Rechnungsdatum: {invoice.IssueDate:dd.MM.yyyy}");
                    col.Item().Text($"Fällig bis: {invoice.DueDate:dd.MM.yyyy}");
                });

                page.Content().PaddingTop(10).Column(col =>
                {
                    col.Item().Table(table =>
                    {
                        table.ColumnsDefinition(cols =>
                        {
                            cols.RelativeColumn(4);
                            cols.RelativeColumn(1);
                            cols.RelativeColumn(2);
                            cols.RelativeColumn(2);
                            cols.RelativeColumn(2);
                            cols.RelativeColumn(2);
                        });

                        table.Header(header =>
                        {
                            header.Cell().Text("Bezeichnung").Bold();
                            header.Cell().Text("Menge").Bold();
                            header.Cell().AlignRight().Text("EP (€)").Bold();
                            header.Cell().AlignRight().Text("Netto (€)").Bold();
                            header.Cell().AlignRight().Text("MwSt.").Bold();
                            header.Cell().AlignRight().Text("Brutto (€)").Bold();
                        });

                        foreach (var pos in invoice.Positions)
                        {
                            table.Cell().Text(pos.MenuItemName);
                            table.Cell().Text(pos.Quantity.ToString());
                            table.Cell().AlignRight().Text(pos.UnitPrice.ToString("F2"));
                            table.Cell().AlignRight().Text(pos.TotalNet.ToString("F2"));
                            table.Cell().AlignRight().Text($"{pos.VatRate * 100:F0}%");
                            table.Cell().AlignRight().Text(pos.TotalGross.ToString("F2"));
                        }
                    });

                    col.Item().PaddingTop(10).AlignRight().Column(totals =>
                    {
                        totals.Item().Text($"Netto gesamt: {invoice.TotalNet:F2} €");
                        totals.Item().Text($"MwSt. gesamt: {invoice.TotalVat:F2} €");
                        totals.Item().Text($"Brutto gesamt: {invoice.TotalGross:F2} €").Bold().FontSize(12);
                    });
                });

                page.Footer().AlignCenter().Text(x =>
                {
                    x.CurrentPageNumber();
                    x.Span(" / ");
                    x.TotalPages();
                });
            });
        }).GeneratePdf();
    }
}
