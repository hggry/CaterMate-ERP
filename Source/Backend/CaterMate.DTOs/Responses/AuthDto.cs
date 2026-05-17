namespace CaterMate.DTOs.Responses;

public class AuthDto
{
    public string Token { get; set; } = "";
    public DateTime ExpiresAt { get; set; }
}
