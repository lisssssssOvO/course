-- Выборка данных с фильтрацией, сортировкой
-- Активные ученики (фильтрация + сортировка по фамилии)
SELECT first_name, last_name, email, registration_date
FROM students
WHERE is_active = TRUE
ORDER BY last_name ASC, first_name ASC;

-- Стили танцев с уровнем сложности 3 и выше
SELECT style_name, difficulty_level, description
FROM dance_styles
WHERE difficulty_level >= 3 AND is_active = TRUE
ORDER BY difficulty_level DESC;

-- Группы с максимальным количеством учеников >= 10
SELECT group_name, max_students, schedule_day, schedule_time
FROM groups
WHERE max_students >= 10 AND is_active = TRUE
ORDER BY max_students DESC;

-- Ученики с датой рождения после 2000 года
SELECT first_name, last_name, birth_date
FROM students
WHERE birth_date >= '2000-01-01'
ORDER BY birth_date;

-- Удаление, изменение данных
-- Повышение абонентской платы для всех групп
UPDATE student_groups
SET monthly_fee = monthly_fee * 1.1;

-- Деактивация ученика
UPDATE students
SET is_active = FALSE
WHERE first_name = 'Иван' AND last_name = 'Смирнов';

-- Обновление уровня сложности стиля
UPDATE dance_styles
SET difficulty_level = 4
WHERE style_name = 'Сальса';

-- Удаление неактивных групп (старше 1 года)
DELETE FROM groups
WHERE is_active = FALSE AND created_at < CURRENT_DATE - INTERVAL '1 year';

-- Обновление способа оплаты для всех платежей
UPDATE payments
SET payment_method = 'Online'
WHERE payment_method = 'Cash';

-- Выборка с группировкой
-- Количество учеников по стилям танцев
SELECT ds.style_name, COUNT(sg.student_id) AS total_students
FROM groups g
JOIN dance_styles ds ON g.style_id = ds.style_id
LEFT JOIN student_groups sg ON g.group_id = sg.group_id
WHERE sg.is_active = TRUE
GROUP BY ds.style_name
ORDER BY total_students DESC;

-- Общая сумма платежей по месяцам
SELECT 
    EXTRACT(YEAR FROM payment_date) AS year,
    EXTRACT(MONTH FROM payment_date) AS month,
    SUM(amount) AS total_amount,
    COUNT(*) AS payment_count
FROM payments
WHERE is_paid = TRUE
GROUP BY year, month
ORDER BY year DESC, month DESC;

-- Количество групп у каждого преподавателя
SELECT 
    t.first_name || ' ' || t.last_name AS teacher_name,
    COUNT(g.group_id) AS group_count
FROM teachers t
LEFT JOIN groups g ON t.teacher_id = g.teacher_id AND g.is_active = TRUE
GROUP BY t.teacher_id, t.first_name, t.last_name
ORDER BY group_count DESC;

-- Средняя плата по стилям танцев
SELECT 
    ds.style_name,
    AVG(sg.monthly_fee) AS avg_monthly_fee,
    MIN(sg.monthly_fee) AS min_fee,
    MAX(sg.monthly_fee) AS max_fee
FROM groups g
JOIN dance_styles ds ON g.style_id = ds.style_id
JOIN student_groups sg ON g.group_id = sg.group_id
WHERE sg.is_active = TRUE
GROUP BY ds.style_name
ORDER BY avg_monthly_fee DESC;

-- Топ-5 учеников по общей сумме платежей
SELECT 
    s.first_name || ' ' || s.last_name AS student,
    SUM(p.amount) AS total_paid
FROM students s
JOIN payments p ON s.student_id = p.student_id
WHERE p.is_paid = TRUE
GROUP BY s.student_id, s.first_name, s.last_name
ORDER BY total_paid DESC
LIMIT 5;

-- Выборка из нескольких связанных таблиц
-- Левое соединение: все группы и их преподаватели
SELECT 
    g.group_name,
    t.first_name || ' ' || t.last_name AS teacher_name,
    ds.style_name
FROM groups g
LEFT JOIN teachers t ON g.teacher_id = t.teacher_id
LEFT JOIN dance_styles ds ON g.style_id = ds.style_id
ORDER BY g.group_name;

-- Правое соединение: все ученики и их группы
SELECT 
    s.first_name || ' ' || s.last_name AS student_name,
    g.group_name
FROM student_groups sg
RIGHT JOIN students s ON sg.student_id = s.student_id
LEFT JOIN groups g ON sg.group_id = g.group_id
WHERE s.is_active = TRUE
ORDER BY student_name;

-- Пересечение: ученики и их платежи
SELECT 
    s.first_name || ' ' || s.last_name AS student,
    p.amount,
    p.payment_date,
    p.payment_method
FROM students s
INNER JOIN payments p ON s.student_id = p.student_id
WHERE p.is_paid = TRUE
ORDER BY p.payment_date DESC;

-- Полная информация: ученики -> группы -> стили -> преподаватели
SELECT 
    s.first_name || ' ' || s.last_name AS student,
    ds.style_name,
    g.group_name,
    t.first_name || ' ' || t.last_name AS teacher,
    sg.monthly_fee,
    sg.enrollment_date
FROM students s
INNER JOIN student_groups sg ON s.student_id = sg.student_id
INNER JOIN groups g ON sg.group_id = g.group_id
INNER JOIN dance_styles ds ON g.style_id = ds.style_id
LEFT JOIN teachers t ON g.teacher_id = t.teacher_id
WHERE s.is_active = TRUE AND sg.is_active = TRUE
ORDER BY sg.enrollment_date DESC;

-- Ученики, которые не платили более 30 дней
SELECT 
    s.first_name || ' ' || s.last_name AS student,
    MAX(p.payment_date) AS last_payment
FROM students s
LEFT JOIN payments p ON s.student_id = p.student_id
WHERE p.is_paid = TRUE
GROUP BY s.student_id, s.first_name, s.last_name
HAVING MAX(p.payment_date) < CURRENT_DATE - INTERVAL '30 days'
OR MAX(p.payment_date) IS NULL;

-- Группы с наибольшим количеством учеников
SELECT 
    g.group_name,
    COUNT(sg.student_id) AS student_count,
    ds.style_name
FROM groups g
JOIN dance_styles ds ON g.style_id = ds.style_id
JOIN student_groups sg ON g.group_id = sg.group_id
WHERE sg.is_active = TRUE
GROUP BY g.group_id, g.group_name, ds.style_name
ORDER BY student_count DESC
LIMIT 5;