<?php
// ==========================================================
// College ERP Management System - Main Entry Point
// ==========================================================
require_once __DIR__ . '/config/db.php';

if (isset($_SESSION['user_id']) && isset($_SESSION['user_role'])) {
    switch ($_SESSION['user_role']) {
        case 'admin':
            redirect(BASE_URL . '/admin/dashboard.php');
            break;
        case 'faculty':
            redirect(BASE_URL . '/faculty/dashboard.php');
            break;
        case 'student':
            redirect(BASE_URL . '/student/dashboard.php');
            break;
    }
}

redirect(BASE_URL . '/login.php');
