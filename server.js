const express = require('express');
const session = require('express-session');
const Database = require('better-sqlite3');
const bcrypt = require('bcryptjs');
const helmet = require('helmet');
const path = require('path');
const fs = require('fs');
const methodOverride = require('method-override');

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// Enable trust proxy for deployment platforms (Render, Railway, Heroku, Cloudflare, etc.)
app.set('trust proxy', 1);

// SQLite Database Path & Automatic Initialization
const DB_PATH = process.env.DB_PATH || path.join(__dirname, 'college_erp.sqlite');
const SEED_SQL_PATH = path.join(__dirname, 'database_sqlite.sql');
const LOCAL_SQLITE_PATH = path.join(__dirname, 'college_erp.sqlite');

if (!fs.existsSync(DB_PATH)) {
  if (fs.existsSync(LOCAL_SQLITE_PATH) && DB_PATH !== LOCAL_SQLITE_PATH) {
    console.log(`Copying local SQLite database to ${DB_PATH}...`);
    fs.copyFileSync(LOCAL_SQLITE_PATH, DB_PATH);
  } else if (fs.existsSync(SEED_SQL_PATH)) {
    console.log(`Database not found at ${DB_PATH}. Initializing database from database_sqlite.sql...`);
    const dbTemp = new Database(DB_PATH);
    const sqlDump = fs.readFileSync(SEED_SQL_PATH, 'utf8');
    dbTemp.exec(sqlDump);
    dbTemp.close();
    console.log(`Database initialized successfully at ${DB_PATH}`);
  } else {
    console.warn(`Warning: SQLite database file not found at ${DB_PATH} and no SQL seed file found.`);
  }
}

const db = new Database(DB_PATH);
db.pragma('foreign_keys = ON');

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Serve static assets (CSS, JS, Images) from public folder
if (fs.existsSync(path.join(__dirname, 'public'))) {
  app.use(express.static(path.join(__dirname, 'public')));
}
if (fs.existsSync(path.join(__dirname, '../public'))) {
  app.use(express.static(path.join(__dirname, '../public')));
}

app.use(helmet({ contentSecurityPolicy: false }));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(methodOverride('_method'));

app.use(session({
  secret: process.env.SESSION_SECRET || 'college-erp-production-secret-key-2026',
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    maxAge: 1000 * 60 * 60 * 8
  }
}));

app.use((req, res, next) => {
  res.locals.user = req.session.user || null;
  res.locals.flash = req.session.flash || null;
  delete req.session.flash;
  next();
});

app.locals.formatDate = v => (v ? String(v).slice(0, 10) : '');
app.locals.money = v => Number(v || 0).toLocaleString('en-IN', { style: 'currency', currency: 'INR' });

function flash(req, type, msg) {
  req.session.flash = { type, msg };
}

function user(req) {
  return req.session.user || null;
}

function requireAuth(roles = []) {
  return (req, res, next) => {
    if (!req.session.user) {
      return res.redirect('/login?next=' + encodeURIComponent(req.originalUrl));
    }
    if (roles.length && !roles.includes(req.session.user.role)) {
      return res.status(403).render('error', {
        title: 'Access denied',
        message: 'You do not have permission to access this page.'
      });
    }
    next();
  };
}

function q(sql, args = []) {
  return db.prepare(sql).all(...args);
}

function one(sql, args = []) {
  return db.prepare(sql).get(...args);
}

