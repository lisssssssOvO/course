using System;

namespace FinanceApp.API.Models;

public class Transaction
{
    public int Id { get; set; }
    public DateOnly Date { get; set; }
    public decimal Amount { get; set; }
    public string? Comment { get; set; }
    public int ExpenseItemId { get; set; }
    public virtual ExpenseItem ExpenseItem { get; set; } = null!;
}