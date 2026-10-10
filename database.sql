-- ==========================================================
-- College ERP Management System - Database Schema & Seed Data
-- Database: college_erp
-- TYCS Mini Project
-- ==========================================================

CREATE DATABASE IF NOT EXISTS `college_erp` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `college_erp`;

-- 1. Users Table (Authentication & Role Management)
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `role` ENUM('admin', 'faculty', 'student') NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Faculty Table
DROP TABLE IF EXISTS `faculty`;
CREATE TABLE `faculty` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `faculty_code` VARCHAR(30) NOT NULL UNIQUE,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `phone` VARCHAR(20) NOT NULL,
    `gender` ENUM('Male', 'Female', 'Other') NOT NULL,
    `department` VARCHAR(100) NOT NULL,
    `qualification` VARCHAR(100) NOT NULL,
    `subject` VARCHAR(100) NOT NULL,
    `joining_date` DATE NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_faculty_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Students Table
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `student_code` VARCHAR(30) NOT NULL UNIQUE,
    `registration_id` VARCHAR(50) NOT NULL UNIQUE,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `phone` VARCHAR(20) NOT NULL,
    `gender` ENUM('Male', 'Female', 'Other') NOT NULL,
    `dob` DATE NOT NULL,
    `address` TEXT NOT NULL,
    `department` VARCHAR(100) NOT NULL,
    `course` VARCHAR(100) NOT NULL,
    `year` VARCHAR(20) NOT NULL,
    `division` VARCHAR(10) NOT NULL,
    `roll_number` VARCHAR(30) NOT NULL,
    `admission_date` DATE NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_student_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Departments Table (NEP 2020 Framework)
DROP TABLE IF EXISTS `departments`;
CREATE TABLE `departments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `department_code` VARCHAR(20) NOT NULL UNIQUE,
    `department_name` VARCHAR(100) NOT NULL UNIQUE,
    `faculty_stream` VARCHAR(100) NOT NULL,
    `description` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Courses Table (Department-Wise under NEP 2020 Rules)
DROP TABLE IF EXISTS `courses`;
CREATE TABLE `courses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `department_id` INT NOT NULL,
    `course_code` VARCHAR(20) NOT NULL UNIQUE,
    `course_name` VARCHAR(150) NOT NULL UNIQUE,
    `nep_level` VARCHAR(50) NOT NULL DEFAULT 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)',
    `duration_years` INT NOT NULL DEFAULT 4,
    `total_semesters` INT NOT NULL DEFAULT 8,
    `degree_type` ENUM('UG Degree / Honours', 'PG Degree', 'UG Diploma') NOT NULL DEFAULT 'UG Degree / Honours',
    `description` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_courses_department` FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Subjects Table
DROP TABLE IF EXISTS `subjects`;
CREATE TABLE `subjects` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `subject_code` VARCHAR(30) NOT NULL UNIQUE,
    `subject_name` VARCHAR(100) NOT NULL,
    `department` VARCHAR(100) NOT NULL,
    `course` VARCHAR(100) NOT NULL,
    `semester` VARCHAR(30) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Attendance Table
DROP TABLE IF EXISTS `attendance`;
CREATE TABLE `attendance` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `subject` VARCHAR(100) NOT NULL,
    `attendance_date` DATE NOT NULL,
    `status` ENUM('Present', 'Absent') NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_attendance_student` FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Fees Table
