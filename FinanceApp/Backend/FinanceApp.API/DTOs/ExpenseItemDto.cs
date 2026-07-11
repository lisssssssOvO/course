namespace FinanceApp.API.DTOs;

public class ExpenseItemDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
}

public class CreateExpenseItemDto
{
    public string Name { get; set; } = string.Empty;
    public int CategoryId { get; set; }
    public bool IsActive { get; set; } = true;
}

public class UpdateExpenseItemDto
{
    public string Name { get; set; } = string.Empty;
    public int CategoryId { get; set; }
    public bool IsActive { get; set; }
}