const entities = {
  students: {
    table: 'students',
    title: 'Students',
    role: ['admin'],
    columns: ['student_code', 'registration_id', 'full_name', 'email', 'phone', 'gender', 'department', 'course', 'year', 'division', 'roll_number', 'admission_date'],
    labels: { student_code: 'Student ID', registration_id: 'Registration ID', full_name: 'Full Name', email: 'Email', phone: 'Phone', gender: 'Gender', department: 'Department', course: 'Course', year: 'Year', division: 'Division', roll_number: 'Roll Number', admission_date: 'Admission Date' }
  },
  faculty: {
    table: 'faculty',
    title: 'Faculty',
    role: ['admin'],
    columns: ['faculty_code', 'full_name', 'email', 'phone', 'gender', 'department', 'qualification', 'subject', 'joining_date'],
    labels: { faculty_code: 'Faculty ID', full_name: 'Full Name', email: 'Email', phone: 'Phone', gender: 'Gender', department: 'Department', qualification: 'Qualification', subject: 'Subject', joining_date: 'Joining Date' }
  },
  subjects: {
    table: 'subjects',
    title: 'Subjects',
    role: ['admin', 'faculty'],
    columns: ['subject_code', 'subject_name', 'department', 'course', 'semester'],
    labels: { subject_code: 'Code', subject_name: 'Subject', department: 'Department', course: 'Course', semester: 'Semester' }
  },
  courses: {
    table: 'courses',
    title: 'Courses',
    role: ['admin'],
    columns: ['course_code', 'course_name', 'nep_level', 'duration_years', 'total_semesters', 'degree_type', 'description'],
    labels: { course_code: 'Code', course_name: 'Course Name', nep_level: 'NEP Level', duration_years: 'Duration (Years)', total_semesters: 'Semesters', degree_type: 'Degree Type', description: 'Description' }
  },
  attendance: {
    table: 'attendance',
    title: 'Attendance',
    role: ['admin', 'faculty'],
    columns: ['student_id', 'subject', 'attendance_date', 'status'],
    labels: { student_id: 'Student ID', subject: 'Subject', attendance_date: 'Date', status: 'Status' }
  },
  fees: {
    table: 'fees',
    title: 'Fees',
    role: ['admin'],
    columns: ['student_id', 'academic_year', 'total_fees', 'paid_amount', 'pending_amount', 'payment_date', 'payment_status'],
    labels: { student_id: 'Student ID', academic_year: 'Academic Year', total_fees: 'Total Fees', paid_amount: 'Paid Amount', pending_amount: 'Pending', payment_date: 'Payment Date', payment_status: 'Status' }
  },
  exams: {
    table: 'exams',
    title: 'Exams',
    role: ['admin', 'faculty'],
    columns: ['exam_name', 'exam_type', 'course', 'semester', 'subject', 'exam_date'],
    labels: { exam_name: 'Exam', exam_type: 'Type', course: 'Course', semester: 'Semester', subject: 'Subject', exam_date: 'Date' }
  },
  marks: {
    table: 'marks',
    title: 'Marks',
    role: ['admin', 'faculty'],
    columns: ['student_id', 'exam_id', 'subject', 'max_marks', 'obtained_marks', 'percentage', 'grade', 'result_status'],
    labels: { student_id: 'Student ID', exam_id: 'Exam ID', subject: 'Subject', max_marks: 'Max Marks', obtained_marks: 'Obtained', percentage: 'Percentage', grade: 'Grade', result_status: 'Result' }
  },
  notices: {
    table: 'notices',
    title: 'Notices',
    role: ['admin', 'faculty'],
    columns: ['title', 'description', 'posted_date', 'posted_by', 'target_audience'],
    labels: { title: 'Title', description: 'Description', posted_date: 'Posted Date', posted_by: 'Posted By', target_audience: 'Audience' }
  }
};

app.get('/', (req, res) => {
  if (!req.session.user) return res.redirect('/login');
  return res.redirect('/' + req.session.user.role + '/dashboard');
});

app.get('/login', (req, res) => {
  if (req.session.user) return res.redirect('/' + req.session.user.role + '/dashboard');
  res.render('login', { error: null, loginInput: req.query.email || '' });
});

app.post('/login', (req, res) => {
  const input = String(req.body.email || '').trim();
  const pass = String(req.body.password || '');
  let u = one('SELECT u.* FROM users u LEFT JOIN students s ON u.id=s.user_id WHERE u.email=? OR s.registration_id=? OR s.student_code=? LIMIT 1', [input, input, input]);
  if (!u || !bcrypt.compareSync(pass, String(u.password).replace(/^\$2y\$/, '$2b$'))) {
    return res.render('login', { error: 'Invalid email / Registration ID / Student Code or password.', loginInput: input });
  }
  req.session.user = { id: u.id, name: u.name, email: u.email, role: u.role };
  res.redirect('/' + u.role + '/dashboard');
});

