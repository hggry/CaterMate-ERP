using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace CaterMate.API.Filters;

public class N8nApiKeyAuthFilter : IAuthorizationFilter
{
    private const string HeaderName = "X-Api-Key";

    private readonly IConfiguration _config;

    public N8nApiKeyAuthFilter(IConfiguration config) => _config = config;

    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var apiKey = _config["N8N_API_KEY"];

        if (string.IsNullOrWhiteSpace(apiKey))
        {
            context.Result = new ObjectResult(new
            {
                status = 500,
                title = "Internal Server Error",
                detail = "Server-Konfigurationsfehler: N8N_API_KEY nicht gesetzt."
            }) { StatusCode = 500 };
            return;
        }

        if (!context.HttpContext.Request.Headers.TryGetValue(HeaderName, out var requestKey)
            || requestKey.ToString() != apiKey)
        {
            context.Result = new ObjectResult(new
            {
                status = 401,
                title = "Unauthorized",
                detail = "Ungültiger oder fehlender X-Api-Key Header."
            }) { StatusCode = 401 };
        }
    }
}
