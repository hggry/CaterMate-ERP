using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Auth;

public interface IAuthService
{
    Task<AuthDto?> LoginAsync(LoginRequest request);
}
