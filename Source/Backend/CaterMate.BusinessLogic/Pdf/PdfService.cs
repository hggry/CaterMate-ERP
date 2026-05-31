using System.Globalization;
using CaterMate.DTOs.Responses;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace CaterMate.BusinessLogic.Pdf;

/// <summary>
/// Generates all customer-facing and internal PDFs.
/// Brand colours: Avocado #7AAA28 (primary fallback), Espresso #3E2818 (text),
/// Sand #F5F5F5 (alternate row), White #FFFFFF.
/// The primary colour can be overridden per-company via CompanySettingsDto.AccentColor.
/// </summary>
public class PdfService : IPdfService
{
    // ── Locale ───────────────────────────────────────────────────────────────
    private static readonly CultureInfo De = CultureInfo.GetCultureInfo("de-AT");

    // Formats a decimal as German currency: e.g. 6.240,00 €
    private static string Eur(decimal v) => v.ToString("N2", De) + " €";
    // Formats quantity with two decimal places using German locale
    private static string Qty(decimal v) => v.ToString("N2", De);

    // ── Brand colours ────────────────────────────────────────────────────────
    private static readonly Color DefaultPrimary = Color.FromHex("#7AAA28");
    private static readonly Color DarkText       = Color.FromHex("#3E2818");

    // Returns the company's accent colour, falling back to the CaterMate default.
    private static Color GetPrimary(CompanySettingsDto c) =>
        string.IsNullOrWhiteSpace(c.AccentColor) ? DefaultPrimary : Color.FromHex(c.AccentColor);
    private static readonly Color AltRow   = Color.FromHex("#F5F5F5");
    private static readonly Color White    = Colors.White;
    private static readonly Color LightGray = Color.FromHex("#E8E8E8");

    // ── Shared helpers ───────────────────────────────────────────────────────

    /// Renders the company header block (logo + name + address + contact).
    private static void AddCompanyHeader(ColumnDescriptor col, CompanySettingsDto c, byte[]? logo)
    {
        col.Item().Row(row =>
        {
            // Logo cell
            if (logo != null)
            {
                row.ConstantItem(60).Height(60).Image(logo).FitArea();
                row.ConstantItem(12); // spacing
            }

            // Company info
            row.RelativeItem().Column(info =>
            {
                info.Item().Text(c.CompanyName).Bold().FontSize(14).FontColor(DarkText);

                var addressParts = new[]
                {
                    c.Street,
                    string.IsNullOrWhiteSpace(c.PostalCode) && string.IsNullOrWhiteSpace(c.City)
                        ? null
                        : $"{c.PostalCode} {c.City}".Trim(),
                    c.Country,
                }.Where(x => !string.IsNullOrWhiteSpace(x));
                foreach (var part in addressParts)
                    info.Item().Text(part).FontSize(9).FontColor(DarkText);
            });

            // Contact + tax info (right-aligned)
            row.RelativeItem().AlignRight().Column(contact =>
            {
                void Line(string? value, string label)
                {
                    if (!string.IsNullOrWhiteSpace(value))
                        contact.Item().Text($"{label}: {value}").FontSize(9).FontColor(DarkText);
                }
                Line(c.Phone, "Tel.");
                Line(c.Email, "E-Mail");
                Line(c.Website, "Web");
                Line(c.VatId, "UID");
                Line(c.TaxNumber, "St.-Nr.");
            });
        });

        // Accent line under header
        col.Item().PaddingTop(6).PaddingBottom(8)
            .LineHorizontal(1.5f).LineColor(GetPrimary(c));
    }

    /// Renders a styled document title row with number/date info on the right.
    private static void AddDocumentTitleBar(ColumnDescriptor col, string title, string infoLeft, string infoRight, Color primary)
    {
        col.Item().PaddingBottom(12).Row(row =>
        {
            row.RelativeItem().Text(title).Bold().FontSize(20).FontColor(primary);
            row.RelativeItem().AlignRight().Column(c =>
            {
                c.Item().Text(infoLeft).FontSize(9).FontColor(DarkText);
                c.Item().Text(infoRight).FontSize(9).FontColor(DarkText);
            });
        });
    }

    /// Renders a standard positions table header.
    private static void AddTableHeader(TableDescriptor table, Color primary)
    {
        table.Header(h =>
        {
            void HeaderCell(string text, bool alignRight = false)
            {
                var cell = h.Cell().Background(primary).Padding(5);
                var txt = cell.Text(text).Bold().FontColor(White).FontSize(9);
                if (alignRight) txt.AlignRight();
            }
            HeaderCell("Bezeichnung");
            HeaderCell("Menge", true);
            HeaderCell("EP (€)", true);
            HeaderCell("Netto (€)", true);
            HeaderCell("MwSt.", true);
            HeaderCell("Brutto (€)", true);
        });
    }