DROP TABLE IF EXISTS `fees`;
CREATE TABLE `fees` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `academic_year` VARCHAR(20) NOT NULL,
    `total_fees` DECIMAL(10,2) NOT NULL,
    `paid_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `pending_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `payment_date` DATE NOT NULL,
    `payment_status` ENUM('Paid', 'Partially Paid', 'Pending') NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_fees_student` FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Exams Table
DROP TABLE IF EXISTS `exams`;
CREATE TABLE `exams` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `exam_name` VARCHAR(100) NOT NULL,
    `exam_type` ENUM('Internal Exam', 'Semester Exam', 'Practical Exam') NOT NULL,
    `course` VARCHAR(100) NOT NULL,
    `semester` VARCHAR(20) NOT NULL,
    `subject` VARCHAR(100) NOT NULL,
    `exam_date` DATE NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Marks & Results Table
DROP TABLE IF EXISTS `marks`;
CREATE TABLE `marks` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `exam_id` INT NOT NULL,
    `subject` VARCHAR(100) NOT NULL,
    `max_marks` DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    `obtained_marks` DECIMAL(5,2) NOT NULL,
    `percentage` DECIMAL(5,2) NOT NULL,
    `grade` VARCHAR(5) NOT NULL,
    `result_status` ENUM('Pass', 'Fail') NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_marks_student` FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_marks_exam` FOREIGN KEY (`exam_id`) REFERENCES `exams`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Notices Table
DROP TABLE IF EXISTS `notices`;
CREATE TABLE `notices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL,
    `posted_date` DATE NOT NULL,
    `posted_by` VARCHAR(100) NOT NULL DEFAULT 'Admin',
    `target_audience` ENUM('All', 'Students', 'Faculty') NOT NULL DEFAULT 'All',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- SEED DATA
-- Default passwords:
-- admin@college.com    -> admin123
-- faculty@college.com  -> faculty123
-- student@college.com  -> student123
-- ==========================================================

