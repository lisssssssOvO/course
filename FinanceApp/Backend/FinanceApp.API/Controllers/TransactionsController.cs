using FinanceApp.API.DTOs;
using FinanceApp.API.Models;
using FinanceApp.API.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FinanceApp.API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class TransactionsController : ControllerBase
{
    private readonly AppDbContext _context;
    private const decimal MaxDailyAmount = 1000000m;

    public TransactionsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<TransactionDto>>> GetTransactions(
        [FromQuery] DateOnly? day,
        [FromQuery] string? month)
    {
        var query = _context.Transactions
            .Include(t => t.ExpenseItem)
            .ThenInclude(e => e.Category)
            .AsQueryable();

        if (day.HasValue)
            query = query.Where(t => t.Date == day.Value);

        if (!string.IsNullOrEmpty(month) && DateOnly.TryParse(month + "-01", out var monthDate))
        {
            var startDate = new DateOnly(monthDate.Year, monthDate.Month, 1);
            var endDate = startDate.AddMonths(1);
            query = query.Where(t => t.Date >= startDate && t.Date < endDate);
        }

        var transactions = await query
            .OrderByDescending(t => t.Date)
            .Select(t => new TransactionDto
            {
                Id = t.Id,
                Date = t.Date,
                Amount = t.Amount,
                Comment = t.Comment,
                ExpenseItemId = t.ExpenseItemId,
                ExpenseItemName = t.ExpenseItem.Name,
                CategoryName = t.ExpenseItem.Category.Name
            })
            .ToListAsync();

        return Ok(transactions);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<TransactionDto>> GetTransaction(int id)
    {
        var transaction = await _context.Transactions
            .Include(t => t.ExpenseItem)
            .ThenInclude(e => e.Category)
            .FirstOrDefaultAsync(t => t.Id == id);

        if (transaction == null)
            return NotFound();

        return Ok(new TransactionDto
        {
            Id = transaction.Id,
            Date = transaction.Date,
            Amount = transaction.Amount,
            Comment = transaction.Comment,
            ExpenseItemId = transaction.ExpenseItemId,
            ExpenseItemName = transaction.ExpenseItem.Name,
            CategoryName = transaction.ExpenseItem.Category.Name
        });
    }

    [HttpPost]
    public async Task<ActionResult<TransactionDto>> CreateTransaction(CreateTransactionDto dto)
    {
        var expenseItem = await _context.ExpenseItems
            .Include(e => e.Category)
            .FirstOrDefaultAsync(e => e.Id == dto.ExpenseItemId);

        if (expenseItem == null)
            return BadRequest("Статья расхода не найдена");

        if (!expenseItem.IsActive)
            return BadRequest("Нельзя выбрать неактивную статью");

        var dailyTotal = await _context.Transactions
            .Where(t => t.Date == dto.Date)
            .SumAsync(t => t.Amount);

        if (dailyTotal + dto.Amount > MaxDailyAmount)
            return BadRequest($"Превышен дневной лимит в {MaxDailyAmount} рублей");

        var transaction = new Transaction
        {
            Date = dto.Date,
            Amount = dto.Amount,
            Comment = dto.Comment,
            ExpenseItemId = dto.ExpenseItemId
        };

        _context.Transactions.Add(transaction);
        await _context.SaveChangesAsync();

        await _context.Entry(transaction)
            .Reference(t => t.ExpenseItem)
            .Query()
            .Include(e => e.Category)
            .LoadAsync();

        return CreatedAtAction(nameof(GetTransaction), new { id = transaction.Id }, new TransactionDto
        {
            Id = transaction.Id,
            Date = transaction.Date,
            Amount = transaction.Amount,
            Comment = transaction.Comment,
            ExpenseItemId = transaction.ExpenseItemId,
            ExpenseItemName = transaction.ExpenseItem.Name,
            CategoryName = transaction.ExpenseItem.Category.Name
        });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateTransaction(int id, UpdateTransactionDto dto)
    {
        var transaction = await _context.Transactions
            .Include(t => t.ExpenseItem)
            .FirstOrDefaultAsync(t => t.Id == id);

        if (transaction == null)
            return NotFound();

        if (!transaction.ExpenseItem.IsActive && dto.ExpenseItemId != transaction.ExpenseItemId)
            return BadRequest("Нельзя изменить статью, так как она стала неактивной");

        if (dto.ExpenseItemId != transaction.ExpenseItemId)
        {
            var newExpenseItem = await _context.ExpenseItems.FindAsync(dto.ExpenseItemId);
            if (newExpenseItem == null)
                return BadRequest("Новая статья не найдена");
            if (!newExpenseItem.IsActive)
                return BadRequest("Нельзя выбрать неактивную статью");
        }

        var dailyTotal = await _context.Transactions
            .Where(t => t.Date == dto.Date && t.Id != id)
            .SumAsync(t => t.Amount);

        if (dailyTotal + dto.Amount > MaxDailyAmount)
            return BadRequest($"Превышен дневной лимит в {MaxDailyAmount} рублей");

        transaction.Date = dto.Date;
        transaction.Amount = dto.Amount;
        transaction.Comment = dto.Comment;
        transaction.ExpenseItemId = dto.ExpenseItemId;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTransaction(int id)
    {
        var transaction = await _context.Transactions.FindAsync(id);
        if (transaction == null)
            return NotFound();

        _context.Transactions.Remove(transaction);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("stats")]
    public async Task<ActionResult<DailyStatsDto>> GetDailyStats([FromQuery] DateOnly date)
    {
        var total = await _context.Transactions
            .Where(t => t.Date == date)
            .SumAsync(t => t.Amount);

        string status, message;

        if (total < 500)
        {
            status = "Green";
            message = "День прошел экономно!";
        }
        else if (total >= 500 && total <= 2000)
        {
            status = "Yellow";
            message = "Траты в пределах обычного";
        }
        else
        {
            status = "Red";
            message = "День был затратным!";
        }

        return Ok(new DailyStatsDto
        {
            Date = date,
            TotalAmount = total,
            Status = status,
            Message = message
        });
    }
}