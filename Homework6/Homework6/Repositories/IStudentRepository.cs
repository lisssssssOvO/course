using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Homework6.Models;

namespace Homework6.Repositories
{
    public interface IStudentRepository
    {
        Task<IEnumerable<Student>> GetAllAsync();
        Task<Student> GetByIdAsync(Guid id);
        Task<Student> GetByEmailAsync(string email);
        Task AddAsync(Student student);
        Task UpdateAsync(Student student);
        Task DeleteAsync(Guid id);
    }
}