using System.Text;
using BCryptNet = BCrypt.Net.BCrypt;
using CaterMate.API.Filters;
using CaterMate.API.Middleware;
using CaterMate.BusinessLogic.Analytics;
using CaterMate.BusinessLogic.Auth;
using CaterMate.BusinessLogic.IncomingInvoices;
using CaterMate.BusinessLogic.Invoicing;
using CaterMate.BusinessLogic.Menu;
using CaterMate.BusinessLogic.Orders;
using CaterMate.BusinessLogic.Pdf;
using CaterMate.BusinessLogic.Procurement;
using CaterMate.BusinessLogic.Quotes;
using CaterMate.BusinessLogic.Settings;
using CaterMate.BusinessLogic.Stock;
using CaterMate.BusinessLogic.Suggestions;
using CaterMate.Db;
using CaterMate.Db.Repositories;
using CaterMate.Db.Seeding;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using QuestPDF.Infrastructure;
using Serilog;
using Serilog.Events;

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft.AspNetCore", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .WriteTo.Console(outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {RequestId} {Message:lj}{NewLine}{Exception}")
    .CreateLogger();

var builder = WebApplication.CreateBuilder(args);
builder.Host.UseSerilog();

var config = builder.Configuration;
var connectionString = config.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("DefaultConnection not configured");

QuestPDF.Settings.License = LicenseType.Community;

// Infrastructure
builder.Services.AddSingleton(new DapperContext(connectionString));
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<ICustomerRepository, CustomerRepository>();
builder.Services.AddScoped<IOrderRepository, OrderRepository>();
builder.Services.AddScoped<IMenuItemRepository, MenuItemRepository>();
builder.Services.AddScoped<IIngredientRepository, IngredientRepository>();
builder.Services.AddScoped<IQuoteRepository, QuoteRepository>();
builder.Services.AddScoped<IPurchaseListRepository, PurchaseListRepository>();
builder.Services.AddScoped<IInvoiceRepository, InvoiceRepository>();
builder.Services.AddScoped<IDashboardRepository, DashboardRepository>();
builder.Services.AddScoped<IIncomingInvoiceRepository, IncomingInvoiceRepository>();

// Business logic
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IMenuItemService, MenuItemService>();
builder.Services.AddScoped<IIngredientService, IngredientService>();
builder.Services.AddScoped<IPdfService, PdfService>();
builder.Services.AddScoped<IQuoteService, QuoteService>();
builder.Services.AddScoped<IPurchaseListService, PurchaseListService>();
builder.Services.AddScoped<IInvoiceService, InvoiceService>();
builder.Services.AddScoped<IDashboardService, DashboardService>();
builder.Services.AddScoped<IIncomingInvoiceService, IncomingInvoiceService>();
builder.Services.AddScoped<ISuggestionService, SuggestionService>();
builder.Services.AddScoped<ICompanySettingsRepository, CompanySettingsRepository>();
builder.Services.AddScoped<ICompanySettingsService, CompanySettingsService>();
builder.Services.AddHttpClient();

// Filters
builder.Services.AddScoped<N8nApiKeyAuthFilter>();

// JWT auth
var jwtSecret = config["JWT_SECRET"] ?? throw new InvalidOperationException("JWT_SECRET not configured");
var jwtIssuer = config["JWT_ISSUER"] ?? "catermate";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtIssuer,
            ValidateAudience = false,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret))
        };
    });

builder.Services.AddAuthorization();

// CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins(
            "http://localhost:3000",
            config["FRONTEND_URL"] ?? "http://localhost:3000")
            .AllowAnyHeader()
            .WithMethods("GET", "POST", "PUT", "PATCH", "DELETE");
    });
});

builder.Services.AddControllers();

if (builder.Environment.IsDevelopment())
    builder.Services.AddEndpointsApiExplorer().AddSwaggerGen();

var app = builder.Build();

if (string.IsNullOrWhiteSpace(config["N8N_API_KEY"]))
    Log.Warning("N8N_API_KEY is not configured — all requests to /api/n8n/* will return 500");

app.UseMiddleware<GlobalExceptionMiddleware>();
app.UseSerilogRequestLogging();
app.UseCors();
app.UseAuthentication();
app.UseAuthorization();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapControllers();

// Admin seeding on startup — failures are logged but do not crash the app
await SeedAdminUserAsync(app);
await SeedDemoOrdersAsync(app);

await app.RunAsync();

static async Task SeedAdminUserAsync(WebApplication app)
{
    using var scope = app.Services.CreateScope();
    var userRepo = scope.ServiceProvider.GetRequiredService<IUserRepository>();
    var cfg = scope.ServiceProvider.GetRequiredService<IConfiguration>();

    for (var attempt = 1; attempt <= 10; attempt++)
    {
        try
        {
            if (!await userRepo.AnyExistsAsync())
            {
                var adminUsername = cfg["SEED_ADMIN_USERNAME"] ?? "admin";
                var adminPassword = cfg["SEED_ADMIN_PASSWORD"]
                    ?? throw new InvalidOperationException("SEED_ADMIN_PASSWORD not configured");
                await userRepo.CreateAsync(adminUsername, BCryptNet.HashPassword(adminPassword));
                Log.Information("Admin user '{Username}' created", adminUsername);
            }
            return;
        }
        catch (Exception ex) when (attempt < 10)
        {
            Log.Warning("DB not ready (attempt {Attempt}/10): {Message}", attempt, ex.Message);
            await Task.Delay(TimeSpan.FromSeconds(3));
        }
        catch (Exception ex)
        {
            Log.Warning(ex, "Admin seeding failed after all retries — continuing without seeding");
            return;
        }
    }
}

static async Task SeedDemoOrdersAsync(WebApplication app)
{
    var cfg = app.Services.GetRequiredService<IConfiguration>();
    if (!string.Equals(cfg["SEED_DEMO_ORDERS"], "true", StringComparison.OrdinalIgnoreCase))
        return;

    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<DapperContext>();

    for (var attempt = 1; attempt <= 10; attempt++)
    {
        try
        {
            await DemoOrderSeeder.SeedAsync(context);
            Log.Information("Demo orders seeded");
            return;
        }
        catch (Exception ex) when (attempt < 10)
        {
            Log.Warning("Demo order seeding delayed (attempt {Attempt}/10): {Message}", attempt, ex.Message);
            await Task.Delay(TimeSpan.FromSeconds(3));
        }
        catch (Exception ex)
        {
            Log.Warning(ex, "Demo order seeding failed after all retries - continuing without demo data");
            return;
        }
    }
}

public partial class Program { }
