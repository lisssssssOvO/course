using System;

namespace FinanceApp.API.DTOs;

public class TransactionDto
{
    public int Id { get; set; }
    public DateOnly Date { get; set; }
    public decimal Amount { get; set; }
    public string? Comment { get; set; }
    public int ExpenseItemId { get; set; }
    public string ExpenseItemName { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
}

public class CreateTransactionDto
{
    public DateOnly Date { get; set; }
    public decimal Amount { get; set; }
    public string? Comment { get; set; }
    public int ExpenseItemId { get; set; }
}

public class UpdateTransactionDto
{
    public DateOnly Date { get; set; }
    public decimal Amount { get; set; }
    public string? Comment { get; set; }
    public int ExpenseItemId { get; set; }
}

public class DailyStatsDto
{
    public DateOnly Date { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}