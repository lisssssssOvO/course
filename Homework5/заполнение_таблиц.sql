-- Стили танцев
INSERT INTO dance_styles (style_name, description, difficulty_level, is_active) VALUES
('Бальные танцы', 'Классические европейские танцы: вальс, танго, фокстрот', 3, TRUE),
('Хип-хоп', 'Уличный стиль танца с элементами импровизации', 2, TRUE),
('Брейк-данс', 'Силовой акробатический стиль', 5, TRUE),
('Джаз-модерн', 'Современное направление с элементами классики', 3, TRUE),
('Сальса', 'Латиноамериканский парный танец', 2, TRUE),
('Бачата', 'Романтичный парный танец из Доминиканы', 2, TRUE),
('Кизомба', 'Ангольский парный танец с плавными движениями', 3, TRUE),
('Танцы на пилоне', 'Акробатика на вертикальном пилоне', 5, TRUE),
('Контемпорари', 'Современный танец с элементами импровизации', 4, TRUE),
('Фламенко', 'Испанский страстный танец', 4, TRUE);

-- Преподаватели
INSERT INTO teachers (first_name, last_name, email, phone, hire_date, is_active) VALUES
('Анна', 'Иванова', 'anna.i@dance.ru', '+7(999)111-22-33', '2020-01-15', TRUE),
('Максим', 'Петров', 'maxim.p@dance.ru', '+7(999)222-33-44', '2020-03-10', TRUE),
('Екатерина', 'Сидорова', 'ekaterina.s@dance.ru', '+7(999)333-44-55', '2021-06-01', TRUE),
('Дмитрий', 'Козлов', 'dmitry.k@dance.ru', '+7(999)444-55-66', '2021-09-15', TRUE),
('Ольга', 'Морозова', 'olga.m@dance.ru', '+7(999)555-66-77', '2022-01-20', TRUE),
('Алексей', 'Волков', 'alexey.v@dance.ru', '+7(999)666-77-88', '2022-05-10', TRUE),
('Марина', 'Павлова', 'marina.p@dance.ru', '+7(999)777-88-99', '2022-08-01', TRUE),
('Сергей', 'Новиков', 'sergey.n@dance.ru', '+7(999)888-99-00', '2023-01-15', TRUE),
('Наталья', 'Федорова', 'natalia.f@dance.ru', '+7(999)999-00-11', '2023-03-20', TRUE),
('Андрей', 'Михайлов', 'andrey.m@dance.ru', '+7(999)000-11-22', '2023-06-01', TRUE);

-- Ученики
INSERT INTO students (first_name, last_name, email, phone, birth_date, registration_date, is_active) VALUES
('Иван', 'Смирнов', 'ivan.smirnov@mail.ru', '+7(900)111-11-11', '2000-05-15', '2023-01-10', TRUE),
('Мария', 'Кузнецова', 'maria.kuz@mail.ru', '+7(900)222-22-22', '2001-08-20', '2023-01-15', TRUE),
('Петр', 'Соколов', 'petr.sokol@yandex.ru', '+7(900)333-33-33', '1999-11-01', '2023-02-01', TRUE),
('Анна', 'Попова', 'anna.popova@gmail.com', '+7(900)444-44-44', '2002-03-10', '2023-02-15', TRUE),
('Дмитрий', 'Лебедев', 'dmitry.lebedev@mail.ru', '+7(900)555-55-55', '2001-07-25', '2023-03-01', TRUE),
('Елена', 'Новикова', 'elena.novikova@gmail.com', '+7(900)666-66-66', '2000-12-05', '2023-03-15', TRUE),
('Алексей', 'Морозов', 'alexey.morozov@yandex.ru', '+7(900)777-77-77', '1998-09-30', '2023-04-01', TRUE),
('Ольга', 'Павлова', 'olga.pavlova@mail.ru', '+7(900)888-88-88', '2002-01-12', '2023-04-15', TRUE),
('Сергей', 'Федоров', 'sergey.fedorov@gmail.com', '+7(900)999-99-99', '2001-06-08', '2023-05-01', TRUE),
('Татьяна', 'Михайлова', 'tatiana.mihailova@yandex.ru', '+7(900)000-00-00', '2000-10-18', '2023-05-15', TRUE);

