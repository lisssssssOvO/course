using FinanceApp.API.DTOs;
using FinanceApp.API.Models;
using FinanceApp.API.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FinanceApp.API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ExpenseItemsController : ControllerBase
{
    private readonly AppDbContext _context;

    public ExpenseItemsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ExpenseItemDto>>> GetExpenseItems()
    {
        var items = await _context.ExpenseItems
            .Include(e => e.Category)
            .Select(e => new ExpenseItemDto
            {
                Id = e.Id,
                Name = e.Name,
                IsActive = e.IsActive,
                CategoryId = e.CategoryId,
                CategoryName = e.Category.Name
            })
            .ToListAsync();

        return Ok(items);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ExpenseItemDto>> GetExpenseItem(int id)
    {
        var item = await _context.ExpenseItems
            .Include(e => e.Category)
            .FirstOrDefaultAsync(e => e.Id == id);

        if (item == null)
            return NotFound();

        return Ok(new ExpenseItemDto
        {
            Id = item.Id,
            Name = item.Name,
            IsActive = item.IsActive,
            CategoryId = item.CategoryId,
            CategoryName = item.Category.Name
        });
    }

    [HttpPost]
    public async Task<ActionResult<ExpenseItemDto>> CreateExpenseItem(CreateExpenseItemDto dto)
    {
        var category = await _context.Categories.FindAsync(dto.CategoryId);
        if (category == null)
            return BadRequest("Категория не найдена");

        var item = new ExpenseItem
        {
            Name = dto.Name,
            IsActive = dto.IsActive,
            CategoryId = dto.CategoryId
        };

        _context.ExpenseItems.Add(item);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetExpenseItem), new { id = item.Id }, new ExpenseItemDto
        {
            Id = item.Id,
            Name = item.Name,
            IsActive = item.IsActive,
            CategoryId = item.CategoryId,
            CategoryName = category.Name
        });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateExpenseItem(int id, UpdateExpenseItemDto dto)
    {
        var item = await _context.ExpenseItems.FindAsync(id);
        if (item == null)
            return NotFound();

        var category = await _context.Categories.FindAsync(dto.CategoryId);
        if (category == null)
            return BadRequest("Категория не найдена");

        item.Name = dto.Name;
        item.IsActive = dto.IsActive;
        item.CategoryId = dto.CategoryId;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteExpenseItem(int id)
    {
        var item = await _context.ExpenseItems.FindAsync(id);
        if (item == null)
            return NotFound();

        var hasTransactions = await _context.Transactions.AnyAsync(t => t.ExpenseItemId == id);
        if (hasTransactions)
            return BadRequest("Нельзя удалить статью с транзакциями");

        _context.ExpenseItems.Remove(item);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}