using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Npgsql;
using Homework6.Models;

namespace Homework6.Repositories
{
    public class StudentRepositoryAdo : IStudentRepository
    {
        private readonly string _connectionString;

        public StudentRepositoryAdo(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<Student>> GetAllAsync()
        {
            var students = new List<Student>();
            const string sql = @"
                SELECT student_id, first_name, last_name, email, phone, 
                       birth_date, registration_date, is_active, created_at
                FROM students
                WHERE is_active = true
                ORDER BY last_name, first_name";

            using var connection = new NpgsqlConnection(_connectionString);
            using var command = new NpgsqlCommand(sql, connection);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                students.Add(MapToStudent(reader));
            }

            return students;
        }

        public async Task<Student> GetByIdAsync(Guid id)
        {
            const string sql = @"
                SELECT student_id, first_name, last_name, email, phone, 
                       birth_date, registration_date, is_active, created_at
                FROM students
                WHERE student_id = @StudentId AND is_active = true";

            using var connection = new NpgsqlConnection(_connectionString);
            using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddWithValue("@StudentId", id);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                return MapToStudent(reader);
            }

            return null;
        }

        public async Task<Student> GetByEmailAsync(string email)
        {
            const string sql = @"
                SELECT student_id, first_name, last_name, email, phone, 
                       birth_date, registration_date, is_active, created_at
                FROM students
                WHERE email = @Email AND is_active = true";

            using var connection = new NpgsqlConnection(_connectionString);
            using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddWithValue("@Email", email);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                return MapToStudent(reader);
            }

            return null;
        }

        public async Task AddAsync(Student student)
        {
            const string sql = @"
                INSERT INTO students (student_id, first_name, last_name, email, phone, birth_date, is_active)
                VALUES (@StudentId, @FirstName, @LastName, @Email, @Phone, @BirthDate, @IsActive)";

            using var connection = new NpgsqlConnection(_connectionString);
            using var command = new NpgsqlCommand(sql, connection);

            command.Parameters.AddWithValue("@StudentId", student.StudentId);
            command.Parameters.AddWithValue("@FirstName", student.FirstName);
            command.Parameters.AddWithValue("@LastName", student.LastName);
            command.Parameters.AddWithValue("@Email", student.Email ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@Phone", student.Phone ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@BirthDate", student.BirthDate ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@IsActive", student.IsActive);

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
        }

        public async Task UpdateAsync(Student student)
        {
            const string sql = @"
                UPDATE students
                SET first_name = @FirstName,
                    last_name = @LastName,
                    email = @Email,
                    phone = @Phone,
                    birth_date = @BirthDate,
                    is_active = @IsActive
                WHERE student_id = @StudentId";

            using var connection = new NpgsqlConnection(_connectionString);
            using var command = new NpgsqlCommand(sql, connection);

            command.Parameters.AddWithValue("@FirstName", student.FirstName);
            command.Parameters.AddWithValue("@LastName", student.LastName);
            command.Parameters.AddWithValue("@Email", student.Email ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@Phone", student.Phone ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@BirthDate", student.BirthDate ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@IsActive", student.IsActive);
            command.Parameters.AddWithValue("@StudentId", student.StudentId);

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
        }

        public async Task DeleteAsync(Guid id)
        {
            const string sql = @"
                UPDATE students
                SET is_active = false
                WHERE student_id = @StudentId";

            using var connection = new NpgsqlConnection(_connectionString);
            using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddWithValue("@StudentId", id);

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
        }

        private static Student MapToStudent(NpgsqlDataReader reader)
        {
            DateTime registrationDate;
            try
            {
                registrationDate = reader.GetDateTime(reader.GetOrdinal("registration_date"));
                if (registrationDate.Year < 1900)
                {
                    registrationDate = DateTime.UtcNow;
                }
            }
            catch
            {
                registrationDate = DateTime.UtcNow;
            }

            DateTime createdAt;
            try
            {
                createdAt = reader.GetDateTime(reader.GetOrdinal("created_at"));
                if (createdAt.Year < 1900)
                {
                    createdAt = DateTime.UtcNow;
                }
            }
            catch
            {
                createdAt = DateTime.UtcNow;
            }

            return new Student
            {
                StudentId = reader.GetGuid(reader.GetOrdinal("student_id")),
                FirstName = reader.GetString(reader.GetOrdinal("first_name")),
                LastName = reader.GetString(reader.GetOrdinal("last_name")),
                Email = reader.IsDBNull(reader.GetOrdinal("email")) ? null : reader.GetString(reader.GetOrdinal("email")),
                Phone = reader.IsDBNull(reader.GetOrdinal("phone")) ? null : reader.GetString(reader.GetOrdinal("phone")),
                BirthDate = reader.IsDBNull(reader.GetOrdinal("birth_date")) ? null : reader.GetDateTime(reader.GetOrdinal("birth_date")),
                RegistrationDate = registrationDate,
                IsActive = reader.GetBoolean(reader.GetOrdinal("is_active")),
                CreatedAt = createdAt
            };
        }
    }
}