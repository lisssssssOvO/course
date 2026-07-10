using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Homework6.Models;
using Homework6.Data;

namespace Homework6.Repositories
{
    public class StudentRepositoryEf : IStudentRepository
    {
        private readonly AppDbContext _context;

        public StudentRepositoryEf(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Student>> GetAllAsync()
        {
            return await _context.Students
                .Where(s => s.IsActive)
                .OrderBy(s => s.LastName)
                .ThenBy(s => s.FirstName)
                .ToListAsync();
        }

        public async Task<Student> GetByIdAsync(Guid id)
        {
            return await _context.Students
                .FirstOrDefaultAsync(s => s.StudentId == id && s.IsActive);
        }

        public async Task<Student> GetByEmailAsync(string email)
        {
            return await _context.Students
                .FirstOrDefaultAsync(s => s.Email == email && s.IsActive);
        }

        public async Task AddAsync(Student student)
        {
            student.IsActive = true;
            _context.Students.Add(student);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Student student)
        {
            var existing = await _context.Students.FindAsync(student.StudentId);
            if (existing == null)
                throw new Exception("Ученик не найден");

            existing.FirstName = student.FirstName;
            existing.LastName = student.LastName;
            existing.Email = student.Email;
            existing.Phone = student.Phone;
            existing.BirthDate = student.BirthDate;

            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Guid id)
        {
            var student = await _context.Students.FindAsync(id);
            if (student != null)
            {
                student.IsActive = false;
                await _context.SaveChangesAsync();
            }
        }
    }
}