app.post('/register', (req, res) => {
  const b = req.body;
  if (!b.full_name || !b.email || !b.password) {
    return res.render('login', { error: 'Name, email and password are required.', loginInput: b.email || '' });
  }
  if (one('SELECT id FROM users WHERE email=?', [b.email])) {
    return res.render('login', { error: 'Email already registered.', loginInput: b.email });
  }
  const tx = db.transaction(() => {
    const r = db.prepare("INSERT INTO users(name,email,password,role) VALUES(?,?,?,'student')").run(b.full_name, b.email, bcrypt.hashSync(b.password, 10));
    const id = r.lastInsertRowid;
    const n = Number(one('SELECT COALESCE(MAX(id),0)+1 n FROM students').n);
    db.prepare(`INSERT INTO students(user_id,student_code,registration_id,full_name,email,phone,gender,dob,address,department,course,year,division,roll_number,admission_date) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`)
      .run(id, 'STU' + (100 + n), 'REG2026' + String(n).padStart(3, '0'), b.full_name, b.email, b.phone || '', b.gender || 'Male', b.dob || '', b.address || '', b.department || 'Computer Science', b.course || 'B.Sc. Computer Science', b.year || 'TY', b.division || 'A', b.roll_number || ('TYCS-' + String(n).padStart(2, '0')), new Date().toISOString().slice(0, 10));
  });
  tx();
  flash(req, 'success', 'Registration successful. You can now log in.');
  res.redirect('/login');
});

app.get('/register', (req, res) => res.redirect('/login?tab=register'));
app.get('/logout', (req, res) => req.session.destroy(() => res.redirect('/login')));

app.get('/admin/dashboard', requireAuth(['admin']), (req, res) => dashboard(req, res, 'admin'));
app.get('/faculty/dashboard', requireAuth(['faculty']), (req, res) => dashboard(req, res, 'faculty'));
app.get('/student/dashboard', requireAuth(['student']), (req, res) => dashboard(req, res, 'student'));

function dashboard(req, res, role) {
  const counts = {
    students: one('SELECT COUNT(*) n FROM students').n,
    faculty: one('SELECT COUNT(*) n FROM faculty').n,
    subjects: one('SELECT COUNT(*) n FROM subjects').n,
    courses: one('SELECT COUNT(*) n FROM courses').n,
    attendance: one('SELECT COUNT(*) n FROM attendance').n,
    fees: one('SELECT COUNT(*) n FROM fees').n,
    exams: one('SELECT COUNT(*) n FROM exams').n,
    marks: one('SELECT COUNT(*) n FROM marks').n
  };
  let recent = q('SELECT * FROM notices ORDER BY id DESC LIMIT 5');
  if (role === 'student') {
    const s = one('SELECT * FROM students WHERE user_id=?', [req.session.user.id]);
    recent = q("SELECT * FROM notices WHERE target_audience IN ('All','Students','Student') ORDER BY id DESC LIMIT 5");
    return res.render('dashboard', { role, counts, recent, student: s });
  }
  res.render('dashboard', { role, counts, recent, student: null });
}

function listPage(req, res, key) {
  const e = entities[key];
  let search = String(req.query.search || '').trim();
  let sql = 'SELECT * FROM ' + e.table;
  let params = [];
  if (search) {
    const parts = e.columns.map(c => c + ' LIKE ?');
    sql += ' WHERE ' + parts.join(' OR ');
    params = e.columns.map(() => '%' + search + '%');
  }
  sql += ' ORDER BY id DESC';
  let rows = q(sql, params);
  res.render('entity_list', { entity: e, key, rows, search });
}

function saveRow(req, res, key, id) {
  const e = entities[key];
  const b = req.body;
  const vals = e.columns.map(c => b[c] ?? '');
  if (key === 'fees' && b.total_fees) {
    vals[e.columns.indexOf('pending_amount')] = Math.max(0, Number(b.total_fees) - Number(b.paid_amount || 0));
  }
  if (key === 'marks' && b.max_marks) {
    vals[e.columns.indexOf('percentage')] = (Number(b.obtained_marks || 0) / Number(b.max_marks)) * 100;
    const p = vals[e.columns.indexOf('percentage')];
    vals[e.columns.indexOf('grade')] = p >= 90 ? 'A+' : p >= 80 ? 'A' : p >= 70 ? 'B' : p >= 60 ? 'C' : p >= 50 ? 'D' : 'F';
    vals[e.columns.indexOf('result_status')] = p >= 40 ? 'Pass' : 'Fail';
  }
  if (id) {
    db.prepare(`UPDATE ${e.table} SET ${e.columns.map(c => c + '=?').join(',')} WHERE id=?`).run(...vals, id);
  } else {
    db.prepare(`INSERT INTO ${e.table}(${e.columns.join(',')}) VALUES(${e.columns.map(() => '?').join(',')})`).run(...vals);
  }
  flash(req, 'success', `${e.title.slice(0, -1)} ${id ? 'updated' : 'added'} successfully.`);
  res.redirect('/' + req.session.user.role + '/' + key);
}

