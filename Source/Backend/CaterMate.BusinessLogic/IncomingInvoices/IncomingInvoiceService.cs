using System.Net.Http.Headers;
using CaterMate.Db.Entities;
using CaterMate.Db.Repositories;
using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace CaterMate.BusinessLogic.IncomingInvoices;

public class IncomingInvoiceService : IIncomingInvoiceService
{
    private readonly IIncomingInvoiceRepository _repo;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _config;
    private readonly ILogger<IncomingInvoiceService> _logger;

    public IncomingInvoiceService(
        IIncomingInvoiceRepository repo,
        IHttpClientFactory httpClientFactory,
        IConfiguration config,
        ILogger<IncomingInvoiceService> logger)
    {
        _repo = repo;
        _httpClientFactory = httpClientFactory;
        _config = config;
        _logger = logger;
    }

    public async Task<IncomingInvoiceDto> UploadAsync(IFormFile file)
    {
        var uploadDir = "/app/uploads";
        Directory.CreateDirectory(uploadDir);
        var fileName = $"{Guid.NewGuid()}_{file.FileName}";
        var filePath = Path.Combine(uploadDir, fileName);

        await using (var stream = File.Create(filePath))
            await file.CopyToAsync(stream);

        var entity = new IncomingInvoiceEntity { FilePath = filePath };
        var id = await _repo.CreateAsync(entity);

        _ = SendN8nWebhookAsync(id, filePath);

        return new IncomingInvoiceDto { Id = id, Status = "Pending" };
    }

    public async Task<IEnumerable<IncomingInvoiceDto>> GetAllInvoicesAsync()
    {
        var invoices = await _repo.GetAllInvoicesAsync();
        return invoices.Select(i => new IncomingInvoiceDto
        {
            Id = i.Id,
            Status = i.Status,
            FileName = StripGuidPrefix(Path.GetFileName(i.FilePath)),
            CreatedAt = i.CreatedAt,
            ProcessedAt = i.ProcessedAt
        });
    }

    // Stored files are named "{guid}_{originalName}" — show only the original part.
    private static string StripGuidPrefix(string fileName)
    {
        var idx = fileName.IndexOf('_');
        return idx >= 0 && idx < fileName.Length - 1 ? fileName[(idx + 1)..] : fileName;
    }

    public async Task<IEnumerable<PriceSuggestionDto>> GetSuggestionsAsync(int id)
    {
        var invoice = await _repo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"IncomingInvoice {id} not found");

        if (invoice.Status == "Pending")
            return [];

        var suggestions = await _repo.GetSuggestionsByInvoiceIdAsync(id);
        return suggestions.Select(MapToDto);
    }

    public async Task<IEnumerable<PriceSuggestionDto>> GetAllSuggestionsAsync()
    {
        var suggestions = await _repo.GetAllSuggestionsAsync();
        return suggestions.Select(MapToDto);
    }

    public async Task AcceptSuggestionAsync(int suggestionId)
    {
        var suggestion = await _repo.GetSuggestionByIdAsync(suggestionId)
            ?? throw new KeyNotFoundException($"Suggestion {suggestionId} not found");

        await _repo.UpdateIngredientPriceAsync(suggestion.IngredientId, suggestion.SuggestedPrice);
        await _repo.DeleteSuggestionAsync(suggestionId);
    }

    public async Task DiscardSuggestionAsync(int suggestionId)
    {
        _ = await _repo.GetSuggestionByIdAsync(suggestionId)
            ?? throw new KeyNotFoundException($"Suggestion {suggestionId} not found");

        await _repo.DeleteSuggestionAsync(suggestionId);
    }

    public async Task ConfirmAsync(int id, ConfirmSuggestionsRequest request)
    {
        _ = await _repo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"IncomingInvoice {id} not found");

        var allSuggestions = (await _repo.GetSuggestionsByInvoiceIdAsync(id))
            .ToDictionary(s => s.Id);

        foreach (var decision in request.Decisions)
        {
            await _repo.UpdateSuggestionDecisionAsync(decision.SuggestionId, decision.Accepted);

            if (decision.Accepted && allSuggestions.TryGetValue(decision.SuggestionId, out var suggestion))
                await _repo.UpdateIngredientPriceAsync(suggestion.IngredientId, suggestion.SuggestedPrice);
        }
    }

    public async Task SaveFromN8nAsync(int id, N8nSaveSuggestionsRequest request)
    {
        var invoice = await _repo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"IncomingInvoice {id} not found");

        var suggestions = request.Suggestions.Select(s => new IncomingInvoiceSuggestionEntity
        {
            IncomingInvoiceId = id,
            IngredientId = s.IngredientId,
            IngredientName = s.IngredientName,
            CurrentPrice = s.CurrentPrice,
            SuggestedPrice = s.SuggestedPrice
        }).ToList();

        await _repo.SaveSuggestionsAsync(id, suggestions);
    }

    private async Task SendN8nWebhookAsync(int invoiceId, string filePath)
    {
        var webhookUrl = _config["N8N_WEBHOOK_INCOMING_URL"];
        if (string.IsNullOrEmpty(webhookUrl))
            return;

        try
        {
            var client = _httpClientFactory.CreateClient();

            using var form = new MultipartFormDataContent();
            var fileBytes = await File.ReadAllBytesAsync(filePath);
            var fileContent = new ByteArrayContent(fileBytes);
            fileContent.Headers.ContentType = new MediaTypeHeaderValue("application/pdf");
            form.Add(fileContent, "file", Path.GetFileName(filePath));

            // The invoice id goes as a query parameter — multipart text fields do not
            // reliably reach n8n's $json.body, but query params always land in $json.query.
            var url = webhookUrl + (webhookUrl.Contains('?') ? "&" : "?") + "incomingInvoiceId=" + invoiceId;

            await client.PostAsync(url, form);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send n8n webhook for incoming invoice {InvoiceId}", invoiceId);
        }
    }

    private static PriceSuggestionDto MapToDto(IncomingInvoiceSuggestionEntity s) =>
        new()
        {
            Id = s.Id,
            IncomingInvoiceId = s.IncomingInvoiceId,
            IngredientId = s.IngredientId,
            IngredientName = s.IngredientName,
            CurrentPrice = s.CurrentPrice,
            SuggestedPrice = s.SuggestedPrice,
            Accepted = s.Accepted
        };
}
