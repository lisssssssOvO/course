using System;
using System.Text;

namespace CompoundInterestCalculator
{
    class Program
    {
        static void Main(string[] args)
        {
            string result = CalculateCompoundInterest(1000, 3, 10);
            Console.WriteLine(result);
            Console.ReadKey();
        }

        public static string CalculateCompoundInterest(double initialDeposit, int years, double interestRate)
        {
            var result = new StringBuilder();
            double currentAmount = initialDeposit;

            for (int year = 1; year <= years; year++)
            {
                currentAmount *= (1 + interestRate / 100);
                result.AppendLine($"Год {year}: {currentAmount:F2} руб.");
            }

            return result.ToString().TrimEnd();
        }
    }
}