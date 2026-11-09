-- Part 1: Create tables
CREATE TABLE IF NOT EXISTS students (
  student_id INTEGER PRIMARY KEY,
  student_name TEXT NOT NULL,
  student_email TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS tutoring_requests (
  request_id INTEGER PRIMARY KEY,
  student_id INTEGER NOT NULL,
  course TEXT NOT NULL,
  topic TEXT NOT NULL,
  preferred_date TEXT NOT NULL,
  preferred_time TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'Open',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(student_id)
);

-- Part 2: Insert students and tutoring requests
INSERT OR IGNORE INTO students (student_name, student_email)
VALUES ('Jordan Lee', 'jordan.lee@example.edu');

INSERT OR IGNORE INTO students (student_name, student_email)
VALUES ('Avery Patel', 'avery.patel@example.edu');

-- Jordan = student_id 1, Avery = student_id 2
INSERT INTO tutoring_requests
  (student_id, course, topic, preferred_date, preferred_time)
VALUES
  (1, 'IS 6465', 'Forms', '2026-11-15', '10:00');

INSERT INTO tutoring_requests
  (student_id, course, topic, preferred_date, preferred_time)
VALUES
  (1, 'IS 6465', 'SQL SELECT', '2026-11-18', '14:00');

INSERT INTO tutoring_requests
  (student_id, course, topic, preferred_date, preferred_time)
VALUES
  (2, 'IS 6465', 'SQLite CRUD', '2026-11-20', '11:30');

-- Part 3: Read the stored data
SELECT * FROM students;

SELECT * FROM tutoring_requests;

SELECT * FROM tutoring_requests
WHERE status = 'Open';

SELECT * FROM tutoring_requests
WHERE request_id = 1;

SELECT
  r.request_id,
  s.student_name,
  s.student_email,
  r.course,
  r.topic,
  r.preferred_date,
  r.preferred_time,
  r.status
FROM tutoring_requests AS r
JOIN students AS s ON r.student_id = s.student_id
ORDER BY r.preferred_date;

-- Part 4: Update one request
-- Change Jordan's first request
UPDATE tutoring_requests
SET topic = 'Forms and validation',
    preferred_date = '2026-11-16',
    preferred_time = '15:00'
WHERE request_id = 1;

-- Set Avery's request to Cancelled
UPDATE tutoring_requests
SET status = 'Cancelled'
WHERE request_id = 3;

-- Part 5: Delete one test request
INSERT INTO tutoring_requests
  (student_id, course, topic, preferred_date, preferred_time)
VALUES
  (1, 'IS 6465', 'Delete Practice', '2026-11-22', '09:00');

-- On a fresh db this test row is request_id 4
DELETE FROM tutoring_requests
WHERE request_id = 4;
