<?php
// ==========================================================
// User Authentication & Student Registration Portal
// College ERP Management System - TYCS Mini Project
// ==========================================================
require_once __DIR__ . '/config/db.php';

// Redirect if already logged in
if (isset($_SESSION['user_id']) && isset($_SESSION['user_role'])) {
    if ($_SESSION['user_role'] === 'admin') redirect(BASE_URL . '/admin/dashboard.php');
    if ($_SESSION['user_role'] === 'faculty') redirect(BASE_URL . '/faculty/dashboard.php');
    if ($_SESSION['user_role'] === 'student') redirect(BASE_URL . '/student/dashboard.php');
}

// Compute next suggested Registration ID and Student Code
$lastId = $pdo->query("SELECT MAX(id) FROM students")->fetchColumn() ?: 0;
$suggestedRegId = 'REG2026' . str_pad($lastId + 1, 3, '0', STR_PAD_LEFT);
$suggestedCode = 'STU' . (100 + $lastId + 1);

// Determine active tab: Default is 'register' (Registration first, then Login)
$activeTab = $_GET['tab'] ?? 'register';
if (!in_array($activeTab, ['register', 'login'])) {
    $activeTab = 'register';
}

$loginError = '';
$regErrors = [];
$loginInputVal = trim($_GET['email'] ?? '');
$nepStructure = getNepDepartmentsWithCourses($pdo);

$regData = [
    'full_name'   => '',
    'email'       => '',
    'phone'       => '',
    'gender'      => 'Male',
    'dob'         => '',
    'department'  => 'Computer Science',
    'course'      => 'B.Sc. Computer Science',
    'year'        => 'TY',
    'division'    => 'A',
    'roll_number' => '',
    'address'     => ''
];

