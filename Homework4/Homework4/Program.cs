using System;
using System.Collections;
using System.Collections.Generic;

public class SmartStack<T> : IEnumerable<T>
{
    private T[] _items;
    private int _count;

    // Конструктор без параметров (ёмкость 4)
    public SmartStack()
    {
        _items = new T[4];
        _count = 0;
    }

    // Конструктор с указанием ёмкости
    public SmartStack(int capacity)
    {
        if (capacity < 0)
            throw new ArgumentException("Ёмкость не может быть отрицательной");
        _items = new T[capacity];
        _count = 0;
    }

    // Конструктор из коллекции
    public SmartStack(IEnumerable<T> collection)
    {
        if (collection == null)
            throw new ArgumentNullException(nameof(collection));

        List<T> tempList = new List<T>(collection);
        _items = new T[tempList.Count];
        _count = tempList.Count;

        for (int i = 0; i < tempList.Count; i++)
        {
            _items[i] = tempList[i];
        }
    }

    public int Count => _count;
    public int Capacity => _items.Length;

    // Добавление элемента на вершину
    public void Push(T item)
    {
        if (_count == _items.Length)
        {
            T[] newArray = new T[_items.Length * 2];
            Array.Copy(_items, 0, newArray, 0, _count);
            _items = newArray;
        }
        _items[_count] = item;
        _count++;
    }

    // Добавление коллекции
    // При выводе через GetEnumerator() будут идти от вершины к основанию
    public void PushRange(IEnumerable<T> collection)
    {
        if (collection == null)
            throw new ArgumentNullException(nameof(collection));

        List<T> tempList = new List<T>(collection);
        int count = tempList.Count;

        if (count == 0)
            return;

        while (_count + count > _items.Length)
        {
            T[] newArray = new T[_items.Length * 2];
            Array.Copy(_items, 0, newArray, 0, _count);
            _items = newArray;
        }

        for (int i = 0; i < count; i++)
        {
            _items[_count] = tempList[i];
            _count++;
        }
    }

    // Удаление и возврат элемента с вершины
    public T Pop()
    {
        if (_count == 0)
            throw new InvalidOperationException("Стек пуст");

        _count--;
        T item = _items[_count];
        _items[_count] = default(T);
        return item;
    }

    // Просмотр вершины без удаления
    public T Peek()
    {
        if (_count == 0)
            throw new InvalidOperationException("Стек пуст");

        return _items[_count - 1];
    }

    // Проверка наличия элемента в стеке
    public bool Contains(T item)
    {
        EqualityComparer<T> comparer = EqualityComparer<T>.Default;
        for (int i = 0; i < _count; i++)
        {
            if (comparer.Equals(_items[i], item))
                return true;
        }
        return false;
    }

    public T this[int index]
    {
        get
        {
            if (index < 0 || index >= _count)
                throw new ArgumentOutOfRangeException(nameof(index), "Индекс вне границ стека");
            return _items[_count - 1 - index];
        }
        set
        {
            if (index < 0 || index >= _count)
                throw new ArgumentOutOfRangeException(nameof(index), "Индекс вне границ стека");
            _items[_count - 1 - index] = value;
        }
    }

    // Реализация IEnumerable - обход от вершины к основанию
    public IEnumerator<T> GetEnumerator()
    {
        for (int i = _count - 1; i >= 0; i--)
        {
            yield return _items[i];
        }
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }
}

