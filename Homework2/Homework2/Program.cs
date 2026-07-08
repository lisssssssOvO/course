using System;

public class Program
{
    public static void PrintDiamond(int N)
    {
        if (N <= 0 || N % 2 == 0)
        {
            Console.WriteLine("N должно быть положительным нечётным числом");
            return;
        }

        int center = N / 2;

        for (int i = 0; i < N; i++)
        {
            int spaces = Math.Abs(center - i);
            int middle = N - 2 - spaces * 2;

            Console.Write(new string(' ', spaces) + "X");

            if (middle > 0)
            {
                Console.Write(new string(' ', middle) + "X");
            }

            Console.WriteLine();
        }
    }

    public static void Main()
    {
        PrintDiamond(5);
    }
}