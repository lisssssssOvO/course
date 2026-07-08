using System;
using System.Collections.Generic;

namespace ProductManagement
{
    public class Product
    {
        private string _name;
        private string _manufacturer;
        private decimal _price;
        private DateTime _productionDate;
        private DateTime _expiryDate;

        public Product(string name, string manufacturer, decimal price,
                       DateTime productionDate, DateTime expiryDate)
        {
            Name = name;
            Manufacturer = manufacturer;
            Price = price;
            ProductionDate = productionDate;
            ExpiryDate = expiryDate;
        }

        public string Name
        {
            get => _name;
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                    throw new ArgumentException("Название не может быть пустым");
                _name = value;
            }
        }

        public string Manufacturer
        {
            get => _manufacturer;
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                    throw new ArgumentException("Производитель не может быть пустым");
                _manufacturer = value;
            }
        }

        public decimal Price
        {
            get => _price;
            set
            {
                if (value < 0)
                    throw new ArgumentException("Цена не может быть отрицательной");
                _price = value;
            }
        }

        public DateTime ProductionDate
        {
            get => _productionDate;
            set
            {
                if (value > DateTime.Now)
                    throw new ArgumentException("Дата производства не может быть в будущем");
                _productionDate = value;
            }
        }

        public DateTime ExpiryDate
        {
            get => _expiryDate;
            set
            {
                if (value < ProductionDate)
                    throw new ArgumentException("Срок годности не может быть раньше даты производства");
                _expiryDate = value;
            }
        }

        public override string ToString()
        {
            return $"Название: {Name}\n" +
                   $"Производитель: {Manufacturer}\n" +
                   $"Цена: {Price:F2} руб.\n" +
                   $"Дата производства: {ProductionDate:dd.MM.yyyy}\n" +
                   $"Срок годности: {ExpiryDate:dd.MM.yyyy}";
        }
    }

    public class DiscountedProduct : Product
    {
        private int _discountPercent;

        public DiscountedProduct(string name, string manufacturer, decimal price,
                                DateTime productionDate, DateTime expiryDate, int discountPercent)
            : base(name, manufacturer, price, productionDate, expiryDate)
        {
            DiscountPercent = discountPercent;
        }

        public int DiscountPercent
        {
            get => _discountPercent;
            set
            {
                if (value < 0 || value > 100)
                    throw new ArgumentException("Скидка должна быть от 0 до 100%");
                _discountPercent = value;
            }
        }

        public decimal DiscountedPrice
        {
            get
            {
                return Price * (1 - (decimal)DiscountPercent / 100);
            }
        }

        public override string ToString()
        {
            return base.ToString() +
                   $"\nСкидка: {DiscountPercent}%\n" +
                   $"Цена со скидкой: {DiscountedPrice:F2} руб.";
        }
    }

    class Program
    {
        static void Main()
        {
            List<Product> products = new List<Product>();

            while (true)
            {
                Console.WriteLine("\nУправление товарами:");
                Console.WriteLine("1 - Добавить товар");
                Console.WriteLine("2 - Добавить товар со скидкой");
                Console.WriteLine("3 - Показать все товары");
                Console.WriteLine("4 - Выход");
                Console.Write("Выбор: ");

                string choice = Console.ReadLine();

                if (choice == "4") break;

                switch (choice)
                {
                    case "1":
                        try
                        {
                            products.Add(CreateProduct(false));
                            Console.WriteLine("Товар добавлен!");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"Ошибка: {ex.Message}");
                        }
                        break;

                    case "2":
                        try
                        {
                            products.Add(CreateProduct(true));
                            Console.WriteLine("Товар со скидкой добавлен!");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"Ошибка: {ex.Message}");
                        }
                        break;

                    case "3":
                        ShowAll(products);
                        break;

                    default:
                        Console.WriteLine("Неверный ввод");
                        break;
                }
            }
        }

        static Product CreateProduct(bool withDiscount)
        {
            Console.Write("Название: ");
            string name = Console.ReadLine();

            Console.Write("Производитель: ");
            string manufacturer = Console.ReadLine();

            Console.Write("Цена: ");
            decimal price = decimal.Parse(Console.ReadLine());

            Console.Write("Дата производства (дд.мм.гггг): ");
            DateTime prodDate = DateTime.ParseExact(Console.ReadLine(), "dd.MM.yyyy", null);

            Console.Write("Срок годности (дд.мм.гггг): ");
            DateTime expDate = DateTime.ParseExact(Console.ReadLine(), "dd.MM.yyyy", null);

            if (withDiscount)
            {
                Console.Write("Скидка (%): ");
                int discount = int.Parse(Console.ReadLine());
                return new DiscountedProduct(name, manufacturer, price, prodDate, expDate, discount);
            }

            return new Product(name, manufacturer, price, prodDate, expDate);
        }

        static void ShowAll(List<Product> products)
        {
            if (products.Count == 0)
            {
                Console.WriteLine("\nНет товаров");
                return;
            }

            Console.WriteLine("\nСписок товаров:\n");
            for (int i = 0; i < products.Count; i++)
            {
                Console.WriteLine($"Товар #{i + 1}:");
                Console.WriteLine(products[i]);
                Console.WriteLine(new string('-', 30));
            }
        }
    }
}