    /// Renders one data row with alternating background.
    private static void AddTableRow(TableDescriptor table, int rowIndex,
        string name, int qty, decimal unitPrice, decimal net, decimal vatRate, decimal gross)
    {
        var bg = rowIndex % 2 == 0 ? White : AltRow;
        void Cell(string text, bool right = false, bool italic = false)
        {
            var cell = table.Cell().Background(bg).Padding(4);
            var t = cell.Text(text).FontSize(9).FontColor(DarkText);
            if (right) t.AlignRight();
            if (italic) t.Italic();
        }
        Cell(name);
        Cell(qty.ToString("N0", De), right: true);
        Cell(unitPrice.ToString("N2", De), right: true);
        Cell(net.ToString("N2", De), right: true);
        Cell($"{vatRate * 100:F0}%", right: true);
        Cell(gross.ToString("N2", De), right: true);
    }

    /// Renders the totals summary block (right-aligned, with thousands separators).
    private static void AddTotalsSummary(ColumnDescriptor col, decimal net, decimal vat, decimal gross, Color primary)
    {
        col.Item().PaddingTop(10).AlignRight().Width(260).Column(totals =>
        {
            totals.Item().Row(r =>
            {
                r.RelativeItem().Text("Netto gesamt").FontSize(9).FontColor(DarkText);
                r.ConstantItem(100).Text(Eur(net)).AlignRight().FontSize(9).FontColor(DarkText);
            });
            totals.Item().Row(r =>
            {
                r.RelativeItem().Text("MwSt. gesamt").FontSize(9).FontColor(DarkText);
                r.ConstantItem(100).Text(Eur(vat)).AlignRight().FontSize(9).FontColor(DarkText);
            });
            totals.Item().PaddingTop(4)
                .LineHorizontal(1).LineColor(primary);
            totals.Item().PaddingTop(4).Row(r =>
            {
                r.RelativeItem().Text("Brutto gesamt").Bold().FontSize(11).FontColor(primary);
                r.ConstantItem(100).Text(Eur(gross)).AlignRight().Bold().FontSize(11).FontColor(primary);
            });
        });
    }

    /// Renders the bank/payment info box.
    private static void AddPaymentBox(ColumnDescriptor col, CompanySettingsDto c, string paymentNote)
    {
        if (string.IsNullOrWhiteSpace(c.Iban)) return;
        col.Item().PaddingTop(14).Border(1).BorderColor(LightGray).Padding(10).Column(box =>
        {
            box.Item().Text("Zahlungsinformationen").Bold().FontSize(9).FontColor(GetPrimary(c));
            box.Item().PaddingTop(4).Text(paymentNote).FontSize(9).FontColor(DarkText);
            if (!string.IsNullOrWhiteSpace(c.Iban))
                box.Item().Text($"IBAN: {c.Iban}").FontSize(9).FontColor(DarkText);
            var bicBank = string.Join("  |  ", new[] { c.Bic, c.BankName }.Where(x => !string.IsNullOrWhiteSpace(x)));
            if (!string.IsNullOrWhiteSpace(bicBank))
                box.Item().Text(bicBank).FontSize(9).FontColor(DarkText);
        });
    }

    /// Renders the legal footer line.
    private static void AddFooter(PageDescriptor page, CompanySettingsDto c)
    {
        page.Footer().PaddingTop(6).Column(col =>
        {
            col.Item().LineHorizontal(0.5f).LineColor(LightGray);
            col.Item().PaddingTop(4).Row(row =>
            {
                // Legal info left
                row.RelativeItem().Text(t =>
                {
                    var parts = new List<string>();
                    if (!string.IsNullOrWhiteSpace(c.CommercialRegNo))
                        parts.Add($"FN {c.CommercialRegNo}");
                    if (!string.IsNullOrWhiteSpace(c.CommercialCourt))
                        parts.Add(c.CommercialCourt);
                    if (!string.IsNullOrWhiteSpace(c.VatId))
                        parts.Add($"UID: {c.VatId}");
                    t.Span(string.Join("  ·  ", parts)).FontSize(7).FontColor(Colors.Grey.Medium);
                });

                // Page number right
                row.ConstantItem(60).AlignRight().Text(x =>
                {
                    x.Span("Seite ").FontSize(7).FontColor(Colors.Grey.Medium);
                    x.CurrentPageNumber().FontSize(7).FontColor(Colors.Grey.Medium);
                    x.Span(" / ").FontSize(7).FontColor(Colors.Grey.Medium);
                    x.TotalPages().FontSize(7).FontColor(Colors.Grey.Medium);
                });
            });
        });
    }

