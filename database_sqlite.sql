-- ==========================================================
-- College ERP Management System - SQLite Database Dump
-- Converted from MySQL `college_erp`
-- Compatible with SQLite 3 / PDO SQLite
-- ==========================================================

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS `users` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `name` TEXT NOT NULL,
                `email` TEXT NOT NULL UNIQUE,
                `password` TEXT NOT NULL,
                `role` TEXT NOT NULL CHECK (`role` IN ('admin', 'faculty', 'student')),
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP
            );

CREATE TABLE IF NOT EXISTS `departments` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `department_code` TEXT NOT NULL UNIQUE,
                `department_name` TEXT NOT NULL UNIQUE,
                `faculty_stream` TEXT NOT NULL,
                `description` TEXT,
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP
            );

CREATE TABLE IF NOT EXISTS `courses` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `department_id` INTEGER NOT NULL,
                `course_code` TEXT NOT NULL UNIQUE,
                `course_name` TEXT NOT NULL UNIQUE,
                `nep_level` TEXT NOT NULL DEFAULT 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)',
                `duration_years` INTEGER NOT NULL DEFAULT 4,
                `total_semesters` INTEGER NOT NULL DEFAULT 8,
                `degree_type` TEXT NOT NULL DEFAULT 'UG Degree / Honours',
                `description` TEXT,
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
            );

CREATE TABLE IF NOT EXISTS `students` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `user_id` INTEGER,
                `student_code` TEXT NOT NULL UNIQUE,
                `registration_id` TEXT UNIQUE,
                `full_name` TEXT NOT NULL,
                `email` TEXT NOT NULL UNIQUE,
                `phone` TEXT NOT NULL,
                `gender` TEXT NOT NULL CHECK (`gender` IN ('Male', 'Female', 'Other')),
                `dob` TEXT NOT NULL,
                `address` TEXT NOT NULL,
                `department` TEXT NOT NULL,
                `course` TEXT NOT NULL,
                `year` TEXT NOT NULL,
                `division` TEXT NOT NULL,
                `roll_number` TEXT NOT NULL,
                `admission_date` TEXT NOT NULL,
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
            );

CREATE TABLE IF NOT EXISTS `faculty` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `user_id` INTEGER,
                `faculty_code` TEXT NOT NULL UNIQUE,
                `full_name` TEXT NOT NULL,
                `email` TEXT NOT NULL UNIQUE,
                `phone` TEXT NOT NULL,
                `gender` TEXT NOT NULL CHECK (`gender` IN ('Male', 'Female', 'Other')),
                `department` TEXT NOT NULL,
                `qualification` TEXT NOT NULL,
                `subject` TEXT NOT NULL,
                `joining_date` TEXT NOT NULL,
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
            );

CREATE TABLE IF NOT EXISTS `subjects` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `subject_code` TEXT NOT NULL UNIQUE,
                `subject_name` TEXT NOT NULL,
                `department` TEXT NOT NULL,
                `course` TEXT NOT NULL,
                `semester` TEXT NOT NULL,
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP
            );

CREATE TABLE IF NOT EXISTS `attendance` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `student_id` INTEGER NOT NULL,
                `subject` TEXT NOT NULL,
                `attendance_date` TEXT NOT NULL,
                `status` TEXT NOT NULL CHECK (`status` IN ('Present', 'Absent')),
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
            );

CREATE TABLE IF NOT EXISTS `fees` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `student_id` INTEGER NOT NULL,
                `academic_year` TEXT NOT NULL,
                `total_fees` REAL NOT NULL,
                `paid_amount` REAL NOT NULL DEFAULT 0.0,
                `pending_amount` REAL NOT NULL DEFAULT 0.0,
                `payment_date` TEXT NOT NULL,
                `payment_status` TEXT NOT NULL CHECK (`payment_status` IN ('Paid', 'Partially Paid', 'Pending')),
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
            );

CREATE TABLE IF NOT EXISTS `exams` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `exam_name` TEXT NOT NULL,
                `exam_type` TEXT NOT NULL CHECK (`exam_type` IN ('Internal Exam', 'Semester Exam', 'Practical Exam')),
                `course` TEXT NOT NULL,
                `semester` TEXT NOT NULL,
                `subject` TEXT NOT NULL,
                `exam_date` TEXT NOT NULL,
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP
            );

CREATE TABLE IF NOT EXISTS `marks` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `student_id` INTEGER NOT NULL,
                `exam_id` INTEGER NOT NULL,
                `subject` TEXT NOT NULL,
                `max_marks` REAL NOT NULL DEFAULT 100.0,
                `obtained_marks` REAL NOT NULL,
                `percentage` REAL NOT NULL,
                `grade` TEXT NOT NULL,
                `result_status` TEXT NOT NULL CHECK (`result_status` IN ('Pass', 'Fail')),
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
                FOREIGN KEY (`exam_id`) REFERENCES `exams`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
            );

CREATE TABLE IF NOT EXISTS `notices` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `title` TEXT NOT NULL,
                `description` TEXT NOT NULL,
                `posted_date` TEXT NOT NULL,
                `posted_by` TEXT NOT NULL DEFAULT 'Admin',
                `target_audience` TEXT NOT NULL DEFAULT 'All' CHECK (`target_audience` IN ('All', 'Students', 'Faculty')),
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP
            );

-- ==========================================================
-- DATA MIGRATION INSERTS
-- ==========================================================

-- Table: `users` (13 rows)
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('1', 'System Administrator', 'admin@college.com', '$2y$10$4mbZp1fapMF2Wk4QmYKLnevvuznGrPiyLaph7RFPI4oxD.HuwkmQa', 'admin', '2026-10-02 10:22:25');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('2', 'Prof. Rajesh Sharma', 'faculty@college.com', '$2y$10$GUfU7qwDRC2eWQT0elDyKuL.braoSH4/nIrjYtAAv43VjDfriXCLC', 'faculty', '2026-10-02 10:22:25');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('3', 'Rahul Verma', 'student@college.com', '$2y$10$MEe0mi9QHuQ/rmeAHIUePO/rWPnXg31w5GHcLv8Sbh3kuwktU5YDi', 'student', '2026-10-02 10:22:25');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('4', 'Dr. Sunita Kulkarni', 'sunita.kulkarni@college.com', '$2y$10$GUfU7qwDRC2eWQT0elDyKuL.braoSH4/nIrjYtAAv43VjDfriXCLC', 'faculty', '2026-10-02 10:22:25');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('5', 'Prof. Amit Joshi', 'amit.joshi@college.com', '$2y$10$GUfU7qwDRC2eWQT0elDyKuL.braoSH4/nIrjYtAAv43VjDfriXCLC', 'faculty', '2026-10-02 10:22:25');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('6', 'Sneha Patil', 'sneha.patil@college.com', '$2y$10$MEe0mi9QHuQ/rmeAHIUePO/rWPnXg31w5GHcLv8Sbh3kuwktU5YDi', 'student', '2026-10-02 10:22:25');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('7', 'Rohan Mehta', 'rohan.mehta@college.com', '$2y$10$MEe0mi9QHuQ/rmeAHIUePO/rWPnXg31w5GHcLv8Sbh3kuwktU5YDi', 'student', '2026-10-02 10:22:25');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('8', 'Ananya Iyer', 'ananya.iyer@college.com', '$2y$10$MEe0mi9QHuQ/rmeAHIUePO/rWPnXg31w5GHcLv8Sbh3kuwktU5YDi', 'student', '2026-10-02 10:22:25');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('9', 'Sushant Gaikwad', 'sushant.gaikwad@college.com', '$2y$10$r3suXEDySkyFvW8d93e.R.m/6rDmIUd1GCwRRJ59dWboWzOUlMdCq', 'student', '2026-10-02 10:55:35');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('10', 'Sushant Gaikwad', 'sushantgaikwad805@gmail.com', '$2y$10$Uf4M24cTH9Opo5Qq1wkX4.9K8hGE9asGowZm4JVUzW4oBMT8kZ09W', 'student', '2026-10-02 11:24:03');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('11', 'nikhil halwai', 'halwai1125114@gmail.com', '$2y$10$HFcLyQQ/K7MBDMCDGKVzo.pDtTopu0j9/9rKy7S07pXZeh.gLqsiu', 'student', '2026-10-02 11:42:03');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('12', 'niraj', 'abc09@gmail.com', '$2y$10$Tkx49kcy3q/zNqURRX0oE.u/sDxULrAk0j0gbTwUGdz79a.YlBCfi', 'student', '2026-10-02 11:55:52');
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES ('14', 'niraj', 'niraj12@gmail.com', '$2y$10$7DlHU.6r3FN.mc6wEJUM9e5Id/T./s7D4pxXIu00KDF44mmz4uWlK', 'faculty', '2026-10-02 11:59:35');

