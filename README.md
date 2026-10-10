# College ERP — Node.js + Express + SQLite

PHP has been removed from the deployable application. The new application uses Node.js, Express, EJS, SQLite (`better-sqlite3`), sessions, bcrypt-compatible password verification, Helmet, and the original SQLite data.

## Run locally
```bash
npm install
npm start
```
Open `http://localhost:3000`.

## Demo accounts
- Admin: `admin@college.com` / `admin123`
- Faculty: `faculty@college.com` / `faculty123`
- Student: `student@college.com` / `student123`

## Deploy on Render
- Build command: `npm install`
- Start command: `npm start`
- Environment: `NODE_ENV=production`
- Add `SESSION_SECRET` with a long random value.
- For persistent SQLite writes on Render, attach a persistent disk and set `DB_PATH` to the mounted database path.

## Main modules
Authentication/registration, dashboards, students, faculty, subjects, courses, attendance, fees, exams, marks, notices, and student self-service pages.
