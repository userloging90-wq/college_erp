<?php
// ==========================================================
// Database Converter: MySQL (college_erp) -> SQLite
// College ERP Management System - TYCS Mini Project
// ==========================================================
header('Content-Type: text/plain');

$mysqlHost = 'localhost';
$mysqlDb   = 'college_erp';
$mysqlUser = 'root';
$mysqlPass = '';
$sqliteFile = __DIR__ . '/college_erp.sqlite';
$sqliteSqlFile = __DIR__ . '/database_sqlite.sql';

echo "=== College ERP Database: MySQL to SQLite Converter ===\n\n";

try {
    // 1. Connect to MySQL
    $mysqlDsn = "mysql:host={$mysqlHost};dbname={$mysqlDb};charset=utf8mb4";
    $mysqlPdo = new PDO($mysqlDsn, $mysqlUser, $mysqlPass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    echo "[OK] Connected to MySQL database '{$mysqlDb}'.\n";

    // 2. Remove old SQLite database file if exists to start fresh
    if (file_exists($sqliteFile)) {
        unlink($sqliteFile);
        echo "[INFO] Removed existing {$sqliteFile}.\n";
    }

    // 3. Connect to SQLite
    $sqlitePdo = new PDO("sqlite:" . $sqliteFile, null, null, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    $sqlitePdo->exec("PRAGMA foreign_keys = ON;");
    echo "[OK] Created and connected to SQLite database '{$sqliteFile}'.\n\n";

    // 4. Define SQLite Schema
    $schemas = [
        'users' => "
            CREATE TABLE IF NOT EXISTS `users` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `name` TEXT NOT NULL,
                `email` TEXT NOT NULL UNIQUE,
                `password` TEXT NOT NULL,
                `role` TEXT NOT NULL CHECK (`role` IN ('admin', 'faculty', 'student')),
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP
            );
        ",
        'departments' => "
            CREATE TABLE IF NOT EXISTS `departments` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `department_code` TEXT NOT NULL UNIQUE,
                `department_name` TEXT NOT NULL UNIQUE,
                `faculty_stream` TEXT NOT NULL,
                `description` TEXT,
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP
            );
        ",
        'courses' => "
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
        ",
        'students' => "
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
        ",
        'faculty' => "
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
        ",
        'subjects' => "
            CREATE TABLE IF NOT EXISTS `subjects` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `subject_code` TEXT NOT NULL UNIQUE,
                `subject_name` TEXT NOT NULL,
                `department` TEXT NOT NULL,
                `course` TEXT NOT NULL,
                `semester` TEXT NOT NULL,
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP
            );
        ",
        'attendance' => "
            CREATE TABLE IF NOT EXISTS `attendance` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `student_id` INTEGER NOT NULL,
                `subject` TEXT NOT NULL,
                `attendance_date` TEXT NOT NULL,
                `status` TEXT NOT NULL CHECK (`status` IN ('Present', 'Absent')),
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
            );
        ",
        'fees' => "
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
        ",
        'exams' => "
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
        ",
        'marks' => "
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
        ",
        'notices' => "
            CREATE TABLE IF NOT EXISTS `notices` (
                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                `title` TEXT NOT NULL,
                `description` TEXT NOT NULL,
                `posted_date` TEXT NOT NULL,
                `posted_by` TEXT NOT NULL DEFAULT 'Admin',
                `target_audience` TEXT NOT NULL DEFAULT 'All' CHECK (`target_audience` IN ('All', 'Students', 'Faculty')),
                `created_at` TEXT DEFAULT CURRENT_TIMESTAMP
            );
        "
    ];

    // Start SQL dump string
    $sqlDump = "-- ==========================================================\n";
    $sqlDump .= "-- College ERP Management System - SQLite Database Dump\n";
    $sqlDump .= "-- Converted from MySQL `college_erp`\n";
    $sqlDump .= "-- Compatible with SQLite 3 / PDO SQLite\n";
    $sqlDump .= "-- ==========================================================\n\n";
    $sqlDump .= "PRAGMA foreign_keys = ON;\n\n";

    echo "--- Creating SQLite Tables ---\n";
    foreach ($schemas as $tableName => $schemaSql) {
        $sqlitePdo->exec($schemaSql);
        $sqlDump .= trim($schemaSql) . "\n\n";
        echo "[+] Table '{$tableName}' created in SQLite.\n";
    }

    echo "\n--- Migrating Data from MySQL to SQLite ---\n";

    // Tables in insertion order to honor foreign key constraints
    $tableOrder = [
        'users',
        'departments',
        'courses',
        'students',
        'faculty',
        'subjects',
        'exams',
        'attendance',
        'fees',
        'marks',
        'notices'
    ];

    $sqlDump .= "-- ==========================================================\n";
    $sqlDump .= "-- DATA MIGRATION INSERTS\n";
    $sqlDump .= "-- ==========================================================\n\n";

    foreach ($tableOrder as $table) {
        $rows = $mysqlPdo->query("SELECT * FROM `{$table}` ORDER BY id ASC")->fetchAll();
        $rowCount = count($rows);

        if ($rowCount > 0) {
            $columns = array_keys($rows[0]);
            $colList = implode(', ', array_map(function($c) { return "`{$c}`"; }, $columns));
            $placeholders = implode(', ', array_fill(0, count($columns), '?'));

            $insStmt = $sqlitePdo->prepare("INSERT INTO `{$table}` ({$colList}) VALUES ({$placeholders})");

            $sqlDump .= "-- Table: `{$table}` ({$rowCount} rows)\n";

            $sqlitePdo->beginTransaction();
            foreach ($rows as $row) {
                $values = array_values($row);
                $insStmt->execute($values);

                // Format values for SQL dump
                $escapedVals = array_map(function($val) {
                    if ($val === null) return 'NULL';
                    if (is_numeric($val) && !is_string($val)) return $val;
                    return "'" . str_replace("'", "''", $val) . "'";
                }, $values);
                $sqlDump .= "INSERT INTO `{$table}` ({$colList}) VALUES (" . implode(', ', $escapedVals) . ");\n";
            }
            $sqlitePdo->commit();
            $sqlDump .= "\n";
        }

        echo "  -> Migrated {$rowCount} rows into '{$table}'.\n";
    }

    // Save SQLite SQL Dump file
    file_put_contents($sqliteSqlFile, $sqlDump);
    echo "\n[OK] Generated SQL dump: '{$sqliteSqlFile}' (" . round(filesize($sqliteSqlFile) / 1024, 2) . " KB).\n";
    echo "[OK] Generated SQLite database file: '{$sqliteFile}' (" . round(filesize($sqliteFile) / 1024, 2) . " KB).\n\n";

    echo "=== Conversion Completed Successfully! ===\n";

} catch (Exception $e) {
    if (isset($sqlitePdo) && $sqlitePdo->inTransaction()) {
        $sqlitePdo->rollBack();
    }
    echo "[ERROR] " . $e->getMessage() . "\n";
    exit(1);
}
