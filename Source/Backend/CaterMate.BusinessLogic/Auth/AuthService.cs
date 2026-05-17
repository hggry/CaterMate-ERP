using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BCryptNet = BCrypt.Net.BCrypt;
using CaterMate.Db.Repositories;
using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace CaterMate.BusinessLogic.Auth;

public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepo;
    private readonly IConfiguration _config;

    public AuthService(IUserRepository userRepo, IConfiguration config)
    {
        _userRepo = userRepo;
        _config = config;
    }

    public async Task<AuthDto?> LoginAsync(LoginRequest request)
    {
        var user = await _userRepo.GetByUsernameAsync(request.Username);
        if (user == null || !BCryptNet.Verify(request.Password, user.PasswordHash))
            return null;

        var secret = _config["JWT_SECRET"] ?? throw new InvalidOperationException("JWT_SECRET not configured");
        var issuer = _config["JWT_ISSUER"] ?? "catermate";
        var expiryHours = int.Parse(_config["JWT_EXPIRY_HOURS"] ?? "8");
        var expiresAt = DateTime.UtcNow.AddHours(expiryHours);

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.UniqueName, user.Username),
        };

        var token = new JwtSecurityToken(
            issuer: issuer,
            claims: claims,
            expires: expiresAt,
            signingCredentials: creds);

        return new AuthDto
        {
            Token = new JwtSecurityTokenHandler().WriteToken(token),
            ExpiresAt = expiresAt
        };

    }
}
