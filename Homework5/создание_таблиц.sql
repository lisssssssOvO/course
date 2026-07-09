-- Расширение для UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Стили танцев
CREATE TABLE dance_styles (
    style_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    style_name VARCHAR(100) NOT NULL,
    description TEXT,
    difficulty_level INT CHECK (difficulty_level BETWEEN 1 AND 5),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Преподаватели
CREATE TABLE teachers (
    teacher_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ученики
CREATE TABLE students (
    student_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    birth_date DATE,
    registration_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Группы
CREATE TABLE groups (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL,
    style_id UUID NOT NULL,
    teacher_id INT NOT NULL,
    max_students INT DEFAULT 15,
    room_number VARCHAR(10),
    schedule_day INT CHECK (schedule_day BETWEEN 1 AND 7),
    schedule_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_groups_style FOREIGN KEY (style_id) REFERENCES dance_styles(style_id),
    CONSTRAINT fk_groups_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);

-- Связь учеников и групп
CREATE TABLE student_groups (
    student_id UUID NOT NULL,
    group_id INT NOT NULL,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    monthly_fee DECIMAL(10,2) CHECK (monthly_fee >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_student_groups PRIMARY KEY (student_id, group_id),
    CONSTRAINT fk_sg_student FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_sg_group FOREIGN KEY (group_id) REFERENCES groups(group_id)
);

-- Платежи
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    student_id UUID NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) CHECK (payment_method IN ('Cash', 'Card', 'Online')),
    is_paid BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_payments_student FOREIGN KEY (student_id) REFERENCES students(student_id)
);