-- Insert Users
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`) VALUES
(1, 'System Administrator', 'admin@college.com', '$2y$10$4mbZp1fapMF2Wk4QmYKLnevvuznGrPiyLaph7RFPI4oxD.HuwkmQa', 'admin'),
(2, 'Prof. Rajesh Sharma', 'faculty@college.com', '$2y$10$GUfU7qwDRC2eWQT0elDyKuL.braoSH4/nIrjYtAAv43VjDfriXCLC', 'faculty'),
(3, 'Rahul Verma', 'student@college.com', '$2y$10$MEe0mi9QHuQ/rmeAHIUePO/rWPnXg31w5GHcLv8Sbh3kuwktU5YDi', 'student'),
(4, 'Dr. Sunita Kulkarni', 'sunita.kulkarni@college.com', '$2y$10$GUfU7qwDRC2eWQT0elDyKuL.braoSH4/nIrjYtAAv43VjDfriXCLC', 'faculty'),
(5, 'Prof. Amit Joshi', 'amit.joshi@college.com', '$2y$10$GUfU7qwDRC2eWQT0elDyKuL.braoSH4/nIrjYtAAv43VjDfriXCLC', 'faculty'),
(6, 'Sneha Patil', 'sneha.patil@college.com', '$2y$10$MEe0mi9QHuQ/rmeAHIUePO/rWPnXg31w5GHcLv8Sbh3kuwktU5YDi', 'student'),
(7, 'Rohan Mehta', 'rohan.mehta@college.com', '$2y$10$MEe0mi9QHuQ/rmeAHIUePO/rWPnXg31w5GHcLv8Sbh3kuwktU5YDi', 'student'),
(8, 'Ananya Iyer', 'ananya.iyer@college.com', '$2y$10$MEe0mi9QHuQ/rmeAHIUePO/rWPnXg31w5GHcLv8Sbh3kuwktU5YDi', 'student');

-- Insert Faculty
INSERT INTO `faculty` (`id`, `user_id`, `faculty_code`, `full_name`, `email`, `phone`, `gender`, `department`, `qualification`, `subject`, `joining_date`) VALUES
(1, 2, 'FAC101', 'Prof. Rajesh Sharma', 'faculty@college.com', '9820123456', 'Male', 'Computer Science', 'M.Tech (CSE), Ph.D.', 'Web Technologies', '2019-07-15'),
(2, 4, 'FAC102', 'Dr. Sunita Kulkarni', 'sunita.kulkarni@college.com', '9820234567', 'Female', 'Computer Science', 'M.Sc. Computer Science', 'Database Systems', '2020-08-01'),
(3, 5, 'FAC103', 'Prof. Amit Joshi', 'amit.joshi@college.com', '9820345678', 'Male', 'Information Technology', 'M.E. (Information Tech)', 'Software Engineering', '2021-01-10');

-- Insert Departments (NEP 2020 Framework)
INSERT INTO `departments` (`id`, `department_code`, `department_name`, `faculty_stream`, `description`) VALUES
(1, 'CS', 'Computer Science', 'Faculty of Science & Technology', 'Department offering computing theory, software engineering, AI, algorithms, and systems under NEP framework.'),
(2, 'IT', 'Information Technology', 'Faculty of Science & Technology', 'Department focusing on networking, cloud architecture, cybersecurity, and applied modern software systems.'),
(3, 'COMM', 'Commerce & Management', 'Faculty of Commerce & Management', 'Department providing finance, corporate accounting, management, banking, and financial markets under NEP.'),
(4, 'SCI', 'Science', 'Faculty of Science & Technology', 'Department covering foundational & applied basic sciences: Physics, Chemistry, Maths, Biotechnology & Microbiology.'),
(5, 'ARTS', 'Arts & Humanities', 'Faculty of Humanities & Social Sciences', 'Department cultivating critical inquiry, English literature, economics, psychology, and mass communication.');

-- Insert Courses (Department-Wise as per NEP 2020 Rules)
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`) VALUES
-- Computer Science Department
(1, 1, 'BSC-CS', 'B.Sc. Computer Science', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'NEP 4-year undergraduate curriculum covering programming, data structures, algorithms, databases, web development, and AI.'),
(2, 1, 'BSC-DSAI', 'B.Sc. Data Science & Artificial Intelligence', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Specialized NEP major covering machine learning, deep learning, big data analytics, statistical modeling, and computer vision.'),
(3, 1, 'BSC-CSDF', 'B.Sc. Cyber Security & Forensics', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Comprehensive security program focusing on ethical hacking, digital forensics, network defense, cryptography, and cyber laws.'),
(4, 1, 'BCA', 'Bachelor of Computer Applications (BCA)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Application-oriented NEP program emphasizing enterprise software development, mobile apps, database administration, and UI/UX design.'),
(5, 1, 'MSC-CS', 'M.Sc. Computer Science', 'NEP Level 6.5 (PG 2-Year)', 2, 4, 'PG Degree', 'Postgraduate research and industry-ready program in advanced computing, distributed systems, parallel processing, and research dissertation.'),
-- Information Technology Department
(6, 2, 'BSC-IT', 'B.Sc. Information Technology', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'NEP honors degree covering full-stack web, networking, DevOps, virtualization, IT security, and enterprise database systems.'),
(7, 2, 'BSC-SDCC', 'B.Sc. Software Development & Cloud Computing', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Focusing on AWS, Azure, microservices, containerization with Docker/Kubernetes, and enterprise cloud software pipelines.'),
(8, 2, 'BSC-IOT', 'B.Sc. Internet of Things (IoT) & Smart Systems', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Sensor architectures, Raspberry Pi/Arduino physical computing, industrial automation, and wireless sensor networks.'),
(9, 2, 'MSC-IT', 'M.Sc. Information Technology', 'NEP Level 6.5 (PG 2-Year)', 2, 4, 'PG Degree', 'Postgraduate degree focused on cloud architecture, cybersecurity management, artificial neural networks, and IT governance.'),
-- Commerce & Management Department
(10, 3, 'BCOM', 'Bachelor of Commerce (B.Com)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Foundational NEP commerce program encompassing corporate accounting, financial management, business economics, taxation, and mercantile law.'),
(11, 3, 'BAF', 'B.Com. Accounting & Finance (BAF)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Specialized program in auditing, advanced cost accounting, financial reporting, corporate governance, and investment banking.'),
(12, 3, 'BBI', 'B.Com. Banking & Insurance (BBI)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Focusing on banking regulations, central banking, risk management, life & general insurance underwriting, and FinTech.'),
(13, 3, 'BFM', 'B.Com. Financial Markets (BFM)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Specialized degree in capital markets, equity research, derivatives trading, portfolio optimization, and securities laws.'),
(14, 3, 'BMS', 'Bachelor of Management Studies (BMS / BBA)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Business leadership program with specializations in Marketing, Finance, and Human Resource Management under NEP framework.'),
(15, 3, 'MCOM', 'Master of Commerce (M.Com)', 'NEP Level 6.5 (PG 2-Year)', 2, 4, 'PG Degree', 'Postgraduate research in corporate financial strategy, international finance, strategic management, and corporate reporting.'),
-- Science Department
(16, 4, 'BSC-PHY', 'B.Sc. Physics', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Core physics degree covering classical mechanics, quantum physics, thermodynamics, electronics, solid state physics, and optics.'),
(17, 4, 'BSC-CHEM', 'B.Sc. Chemistry', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Covering organic synthesis, physical chemistry, analytical instrumentation, polymer chemistry, and industrial biochemistry.'),
(18, 4, 'BSC-MATH', 'B.Sc. Mathematics & Statistics', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Abstract algebra, real analysis, differential equations, probability theory, statistical inference, and operations research.'),
(19, 4, 'BSC-BT', 'B.Sc. Biotechnology', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Molecular biology, recombinant DNA technology, genetic engineering, bioprocess technology, and bio-informatics.'),
(20, 4, 'BSC-MB', 'B.Sc. Microbiology', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Bacteriology, virology, immunology, industrial fermentation, medical microbiology, and food microbiology.'),
-- Arts & Humanities Department
(21, 5, 'BA-GEN', 'Bachelor of Arts (B.A. General)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Multidisciplinary arts degree with combinations of literature, political science, history, sociology, and modern languages.'),
(22, 5, 'BA-ENG', 'B.A. English Literature', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'British literature, Indian writing in English, literary criticism, linguistics, creative writing, and comparative literature.'),
(23, 5, 'BA-PSY', 'B.A. Psychology', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'General psychology, developmental psychology, social psychology, psychopathology, psychological testing, and counseling.'),
(24, 5, 'BA-ECO', 'B.A. Economics', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Microeconomics, macroeconomics, public finance, Indian financial system, econometrics, and international trade.'),
(25, 5, 'BAMMC', 'B.A. Multimedia & Mass Communication (BAMMC)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', 4, 8, 'UG Degree / Honours', 'Journalism, public relations, advertising, digital media production, film appreciation, and mass media communication.');

-- Insert Students
INSERT INTO `students` (`id`, `user_id`, `student_code`, `registration_id`, `full_name`, `email`, `phone`, `gender`, `dob`, `address`, `department`, `course`, `year`, `division`, `roll_number`, `admission_date`) VALUES
(1, 3, 'STU101', 'REG2026001', 'Rahul Verma', 'student@college.com', '9876543210', 'Male', '2004-05-14', 'Flat 402, Sunshine Heights, MG Road, Mumbai', 'Computer Science', 'B.Sc. Computer Science', 'TY', 'A', 'TYCS-01', '2023-06-15'),
(2, 6, 'STU102', 'REG2026002', 'Sneha Patil', 'sneha.patil@college.com', '9876543211', 'Female', '2004-08-22', '12/B Gokul Dham Colony, Pune', 'Computer Science', 'B.Sc. Computer Science', 'TY', 'A', 'TYCS-02', '2023-06-15'),
(3, 7, 'STU103', 'REG2026003', 'Rohan Mehta', 'rohan.mehta@college.com', '9876543212', 'Male', '2004-11-03', '703 Lakeview Towers, Thane West', 'Computer Science', 'B.Sc. Computer Science', 'TY', 'B', 'TYCS-03', '2023-06-18'),
(4, 8, 'STU104', 'REG2026004', 'Ananya Iyer', 'ananya.iyer@college.com', '9876543213', 'Female', '2005-02-19', 'Block C-10, Green Park, Navi Mumbai', 'Information Technology', 'B.Sc. IT', 'SY', 'A', 'SYIT-05', '2024-06-20');

-- Insert Subjects (Full B.Sc. Computer Science Curriculum: Semester I to VI + B.Sc. IT)
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`) VALUES
-- Semester I (FYCS)
(13, 'CS101', 'Computer Organization and Design', 'Computer Science', 'B.Sc. Computer Science', 'Semester I'),
(14, 'CS102', 'Programming with Python - I', 'Computer Science', 'B.Sc. Computer Science', 'Semester I'),
(15, 'CS103', 'Free and Open Source Software', 'Computer Science', 'B.Sc. Computer Science', 'Semester I'),
(16, 'CS104', 'Database Systems Fundamentals', 'Computer Science', 'B.Sc. Computer Science', 'Semester I'),
(17, 'CS105', 'Discrete Mathematics', 'Computer Science', 'B.Sc. Computer Science', 'Semester I'),
(18, 'CS106', 'Descriptive Statistics', 'Computer Science', 'B.Sc. Computer Science', 'Semester I'),
(19, 'CS107', 'Soft Skills Development', 'Computer Science', 'B.Sc. Computer Science', 'Semester I'),
-- Semester II (FYCS)
(20, 'CS201', 'Programming with C', 'Computer Science', 'B.Sc. Computer Science', 'Semester II'),
(21, 'CS202', 'Programming with Python - II', 'Computer Science', 'B.Sc. Computer Science', 'Semester II'),
(22, 'CS203', 'Linux Operating System', 'Computer Science', 'B.Sc. Computer Science', 'Semester II'),
(23, 'CS204', 'Data Structures', 'Computer Science', 'B.Sc. Computer Science', 'Semester II'),
(24, 'CS205', 'Calculus and Mathematical Methods', 'Computer Science', 'B.Sc. Computer Science', 'Semester II'),
(25, 'CS206', 'Statistical Methods and Testing', 'Computer Science', 'B.Sc. Computer Science', 'Semester II'),
(26, 'CS207', 'Green Technologies', 'Computer Science', 'B.Sc. Computer Science', 'Semester II'),
-- Semester III (SYCS)
(6, 'CS301', 'Principles of Operating Systems', 'Computer Science', 'B.Sc. Computer Science', 'Semester III'),
(28, 'CS302', 'Core Java Programming', 'Computer Science', 'B.Sc. Computer Science', 'Semester III'),
(29, 'CS303', 'Database Management Systems (Advanced)', 'Computer Science', 'B.Sc. Computer Science', 'Semester III'),
(30, 'CS304', 'Combinatorics and Graph Theory', 'Computer Science', 'B.Sc. Computer Science', 'Semester III'),
(31, 'CS305', 'Physical Computing and IoT Programming', 'Computer Science', 'B.Sc. Computer Science', 'Semester III'),
(32, 'CS306', 'Web Programming and Scripting', 'Computer Science', 'B.Sc. Computer Science', 'Semester III'),
-- Semester IV (SYCS)
(33, 'CS401', 'Fundamentals of Algorithms', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV'),
(34, 'CS402', 'Advanced Java Programming', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV'),
(35, 'CS403', 'Computer Networks and Protocols', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV'),
(36, 'CS404', 'Software Engineering Principles', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV'),
(37, 'CS405', 'Linear Algebra', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV'),
(38, 'CS406', '.NET Technologies with C#', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV'),
-- Semester V (TYCS)
(1, 'CS501', 'Web Technologies', 'Computer Science', 'B.Sc. Computer Science', 'Semester V'),
(2, 'CS502', 'Database Systems', 'Computer Science', 'B.Sc. Computer Science', 'Semester V'),
(3, 'CS503', 'Software Engineering', 'Computer Science', 'B.Sc. Computer Science', 'Semester V'),
(4, 'CS504', 'Python Programming', 'Computer Science', 'B.Sc. Computer Science', 'Semester V'),
(5, 'CS505', 'Computer Networks', 'Computer Science', 'B.Sc. Computer Science', 'Semester V'),
(44, 'CS506', 'Artificial Intelligence', 'Computer Science', 'B.Sc. Computer Science', 'Semester V'),
(11, 'CS507', 'Machine Learning & Data Mining', 'Computer Science', 'B.Sc. Computer Science', 'Semester V'),
(46, 'CS508', 'Linux Server Administration', 'Computer Science', 'B.Sc. Computer Science', 'Semester V'),
(12, 'SUB512', 'Robotics & Embedded Systems', 'Computer Science', 'B.Sc. Computer Science', 'Semester V'),
(10, 'IT501', 'Advanced Web Programming', 'Information Technology', 'B.Sc. IT', 'Semester V'),
-- Semester VI (TYCS)
(7, 'CS601', 'Cloud Computing', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI'),
(8, 'CS602', 'Cyber Forensics & Information Security', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI'),
(9, 'CS603', 'Information Retrieval', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI'),
(50, 'CS604', 'Data Science & Big Data Analytics', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI'),
(51, 'CS605', 'Ethical Hacking', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI'),
(52, 'CS606', 'Project Implementation & Viva', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI'),
-- Commerce & Management NEP Subjects
(53, 'BCOM101', 'Financial Accounting - I', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I'),
(54, 'BCOM102', 'Business Economics - I', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I'),
(55, 'BCOM103', 'Commerce & Business Organization', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I'),
(56, 'BCOM104', 'Business Communication - I', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I'),
(57, 'BCOM105', 'Environmental Studies (VAC)', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I'),
(58, 'BCOM106', 'Mathematical & Statistical Techniques', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I'),
(59, 'BAF101', 'Financial Accounting - Paper I', 'Commerce & Management', 'B.Com. Accounting & Finance (BAF)', 'Semester I'),
(60, 'BAF102', 'Cost Accounting - Introduction', 'Commerce & Management', 'B.Com. Accounting & Finance (BAF)', 'Semester I'),
(61, 'BAF103', 'Financial Management - I', 'Commerce & Management', 'B.Com. Accounting & Finance (BAF)', 'Semester I'),
(62, 'BAF104', 'Business Communication in Finance', 'Commerce & Management', 'B.Com. Accounting & Finance (BAF)', 'Semester I'),
(63, 'BMS101', 'Principles of Management', 'Commerce & Management', 'Bachelor of Management Studies (BMS / BBA)', 'Semester I'),
(64, 'BMS102', 'Business Law & Corporate Governance', 'Commerce & Management', 'Bachelor of Management Studies (BMS / BBA)', 'Semester I'),
(65, 'BMS103', 'Business Statistics (MDC)', 'Commerce & Management', 'Bachelor of Management Studies (BMS / BBA)', 'Semester I'),
(66, 'BMS104', 'Marketing Management Fundamentals', 'Commerce & Management', 'Bachelor of Management Studies (BMS / BBA)', 'Semester I'),
-- Science NEP Subjects
(67, 'PHY101', 'Classical Mechanics & Wave Motion', 'Science', 'B.Sc. Physics', 'Semester I'),
(68, 'PHY102', 'Electricity, Magnetism & Electronics', 'Science', 'B.Sc. Physics', 'Semester I'),
(69, 'CHEM101', 'Inorganic & Organic Chemistry - I', 'Science', 'B.Sc. Chemistry', 'Semester I'),
(70, 'CHEM102', 'Physical Chemistry & Analytical Tools', 'Science', 'B.Sc. Chemistry', 'Semester I'),
(71, 'BT101', 'Cell Biology & Biomolecules', 'Science', 'B.Sc. Biotechnology', 'Semester I'),
(72, 'BT102', 'Microbiology & Bio-techniques', 'Science', 'B.Sc. Biotechnology', 'Semester I'),
-- Arts & Humanities NEP Subjects
(73, 'ENG101', 'Introduction to Literature & Drama', 'Arts & Humanities', 'B.A. English Literature', 'Semester I'),
(74, 'ENG102', 'History of English Literature', 'Arts & Humanities', 'B.A. English Literature', 'Semester I'),
(75, 'PSY101', 'Foundations of Psychology', 'Arts & Humanities', 'B.A. Psychology', 'Semester I'),
(76, 'PSY102', 'Psychology of Human Development', 'Arts & Humanities', 'B.A. Psychology', 'Semester I'),
(77, 'ECO101', 'Microeconomics Principles', 'Arts & Humanities', 'B.A. Economics', 'Semester I'),
(78, 'ECO102', 'Indian Economy in Transition', 'Arts & Humanities', 'B.A. Economics', 'Semester I'),
(79, 'MMC101', 'Fundamentals of Mass Communication', 'Arts & Humanities', 'B.A. Multimedia & Mass Communication (BAMMC)', 'Semester I'),
(80, 'MMC102', 'Visual Communication & Media Writing', 'Arts & Humanities', 'B.A. Multimedia & Mass Communication (BAMMC)', 'Semester I'),
-- Information Technology NEP Subjects
(81, 'IT101', 'Imperative Programming with C', 'Information Technology', 'B.Sc. Information Technology', 'Semester I'),
(82, 'IT102', 'Digital Electronics & Microprocessors', 'Information Technology', 'B.Sc. Information Technology', 'Semester I'),
(83, 'IT103', 'Operating Systems & CLI Architecture', 'Information Technology', 'B.Sc. Information Technology', 'Semester I'),
(84, 'IT104', 'Discrete Mathematics for IT', 'Information Technology', 'B.Sc. Information Technology', 'Semester I'),
(85, 'IT105', 'Technical Communication Skills (AEC)', 'Information Technology', 'B.Sc. Information Technology', 'Semester I');

-- Insert Attendance Records
INSERT INTO `attendance` (`student_id`, `subject`, `attendance_date`, `status`) VALUES
(1, 'Web Technologies', '2026-09-01', 'Present'),
(1, 'Web Technologies', '2026-09-02', 'Present'),
(1, 'Web Technologies', '2026-09-03', 'Present'),
(1, 'Web Technologies', '2026-09-04', 'Absent'),
(1, 'Web Technologies', '2026-09-07', 'Present'),
(1, 'Database Systems', '2026-09-01', 'Present'),
(1, 'Database Systems', '2026-09-02', 'Present'),
(1, 'Database Systems', '2026-09-03', 'Absent'),
(1, 'Database Systems', '2026-09-04', 'Present'),
(1, 'Database Systems', '2026-09-07', 'Present'),
(1, 'Software Engineering', '2026-09-01', 'Present'),
(1, 'Software Engineering', '2026-09-02', 'Present'),
(1, 'Software Engineering', '2026-09-03', 'Present'),
(1, 'Software Engineering', '2026-09-04', 'Present'),
(1, 'Software Engineering', '2026-09-07', 'Present'),

(2, 'Web Technologies', '2026-09-01', 'Present'),
(2, 'Web Technologies', '2026-09-02', 'Present'),
(2, 'Web Technologies', '2026-09-03', 'Present'),
(2, 'Web Technologies', '2026-09-04', 'Present'),
(2, 'Web Technologies', '2026-09-07', 'Present'),

(3, 'Web Technologies', '2026-09-01', 'Absent'),
(3, 'Web Technologies', '2026-09-02', 'Absent'),
(3, 'Web Technologies', '2026-09-03', 'Present'),
(3, 'Web Technologies', '2026-09-04', 'Present'),
(3, 'Web Technologies', '2026-09-07', 'Absent');

-- Insert Fees Records
INSERT INTO `fees` (`student_id`, `academic_year`, `total_fees`, `paid_amount`, `pending_amount`, `payment_date`, `payment_status`) VALUES
(1, '2025-2026', 45000.00, 45000.00, 0.00, '2025-07-10', 'Paid'),
(1, '2026-2027', 48000.00, 30000.00, 18000.00, '2026-06-25', 'Partially Paid'),
(2, '2026-2027', 48000.00, 48000.00, 0.00, '2026-06-20', 'Paid'),
(3, '2026-2027', 48000.00, 0.00, 48000.00, '2026-06-15', 'Pending'),
(4, '2026-2027', 42000.00, 25000.00, 17000.00, '2026-07-05', 'Partially Paid');

-- Insert Exams
INSERT INTO `exams` (`id`, `exam_name`, `exam_type`, `course`, `semester`, `subject`, `exam_date`) VALUES
(1, 'TYCS Semester V Unit Test', 'Internal Exam', 'B.Sc. Computer Science', 'Semester V', 'Web Technologies', '2026-08-10'),
(2, 'TYCS Semester V Mid-Term Exam', 'Semester Exam', 'B.Sc. Computer Science', 'Semester V', 'Database Systems', '2026-08-25'),
(3, 'TYCS Advanced Web Tech Practical', 'Practical Exam', 'B.Sc. Computer Science', 'Semester V', 'Web Technologies Lab', '2026-09-12'),
(4, 'SYIT Semester III Theory Exam', 'Semester Exam', 'B.Sc. IT', 'Semester III', 'Data Structures', '2026-09-20');

-- Insert Marks / Results
INSERT INTO `marks` (`student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`) VALUES
(1, 1, 'Web Technologies', 50.00, 44.00, 88.00, 'A', 'Pass'),
(1, 2, 'Database Systems', 100.00, 86.00, 86.00, 'A', 'Pass'),
(1, 3, 'Web Technologies Lab', 50.00, 46.00, 92.00, 'A+', 'Pass'),
(2, 1, 'Web Technologies', 50.00, 48.00, 96.00, 'A+', 'Pass'),
(2, 2, 'Database Systems', 100.00, 91.00, 91.00, 'A+', 'Pass'),
(3, 1, 'Web Technologies', 50.00, 22.00, 44.00, 'F', 'Fail'),
(3, 2, 'Database Systems', 100.00, 48.00, 48.00, 'F', 'Fail');

-- Insert Notices
INSERT INTO `notices` (`title`, `description`, `posted_date`, `posted_by`, `target_audience`) VALUES
('TYCS Mini Project Submission & Viva Schedule', 'All TYCS students are hereby notified that the final submission of the mini project along with documentation is scheduled between 15th Oct and 20th Oct 2026. Viva will be conducted in the Computer Lab 3.', '2026-10-01', 'Admin', 'Students'),
('Faculty Meeting for NAAC Accreditation Preparation', 'A mandatory meeting for all faculty members will be held on Friday at 3:00 PM in Conference Room A to discuss the criteria and documentation for the upcoming NAAC peer team visit.', '2026-09-28', 'Admin', 'Faculty'),
('Annual Sports and Cultural Fest - Zephyr 2026', 'College is delighted to announce our annual inter-collegiate fest Zephyr 2026 from 10th November. Registration for sports, dance, coding hackathons, and drama starts next Monday.', '2026-09-25', 'Admin', 'All'),
('Semester V Examination Hall Tickets Available', 'Students are advised to collect their Semester V Examination Hall Tickets from the admin counter after clearing any pending fee dues before 5th October 2026.', '2026-09-20', 'Admin', 'Students');
