using System.ComponentModel.DataAnnotations;

namespace CaterMate.DTOs.Requests;

public class N8nSuggestionItem
{
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = "";
    public decimal SuggestedPrice { get; set; }
    public decimal CurrentPrice { get; set; }
}

public class N8nSaveSuggestionsRequest
{
    [Required]
    public List<N8nSuggestionItem> Suggestions { get; set; } = [];
}
