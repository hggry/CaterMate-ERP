using System.ComponentModel.DataAnnotations;

namespace CaterMate.DTOs.Requests;

public class ConfirmSuggestionsRequest
{
    [Required]
    public List<SuggestionDecision> Decisions { get; set; } = [];
}
