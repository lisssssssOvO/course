using Microsoft.EntityFrameworkCore;
using Homework6.Models;

namespace Homework6.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        public DbSet<Student> Students { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Student>(entity =>
            {
                entity.ToTable("students");

                entity.HasKey(e => e.StudentId);
                entity.Property(e => e.StudentId)
                    .HasColumnName("student_id")
                    .HasDefaultValueSql("uuid_generate_v4()");

                entity.Property(e => e.FirstName)
                    .HasColumnName("first_name")
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.LastName)
                    .HasColumnName("last_name")
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.Email)
                    .HasColumnName("email")
                    .HasMaxLength(100)
                    .IsRequired(false);

                entity.Property(e => e.Phone)
                    .HasColumnName("phone")
                    .HasMaxLength(20)
                    .IsRequired(false);

                entity.Property(e => e.BirthDate)
                    .HasColumnName("birth_date")
                    .IsRequired(false);

                entity.Property(e => e.RegistrationDate)
                    .HasColumnName("registration_date")
                    .HasDefaultValueSql("CURRENT_DATE")
                    .ValueGeneratedOnAdd();

                entity.Property(e => e.IsActive)
                    .HasColumnName("is_active")
                    .HasDefaultValue(true);

                entity.Property(e => e.CreatedAt)
                    .HasColumnName("created_at")
                    .HasDefaultValueSql("CURRENT_TIMESTAMP")
                    .ValueGeneratedOnAdd();

                entity.HasIndex(e => e.Email)
                    .IsUnique()
                    .HasFilter("\"email\" IS NOT NULL");
            });

            base.OnModelCreating(modelBuilder);
        }
    }
}