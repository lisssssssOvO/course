using FinanceApp.API.Models;
using Microsoft.EntityFrameworkCore;

namespace FinanceApp.API.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Category> Categories { get; set; }
    public DbSet<ExpenseItem> ExpenseItems { get; set; }
    public DbSet<Transaction> Transactions { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Transaction>()
            .Property(t => t.Amount)
            .HasPrecision(18, 2);

        modelBuilder.Entity<Category>()
            .Property(c => c.Budget)
            .HasPrecision(18, 2);

        modelBuilder.Entity<ExpenseItem>()
            .HasIndex(e => e.CategoryId);

        modelBuilder.Entity<Transaction>()
            .HasIndex(t => t.ExpenseItemId);

        modelBuilder.Entity<Transaction>()
            .HasIndex(t => t.Date);
    }
}