-- Table: `departments` (5 rows)
INSERT INTO `departments` (`id`, `department_code`, `department_name`, `faculty_stream`, `description`, `created_at`) VALUES ('1', 'CS', 'Computer Science', 'Faculty of Science & Technology', 'Department offering computing theory, software engineering, AI, algorithms, and systems under NEP framework.', '2026-10-02 12:31:54');
INSERT INTO `departments` (`id`, `department_code`, `department_name`, `faculty_stream`, `description`, `created_at`) VALUES ('2', 'IT', 'Information Technology', 'Faculty of Science & Technology', 'Department focusing on networking, cloud architecture, cybersecurity, and applied modern software systems.', '2026-10-02 12:31:54');
INSERT INTO `departments` (`id`, `department_code`, `department_name`, `faculty_stream`, `description`, `created_at`) VALUES ('3', 'COMM', 'Commerce & Management', 'Faculty of Commerce & Management', 'Department providing finance, corporate accounting, management, banking, and financial markets under NEP.', '2026-10-02 12:31:54');
INSERT INTO `departments` (`id`, `department_code`, `department_name`, `faculty_stream`, `description`, `created_at`) VALUES ('4', 'SCI', 'Science', 'Faculty of Science & Technology', 'Department covering foundational & applied basic sciences: Physics, Chemistry, Maths, Biotechnology & Microbiology.', '2026-10-02 12:31:54');
INSERT INTO `departments` (`id`, `department_code`, `department_name`, `faculty_stream`, `description`, `created_at`) VALUES ('5', 'ARTS', 'Arts & Humanities', 'Faculty of Humanities & Social Sciences', 'Department cultivating critical inquiry, English literature, economics, psychology, and mass communication.', '2026-10-02 12:31:54');