function entityRoute(prefix, key) {
  const e = entities[key];
  app.get('/' + prefix + '/' + key, requireAuth(e.role), (req, res) => listPage(req, res, key));
  app.get('/' + prefix + '/' + key + '/add', requireAuth(e.role), (req, res) => res.render('entity_form', { entity: e, key, row: null }));
  app.post('/' + prefix + '/' + key, requireAuth(e.role), (req, res) => saveRow(req, res, key, null));
  app.get('/' + prefix + '/' + key + '/:id/edit', requireAuth(e.role), (req, res) => {
    const row = one('SELECT * FROM ' + e.table + ' WHERE id=?', [req.params.id]);
    if (!row) return res.status(404).render('error', { title: 'Not found', message: 'Record not found.' });
    res.render('entity_form', { entity: e, key, row });
  });
  app.post('/' + prefix + '/' + key + '/:id', requireAuth(e.role), (req, res) => saveRow(req, res, key, req.params.id));
  app.post('/' + prefix + '/' + key + '/:id/delete', requireAuth(e.role), (req, res) => {
    db.prepare('DELETE FROM ' + e.table + ' WHERE id=?').run(req.params.id);
    flash(req, 'success', 'Record deleted successfully.');
    res.redirect('/' + prefix + '/' + key);
  });
}

for (const k of Object.keys(entities)) {
  const prefixes = entities[k].role.includes('admin') ? ['admin'] : ['faculty'];
  if (entities[k].role.includes('admin') && entities[k].role.includes('faculty')) prefixes.push('faculty');
  for (const p of prefixes) entityRoute(p, k);
}

// Student self-service pages
app.get('/student/profile', requireAuth(['student']), (req, res) => {
  const s = one('SELECT * FROM students WHERE user_id=?', [req.session.user.id]);
  res.render('profile', { student: s });
});

app.post('/student/profile', requireAuth(['student']), (req, res) => {
  const b = req.body;
  db.prepare('UPDATE students SET phone=?,address=? WHERE user_id=?').run(b.phone || '', b.address || '', req.session.user.id);
  flash(req, 'success', 'Profile updated.');
  res.redirect('/student/profile');
});

app.get('/student/attendance', requireAuth(['student']), (req, res) => {
  const s = one('SELECT * FROM students WHERE user_id=?', [req.session.user.id]);
  const rows = q('SELECT * FROM attendance WHERE student_id=? ORDER BY attendance_date DESC', [s.id]);
  res.render('student_table', { title: 'My Attendance', rows, columns: ['subject', 'attendance_date', 'status'] });
});

app.get('/student/fees', requireAuth(['student']), (req, res) => {
  const s = one('SELECT * FROM students WHERE user_id=?', [req.session.user.id]);
  const rows = q('SELECT * FROM fees WHERE student_id=? ORDER BY id DESC', [s.id]);
  res.render('student_table', { title: 'My Fees', rows, columns: ['academic_year', 'total_fees', 'paid_amount', 'pending_amount', 'payment_date', 'payment_status'] });
});

app.get('/student/marks', requireAuth(['student']), (req, res) => {
  const s = one('SELECT * FROM marks WHERE student_id=? ORDER BY id DESC', [one('SELECT id FROM students WHERE user_id=?', [req.session.user.id]).id]);
  res.render('student_table', { title: 'My Marks', rows: s, columns: ['subject', 'max_marks', 'obtained_marks', 'percentage', 'grade', 'result_status'] });
});

app.get('/student/notices', requireAuth(['student']), (req, res) => {
  const rows = q("SELECT * FROM notices WHERE target_audience IN ('All','Students','Student') ORDER BY id DESC");
  res.render('student_table', { title: 'Notices', rows, columns: ['title', 'description', 'posted_date', 'posted_by', 'target_audience'] });
});

app.use((req, res) => res.status(404).render('error', { title: 'Page not found', message: 'The requested page does not exist.' }));

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).render('error', { title: 'Server error', message: process.env.NODE_ENV === 'production' ? 'Something went wrong.' : err.message });
});

app.listen(PORT, HOST, () => {
  console.log(`College ERP running on http://${HOST}:${PORT}`);
});
