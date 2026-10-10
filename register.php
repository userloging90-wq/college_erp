<?php
// ==========================================================
// Student Registration Shortcut
// College ERP Management System - TYCS Mini Project
// ==========================================================
require_once __DIR__ . '/config/db.php';

// Redirect to registration tab on the main authentication portal
redirect(BASE_URL . '/login.php?tab=register');