-- Table: `courses` (25 rows)
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('1', '1', 'BSC-CS', 'B.Sc. Computer Science', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'NEP 4-year undergraduate curriculum covering programming, data structures, algorithms, databases, web development, and AI with multiple entry/exit.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('2', '1', 'BSC-DSAI', 'B.Sc. Data Science & Artificial Intelligence', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Specialized NEP major covering machine learning, deep learning, big data analytics, statistical modeling, and computer vision.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('3', '1', 'BSC-CSDF', 'B.Sc. Cyber Security & Forensics', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Comprehensive security program focusing on ethical hacking, digital forensics, network defense, cryptography, and cyber laws.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('4', '1', 'BCA', 'Bachelor of Computer Applications (BCA)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Application-oriented NEP program emphasizing enterprise software development, mobile apps, database administration, and UI/UX design.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('5', '1', 'MSC-CS', 'M.Sc. Computer Science', 'NEP Level 6.5 (PG 2-Year)', '2', '4', 'PG Degree', 'Postgraduate research and industry-ready program in advanced computing, distributed systems, parallel processing, and research dissertation.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('6', '2', 'BSC-IT', 'B.Sc. Information Technology', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'NEP honors degree covering full-stack web, networking, DevOps, virtualization, IT security, and enterprise database systems.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('7', '2', 'BSC-SDCC', 'B.Sc. Software Development & Cloud Computing', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Focusing on AWS, Azure, microservices, containerization with Docker/Kubernetes, and enterprise cloud software pipelines.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('8', '2', 'BSC-IOT', 'B.Sc. Internet of Things (IoT) & Smart Systems', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Sensor architectures, Raspberry Pi/Arduino physical computing, industrial automation, and wireless sensor networks.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('9', '2', 'MSC-IT', 'M.Sc. Information Technology', 'NEP Level 6.5 (PG 2-Year)', '2', '4', 'PG Degree', 'Postgraduate degree focused on cloud architecture, cybersecurity management, artificial neural networks, and IT governance.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('10', '3', 'BCOM', 'Bachelor of Commerce (B.Com)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Foundational NEP commerce program encompassing corporate accounting, financial management, business economics, taxation, and mercantile law.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('11', '3', 'BAF', 'B.Com. Accounting & Finance (BAF)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Specialized program in auditing, advanced cost accounting, financial reporting, corporate governance, and investment banking.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('12', '3', 'BBI', 'B.Com. Banking & Insurance (BBI)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Focusing on banking regulations, central banking, risk management, life & general insurance underwriting, and FinTech.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('13', '3', 'BFM', 'B.Com. Financial Markets (BFM)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Specialized degree in capital markets, equity research, derivatives trading, portfolio optimization, and securities laws.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('14', '3', 'BMS', 'Bachelor of Management Studies (BMS / BBA)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Business leadership program with specializations in Marketing, Finance, and Human Resource Management under NEP framework.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('15', '3', 'MCOM', 'Master of Commerce (M.Com)', 'NEP Level 6.5 (PG 2-Year)', '2', '4', 'PG Degree', 'Postgraduate research in corporate financial strategy, international finance, strategic management, and corporate reporting.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('16', '4', 'BSC-PHY', 'B.Sc. Physics', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Core physics degree covering classical mechanics, quantum physics, thermodynamics, electronics, solid state physics, and optics.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('17', '4', 'BSC-CHEM', 'B.Sc. Chemistry', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Covering organic synthesis, physical chemistry, analytical instrumentation, polymer chemistry, and industrial biochemistry.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('18', '4', 'BSC-MATH', 'B.Sc. Mathematics & Statistics', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Abstract algebra, real analysis, differential equations, probability theory, statistical inference, and operations research.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('19', '4', 'BSC-BT', 'B.Sc. Biotechnology', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Molecular biology, recombinant DNA technology, genetic engineering, bioprocess technology, and bio-informatics.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('20', '4', 'BSC-MB', 'B.Sc. Microbiology', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Bacteriology, virology, immunology, industrial fermentation, medical microbiology, and food microbiology.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('21', '5', 'BA-GEN', 'Bachelor of Arts (B.A. General)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Multidisciplinary arts degree with combinations of literature, political science, history, sociology, and modern languages.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('22', '5', 'BA-ENG', 'B.A. English Literature', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'British literature, Indian writing in English, literary criticism, linguistics, creative writing, and comparative literature.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('23', '5', 'BA-PSY', 'B.A. Psychology', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'General psychology, developmental psychology, social psychology, psychopathology, psychological testing, and counseling.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('24', '5', 'BA-ECO', 'B.A. Economics', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Microeconomics, macroeconomics, public finance, Indian financial system, econometrics, and international trade.', '2026-10-02 12:31:54');
INSERT INTO `courses` (`id`, `department_id`, `course_code`, `course_name`, `nep_level`, `duration_years`, `total_semesters`, `degree_type`, `description`, `created_at`) VALUES ('25', '5', 'BAMMC', 'B.A. Multimedia & Mass Communication (BAMMC)', 'NEP Level 4.5 - 6.0 (UG 4-Year Honours)', '4', '8', 'UG Degree / Honours', 'Journalism, public relations, advertising, digital media production, film appreciation, and mass media communication.', '2026-10-02 12:31:54');

-- Table: `students` (8 rows)
INSERT INTO `students` (`id`, `user_id`, `student_code`, `registration_id`, `full_name`, `email`, `phone`, `gender`, `dob`, `address`, `department`, `course`, `year`, `division`, `roll_number`, `admission_date`, `created_at`) VALUES ('1', '3', 'STU101', 'REG2026001', 'Rahul Verma', 'student@college.com', '9876543210', 'Male', '2004-05-14', 'Flat 402, Sunshine Heights, MG Road, Mumbai', 'Computer Science', 'B.Sc. Computer Science', 'TY', 'A', 'TYCS-01', '2023-06-15', '2026-10-02 10:22:25');
INSERT INTO `students` (`id`, `user_id`, `student_code`, `registration_id`, `full_name`, `email`, `phone`, `gender`, `dob`, `address`, `department`, `course`, `year`, `division`, `roll_number`, `admission_date`, `created_at`) VALUES ('2', '6', 'STU102', 'REG2026002', 'Sneha Patil', 'sneha.patil@college.com', '9876543211', 'Female', '2004-08-22', '12/B Gokul Dham Colony, Pune', 'Computer Science', 'B.Sc. Computer Science', 'TY', 'A', 'TYCS-02', '2023-06-15', '2026-10-02 10:22:25');
INSERT INTO `students` (`id`, `user_id`, `student_code`, `registration_id`, `full_name`, `email`, `phone`, `gender`, `dob`, `address`, `department`, `course`, `year`, `division`, `roll_number`, `admission_date`, `created_at`) VALUES ('3', '7', 'STU103', 'REG2026003', 'Rohan Mehta', 'rohan.mehta@college.com', '9876543212', 'Male', '2004-11-03', '703 Lakeview Towers, Thane West', 'Computer Science', 'B.Sc. Computer Science', 'TY', 'B', 'TYCS-03', '2023-06-18', '2026-10-02 10:22:25');
INSERT INTO `students` (`id`, `user_id`, `student_code`, `registration_id`, `full_name`, `email`, `phone`, `gender`, `dob`, `address`, `department`, `course`, `year`, `division`, `roll_number`, `admission_date`, `created_at`) VALUES ('4', '8', 'STU104', 'REG2026004', 'Ananya Iyer', 'ananya.iyer@college.com', '9876543213', 'Female', '2005-02-19', 'Block C-10, Green Park, Navi Mumbai', 'Information Technology', 'B.Sc. IT', 'SY', 'A', 'SYIT-05', '2024-06-20', '2026-10-02 10:22:25');
INSERT INTO `students` (`id`, `user_id`, `student_code`, `registration_id`, `full_name`, `email`, `phone`, `gender`, `dob`, `address`, `department`, `course`, `year`, `division`, `roll_number`, `admission_date`, `created_at`) VALUES ('5', '9', 'STU105', 'REG2026005', 'Sushant Gaikwad', 'sushant.gaikwad@college.com', '9876543210', 'Male', '2004-08-15', 'Pune, Maharashtra', 'Computer Science', 'B.Sc. Computer Science', 'TY', 'A', 'TYCS-05', '2026-10-02', '2026-10-02 10:55:35');
INSERT INTO `students` (`id`, `user_id`, `student_code`, `registration_id`, `full_name`, `email`, `phone`, `gender`, `dob`, `address`, `department`, `course`, `year`, `division`, `roll_number`, `admission_date`, `created_at`) VALUES ('6', '10', 'STU106', 'REG2026006', 'Sushant Gaikwad', 'sushantgaikwad805@gmail.com', '8850329045', 'Male', '2005-03-05', 'Vashi', 'Computer Science', 'B.Sc. Computer Science', 'TY', 'B', '408', '2026-10-02', '2026-10-02 11:24:03');
INSERT INTO `students` (`id`, `user_id`, `student_code`, `registration_id`, `full_name`, `email`, `phone`, `gender`, `dob`, `address`, `department`, `course`, `year`, `division`, `roll_number`, `admission_date`, `created_at`) VALUES ('7', '11', 'STU107', 'REG2026007', 'nikhil halwai', 'halwai1125114@gmail.com', '8108992987', 'Male', '2005-07-04', 'vashi', 'Computer Science', 'B.Sc. Computer Science', 'TY', 'B', '440', '2026-10-02', '2026-10-02 11:42:03');
INSERT INTO `students` (`id`, `user_id`, `student_code`, `registration_id`, `full_name`, `email`, `phone`, `gender`, `dob`, `address`, `department`, `course`, `year`, `division`, `roll_number`, `admission_date`, `created_at`) VALUES ('8', '12', '356', '24504040', 'niraj', 'abc09@gmail.com', '9876543210', 'Male', '2000-05-04', 'vashi', 'Computer Science', 'B.Sc. Computer Science', 'TY', 'A', '356', '2026-10-02', '2026-10-02 11:55:52');

-- Table: `faculty` (4 rows)
INSERT INTO `faculty` (`id`, `user_id`, `faculty_code`, `full_name`, `email`, `phone`, `gender`, `department`, `qualification`, `subject`, `joining_date`, `created_at`) VALUES ('1', '2', 'FAC101', 'Prof. Rajesh Sharma', 'faculty@college.com', '9820123456', 'Male', 'Computer Science', 'M.Tech (CSE), Ph.D.', 'Web Technologies', '2019-07-15', '2026-10-02 10:22:25');
INSERT INTO `faculty` (`id`, `user_id`, `faculty_code`, `full_name`, `email`, `phone`, `gender`, `department`, `qualification`, `subject`, `joining_date`, `created_at`) VALUES ('2', '4', 'FAC102', 'Dr. Sunita Kulkarni', 'sunita.kulkarni@college.com', '9820234567', 'Female', 'Computer Science', 'M.Sc. Computer Science', 'Database Systems', '2020-08-01', '2026-10-02 10:22:25');
INSERT INTO `faculty` (`id`, `user_id`, `faculty_code`, `full_name`, `email`, `phone`, `gender`, `department`, `qualification`, `subject`, `joining_date`, `created_at`) VALUES ('3', '5', 'FAC103', 'Prof. Amit Joshi', 'amit.joshi@college.com', '9820345678', 'Male', 'Information Technology', 'M.E. (Information Tech)', 'Software Engineering', '2021-01-10', '2026-10-02 10:22:25');
INSERT INTO `faculty` (`id`, `user_id`, `faculty_code`, `full_name`, `email`, `phone`, `gender`, `department`, `qualification`, `subject`, `joining_date`, `created_at`) VALUES ('4', '14', 'FAC104', 'niraj', 'niraj12@gmail.com', '9876543210', 'Male', 'Computer Science', 'M.Sc. Computer Science', 'Artificial Intelligence', '2026-10-02', '2026-10-02 11:59:35');

-- Table: `subjects` (75 rows)
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('1', 'CS501', 'Web Technologies', 'Computer Science', 'B.Sc. Computer Science', 'Semester V', '2026-10-02 11:28:05');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('2', 'CS502', 'Database Systems', 'Computer Science', 'B.Sc. Computer Science', 'Semester V', '2026-10-02 11:28:05');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('3', 'CS503', 'Software Engineering', 'Computer Science', 'B.Sc. Computer Science', 'Semester V', '2026-10-02 11:28:05');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('4', 'CS504', 'Python Programming', 'Computer Science', 'B.Sc. Computer Science', 'Semester V', '2026-10-02 11:28:05');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('5', 'CS505', 'Computer Networks', 'Computer Science', 'B.Sc. Computer Science', 'Semester V', '2026-10-02 11:28:05');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('6', 'CS301', 'Principles of Operating Systems', 'Computer Science', 'B.Sc. Computer Science', 'Semester III', '2026-10-02 11:28:05');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('7', 'CS601', 'Cloud Computing', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI', '2026-10-02 11:28:05');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('8', 'CS602', 'Cyber Forensics & Information Security', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI', '2026-10-02 11:28:05');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('9', 'CS603', 'Information Retrieval', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI', '2026-10-02 11:28:05');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('10', 'IT501', 'Advanced Web Programming', 'Information Technology', 'B.Sc. IT', 'Semester V', '2026-10-02 11:28:05');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('11', 'CS507', 'Machine Learning & Data Mining', 'Computer Science', 'B.Sc. Computer Science', 'Semester V', '2026-10-02 11:36:07');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('12', 'SUB512', 'Robotics & Embedded Systems', 'Computer Science', 'B.Sc. Computer Science', 'Semester V', '2026-10-02 11:36:25');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('13', 'CS101', 'Computer Organization and Design', 'Computer Science', 'B.Sc. Computer Science', 'Semester I', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('14', 'CS102', 'Programming with Python - I', 'Computer Science', 'B.Sc. Computer Science', 'Semester I', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('15', 'CS103', 'Free and Open Source Software', 'Computer Science', 'B.Sc. Computer Science', 'Semester I', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('16', 'CS104', 'Database Systems Fundamentals', 'Computer Science', 'B.Sc. Computer Science', 'Semester I', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('17', 'CS105', 'Discrete Mathematics', 'Computer Science', 'B.Sc. Computer Science', 'Semester I', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('18', 'CS106', 'Descriptive Statistics', 'Computer Science', 'B.Sc. Computer Science', 'Semester I', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('19', 'CS107', 'Soft Skills Development', 'Computer Science', 'B.Sc. Computer Science', 'Semester I', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('20', 'CS201', 'Programming with C', 'Computer Science', 'B.Sc. Computer Science', 'Semester II', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('21', 'CS202', 'Programming with Python - II', 'Computer Science', 'B.Sc. Computer Science', 'Semester II', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('22', 'CS203', 'Linux Operating System', 'Computer Science', 'B.Sc. Computer Science', 'Semester II', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('23', 'CS204', 'Data Structures', 'Computer Science', 'B.Sc. Computer Science', 'Semester II', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('24', 'CS205', 'Calculus and Mathematical Methods', 'Computer Science', 'B.Sc. Computer Science', 'Semester II', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('25', 'CS206', 'Statistical Methods and Testing', 'Computer Science', 'B.Sc. Computer Science', 'Semester II', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('26', 'CS207', 'Green Technologies', 'Computer Science', 'B.Sc. Computer Science', 'Semester II', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('28', 'CS302', 'Core Java Programming', 'Computer Science', 'B.Sc. Computer Science', 'Semester III', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('29', 'CS303', 'Database Management Systems (Advanced)', 'Computer Science', 'B.Sc. Computer Science', 'Semester III', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('30', 'CS304', 'Combinatorics and Graph Theory', 'Computer Science', 'B.Sc. Computer Science', 'Semester III', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('31', 'CS305', 'Physical Computing and IoT Programming', 'Computer Science', 'B.Sc. Computer Science', 'Semester III', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('32', 'CS306', 'Web Programming and Scripting', 'Computer Science', 'B.Sc. Computer Science', 'Semester III', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('33', 'CS401', 'Fundamentals of Algorithms', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('34', 'CS402', 'Advanced Java Programming', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('35', 'CS403', 'Computer Networks and Protocols', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('36', 'CS404', 'Software Engineering Principles', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('37', 'CS405', 'Linear Algebra', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('38', 'CS406', '.NET Technologies with C#', 'Computer Science', 'B.Sc. Computer Science', 'Semester IV', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('44', 'CS506', 'Artificial Intelligence', 'Computer Science', 'B.Sc. Computer Science', 'Semester V', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('46', 'CS508', 'Linux Server Administration', 'Computer Science', 'B.Sc. Computer Science', 'Semester V', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('50', 'CS604', 'Data Science & Big Data Analytics', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('51', 'CS605', 'Ethical Hacking', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('52', 'CS606', 'Project Implementation & Viva', 'Computer Science', 'B.Sc. Computer Science', 'Semester VI', '2026-10-02 11:46:11');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('53', 'BCOM101', 'Financial Accounting - I', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('54', 'BCOM102', 'Business Economics - I', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('55', 'BCOM103', 'Commerce & Business Organization', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('56', 'BCOM104', 'Business Communication - I', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('57', 'BCOM105', 'Environmental Studies (VAC)', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('58', 'BCOM106', 'Mathematical & Statistical Techniques', 'Commerce & Management', 'Bachelor of Commerce (B.Com)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('59', 'BAF101', 'Financial Accounting - Paper I', 'Commerce & Management', 'B.Com. Accounting & Finance (BAF)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('60', 'BAF102', 'Cost Accounting - Introduction', 'Commerce & Management', 'B.Com. Accounting & Finance (BAF)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('61', 'BAF103', 'Financial Management - I', 'Commerce & Management', 'B.Com. Accounting & Finance (BAF)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('62', 'BAF104', 'Business Communication in Finance', 'Commerce & Management', 'B.Com. Accounting & Finance (BAF)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('63', 'BMS101', 'Principles of Management', 'Commerce & Management', 'Bachelor of Management Studies (BMS / BBA)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('64', 'BMS102', 'Business Law & Corporate Governance', 'Commerce & Management', 'Bachelor of Management Studies (BMS / BBA)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('65', 'BMS103', 'Business Statistics (MDC)', 'Commerce & Management', 'Bachelor of Management Studies (BMS / BBA)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('66', 'BMS104', 'Marketing Management Fundamentals', 'Commerce & Management', 'Bachelor of Management Studies (BMS / BBA)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('67', 'PHY101', 'Classical Mechanics & Wave Motion', 'Science', 'B.Sc. Physics', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('68', 'PHY102', 'Electricity, Magnetism & Electronics', 'Science', 'B.Sc. Physics', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('69', 'CHEM101', 'Inorganic & Organic Chemistry - I', 'Science', 'B.Sc. Chemistry', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('70', 'CHEM102', 'Physical Chemistry & Analytical Tools', 'Science', 'B.Sc. Chemistry', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('71', 'BT101', 'Cell Biology & Biomolecules', 'Science', 'B.Sc. Biotechnology', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('72', 'BT102', 'Microbiology & Bio-techniques', 'Science', 'B.Sc. Biotechnology', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('73', 'ENG101', 'Introduction to Literature & Drama', 'Arts & Humanities', 'B.A. English Literature', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('74', 'ENG102', 'History of English Literature', 'Arts & Humanities', 'B.A. English Literature', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('75', 'PSY101', 'Foundations of Psychology', 'Arts & Humanities', 'B.A. Psychology', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('76', 'PSY102', 'Psychology of Human Development', 'Arts & Humanities', 'B.A. Psychology', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('77', 'ECO101', 'Microeconomics Principles', 'Arts & Humanities', 'B.A. Economics', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('78', 'ECO102', 'Indian Economy in Transition', 'Arts & Humanities', 'B.A. Economics', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('79', 'MMC101', 'Fundamentals of Mass Communication', 'Arts & Humanities', 'B.A. Multimedia & Mass Communication (BAMMC)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('80', 'MMC102', 'Visual Communication & Media Writing', 'Arts & Humanities', 'B.A. Multimedia & Mass Communication (BAMMC)', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('81', 'IT101', 'Imperative Programming with C', 'Information Technology', 'B.Sc. Information Technology', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('82', 'IT102', 'Digital Electronics & Microprocessors', 'Information Technology', 'B.Sc. Information Technology', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('83', 'IT103', 'Operating Systems & CLI Architecture', 'Information Technology', 'B.Sc. Information Technology', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('84', 'IT104', 'Discrete Mathematics for IT', 'Information Technology', 'B.Sc. Information Technology', 'Semester I', '2026-10-02 12:31:54');
INSERT INTO `subjects` (`id`, `subject_code`, `subject_name`, `department`, `course`, `semester`, `created_at`) VALUES ('85', 'IT105', 'Technical Communication Skills (AEC)', 'Information Technology', 'B.Sc. Information Technology', 'Semester I', '2026-10-02 12:31:54');

-- Table: `exams` (4 rows)
INSERT INTO `exams` (`id`, `exam_name`, `exam_type`, `course`, `semester`, `subject`, `exam_date`, `created_at`) VALUES ('1', 'TYCS Semester V Unit Test', 'Internal Exam', 'B.Sc. Computer Science', 'Semester V', 'Web Technologies', '2026-08-10', '2026-10-02 10:22:25');
INSERT INTO `exams` (`id`, `exam_name`, `exam_type`, `course`, `semester`, `subject`, `exam_date`, `created_at`) VALUES ('2', 'TYCS Semester V Mid-Term Exam', 'Semester Exam', 'B.Sc. Computer Science', 'Semester V', 'Database Systems', '2026-08-25', '2026-10-02 10:22:25');
INSERT INTO `exams` (`id`, `exam_name`, `exam_type`, `course`, `semester`, `subject`, `exam_date`, `created_at`) VALUES ('3', 'TYCS Advanced Web Tech Practical', 'Practical Exam', 'B.Sc. Computer Science', 'Semester V', 'Web Technologies Lab', '2026-09-12', '2026-10-02 10:22:25');
INSERT INTO `exams` (`id`, `exam_name`, `exam_type`, `course`, `semester`, `subject`, `exam_date`, `created_at`) VALUES ('4', 'SYIT Semester III Theory Exam', 'Semester Exam', 'B.Sc. IT', 'Semester III', 'Data Structures', '2026-09-20', '2026-10-02 10:22:25');

-- Table: `attendance` (393 rows)
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('1', '1', 'Web Technologies', '2026-09-01', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('2', '1', 'Web Technologies', '2026-09-02', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('3', '1', 'Web Technologies', '2026-09-03', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('4', '1', 'Web Technologies', '2026-09-04', 'Absent', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('5', '1', 'Web Technologies', '2026-09-07', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('6', '1', 'Database Systems', '2026-09-01', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('7', '1', 'Database Systems', '2026-09-02', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('8', '1', 'Database Systems', '2026-09-03', 'Absent', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('9', '1', 'Database Systems', '2026-09-04', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('10', '1', 'Database Systems', '2026-09-07', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('11', '1', 'Software Engineering', '2026-09-01', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('12', '1', 'Software Engineering', '2026-09-02', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('13', '1', 'Software Engineering', '2026-09-03', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('14', '1', 'Software Engineering', '2026-09-04', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('15', '1', 'Software Engineering', '2026-09-07', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('16', '2', 'Web Technologies', '2026-09-01', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('17', '2', 'Web Technologies', '2026-09-02', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('18', '2', 'Web Technologies', '2026-09-03', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('19', '2', 'Web Technologies', '2026-09-04', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('20', '2', 'Web Technologies', '2026-09-07', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('21', '3', 'Web Technologies', '2026-09-01', 'Absent', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('22', '3', 'Web Technologies', '2026-09-02', 'Absent', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('23', '3', 'Web Technologies', '2026-09-03', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('24', '3', 'Web Technologies', '2026-09-04', 'Present', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('25', '3', 'Web Technologies', '2026-09-07', 'Absent', '2026-10-02 10:22:25');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('27', '5', 'Web Technologies', '2026-09-01', 'Absent', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('28', '5', 'Web Technologies', '2026-09-02', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('29', '5', 'Web Technologies', '2026-09-03', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('30', '5', 'Web Technologies', '2026-09-04', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('31', '5', 'Web Technologies', '2026-09-07', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('32', '5', 'Web Technologies', '2026-09-08', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('33', '5', 'Web Technologies', '2026-09-09', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('34', '5', 'Web Technologies', '2026-09-10', 'Absent', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('35', '5', 'Web Technologies', '2026-09-11', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('36', '5', 'Web Technologies', '2026-09-14', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('37', '5', 'Web Technologies', '2026-09-15', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('38', '5', 'Web Technologies', '2026-09-16', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('39', '5', 'Web Technologies', '2026-09-17', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('40', '5', 'Web Technologies', '2026-09-18', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('41', '5', 'Web Technologies', '2026-09-21', 'Absent', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('42', '5', 'Web Technologies', '2026-09-22', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('43', '5', 'Web Technologies', '2026-09-23', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('44', '5', 'Web Technologies', '2026-09-24', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('45', '5', 'Web Technologies', '2026-09-25', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('46', '5', 'Web Technologies', '2026-09-28', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('47', '5', 'Database Systems', '2026-09-01', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('48', '5', 'Database Systems', '2026-09-02', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('49', '5', 'Database Systems', '2026-09-03', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('50', '5', 'Database Systems', '2026-09-04', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('51', '5', 'Database Systems', '2026-09-07', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('52', '5', 'Database Systems', '2026-09-08', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('53', '5', 'Database Systems', '2026-09-09', 'Absent', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('54', '5', 'Database Systems', '2026-09-10', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('55', '5', 'Database Systems', '2026-09-11', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('56', '5', 'Database Systems', '2026-09-14', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('57', '5', 'Database Systems', '2026-09-15', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('58', '5', 'Database Systems', '2026-09-16', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('59', '5', 'Database Systems', '2026-09-17', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('60', '5', 'Database Systems', '2026-09-18', 'Absent', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('61', '5', 'Database Systems', '2026-09-21', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('62', '5', 'Database Systems', '2026-09-22', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('63', '5', 'Database Systems', '2026-09-23', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('64', '5', 'Database Systems', '2026-09-24', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('65', '5', 'Database Systems', '2026-09-25', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('66', '5', 'Database Systems', '2026-09-28', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('67', '5', 'Software Engineering', '2026-09-01', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('68', '5', 'Software Engineering', '2026-09-02', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('69', '5', 'Software Engineering', '2026-09-03', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('70', '5', 'Software Engineering', '2026-09-04', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('71', '5', 'Software Engineering', '2026-09-07', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('72', '5', 'Software Engineering', '2026-09-08', 'Absent', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('73', '5', 'Software Engineering', '2026-09-09', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('74', '5', 'Software Engineering', '2026-09-10', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('75', '5', 'Software Engineering', '2026-09-11', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('76', '5', 'Software Engineering', '2026-09-14', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('77', '5', 'Software Engineering', '2026-09-15', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('78', '5', 'Software Engineering', '2026-09-16', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('79', '5', 'Software Engineering', '2026-09-17', 'Absent', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('80', '5', 'Software Engineering', '2026-09-18', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('81', '5', 'Software Engineering', '2026-09-21', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('82', '5', 'Software Engineering', '2026-09-22', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('83', '5', 'Software Engineering', '2026-09-23', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('84', '5', 'Software Engineering', '2026-09-24', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('85', '5', 'Software Engineering', '2026-09-25', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('86', '5', 'Software Engineering', '2026-09-28', 'Absent', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('87', '5', 'Python Programming', '2026-09-01', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('88', '5', 'Python Programming', '2026-09-02', 'Present', '2026-10-02 11:46:11');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('89', '5', 'Python Programming', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('90', '5', 'Python Programming', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('91', '5', 'Python Programming', '2026-09-07', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('92', '5', 'Python Programming', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('93', '5', 'Python Programming', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('94', '5', 'Python Programming', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('95', '5', 'Python Programming', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('96', '5', 'Python Programming', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('97', '5', 'Python Programming', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('98', '5', 'Python Programming', '2026-09-16', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('99', '5', 'Python Programming', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('100', '5', 'Python Programming', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('101', '5', 'Python Programming', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('102', '5', 'Python Programming', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('103', '5', 'Python Programming', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('104', '5', 'Python Programming', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('105', '5', 'Python Programming', '2026-09-25', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('106', '5', 'Python Programming', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('107', '5', 'Computer Networks', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('108', '5', 'Computer Networks', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('109', '5', 'Computer Networks', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('110', '5', 'Computer Networks', '2026-09-04', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('111', '5', 'Computer Networks', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('112', '5', 'Computer Networks', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('113', '5', 'Computer Networks', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('114', '5', 'Computer Networks', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('115', '5', 'Computer Networks', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('116', '5', 'Computer Networks', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('117', '5', 'Computer Networks', '2026-09-15', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('118', '5', 'Computer Networks', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('119', '5', 'Computer Networks', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('120', '5', 'Computer Networks', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('121', '5', 'Computer Networks', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('122', '5', 'Computer Networks', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('123', '5', 'Computer Networks', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('124', '5', 'Computer Networks', '2026-09-24', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('125', '5', 'Computer Networks', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('126', '5', 'Computer Networks', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('127', '5', 'Artificial Intelligence', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('128', '5', 'Artificial Intelligence', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('129', '5', 'Artificial Intelligence', '2026-09-03', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('130', '5', 'Artificial Intelligence', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('131', '5', 'Artificial Intelligence', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('132', '5', 'Artificial Intelligence', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('133', '5', 'Artificial Intelligence', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('134', '5', 'Artificial Intelligence', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('135', '5', 'Artificial Intelligence', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('136', '5', 'Artificial Intelligence', '2026-09-14', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('137', '5', 'Artificial Intelligence', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('138', '5', 'Artificial Intelligence', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('139', '5', 'Artificial Intelligence', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('140', '5', 'Artificial Intelligence', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('141', '5', 'Artificial Intelligence', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('142', '5', 'Artificial Intelligence', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('143', '5', 'Artificial Intelligence', '2026-09-23', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('144', '5', 'Artificial Intelligence', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('145', '5', 'Artificial Intelligence', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('146', '5', 'Artificial Intelligence', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('147', '6', 'Web Technologies', '2026-09-01', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('148', '6', 'Web Technologies', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('149', '6', 'Web Technologies', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('150', '6', 'Web Technologies', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('151', '6', 'Web Technologies', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('152', '6', 'Web Technologies', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('153', '6', 'Web Technologies', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('154', '6', 'Web Technologies', '2026-09-10', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('155', '6', 'Web Technologies', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('156', '6', 'Web Technologies', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('157', '6', 'Web Technologies', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('158', '6', 'Web Technologies', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('159', '6', 'Web Technologies', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('160', '6', 'Web Technologies', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('161', '6', 'Web Technologies', '2026-09-21', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('162', '6', 'Web Technologies', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('163', '6', 'Web Technologies', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('164', '6', 'Web Technologies', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('165', '6', 'Web Technologies', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('166', '6', 'Web Technologies', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('167', '6', 'Database Systems', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('168', '6', 'Database Systems', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('169', '6', 'Database Systems', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('170', '6', 'Database Systems', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('171', '6', 'Database Systems', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('172', '6', 'Database Systems', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('173', '6', 'Database Systems', '2026-09-09', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('174', '6', 'Database Systems', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('175', '6', 'Database Systems', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('176', '6', 'Database Systems', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('177', '6', 'Database Systems', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('178', '6', 'Database Systems', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('179', '6', 'Database Systems', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('180', '6', 'Database Systems', '2026-09-18', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('181', '6', 'Database Systems', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('182', '6', 'Database Systems', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('183', '6', 'Database Systems', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('184', '6', 'Database Systems', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('185', '6', 'Database Systems', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('186', '6', 'Database Systems', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('187', '6', 'Software Engineering', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('188', '6', 'Software Engineering', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('189', '6', 'Software Engineering', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('190', '6', 'Software Engineering', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('191', '6', 'Software Engineering', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('192', '6', 'Software Engineering', '2026-09-08', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('193', '6', 'Software Engineering', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('194', '6', 'Software Engineering', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('195', '6', 'Software Engineering', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('196', '6', 'Software Engineering', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('197', '6', 'Software Engineering', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('198', '6', 'Software Engineering', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('199', '6', 'Software Engineering', '2026-09-17', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('200', '6', 'Software Engineering', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('201', '6', 'Software Engineering', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('202', '6', 'Software Engineering', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('203', '6', 'Software Engineering', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('204', '6', 'Software Engineering', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('205', '6', 'Software Engineering', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('206', '6', 'Software Engineering', '2026-09-28', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('207', '6', 'Python Programming', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('208', '6', 'Python Programming', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('209', '6', 'Python Programming', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('210', '6', 'Python Programming', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('211', '6', 'Python Programming', '2026-09-07', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('212', '6', 'Python Programming', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('213', '6', 'Python Programming', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('214', '6', 'Python Programming', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('215', '6', 'Python Programming', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('216', '6', 'Python Programming', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('217', '6', 'Python Programming', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('218', '6', 'Python Programming', '2026-09-16', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('219', '6', 'Python Programming', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('220', '6', 'Python Programming', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('221', '6', 'Python Programming', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('222', '6', 'Python Programming', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('223', '6', 'Python Programming', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('224', '6', 'Python Programming', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('225', '6', 'Python Programming', '2026-09-25', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('226', '6', 'Python Programming', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('227', '6', 'Computer Networks', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('228', '6', 'Computer Networks', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('229', '6', 'Computer Networks', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('230', '6', 'Computer Networks', '2026-09-04', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('231', '6', 'Computer Networks', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('232', '6', 'Computer Networks', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('233', '6', 'Computer Networks', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('234', '6', 'Computer Networks', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('235', '6', 'Computer Networks', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('236', '6', 'Computer Networks', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('237', '6', 'Computer Networks', '2026-09-15', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('238', '6', 'Computer Networks', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('239', '6', 'Computer Networks', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('240', '6', 'Computer Networks', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('241', '6', 'Computer Networks', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('242', '6', 'Computer Networks', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('243', '6', 'Computer Networks', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('244', '6', 'Computer Networks', '2026-09-24', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('245', '6', 'Computer Networks', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('246', '6', 'Computer Networks', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('247', '6', 'Artificial Intelligence', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('248', '6', 'Artificial Intelligence', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('249', '6', 'Artificial Intelligence', '2026-09-03', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('250', '6', 'Artificial Intelligence', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('251', '6', 'Artificial Intelligence', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('252', '6', 'Artificial Intelligence', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('253', '6', 'Artificial Intelligence', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('254', '6', 'Artificial Intelligence', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('255', '6', 'Artificial Intelligence', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('256', '6', 'Artificial Intelligence', '2026-09-14', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('257', '6', 'Artificial Intelligence', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('258', '6', 'Artificial Intelligence', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('259', '6', 'Artificial Intelligence', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('260', '6', 'Artificial Intelligence', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('261', '6', 'Artificial Intelligence', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('262', '6', 'Artificial Intelligence', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('263', '6', 'Artificial Intelligence', '2026-09-23', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('264', '6', 'Artificial Intelligence', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('265', '6', 'Artificial Intelligence', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('266', '6', 'Artificial Intelligence', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('267', '7', 'Web Technologies', '2026-09-01', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('268', '7', 'Web Technologies', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('269', '7', 'Web Technologies', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('270', '7', 'Web Technologies', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('271', '7', 'Web Technologies', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('272', '7', 'Web Technologies', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('273', '7', 'Web Technologies', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('274', '7', 'Web Technologies', '2026-09-10', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('275', '7', 'Web Technologies', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('276', '7', 'Web Technologies', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('277', '7', 'Web Technologies', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('278', '7', 'Web Technologies', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('279', '7', 'Web Technologies', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('280', '7', 'Web Technologies', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('281', '7', 'Web Technologies', '2026-09-21', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('282', '7', 'Web Technologies', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('283', '7', 'Web Technologies', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('284', '7', 'Web Technologies', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('285', '7', 'Web Technologies', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('286', '7', 'Web Technologies', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('287', '7', 'Database Systems', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('288', '7', 'Database Systems', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('289', '7', 'Database Systems', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('290', '7', 'Database Systems', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('291', '7', 'Database Systems', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('292', '7', 'Database Systems', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('293', '7', 'Database Systems', '2026-09-09', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('294', '7', 'Database Systems', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('295', '7', 'Database Systems', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('296', '7', 'Database Systems', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('297', '7', 'Database Systems', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('298', '7', 'Database Systems', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('299', '7', 'Database Systems', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('300', '7', 'Database Systems', '2026-09-18', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('301', '7', 'Database Systems', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('302', '7', 'Database Systems', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('303', '7', 'Database Systems', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('304', '7', 'Database Systems', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('305', '7', 'Database Systems', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('306', '7', 'Database Systems', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('307', '7', 'Software Engineering', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('308', '7', 'Software Engineering', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('309', '7', 'Software Engineering', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('310', '7', 'Software Engineering', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('311', '7', 'Software Engineering', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('312', '7', 'Software Engineering', '2026-09-08', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('313', '7', 'Software Engineering', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('314', '7', 'Software Engineering', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('315', '7', 'Software Engineering', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('316', '7', 'Software Engineering', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('317', '7', 'Software Engineering', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('318', '7', 'Software Engineering', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('319', '7', 'Software Engineering', '2026-09-17', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('320', '7', 'Software Engineering', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('321', '7', 'Software Engineering', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('322', '7', 'Software Engineering', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('323', '7', 'Software Engineering', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('324', '7', 'Software Engineering', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('325', '7', 'Software Engineering', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('326', '7', 'Software Engineering', '2026-09-28', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('327', '7', 'Python Programming', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('328', '7', 'Python Programming', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('329', '7', 'Python Programming', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('330', '7', 'Python Programming', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('331', '7', 'Python Programming', '2026-09-07', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('332', '7', 'Python Programming', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('333', '7', 'Python Programming', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('334', '7', 'Python Programming', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('335', '7', 'Python Programming', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('336', '7', 'Python Programming', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('337', '7', 'Python Programming', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('338', '7', 'Python Programming', '2026-09-16', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('339', '7', 'Python Programming', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('340', '7', 'Python Programming', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('341', '7', 'Python Programming', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('342', '7', 'Python Programming', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('343', '7', 'Python Programming', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('344', '7', 'Python Programming', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('345', '7', 'Python Programming', '2026-09-25', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('346', '7', 'Python Programming', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('347', '7', 'Computer Networks', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('348', '7', 'Computer Networks', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('349', '7', 'Computer Networks', '2026-09-03', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('350', '7', 'Computer Networks', '2026-09-04', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('351', '7', 'Computer Networks', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('352', '7', 'Computer Networks', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('353', '7', 'Computer Networks', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('354', '7', 'Computer Networks', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('355', '7', 'Computer Networks', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('356', '7', 'Computer Networks', '2026-09-14', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('357', '7', 'Computer Networks', '2026-09-15', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('358', '7', 'Computer Networks', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('359', '7', 'Computer Networks', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('360', '7', 'Computer Networks', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('361', '7', 'Computer Networks', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('362', '7', 'Computer Networks', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('363', '7', 'Computer Networks', '2026-09-23', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('364', '7', 'Computer Networks', '2026-09-24', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('365', '7', 'Computer Networks', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('366', '7', 'Computer Networks', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('367', '7', 'Artificial Intelligence', '2026-09-01', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('368', '7', 'Artificial Intelligence', '2026-09-02', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('369', '7', 'Artificial Intelligence', '2026-09-03', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('370', '7', 'Artificial Intelligence', '2026-09-04', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('371', '7', 'Artificial Intelligence', '2026-09-07', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('372', '7', 'Artificial Intelligence', '2026-09-08', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('373', '7', 'Artificial Intelligence', '2026-09-09', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('374', '7', 'Artificial Intelligence', '2026-09-10', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('375', '7', 'Artificial Intelligence', '2026-09-11', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('376', '7', 'Artificial Intelligence', '2026-09-14', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('377', '7', 'Artificial Intelligence', '2026-09-15', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('378', '7', 'Artificial Intelligence', '2026-09-16', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('379', '7', 'Artificial Intelligence', '2026-09-17', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('380', '7', 'Artificial Intelligence', '2026-09-18', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('381', '7', 'Artificial Intelligence', '2026-09-21', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('382', '7', 'Artificial Intelligence', '2026-09-22', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('383', '7', 'Artificial Intelligence', '2026-09-23', 'Absent', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('384', '7', 'Artificial Intelligence', '2026-09-24', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('385', '7', 'Artificial Intelligence', '2026-09-25', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('386', '7', 'Artificial Intelligence', '2026-09-28', 'Present', '2026-10-02 11:46:12');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('395', '8', 'Computer Networks', '2026-10-02', 'Absent', '2026-10-02 12:03:52');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('396', '6', 'Computer Networks', '2026-10-02', 'Present', '2026-10-02 12:03:52');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('397', '7', 'Computer Networks', '2026-10-02', 'Present', '2026-10-02 12:03:52');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('398', '4', 'Computer Networks', '2026-10-02', 'Present', '2026-10-02 12:03:52');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('399', '1', 'Computer Networks', '2026-10-02', 'Absent', '2026-10-02 12:03:52');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('400', '2', 'Computer Networks', '2026-10-02', 'Present', '2026-10-02 12:03:52');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('401', '3', 'Computer Networks', '2026-10-02', 'Present', '2026-10-02 12:03:52');
INSERT INTO `attendance` (`id`, `student_id`, `subject`, `attendance_date`, `status`, `created_at`) VALUES ('402', '5', 'Computer Networks', '2026-10-02', 'Absent', '2026-10-02 12:03:52');

-- Table: `fees` (8 rows)
INSERT INTO `fees` (`id`, `student_id`, `academic_year`, `total_fees`, `paid_amount`, `pending_amount`, `payment_date`, `payment_status`, `created_at`) VALUES ('1', '1', '2025-2026', '45000.00', '45000.00', '0.00', '2025-07-10', 'Paid', '2026-10-02 10:22:25');
INSERT INTO `fees` (`id`, `student_id`, `academic_year`, `total_fees`, `paid_amount`, `pending_amount`, `payment_date`, `payment_status`, `created_at`) VALUES ('2', '1', '2026-2027', '48000.00', '30000.00', '18000.00', '2026-06-25', 'Partially Paid', '2026-10-02 10:22:25');
INSERT INTO `fees` (`id`, `student_id`, `academic_year`, `total_fees`, `paid_amount`, `pending_amount`, `payment_date`, `payment_status`, `created_at`) VALUES ('3', '2', '2026-2027', '48000.00', '48000.00', '0.00', '2026-06-20', 'Paid', '2026-10-02 10:22:25');
INSERT INTO `fees` (`id`, `student_id`, `academic_year`, `total_fees`, `paid_amount`, `pending_amount`, `payment_date`, `payment_status`, `created_at`) VALUES ('4', '3', '2026-2027', '48000.00', '0.00', '48000.00', '2026-06-15', 'Pending', '2026-10-02 10:22:25');
INSERT INTO `fees` (`id`, `student_id`, `academic_year`, `total_fees`, `paid_amount`, `pending_amount`, `payment_date`, `payment_status`, `created_at`) VALUES ('5', '4', '2026-2027', '42000.00', '25000.00', '17000.00', '2026-07-05', 'Partially Paid', '2026-10-02 10:22:25');
INSERT INTO `fees` (`id`, `student_id`, `academic_year`, `total_fees`, `paid_amount`, `pending_amount`, `payment_date`, `payment_status`, `created_at`) VALUES ('6', '3', '2026-2027', '47999.95', '40000.00', '7999.95', '2026-10-02', 'Partially Paid', '2026-10-02 11:50:28');
INSERT INTO `fees` (`id`, `student_id`, `academic_year`, `total_fees`, `paid_amount`, `pending_amount`, `payment_date`, `payment_status`, `created_at`) VALUES ('7', '8', '2026-2027', '48000.00', '34999.98', '13000.02', '2026-10-02', 'Partially Paid', '2026-10-02 11:56:34');
INSERT INTO `fees` (`id`, `student_id`, `academic_year`, `total_fees`, `paid_amount`, `pending_amount`, `payment_date`, `payment_status`, `created_at`) VALUES ('8', '7', '2026-2027', '48000.00', '48000.00', '0.00', '2026-06-22', 'Paid', '2026-10-02 12:09:47');

-- Table: `marks` (12 rows)
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('1', '1', '1', 'Web Technologies', '50.00', '44.00', '88.00', 'A', 'Pass', '2026-10-02 10:22:25');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('2', '1', '2', 'Database Systems', '100.00', '86.00', '86.00', 'A', 'Pass', '2026-10-02 10:22:25');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('3', '1', '3', 'Web Technologies Lab', '50.00', '46.00', '92.00', 'A+', 'Pass', '2026-10-02 10:22:25');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('4', '2', '1', 'Web Technologies', '50.00', '48.00', '96.00', 'A+', 'Pass', '2026-10-02 10:22:25');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('5', '2', '2', 'Database Systems', '100.00', '91.00', '91.00', 'A+', 'Pass', '2026-10-02 10:22:25');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('6', '3', '1', 'Web Technologies', '50.00', '22.00', '44.00', 'F', 'Fail', '2026-10-02 10:22:25');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('7', '3', '2', 'Database Systems', '100.00', '48.00', '48.00', 'F', 'Fail', '2026-10-02 10:22:25');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('8', '6', '4', 'Data Structures', '100.00', '60.00', '60.00', 'C', 'Pass', '2026-10-02 11:53:10');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('9', '8', '2', 'Database Systems', '100.00', '75.00', '75.00', 'B', 'Pass', '2026-10-02 11:57:10');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('10', '7', '1', 'Web Technologies', '50.00', '46.00', '92.00', 'A+', 'Pass', '2026-10-02 12:09:47');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('11', '7', '2', 'Database Systems', '100.00', '88.00', '88.00', 'A', 'Pass', '2026-10-02 12:09:47');
INSERT INTO `marks` (`id`, `student_id`, `exam_id`, `subject`, `max_marks`, `obtained_marks`, `percentage`, `grade`, `result_status`, `created_at`) VALUES ('12', '7', '3', 'Web Technologies Lab', '50.00', '47.00', '94.00', 'A+', 'Pass', '2026-10-02 12:09:47');

-- Table: `notices` (4 rows)
INSERT INTO `notices` (`id`, `title`, `description`, `posted_date`, `posted_by`, `target_audience`, `created_at`) VALUES ('1', 'TYCS Mini Project Submission & Viva Schedule', 'All TYCS students are hereby notified that the final submission of the mini project along with documentation is scheduled between 15th Oct and 20th Oct 2026. Viva will be conducted in the Computer Lab 3.', '2026-10-01', 'Admin', 'Students', '2026-10-02 10:22:25');
INSERT INTO `notices` (`id`, `title`, `description`, `posted_date`, `posted_by`, `target_audience`, `created_at`) VALUES ('2', 'Faculty Meeting for NAAC Accreditation Preparation', 'A mandatory meeting for all faculty members will be held on Friday at 3:00 PM in Conference Room A to discuss the criteria and documentation for the upcoming NAAC peer team visit.', '2026-09-28', 'Admin', 'Faculty', '2026-10-02 10:22:25');
INSERT INTO `notices` (`id`, `title`, `description`, `posted_date`, `posted_by`, `target_audience`, `created_at`) VALUES ('3', 'Annual Sports and Cultural Fest - Zephyr 2026', 'College is delighted to announce our annual inter-collegiate fest Zephyr 2026 from 10th November. Registration for sports, dance, coding hackathons, and drama starts next Monday.', '2026-09-25', 'Admin', 'All', '2026-10-02 10:22:25');
INSERT INTO `notices` (`id`, `title`, `description`, `posted_date`, `posted_by`, `target_audience`, `created_at`) VALUES ('4', 'Semester V Examination Hall Tickets Available', 'Students are advised to collect their Semester V Examination Hall Tickets from the admin counter after clearing any pending fee dues before 5th October 2026.', '2026-09-20', 'Admin', 'Students', '2026-10-02 10:22:25');