    // ── Public PDF generators ────────────────────────────────────────────────

    public byte[] GenerateQuotePdf(QuoteDto quote, string customerName, DateTime eventDate, CompanySettingsDto company)
    {
        var logo = GetLogoBytes(company);
        var primary = GetPrimary(company);
        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.DefaultTextStyle(x => x.FontSize(10).FontColor(DarkText));

                page.Header().Column(col =>
                {
                    AddCompanyHeader(col, company, logo);
                });

                page.Content().Column(col =>
                {
                    // Document title + meta
                    AddDocumentTitleBar(col, "Angebot",
                        $"Angebotsnummer: A-{quote.Id:D5}",
                        $"Erstellt am: {quote.CreatedAt:dd.MM.yyyy}", primary);

                    // Recipient block
                    col.Item().PaddingBottom(10).Row(row =>
                    {
                        row.RelativeItem().Column(r =>
                        {
                            r.Item().Text("An:").FontSize(8).FontColor(Colors.Grey.Medium);
                            r.Item().Text(customerName).Bold().FontSize(11).FontColor(DarkText);
                            r.Item().Text($"Veranstaltungsdatum: {eventDate:dd.MM.yyyy}")
                                .FontSize(9).FontColor(DarkText);
                        });
                    });

                    // Positions table
                    col.Item().Table(table =>
                    {
                        table.ColumnsDefinition(cols =>
                        {
                            cols.RelativeColumn(4);
                            cols.RelativeColumn(1);
                            cols.RelativeColumn(2);
                            cols.RelativeColumn(2);
                            cols.RelativeColumn(1.5f);
                            cols.RelativeColumn(2);
                        });
                        AddTableHeader(table, primary);

                        var rowIndex = 0;
                        foreach (var pos in quote.Positions)
                        {
                            AddTableRow(table, rowIndex++,
                                pos.MenuItemName, pos.Quantity, pos.UnitPrice,
                                pos.TotalNet, pos.VatRate, pos.TotalGross);
                        }

                        // Admin fee row
                        var bg = rowIndex % 2 == 0 ? White : AltRow;
                        table.Cell().ColumnSpan(3).Background(bg).Padding(4)
                            .Text("Verwaltungspauschale").Italic().FontSize(9).FontColor(DarkText);
                        table.Cell().Background(bg).Padding(4)
                            .Text(quote.AdminFee.ToString("N2", De)).AlignRight().Italic().FontSize(9).FontColor(DarkText);
                        table.Cell().Background(bg).Padding(4);
                        table.Cell().Background(bg).Padding(4);
                    });

                    AddTotalsSummary(col, quote.TotalNet, quote.TotalVat, quote.TotalGross, primary);

                    // Offer validity note
                    col.Item().PaddingTop(12).Text(
                        "Dieses Angebot ist 30 Tage gültig. Wir freuen uns auf Ihre Bestätigung.")
                        .FontSize(9).FontColor(Colors.Grey.Medium).Italic();

                    AddPaymentBox(col, company, "Bitte überweisen Sie den Betrag nach Bestätigung des Angebots.");
                });

                AddFooter(page, company);
            });
        }).GeneratePdf();
    }

    public byte[] GenerateInvoicePdf(InvoiceDto invoice, CompanySettingsDto company)
    {
        var logo = GetLogoBytes(company);
        var primary = GetPrimary(company);
        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.DefaultTextStyle(x => x.FontSize(10).FontColor(DarkText));

                page.Header().Column(col =>
                {
                    AddCompanyHeader(col, company, logo);
                });

                page.Content().Column(col =>
                {
                    AddDocumentTitleBar(col, "Rechnung",
                        $"Rechnungsnummer: {invoice.InvoiceNumber}",
                        $"Datum: {invoice.IssueDate:dd.MM.yyyy}  ·  Fällig: {invoice.DueDate:dd.MM.yyyy}", primary);

                    // Recipient
                    col.Item().PaddingBottom(10).Column(r =>
                    {
                        r.Item().Text("Rechnungsempfänger:").FontSize(8).FontColor(Colors.Grey.Medium);
                        r.Item().Text(invoice.CustomerName).Bold().FontSize(11).FontColor(DarkText);
                    });

                    // Positions table
                    col.Item().Table(table =>
                    {
                        table.ColumnsDefinition(cols =>
                        {
                            cols.RelativeColumn(4);
                            cols.RelativeColumn(1);
                            cols.RelativeColumn(2);
                            cols.RelativeColumn(2);
                            cols.RelativeColumn(1.5f);
                            cols.RelativeColumn(2);
                        });
                        AddTableHeader(table, primary);

                        var rowIndex = 0;
                        foreach (var pos in invoice.Positions)
                        {
                            AddTableRow(table, rowIndex++,
                                pos.MenuItemName, pos.Quantity, pos.UnitPrice,
                                pos.TotalNet, pos.VatRate, pos.TotalGross);
                        }
                    });

                    AddTotalsSummary(col, invoice.TotalNet, invoice.TotalVat, invoice.TotalGross, primary);

                    AddPaymentBox(col, company,
                        $"Bitte überweisen Sie {invoice.TotalGross:F2} € bis {invoice.DueDate:dd.MM.yyyy}.");
                });

                AddFooter(page, company);
            });
        }).GeneratePdf();
    }

    public byte[] GeneratePurchaseListPdf(PurchaseListDto purchaseList, int guestCount, CompanySettingsDto company)
    {
        var logo = GetLogoBytes(company);
        var primary = GetPrimary(company);
        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.DefaultTextStyle(x => x.FontSize(10).FontColor(DarkText));

                page.Header().Column(col =>
                {
                    AddCompanyHeader(col, company, logo);
                });

                page.Content().Column(col =>
                {
                    AddDocumentTitleBar(col, "Einkaufsliste",
                        $"Auftrag #{purchaseList.OrderId}  ·  {guestCount} Personen",
                        $"Sicherheitsaufschlag: {purchaseList.SafetyMargin * 100:F0}%", primary);

                    foreach (var group in purchaseList.Groups)
                    {
                        // Category header bar
                        col.Item().PaddingTop(10).Background(primary).Padding(5)
                            .Text(group.Category).Bold().FontSize(10).FontColor(White);

                        col.Item().Table(table =>
                        {
                            table.ColumnsDefinition(cols =>
                            {
                                cols.RelativeColumn(5);
                                cols.RelativeColumn(2);
                                cols.RelativeColumn(1);
                                cols.ConstantColumn(22);
                            });

                            // Group header
                            table.Header(h =>
                            {
                                void H(string t, bool right = false)
                                {
                                    var cell = h.Cell().Background(AltRow).Padding(4);
                                    var txt = cell.Text(t).Bold().FontSize(8).FontColor(DarkText);
                                    if (right) txt.AlignRight();
                                }
                                H("Zutat");
                                H("Menge", right: true);
                                H("Einheit");
                                H("");  // Checkbox column header — blank
                            });

                            var rowIndex = 0;
                            foreach (var item in group.Items)
                            {
                                var bg = rowIndex++ % 2 == 0 ? White : AltRow;
                                table.Cell().Background(bg).Padding(3)
                                    .Text(item.IngredientName).FontSize(9).FontColor(DarkText);
                                // TextDescriptor.AlignRight() is used here (not container.AlignRight())
                                // to avoid text overflowing the cell boundary in QuestPDF.
                                table.Cell().Background(bg).Padding(3)
                                    .Text(Qty(item.RequiredQuantity)).AlignRight().FontSize(9).FontColor(DarkText);
                                table.Cell().Background(bg).Padding(3)
                                    .Text(item.Unit).FontSize(9).FontColor(DarkText);
                                // Small bordered box for manual check-off (replaces ☐ which
                                // is not in the QuestPDF default font set)
                                table.Cell().Background(bg).Padding(4)
                                    .Border(0.5f).BorderColor(LightGray).Text("").FontSize(9);
                            }
                        });
                    }
                });

                AddFooter(page, company);
            });
        }).GeneratePdf();
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    /// Tries to read the logo file synchronously from disk (called within sync QuestPDF render).
    private static byte[]? GetLogoBytes(CompanySettingsDto company)
    {
        // CompanySettingsService exposes HasLogo but not the path.
        // We re-read from the known upload directory using a glob pattern.
        if (!company.HasLogo) return null;
        try
        {
            var files = Directory.GetFiles("/app/uploads", "logo_*");
            return files.Length > 0 ? File.ReadAllBytes(files.OrderByDescending(f => f).First()) : null;
        }
        catch
        {
            return null;
        }
    }
}
