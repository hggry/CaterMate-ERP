using System.ComponentModel.DataAnnotations;

namespace CaterMate.DTOs.Requests;

public class UpdateCompanySettingsRequest
{
    [Required]
    [StringLength(200)]
    public string CompanyName { get; set; } = "";
    public string? Street { get; set; }
    public string? PostalCode { get; set; }
    public string? City { get; set; }
    public string? Country { get; set; }
    public string? Phone { get; set; }
    [EmailAddress]
    public string? Email { get; set; }
    public string? Website { get; set; }
    public string? VatId { get; set; }
    public string? TaxNumber { get; set; }
    public string? Iban { get; set; }
    public string? Bic { get; set; }
    public string? BankName { get; set; }
    public string? CommercialRegNo { get; set; }
    public string? CommercialCourt { get; set; }
}