-- Группы
INSERT INTO groups (group_name, style_id, teacher_id, max_students, room_number, schedule_day, schedule_time, is_active) VALUES
('Бальный вальс', (SELECT style_id FROM dance_styles WHERE style_name = 'Бальные танцы'), 1, 12, '101', 1, '10:00:00', TRUE),
('Хип-хоп для начинающих', (SELECT style_id FROM dance_styles WHERE style_name = 'Хип-хоп'), 3, 15, '102', 2, '11:00:00', TRUE),
('Сальса-дэнс', (SELECT style_id FROM dance_styles WHERE style_name = 'Сальса'), 2, 10, '103', 3, '12:00:00', TRUE),
('Бачата', (SELECT style_id FROM dance_styles WHERE style_name = 'Бачата'), 2, 10, '103', 3, '13:00:00', TRUE),
('Джаз-модерн', (SELECT style_id FROM dance_styles WHERE style_name = 'Джаз-модерн'), 4, 12, '104', 4, '14:00:00', TRUE),
('Брейк-данс', (SELECT style_id FROM dance_styles WHERE style_name = 'Брейк-данс'), 5, 8, '105', 5, '15:00:00', TRUE),
('Контемпорари', (SELECT style_id FROM dance_styles WHERE style_name = 'Контемпорари'), 4, 10, '104', 6, '16:00:00', TRUE),
('Кизомба', (SELECT style_id FROM dance_styles WHERE style_name = 'Кизомба'), 6, 10, '103', 1, '17:00:00', TRUE),
('Пилон (начинающие)', (SELECT style_id FROM dance_styles WHERE style_name = 'Танцы на пилоне'), 7, 8, '106', 2, '18:00:00', TRUE),
('Фламенко', (SELECT style_id FROM dance_styles WHERE style_name = 'Фламенко'), 8, 10, '107', 3, '19:00:00', TRUE);

-- Связь учеников и групп
INSERT INTO student_groups (student_id, group_id, enrollment_date, monthly_fee, is_active) VALUES
((SELECT student_id FROM students WHERE email = 'ivan.smirnov@mail.ru'), 1, '2023-01-10', 5000.00, TRUE),
((SELECT student_id FROM students WHERE email = 'maria.kuz@mail.ru'), 1, '2023-01-15', 5000.00, TRUE),
((SELECT student_id FROM students WHERE email = 'petr.sokol@yandex.ru'), 1, '2023-02-01', 5000.00, TRUE),
((SELECT student_id FROM students WHERE email = 'anna.popova@gmail.com'), 2, '2023-02-15', 4500.00, TRUE),
((SELECT student_id FROM students WHERE email = 'dmitry.lebedev@mail.ru'), 2, '2023-03-01', 4500.00, TRUE),
((SELECT student_id FROM students WHERE email = 'elena.novikova@gmail.com'), 2, '2023-03-15', 4500.00, TRUE),
((SELECT student_id FROM students WHERE email = 'alexey.morozov@yandex.ru'), 3, '2023-04-01', 5500.00, TRUE),
((SELECT student_id FROM students WHERE email = 'olga.pavlova@mail.ru'), 3, '2023-04-15', 5500.00, TRUE),
((SELECT student_id FROM students WHERE email = 'sergey.fedorov@gmail.com'), 3, '2023-05-01', 5500.00, TRUE),
((SELECT student_id FROM students WHERE email = 'tatiana.mihailova@yandex.ru'), 4, '2023-05-15', 5000.00, TRUE);

-- Платежи
INSERT INTO payments (student_id, amount, payment_date, payment_method, is_paid, description) VALUES
((SELECT student_id FROM students WHERE email = 'ivan.smirnov@mail.ru'), 5000.00, '2023-01-10 10:00:00', 'Card', TRUE, 'Оплата за январь - Бальный вальс'),
((SELECT student_id FROM students WHERE email = 'ivan.smirnov@mail.ru'), 5500.00, '2023-02-15 11:00:00', 'Online', TRUE, 'Оплата за февраль - Сальса'),
((SELECT student_id FROM students WHERE email = 'ivan.smirnov@mail.ru'), 5000.00, '2023-03-10 10:00:00', 'Card', TRUE, 'Оплата за март - Бальный вальс'),
((SELECT student_id FROM students WHERE email = 'maria.kuz@mail.ru'), 5000.00, '2023-01-15 12:00:00', 'Cash', TRUE, 'Оплата за январь - Бальный вальс'),
((SELECT student_id FROM students WHERE email = 'maria.kuz@mail.ru'), 5000.00, '2023-02-15 12:00:00', 'Cash', TRUE, 'Оплата за февраль - Бальный вальс'),
((SELECT student_id FROM students WHERE email = 'maria.kuz@mail.ru'), 5000.00, '2023-03-01 13:00:00', 'Online', TRUE, 'Оплата за март - Бачата');