class Program
{
    static void Main()
    {
        Console.WriteLine("Умный стек:\n");

        Console.WriteLine("1. Конструктор без параметров (ёмкость 4)");
        var stack = new SmartStack<int>();
        Console.WriteLine($"   Capacity: {stack.Capacity}, Count: {stack.Count}\n");

        Console.WriteLine("2. Конструктор с указанием ёмкости");
        var stackWithCapacity = new SmartStack<int>(10);
        Console.WriteLine($"   Capacity: {stackWithCapacity.Capacity}, Count: {stackWithCapacity.Count}\n");

        Console.WriteLine("3. Конструктор из коллекции IEnumerable<T>");
        var sourceList = new List<int> { 10, 20, 30, 40, 50 };
        var stackFromCollection = new SmartStack<int>(sourceList);
        Console.WriteLine($"   Исходная коллекция: {string.Join(", ", sourceList)}");
        Console.WriteLine($"   Стек (от вершины): {string.Join(", ", stackFromCollection)}\n");

        Console.WriteLine("4. Метод Push (с удвоением ёмкости)");
        var pushStack = new SmartStack<int>();
        for (int i = 1; i <= 10; i++)
        {
            pushStack.Push(i);
            Console.WriteLine($"   Push {i}: Count = {pushStack.Count}, Capacity = {pushStack.Capacity}");
        }
        Console.WriteLine();

        Console.WriteLine("5. Метод PushRange (добавление коллекции в обратном порядке)");
        var rangeStack = new SmartStack<int>();
        rangeStack.Push(1);
        rangeStack.Push(2);
        rangeStack.Push(3);
        Console.WriteLine($"   До PushRange: {string.Join(", ", rangeStack)}");

        var addList = new List<int> { 100, 200, 300 };
        rangeStack.PushRange(addList);
        Console.WriteLine($"   Добавляем: {string.Join(", ", addList)}");
        Console.WriteLine($"   После PushRange: {string.Join(", ", rangeStack)}\n");

        Console.WriteLine("6. Метод Pop (удаление с вершины)");
        var popStack = new SmartStack<int>();
        popStack.Push(1);
        popStack.Push(2);
        popStack.Push(3);
        Console.WriteLine($"   До Pop: {string.Join(", ", popStack)}");
        Console.WriteLine($"   Pop: {popStack.Pop()}");
        Console.WriteLine($"   Pop: {popStack.Pop()}");
        Console.WriteLine($"   После Pop: {string.Join(", ", popStack)}");
        Console.WriteLine($"   Count: {popStack.Count}, Capacity: {popStack.Capacity} (не уменьшилась)\n");

        Console.WriteLine("7. Метод Peek (просмотр вершины без удаления)");
        var peekStack = new SmartStack<int>();
        peekStack.Push(1);
        peekStack.Push(2);
        peekStack.Push(3);
        Console.WriteLine($"   Стек: {string.Join(", ", peekStack)}");
        Console.WriteLine($"   Peek: {peekStack.Peek()} (вершина)");
        Console.WriteLine($"   После Peek стек не изменился: {string.Join(", ", peekStack)}\n");

        Console.WriteLine("8. Метод Contains (проверка наличия элемента)");
        var containsStack = new SmartStack<int>();
        containsStack.Push(1);
        containsStack.Push(2);
        containsStack.Push(3);
        containsStack.Push(4);
        containsStack.Push(5);
        Console.WriteLine($"   Стек: {string.Join(", ", containsStack)}");
        Console.WriteLine($"   Contains(3): {containsStack.Contains(3)}");
        Console.WriteLine($"   Contains(99): {containsStack.Contains(99)}\n");

        Console.WriteLine("9. Свойство Count (количество элементов)");
        var countStack = new SmartStack<string>();
        Console.WriteLine($"   Пустой стек: Count = {countStack.Count}");
        countStack.Push("A");
        countStack.Push("B");
        countStack.Push("C");
        Console.WriteLine($"   После добавления 3 элементов: Count = {countStack.Count}");
        countStack.Pop();
        Console.WriteLine($"   После удаления 1 элемента: Count = {countStack.Count}\n");

        Console.WriteLine("10. Свойство Capacity (ёмкость внутреннего массива)");
        var capacityStack = new SmartStack<int>();
        Console.WriteLine($"   Начальная ёмкость: {capacityStack.Capacity}");
        for (int i = 1; i <= 10; i++)
        {
            capacityStack.Push(i);
            if (i == 5 || i == 9)
                Console.WriteLine($"   После Push {i}: Capacity = {capacityStack.Capacity}");
        }
        Console.WriteLine($"   Итоговая ёмкость: {capacityStack.Capacity}\n");

        Console.WriteLine("11. Реализация IEnumerable<T> (обход от вершины к основанию)");
        var enumStack = new SmartStack<int>();
        enumStack.Push(1);
        enumStack.Push(2);
        enumStack.Push(3);
        enumStack.Push(4);
        enumStack.Push(5);
        Console.Write("   Обход через foreach: ");
        foreach (var item in enumStack)
        {
            Console.Write($"{item} ");
        }
        Console.WriteLine("\n");

        Console.WriteLine("12. Индексатор (доступ по глубине: 0 - вершина)");
        var indexStack = new SmartStack<int>();
        indexStack.Push(10);
        indexStack.Push(20);
        indexStack.Push(30);
        indexStack.Push(40);
        indexStack.Push(50);
        Console.WriteLine($"   Стек: {string.Join(", ", indexStack)}");
        Console.WriteLine($"   indexStack[0] = {indexStack[0]} (вершина)");
        Console.WriteLine($"   indexStack[1] = {indexStack[1]}");
        Console.WriteLine($"   indexStack[2] = {indexStack[2]}");
        Console.WriteLine($"   indexStack[3] = {indexStack[3]}");
        Console.WriteLine($"   indexStack[4] = {indexStack[4]} (основание)");

        try
        {
            var empty = new SmartStack<int>();
            var value = empty[0];
        }
        catch (ArgumentOutOfRangeException ex)
        {
            Console.WriteLine($"   Ошибка при выходе за границы: {ex.Message}");
        }

        Console.WriteLine("\nПроверка исключений:");
        try
        {
            var empty = new SmartStack<int>();
            empty.Pop();
        }
        catch (InvalidOperationException ex)
        {
            Console.WriteLine($"   Pop из пустого стека: {ex.Message}");
        }

        try
        {
            var empty = new SmartStack<int>();
            empty.Peek();
        }
        catch (InvalidOperationException ex)
        {
            Console.WriteLine($"   Peek из пустого стека: {ex.Message}");
        }
    }
}