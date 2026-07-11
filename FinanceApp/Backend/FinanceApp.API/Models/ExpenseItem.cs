namespace FinanceApp.API.Models;

public class ExpenseItem
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public int CategoryId { get; set; }
    public virtual Category Category { get; set; } = null!;
    public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
}