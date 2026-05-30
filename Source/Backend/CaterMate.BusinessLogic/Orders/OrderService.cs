using CaterMate.BusinessLogic.Procurement;
using CaterMate.Db.Entities;
using CaterMate.Db.Repositories;
using CaterMate.DTOs.Requests;
using CaterMate.DTOs.Responses;

namespace CaterMate.BusinessLogic.Orders;

public class OrderService : IOrderService
{
    private readonly IOrderRepository _orderRepo;
    private readonly ICustomerRepository _customerRepo;
    private readonly IMenuItemRepository _menuItemRepo;
    private readonly IPurchaseListService _purchaseListService;

    private static readonly Dictionary<string, string> ValidTransitions = new()
    {
        ["Neu"]             = "Geprüft",
        ["Geprüft"]         = "AngebotErstellt",
        ["AngebotErstellt"] = "Bestätigt",
        ["Bestätigt"]       = "InBeschaffung",
        ["InBeschaffung"]   = "InVorbereitung",
        ["InVorbereitung"]  = "Durchgeführt",
        ["Durchgeführt"]    = "Abgerechnet",
    };

    public OrderService(
        IOrderRepository orderRepo,
        ICustomerRepository customerRepo,
        IMenuItemRepository menuItemRepo,
        IPurchaseListService purchaseListService)
    {
        _orderRepo = orderRepo;
        _customerRepo = customerRepo;
        _menuItemRepo = menuItemRepo;
        _purchaseListService = purchaseListService;
    }

    public async Task<IEnumerable<OrderDto>> GetAllAsync(string? status, DateTime? from, DateTime? to)
    {
        var orders = await _orderRepo.GetAllAsync(status, from, to);
        var result = new List<OrderDto>();
        foreach (var order in orders)
        {
            var customer = await _customerRepo.GetByIdAsync(order.CustomerId);
            var menuItems = await _orderRepo.GetAssignedMenuItemsAsync(order.Id);
            result.Add(MapToDto(order, customer, menuItems));
        }
        return result;
    }

    public async Task<OrderDto> GetByIdAsync(int id)
    {
        var order = await _orderRepo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Order {id} not found");
        var customer = await _customerRepo.GetByIdAsync(order.CustomerId);
        var menuItems = await _orderRepo.GetAssignedMenuItemsAsync(id);
        return MapToDto(order, customer, menuItems);
    }

    public async Task<OrderDto> CreateAsync(CreateOrderRequest request)
    {
        var customerId = await _customerRepo.UpsertByPhoneAsync(request.CustomerName, request.CustomerPhone);

        var entity = new OrderEntity
        {
            CustomerId = customerId,
            EventDate = request.EventDate,
            EventType = request.EventType,
            Location = request.Location,
            GuestCount = request.GuestCount,
            Budget = request.Budget,
            SpecialWishes = request.SpecialWishes,
            Allergies = request.Allergies,
            DishWishes = request.DishWishes,
            Status = "Neu"
        };

        var id = await _orderRepo.CreateAsync(entity);
        return await GetByIdAsync(id);
    }

    public async Task<OrderDto> CreateFromN8nAsync(N8nCreateOrderRequest request)
    {
        foreach (var item in request.OrderMenuItems)
        {
            var exists = await _menuItemRepo.GetByIdAsync(item.MenuItemId);
            if (exists == null)
                throw new KeyNotFoundException($"MenuItem {item.MenuItemId} not found");
        }

        var contact = request.Customer.TelegramChatId?.ToString() ?? request.Customer.Tel;
        var customerId = await _customerRepo.UpsertByPhoneAsync(request.Customer.Name, contact);

        var eventDate = request.Time.HasValue
            ? request.Date.Add(request.Time.Value)
            : request.Date;

        var entity = new OrderEntity
        {
            CustomerId = customerId,
            EventDate = eventDate,
            EventType = request.EventType,
            Location = request.Location ?? string.Empty,
            GuestCount = request.GuestCount,
            Budget = request.Budget,
            DishWishes = request.DishWishes,
            SpecialWishes = request.SpecialWishes,
            Allergies = request.Allergies,
            Status = "Neu"
        };

        var id = await _orderRepo.CreateAsync(entity);

        if (request.OrderMenuItems.Count > 0)
        {
            var items = request.OrderMenuItems
                .Select(m => (m.MenuItemId, m.Count))
                .ToList();
            await _orderRepo.SetMenuItemsWithCountAsync(id, items);
        }

        return await GetByIdAsync(id);
    }

