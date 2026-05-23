using System.ComponentModel.DataAnnotations;

namespace CaterMate.DTOs.Requests;

public class UpdatePurchaseListItemRequest
{
    [Required]
    public bool IsDone { get; set; }
}