// ==========================================================
// HANDLE FORM SUBMISSIONS
// ==========================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $actionType = $_POST['action_type'] ?? 'login';

    // ------------------------------------------------------
    // 1. STUDENT REGISTRATION LOGIC
    // ------------------------------------------------------
    if ($actionType === 'register') {
        $activeTab = 'register';

        $regData['full_name']   = trim($_POST['full_name'] ?? '');
        $regData['email']       = trim($_POST['email'] ?? '');
        $password               = $_POST['password'] ?? '';
        $confirmPassword        = $_POST['confirm_password'] ?? '';
        $regData['phone']       = trim($_POST['phone'] ?? '');
        $regData['gender']      = trim($_POST['gender'] ?? 'Male');
        $regData['dob']         = trim($_POST['dob'] ?? '');
        $regData['department']  = trim($_POST['department'] ?? 'Computer Science');
        $regData['course']      = trim($_POST['course'] ?? 'B.Sc. Computer Science');
        $regData['year']        = trim($_POST['year'] ?? 'TY');
        $regData['division']    = trim($_POST['division'] ?? 'A');
        $regData['roll_number'] = strtoupper(trim($_POST['roll_number'] ?? ''));
        $regData['address']     = trim($_POST['address'] ?? '');

        // Validations
        if (empty($regData['full_name'])) {
            $regErrors[] = 'Full Name is required.';
        }
        if (empty($regData['email']) || !filter_var($regData['email'], FILTER_VALIDATE_EMAIL)) {
            $regErrors[] = 'A valid email address is required (e.g. name@college.com).';
        }
        if (strlen($password) < 6) {
            $regErrors[] = 'Password must be at least 6 characters long.';
        }
        if ($password !== $confirmPassword) {
            $regErrors[] = 'Password and Confirm Password do not match.';
        }
        if (empty($regData['phone']) || strlen($regData['phone']) < 10) {
            $regErrors[] = 'Please enter a valid 10-digit mobile number.';
        }
        if (empty($regData['dob'])) {
            $regErrors[] = 'Date of birth is required.';
        }

        // Duplicate Email check
        if (empty($regErrors)) {
            $chk = $pdo->prepare("SELECT id FROM users WHERE email = ?");
            $chk->execute([$regData['email']]);
            if ($chk->fetch()) {
                $regErrors[] = "An account with email '{$regData['email']}' already exists. Please sign in instead.";
            }
        }

        // Database Insertion
        if (empty($regErrors)) {
            try {
                $pdo->beginTransaction();

                // Compute fresh unique Registration ID
                $maxId = $pdo->query("SELECT MAX(id) FROM students")->fetchColumn() ?: 0;
                $regNum = $maxId + 1;
                do {
                    $newRegId = 'REG2026' . str_pad($regNum, 3, '0', STR_PAD_LEFT);
                    $chkReg = $pdo->prepare("SELECT id FROM students WHERE registration_id = ?");
                    $chkReg->execute([$newRegId]);
                    if ($chkReg->fetch()) {
                        $regNum++;
                    } else {
                        break;
                    }
                } while (true);

                // Compute fresh unique Student Code
                $codeNum = 100 + $maxId + 1;
                do {
                    $newCode = 'STU' . $codeNum;
                    $chkCode = $pdo->prepare("SELECT id FROM students WHERE student_code = ?");
                    $chkCode->execute([$newCode]);
                    if ($chkCode->fetch()) {
                        $codeNum++;
                    } else {
                        break;
                    }
                } while (true);

                // Auto-generate Roll Number if left blank
                $finalRoll = $regData['roll_number'];
                if (empty($finalRoll)) {
                    $finalRoll = 'TYCS-' . str_pad($regNum, 2, '0', STR_PAD_LEFT);
                }

                // 1. Create User Account in `users` table
                $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
                $insUser = $pdo->prepare("INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, 'student')");
                $insUser->execute([$regData['full_name'], $regData['email'], $hashedPassword]);
                $newUserId = $pdo->lastInsertId();

                // 2. Create Student Record in `students` table
                $insStu = $pdo->prepare("
                    INSERT INTO students 
                    (user_id, student_code, registration_id, full_name, email, phone, gender, dob, address, department, course, year, division, roll_number, admission_date) 
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ");
                $insStu->execute([
                    $newUserId,
                    $newCode,
                    $newRegId,
                    $regData['full_name'],
                    $regData['email'],
                    $regData['phone'],
                    $regData['gender'],
                    $regData['dob'],
                    $regData['address'],
                    $regData['department'],
                    $regData['course'],
                    $regData['year'],
                    $regData['division'],
                    $finalRoll,
                    date('Y-m-d')
                ]);

                $pdo->commit();

                // Store registration info for celebratory message
                $_SESSION['new_registration'] = [
                    'name'   => $regData['full_name'],
                    'reg_id' => $newRegId,
                    'code'   => $newCode,
                    'roll'   => $finalRoll,
                    'email'  => $regData['email']
                ];

                setFlash('success', "Registration Successful! Your Official Registration ID is <strong>{$newRegId}</strong>. You can now log in below.");
                redirect(BASE_URL . '/login.php?tab=login&email=' . urlencode($newRegId));
            } catch (Exception $e) {
                $pdo->rollBack();
                $regErrors[] = 'Database error during registration: ' . $e->getMessage();
            }
        }
    }

    // ------------------------------------------------------
    // 2. USER LOGIN LOGIC
    // ------------------------------------------------------
    elseif ($actionType === 'login') {
        $activeTab = 'login';
        $loginInput = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';
        $loginInputVal = $loginInput;

        if (empty($loginInput) || empty($password)) {
            $loginError = 'Please enter both your Email / Registration ID and Password.';
        } else {
            // Query user by Email OR Student Registration ID OR Student Code
            $stmt = $pdo->prepare("
                SELECT u.* 
                FROM users u
                LEFT JOIN students s ON u.id = s.user_id
                WHERE u.email = ? OR s.registration_id = ? OR s.student_code = ?
                LIMIT 1
            ");
            $stmt->execute([$loginInput, $loginInput, $loginInput]);
            $user = $stmt->fetch();

            if ($user && password_verify($password, $user['password'])) {
                // Initialize session
                $_SESSION['user_id'] = $user['id'];
                $_SESSION['user_name'] = $user['name'];
                $_SESSION['user_email'] = $user['email'];
                $_SESSION['user_role'] = $user['role'];

                // Link role specific data
                if ($user['role'] === 'student') {
                    $stuStmt = $pdo->prepare("SELECT * FROM students WHERE user_id = ? OR email = ? LIMIT 1");
                    $stuStmt->execute([$user['id'], $user['email']]);
                    $stu = $stuStmt->fetch();
                    if ($stu) {
                        $_SESSION['student_record_id'] = $stu['id'];
                        $_SESSION['student_code'] = $stu['student_code'];
                        $_SESSION['student_reg_id'] = $stu['registration_id'];
                        $_SESSION['student_course'] = $stu['course'];
                        $_SESSION['student_roll'] = $stu['roll_number'];
                    }
                    unset($_SESSION['new_registration']);
                    setFlash('success', 'Welcome back, ' . $user['name'] . '!');
                    redirect(BASE_URL . '/student/dashboard.php');
                } elseif ($user['role'] === 'faculty') {
                    $facStmt = $pdo->prepare("SELECT * FROM faculty WHERE user_id = ? OR email = ? LIMIT 1");
                    $facStmt->execute([$user['id'], $user['email']]);
                    $fac = $facStmt->fetch();
                    if ($fac) {
                        $_SESSION['faculty_record_id'] = $fac['id'];
                        $_SESSION['faculty_code'] = $fac['faculty_code'];
                        $_SESSION['faculty_dept'] = $fac['department'];
                    }
                    setFlash('success', 'Welcome back, Prof. ' . $user['name'] . '!');
                    redirect(BASE_URL . '/faculty/dashboard.php');
                } else {
                    setFlash('success', 'Welcome Administrator!');
                    redirect(BASE_URL . '/admin/dashboard.php');
                }
            } else {
                $loginError = 'Invalid email or password. Please try again.';
            }
        }
    }
}

$flash = getFlash();
$newRegInfo = $_SESSION['new_registration'] ?? null;
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= $activeTab === 'register' ? 'Student Registration' : 'Login' ?> - College ERP Management System</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="<?= BASE_URL ?>/assets/css/style.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #1e3a8a 0%, #0f172a 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px 15px;
        }
        .auth-container {
            max-width: 600px;
            width: 100%;
        }
        .auth-card {
            background: #ffffff;
            border-radius: 18px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .auth-header {
            background: #ffffff;
            padding: 2rem 2rem 1.25rem;
            text-align: center;
        }
        .auth-icon {
            width: 68px;
            height: 68px;
            background: #dbeafe;
            color: #1d4ed8;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2.1rem;
            margin-bottom: 0.85rem;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);
        }
        .nav-auth-tabs {
            background: #f1f5f9;
            padding: 5px;
            border-radius: 12px;
            margin: 0 1.5rem 1.5rem;
        }
        .btn-tab {
            border-radius: 9px;
            font-weight: 600;
            font-size: 0.92rem;
            color: #64748b;
            border: none;
            padding: 10px 18px;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }
        .btn-tab.active {
            background: #ffffff;
            color: #1d4ed8;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }
        .btn-tab:hover:not(.active) {
            color: #1e293b;
            background: rgba(255, 255, 255, 0.5);
        }
        .demo-box {
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 10px;
            padding: 14px;
            margin-top: 1.5rem;
        }
        .form-section-title {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: #64748b;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 4px;
            margin-bottom: 12px;
        }
    </style>
</head>
<body>

<div class="auth-container">
    <div class="auth-card">
        <!-- Card Header -->
        <div class="auth-header">
            <div class="auth-icon">
                <i class="bi bi-mortarboard-fill"></i>
            </div>
            <h4 class="fw-bold text-dark mb-1" id="authCardTitle">
                <?= $activeTab === 'register' ? 'Student Registration' : 'College ERP Portal' ?>
            </h4>
            <p class="text-muted small mb-0" id="authCardSubtitle">
                <?= $activeTab === 'register' ? 'Register your student profile to generate your official Registration ID' : 'Sign in using your Email or Registration ID' ?>
            </p>
        </div>

        <!-- Tab Switcher: Registration First, then Login -->
        <div class="nav-auth-tabs d-flex">
            <button type="button" class="btn btn-tab flex-fill <?= $activeTab === 'register' ? 'active' : '' ?>" id="tabBtnRegister" onclick="switchAuthTab('register')">
                <i class="bi bi-person-plus-fill"></i>
                <span>1. Register Student</span>
            </button>
            <button type="button" class="btn btn-tab flex-fill <?= $activeTab === 'login' ? 'active' : '' ?>" id="tabBtnLogin" onclick="switchAuthTab('login')">
                <i class="bi bi-box-arrow-in-right"></i>
                <span>2. Sign In (Login)</span>
            </button>
        </div>

        <div class="p-4 pt-0">
            <!-- Global Flash Message -->
            <?php if ($flash): ?>
                <div class="alert alert-<?= htmlspecialchars($flash['type']) ?> alert-dismissible fade show small shadow-sm" role="alert">
                    <?= $flash['message'] ?>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <?php endif; ?>

            <!-- Success Card if Registered Just Now -->
            <?php if ($newRegInfo && $activeTab === 'login'): ?>
                <div class="alert alert-success border-success shadow-sm mb-3">
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <i class="bi bi-check-circle-fill fs-5 text-success"></i>
                        <strong class="text-success">Account Created Successfully!</strong>
                    </div>
                    <div class="small text-muted mb-2">Welcome, <strong><?= htmlspecialchars($newRegInfo['name']) ?></strong>! Your admission record has been registered.</div>
                    <div class="bg-white p-2 rounded border font-monospace small">
                        <div><strong>Official Registration ID:</strong> <span class="badge bg-primary text-white font-monospace fs-6"><?= htmlspecialchars($newRegInfo['reg_id']) ?></span></div>
                        <div><strong>Student ID:</strong> <?= htmlspecialchars($newRegInfo['code']) ?> &bull; <strong>Roll No:</strong> <?= htmlspecialchars($newRegInfo['roll']) ?></div>
                    </div>
                    <small class="text-muted d-block mt-2">Enter your password below to sign in directly.</small>
                </div>
            <?php endif; ?>

            <!-- ==================================================== -->
            <!-- 1. REGISTRATION PANEL (FIRST)                        -->
            <!-- ==================================================== -->
            <div id="registerPanel" class="<?= $activeTab === 'register' ? '' : 'd-none' ?>">
                <?php if (!empty($regErrors)): ?>
                    <div class="alert alert-danger alert-dismissible fade show small shadow-sm" role="alert">
                        <div class="fw-bold mb-1"><i class="bi bi-exclamation-triangle-fill me-1"></i> Please fix the following errors:</div>
                        <ul class="mb-0 ps-3">
                            <?php foreach ($regErrors as $err): ?>
                                <li><?= htmlspecialchars($err) ?></li>
                            <?php endforeach; ?>
                        </ul>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <?php endif; ?>

                <div class="alert alert-soft-primary bg-light border p-2 mb-3 d-flex align-items-center justify-content-between small">
                    <div class="text-muted">
                        <i class="bi bi-info-circle-fill text-primary me-1"></i> New Student Admission
                    </div>
                    <div>
                        <span class="text-muted small">Assigned Reg ID:</span>
                        <span class="badge bg-primary font-monospace"><?= htmlspecialchars($suggestedRegId) ?></span>
                    </div>
                </div>

                <form action="<?= BASE_URL ?>/login.php" method="POST" autocomplete="off">
                    <input type="hidden" name="action_type" value="register">

                    <!-- Personal Information -->
                    <div class="form-section-title">Personal Details</div>
                    <div class="row g-2 mb-3">
                        <div class="col-md-12">
                            <label class="form-label small mb-1" for="reg_full_name">Full Name <span class="text-danger">*</span></label>
                            <div class="input-group input-group-sm">
                                <span class="input-group-text bg-white"><i class="bi bi-person"></i></span>
                                <input type="text" class="form-control" id="reg_full_name" name="full_name" placeholder="e.g. Sushant Gaikwad" value="<?= htmlspecialchars($regData['full_name']) ?>" required>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label small mb-1" for="reg_email">Email Address <span class="text-danger">*</span></label>
                            <div class="input-group input-group-sm">
                                <span class="input-group-text bg-white"><i class="bi bi-envelope"></i></span>
                                <input type="email" class="form-control" id="reg_email" name="email" placeholder="name@college.com" value="<?= htmlspecialchars($regData['email']) ?>" required>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label small mb-1" for="reg_phone">Mobile Number <span class="text-danger">*</span></label>
                            <div class="input-group input-group-sm">
                                <span class="input-group-text bg-white"><i class="bi bi-telephone"></i></span>
                                <input type="tel" class="form-control" id="reg_phone" name="phone" placeholder="10-digit mobile" value="<?= htmlspecialchars($regData['phone']) ?>" required>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label small mb-1" for="reg_gender">Gender <span class="text-danger">*</span></label>
                            <select class="form-select form-select-sm" id="reg_gender" name="gender" required>
                                <option value="Male" <?= $regData['gender'] === 'Male' ? 'selected' : '' ?>>Male</option>
                                <option value="Female" <?= $regData['gender'] === 'Female' ? 'selected' : '' ?>>Female</option>
                                <option value="Other" <?= $regData['gender'] === 'Other' ? 'selected' : '' ?>>Other</option>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label small mb-1" for="reg_dob">Date of Birth <span class="text-danger">*</span></label>
                            <input type="date" class="form-control form-control-sm" id="reg_dob" name="dob" value="<?= htmlspecialchars($regData['dob']) ?>" required>
                        </div>
                    </div>

                    <!-- Academic Details -->
                    <div class="form-section-title">Academic Details (NEP 2020 Rules)</div>
                    <div class="row g-2 mb-3">
                        <div class="col-md-6">
                            <label class="form-label small mb-1" for="reg_department">Department <span class="text-danger">*</span></label>
                            <select class="form-select form-select-sm" id="reg_department" name="department" required>
                                <?php foreach ($nepStructure as $dName => $dInfo): ?>
                                    <option value="<?= htmlspecialchars($dName) ?>" <?= $regData['department'] === $dName ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($dName) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label small mb-1" for="reg_course">Course / Program <span class="text-danger">*</span></label>
                            <select class="form-select form-select-sm" id="reg_course" name="course" required>
                                <?php foreach ($nepStructure as $dName => $dInfo): ?>
                                    <optgroup label="<?= htmlspecialchars($dName) ?>">
                                        <?php foreach ($dInfo['courses'] as $c): ?>
                                            <option value="<?= htmlspecialchars($c['name']) ?>" <?= $regData['course'] === $c['name'] ? 'selected' : '' ?>>
                                                <?= htmlspecialchars($c['name']) ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </optgroup>
                                <?php endforeach; ?>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label small mb-1" for="reg_year">Academic Level / Year</label>
                            <select class="form-select form-select-sm" id="reg_year" name="year" required>
                                <option value="FY" <?= $regData['year'] === 'FY' ? 'selected' : '' ?>>FY (First Year - Level 4.5)</option>
                                <option value="SY" <?= $regData['year'] === 'SY' ? 'selected' : '' ?>>SY (Second Year - Level 5.0)</option>
                                <option value="TY" <?= $regData['year'] === 'TY' ? 'selected' : '' ?>>TY (Third Year - Level 5.5)</option>
                                <option value="Final Year" <?= $regData['year'] === 'Final Year' ? 'selected' : '' ?>>Final Year (Honours - Level 6.0)</option>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label small mb-1" for="reg_division">Division</label>
                            <select class="form-select form-select-sm" id="reg_division" name="division" required>
                                <option value="A" <?= $regData['division'] === 'A' ? 'selected' : '' ?>>Div A</option>
                                <option value="B" <?= $regData['division'] === 'B' ? 'selected' : '' ?>>Div B</option>
                                <option value="C" <?= $regData['division'] === 'C' ? 'selected' : '' ?>>Div C</option>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label small mb-1" for="reg_roll">Roll No <span class="text-muted">(Optional)</span></label>
                            <input type="text" class="form-control form-control-sm" id="reg_roll" name="roll_number" placeholder="e.g. TYCS-05" value="<?= htmlspecialchars($regData['roll_number']) ?>">
                        </div>

                        <div class="col-12">
                            <label class="form-label small mb-1" for="reg_address">Residential Address</label>
                            <textarea class="form-control form-control-sm" id="reg_address" name="address" rows="2" placeholder="Street, City, Pin Code"><?= htmlspecialchars($regData['address']) ?></textarea>
                        </div>
                    </div>

                    <!-- Account Security -->
                    <div class="form-section-title">Create Password</div>
                    <div class="row g-2 mb-4">
                        <div class="col-md-6">
                            <label class="form-label small mb-1" for="reg_password">Password (min 6 chars) <span class="text-danger">*</span></label>
                            <div class="input-group input-group-sm">
                                <span class="input-group-text bg-white"><i class="bi bi-lock"></i></span>
                                <input type="password" class="form-control" id="reg_password" name="password" placeholder="Create password" required minlength="6">
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label small mb-1" for="reg_confirm_password">Confirm Password <span class="text-danger">*</span></label>
                            <div class="input-group input-group-sm">
                                <span class="input-group-text bg-white"><i class="bi bi-shield-check"></i></span>
                                <input type="password" class="form-control" id="reg_confirm_password" name="confirm_password" placeholder="Repeat password" required minlength="6">
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm mb-3">
                        <i class="bi bi-person-check-fill me-1"></i> Register Student Account
                    </button>

                    <div class="text-center small text-muted">
                        Already registered with an account? 
                        <a href="javascript:void(0)" onclick="switchAuthTab('login')" class="fw-semibold text-primary text-decoration-none">
                            Sign In here &rarr;
                        </a>
                    </div>
                </form>
            </div>

            <!-- ==================================================== -->
            <!-- 2. LOGIN PANEL (SECOND)                              -->
            <!-- ==================================================== -->
            <div id="loginPanel" class="<?= $activeTab === 'login' ? '' : 'd-none' ?>">
                <?php if (!empty($loginError)): ?>
                    <div class="alert alert-danger alert-dismissible fade show small shadow-sm" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i> <?= htmlspecialchars($loginError) ?>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <?php endif; ?>

                <form action="<?= BASE_URL ?>/login.php" method="POST" autocomplete="off">
                    <input type="hidden" name="action_type" value="login">

                    <div class="mb-3">
                        <label for="login_email" class="form-label small fw-semibold">Email or Registration ID</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-person"></i></span>
                            <input type="text" class="form-control border-start-0 ps-0" id="login_email" name="email" value="<?= htmlspecialchars($loginInputVal) ?>" placeholder="e.g. REG2026001 or admin@college.com" required autofocus>
                        </div>
                        <div class="form-text small text-muted">You can log in with your Email address OR Registration ID.</div>
                    </div>

                    <div class="mb-3">
                        <label for="login_password" class="form-label small fw-semibold">Password</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                            <input type="password" class="form-control border-start-0 ps-0" id="login_password" name="password" placeholder="Enter your password" required>
                            <button class="btn btn-outline-secondary border-start-0" type="button" id="togglePassword">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm mb-3">
                        <i class="bi bi-box-arrow-in-right me-1"></i> Sign In to ERP
                    </button>

                    <div class="text-center small text-muted mb-3">
                        Don't have an account yet? 
                        <a href="javascript:void(0)" onclick="switchAuthTab('register')" class="fw-semibold text-primary text-decoration-none">
                            Register as a New Student &rarr;
                        </a>
                    </div>
                </form>

                <!-- Demo Accounts Section (Viva & Testing Friendly) -->
                <div class="demo-box">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <span class="small fw-bold text-dark"><i class="bi bi-key-fill text-warning me-1"></i>Quick Demo Logins</span>
                        <span class="badge bg-secondary">TYCS Viva</span>
                    </div>
                    <div class="row g-2">
                        <div class="col-4">
                            <button type="button" class="btn btn-outline-primary btn-sm w-100 py-1" onclick="fillDemo('admin@college.com', 'admin123')">
                                <i class="bi bi-shield-lock d-block"></i> Admin
                            </button>
                        </div>
                        <div class="col-4">
                            <button type="button" class="btn btn-outline-success btn-sm w-100 py-1" onclick="fillDemo('faculty@college.com', 'faculty123')">
                                <i class="bi bi-person-video3 d-block"></i> Faculty
                            </button>
                        </div>
                        <div class="col-4">
                            <button type="button" class="btn btn-outline-info btn-sm w-100 py-1" onclick="fillDemo('student@college.com', 'student123')">
                                <i class="bi bi-mortarboard d-block"></i> Student
                            </button>
                        </div>
                    </div>
                    <div class="text-center mt-2">
                        <small class="text-muted" style="font-size: 0.72rem;">Click any role button above to auto-fill credentials.</small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Campus Footer -->
    <div class="text-center mt-3 text-white-50 small">
        &copy; 2026 <strong>College ERP Management System</strong> &bull; TYCS Academic Project
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
function switchAuthTab(tab) {
    const registerPanel = document.getElementById('registerPanel');
    const loginPanel = document.getElementById('loginPanel');
    const tabBtnRegister = document.getElementById('tabBtnRegister');
    const tabBtnLogin = document.getElementById('tabBtnLogin');
    const authCardTitle = document.getElementById('authCardTitle');
    const authCardSubtitle = document.getElementById('authCardSubtitle');

    if (tab === 'register') {
        registerPanel.classList.remove('d-none');
        loginPanel.classList.add('d-none');
        tabBtnRegister.classList.add('active');
        tabBtnLogin.classList.remove('active');
        if (authCardTitle) authCardTitle.innerText = 'Student Registration';
        if (authCardSubtitle) authCardSubtitle.innerText = 'Register your student profile to generate your official Registration ID';
        document.title = 'Student Registration - College ERP Management System';
        // Focus first input
        const firstInput = document.getElementById('reg_full_name');
        if (firstInput) firstInput.focus();
    } else {
        registerPanel.classList.add('d-none');
        loginPanel.classList.remove('d-none');
        tabBtnLogin.classList.add('active');
        tabBtnRegister.classList.remove('active');
        if (authCardTitle) authCardTitle.innerText = 'College ERP Portal';
        if (authCardSubtitle) authCardSubtitle.innerText = 'Sign in using your Email or Registration ID';
        document.title = 'Login - College ERP Management System';
        // Focus login input
        const loginInput = document.getElementById('login_email');
        if (loginInput) loginInput.focus();
    }
}

function fillDemo(email, pass) {
    switchAuthTab('login');
    document.getElementById('login_email').value = email;
    document.getElementById('login_password').value = pass;
}

const togglePassword = document.getElementById('togglePassword');
const passwordInput = document.getElementById('login_password');
if (togglePassword && passwordInput) {
    togglePassword.addEventListener('click', function () {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        this.querySelector('i').classList.toggle('bi-eye');
        this.querySelector('i').classList.toggle('bi-eye-slash');
    });
}
</script>
</body>
</html>