    public async Task<OrderDto> UpdateAsync(int id, UpdateOrderRequest request)
    {
        var order = await _orderRepo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Order {id} not found");

        if (request.Status != null)
        {
            if (!ValidTransitions.TryGetValue(order.Status, out var allowed) || allowed != request.Status)
                throw new InvalidOperationException(
                    $"Statusübergang von '{order.Status}' nach '{request.Status}' ist nicht erlaubt.");

            await _orderRepo.UpdateStatusAsync(id, request.Status);

            if (request.Status == "Bestätigt")
            {
                await _purchaseListService.CreateForOrderAsync(id);
                await _orderRepo.UpdateStatusAsync(id, "InBeschaffung");
            }
        }

        // With-counts takes priority; fall back to plain ID list if only that is provided.
        if (request.AssignedMenuItemsWithCounts != null)
            await _orderRepo.SetMenuItemsWithCountAsync(id, request.AssignedMenuItemsWithCounts
                .Select(x => (x.MenuItemId, x.Count)).ToList().AsReadOnly());
        else if (request.AssignedMenuItemIds != null)
            await _orderRepo.SetMenuItemsAsync(id, request.AssignedMenuItemIds);

        if (request.CustomerName != null)
            await _customerRepo.UpdateAsync(order.CustomerId, request.CustomerName, request.CustomerPhone);

        if (request.GuestCount.HasValue || request.EventDate.HasValue || request.EventType != null
            || request.Location != null || request.Budget.HasValue || request.SpecialWishes != null
            || request.Allergies != null || request.DishWishes != null)
        {
            order.EventDate = request.EventDate ?? order.EventDate;
            order.GuestCount = request.GuestCount ?? order.GuestCount;
            order.EventType = request.EventType ?? order.EventType;
            order.Location = request.Location ?? order.Location;
            order.Budget = request.Budget ?? order.Budget;
            order.SpecialWishes = request.SpecialWishes ?? order.SpecialWishes;
            order.Allergies = request.Allergies ?? order.Allergies;
            order.DishWishes = request.DishWishes ?? order.DishWishes;
            await _orderRepo.UpdateAsync(order);
        }

        return await GetByIdAsync(id);
    }

    public async Task DeleteAsync(int id)
    {
        var order = await _orderRepo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Order {id} not found");

        if (order.Status != "Neu")
            throw new InvalidOperationException("Nur Aufträge im Status 'Neu' können gelöscht werden.");

        await _orderRepo.DeleteAsync(id);
    }

    // Phases a released/confirmed (or cancelled) order can be reopened from.
    private static readonly HashSet<string> ReopenableFrom =
        new() { "AngebotErstellt", "InBeschaffung", "Storniert" };

    // Phases an order may still be cancelled from (event not yet carried out).
    private static readonly HashSet<string> CancellableFrom =
        new() { "Neu", "Geprüft", "AngebotErstellt", "Bestätigt", "InBeschaffung", "InVorbereitung" };

    public async Task<OrderDto> ReopenAsync(int id)
    {
        var order = await _orderRepo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Order {id} not found");

        if (!ReopenableFrom.Contains(order.Status))
            throw new InvalidOperationException(
                $"Auftrag im Status '{order.Status}' kann nicht wiedereröffnet werden.");

        // Back to 'Geprüft' — menu and master data become editable again. The existing
        // quote / purchase list are kept and overwritten on the next generate / confirm.
        await _orderRepo.UpdateStatusAsync(id, "Geprüft");
        return await GetByIdAsync(id);
    }

    public async Task<OrderDto> CancelAsync(int id)
    {
        var order = await _orderRepo.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Order {id} not found");

        if (!CancellableFrom.Contains(order.Status))
            throw new InvalidOperationException(
                $"Auftrag im Status '{order.Status}' kann nicht storniert werden.");

        await _orderRepo.UpdateStatusAsync(id, "Storniert");
        return await GetByIdAsync(id);
    }

    private static OrderDto MapToDto(OrderEntity order, CaterMate.Db.Entities.CustomerEntity? customer, IEnumerable<MenuItemEntity> menuItems) =>
        new()
        {
            Id = order.Id,
            CustomerId = order.CustomerId,
            CustomerName = customer?.Name ?? "",
            CustomerPhone = customer?.Phone,
            EventDate = order.EventDate,
            EventType = order.EventType,
            Location = order.Location,
            GuestCount = order.GuestCount,
            Budget = order.Budget,
            SpecialWishes = order.SpecialWishes,
            Allergies = order.Allergies,
            DishWishes = order.DishWishes,
            Status = order.Status,
            CreatedAt = order.CreatedAt,
            UpdatedAt = order.UpdatedAt,
            AssignedMenuItems = menuItems.Select(m => new AssignedMenuItemDto
            {
                Id = m.Id,
                Name = m.Name,
                Category = m.Category,
                SalesPricePerPerson = m.SalesPricePerPerson,
                Count = m.AssignedCount
            }).ToList()
        };
}
