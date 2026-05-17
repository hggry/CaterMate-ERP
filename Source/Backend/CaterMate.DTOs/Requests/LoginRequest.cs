using System.ComponentModel.DataAnnotations;

namespace CaterMate.DTOs.Requests;

public class LoginRequest
{
    [Required] public string Username { get; set; } = "";
    [Required] public string Password { get; set; } = "";
}
