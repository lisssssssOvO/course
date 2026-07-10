using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using System.IO;
using System.Linq;
using Homework6.Models;
using Homework6.Data;
using Homework6.Repositories;

namespace Homework6
{
    class Program
    {
        private static string _connectionString;
        private static bool _useEF = false;

        static async Task Main(string[] args)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);

            var configuration = builder.Build();
            _connectionString = configuration.GetConnectionString("DefaultConnection");

            string methodChoice;
            while (true)
            {
                Console.WriteLine("Выберите способ работы с БД:");
                Console.WriteLine("1 - ADO.NET");
                Console.WriteLine("2 - Entity Framework");
                Console.Write("Выбор: ");

                methodChoice = Console.ReadLine();

                if (methodChoice == "1")
                {
                    _useEF = false;
                    break;
                }
                else if (methodChoice == "2")
                {
                    _useEF = true;
                    break;
                }
                else
                {
                    Console.WriteLine("Неверный ввод. Введите 1 или 2.\n");
                }
            }

            while (true)
            {
                Console.WriteLine("\nМеню:");
                Console.WriteLine("1 - Список учеников");
                Console.WriteLine("2 - Добавить ученика");
                Console.WriteLine("3 - Обновить ученика");
                Console.WriteLine("4 - Удалить ученика");
                Console.WriteLine("5 - Поиск по email");
                Console.WriteLine("6 - Выход");
                Console.Write("Выбор: ");

                var choice = Console.ReadLine();

                switch (choice)
                {
                    case "1": await ListStudents(); break;
                    case "2": await AddStudent(); break;
                    case "3": await UpdateStudent(); break;
                    case "4": await DeleteStudent(); break;
                    case "5": await SearchStudent(); break;
                    case "6": return;
                    default: Console.WriteLine("Неверный выбор"); break;
                }
            }
        }

        static IStudentRepository GetRepository()
        {
            if (_useEF)
            {
                var options = new DbContextOptionsBuilder<AppDbContext>()
                    .UseNpgsql(_connectionString)
                    .Options;
                var context = new AppDbContext(options);
                return new StudentRepositoryEf(context);
            }
            else
            {
                return new StudentRepositoryAdo(_connectionString);
            }
        }

        static async Task ListStudents()
        {
            var repo = GetRepository();
            var students = await repo.GetAllAsync();

            Console.WriteLine($"\nВсего учеников: {students.Count()}");
            foreach (var s in students)
            {
                var email = s.Email ?? "Не указан";
                var phone = s.Phone ?? "Не указан";
                var birthDate = s.BirthDate.HasValue ? s.BirthDate.Value.ToString("dd.MM.yyyy") : "Не указана";

                Console.WriteLine($"{s.FirstName} {s.LastName} | Email: {email} | Телефон: {phone} | Дата рождения: {birthDate} | Дата регистрации: {s.RegistrationDate:dd.MM.yyyy}");
            }
        }

        static async Task AddStudent()
        {
            Console.Write("Имя: ");
            var firstName = Console.ReadLine();

            Console.Write("Фамилия: ");
            var lastName = Console.ReadLine();

            Console.Write("Email: ");
            var email = Console.ReadLine();

            Console.Write("Телефон: ");
            var phone = Console.ReadLine();

            Console.Write("Дата рождения (дд.мм.гггг): ");
            var birthDateInput = Console.ReadLine();
            DateTime? birthDate = null;
            if (!string.IsNullOrEmpty(birthDateInput))
            {
                if (DateTime.TryParseExact(birthDateInput, "dd.MM.yyyy", null,
                    System.Globalization.DateTimeStyles.None, out var bd))
                {
                    birthDate = DateTime.SpecifyKind(bd, DateTimeKind.Utc);
                }
            }

            var student = new Student
            {
                StudentId = Guid.NewGuid(),
                FirstName = firstName,
                LastName = lastName,
                Email = string.IsNullOrEmpty(email) ? null : email,
                Phone = string.IsNullOrEmpty(phone) ? null : phone,
                BirthDate = birthDate,
                IsActive = true
            };

            var repo = GetRepository();
            await repo.AddAsync(student);
            Console.WriteLine("Ученик добавлен!");
        }

        static async Task UpdateStudent()
        {
            Console.Write("ID ученика (GUID): ");
            var id = Guid.Parse(Console.ReadLine());

            var repo = GetRepository();
            var student = await repo.GetByIdAsync(id);

            if (student == null)
            {
                Console.WriteLine("Ученик не найден");
                return;
            }

            Console.WriteLine($"\nТекущие данные:");
            Console.WriteLine($"Имя: {student.FirstName}");
            Console.WriteLine($"Фамилия: {student.LastName}");
            Console.WriteLine($"Email: {student.Email}");
            Console.WriteLine($"Телефон: {student.Phone ?? "Не указан"}");
            Console.WriteLine($"Дата рождения: {(student.BirthDate.HasValue ? student.BirthDate.Value.ToString("dd.MM.yyyy") : "Не указана")}");

            Console.WriteLine("\nВведите новые данные (или оставьте пустым, чтобы не менять):");

            Console.Write($"Имя ({student.FirstName}): ");
            var firstName = Console.ReadLine();
            if (!string.IsNullOrEmpty(firstName)) student.FirstName = firstName;

            Console.Write($"Фамилия ({student.LastName}): ");
            var lastName = Console.ReadLine();
            if (!string.IsNullOrEmpty(lastName)) student.LastName = lastName;

            Console.Write($"Email ({student.Email}): ");
            var email = Console.ReadLine();
            if (!string.IsNullOrEmpty(email)) student.Email = email;

            Console.Write($"Телефон ({student.Phone ?? "Не указан"}): ");
            var phone = Console.ReadLine();
            if (!string.IsNullOrEmpty(phone)) student.Phone = phone;

            Console.Write($"Дата рождения ({(student.BirthDate.HasValue ? student.BirthDate.Value.ToString("dd.MM.yyyy") : "Не указана")}): ");
            var birthDateInput = Console.ReadLine();
            if (!string.IsNullOrEmpty(birthDateInput))
            {
                if (DateTime.TryParseExact(birthDateInput, "dd.MM.yyyy", null,
                    System.Globalization.DateTimeStyles.None, out var birthDate))
                {
                    student.BirthDate = DateTime.SpecifyKind(birthDate, DateTimeKind.Utc);
                }
                else
                {
                    Console.WriteLine("Неверный формат даты. Используйте дд.мм.гггг");
                    return;
                }
            }

            await repo.UpdateAsync(student);
            Console.WriteLine("Ученик обновлён!");
        }

        static async Task DeleteStudent()
        {
            Console.Write("ID ученика (GUID): ");
            var id = Guid.Parse(Console.ReadLine());

            var repo = GetRepository();
            await repo.DeleteAsync(id);

            Console.WriteLine("Ученик деактивирован!");
        }

        static async Task SearchStudent()
        {
            Console.Write("Email для поиска: ");
            var email = Console.ReadLine();

            var repo = GetRepository();
            var student = await repo.GetByEmailAsync(email);

            if (student != null)
            {
                Console.WriteLine($"Найден: {student.FirstName} {student.LastName}");
                Console.WriteLine($"Email: {student.Email ?? "Не указан"}");
                Console.WriteLine($"Телефон: {student.Phone ?? "Нет"}");
                Console.WriteLine($"Дата рождения: {(student.BirthDate.HasValue ? student.BirthDate.Value.ToString("dd.MM.yyyy") : "Не указана")}");
            }
            else
            {
                Console.WriteLine("Ученик не найден");
            }
        }
    }
}