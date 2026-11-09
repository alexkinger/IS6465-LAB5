# Lab 5 Notes: Peer Tutoring Hub Database

## Part 1: Create the database tables

### `.tables` and `.schema` output

```
sqlite> .tables
students           tutoring_requests

sqlite> .schema
CREATE TABLE students (
  student_id INTEGER PRIMARY KEY,
  student_name TEXT NOT NULL,
  student_email TEXT NOT NULL UNIQUE
);
CREATE TABLE tutoring_requests (
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
```

### Which column is the primary key in each table?

In the `students` table, `student_id` is the primary key. In the `tutoring_requests` table, `request_id` is the primary key. Each primary key uniquely identifies one row in its table.

### Which column is the foreign key, and what relationship does it represent?

`student_id` in `tutoring_requests` is the foreign key. It references `students(student_id)`. This creates a one-to-many relationship: one student can submit many tutoring requests, and each request belongs to exactly one student.

### Why is student_email marked UNIQUE?

`student_email` is marked UNIQUE so two student rows cannot use the same email address. That keeps each student identity clear and supports find-or-create logic later, when the app looks up a student by email before inserting a new request.

## Part 2: Insert students and tutoring requests

### INSERT statements used

```sql
INSERT OR IGNORE INTO students (student_name, student_email)
VALUES ('Jordan Lee', 'jordan.lee@example.edu');

INSERT OR IGNORE INTO students (student_name, student_email)
VALUES ('Avery Patel', 'avery.patel@example.edu');

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
```

### SELECT * output for both tables

```
sqlite> SELECT * FROM students;
student_id  student_name  student_email
----------  ------------  -----------------------
1           Jordan Lee    jordan.lee@example.edu
2           Avery Patel   avery.patel@example.edu

sqlite> SELECT * FROM tutoring_requests;
request_id  student_id  course   topic        preferred_date  preferred_time  status  created_at
----------  ----------  -------  -----------  --------------  --------------  ------  -------------------
1           1           IS 6465  Forms        2026-11-15      10:00           Open    2026-11-09 02:12:52
2           1           IS 6465  SQL SELECT   2026-11-18      14:00           Open    2026-11-09 02:12:52
3           2           IS 6465  SQLite CRUD  2026-11-20      11:30           Open    2026-11-09 02:12:52
```

### Why does Jordan have one student row but two request rows?

Jordan is stored once in `students` because a student is a single person with one email. Each tutoring request is its own row in `tutoring_requests`, linked back to Jordan through `student_id = 1`. That avoids repeating Jordan's name and email for every request and is the one-to-many relationship the foreign key supports.

## Part 3: Read the stored data

### JOIN query SQL and output

```sql
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
```

```
request_id  student_name  student_email            course   topic        preferred_date  preferred_time  status
----------  ------------  -----------------------  -------  -----------  --------------  --------------  ------
1           Jordan Lee    jordan.lee@example.edu   IS 6465  Forms        2026-11-15      10:00           Open
2           Jordan Lee    jordan.lee@example.edu   IS 6465  SQL SELECT   2026-11-18      14:00           Open
3           Avery Patel   avery.patel@example.edu  IS 6465  SQLite CRUD  2026-11-20      11:30           Open
```

### What does the JOIN condition connect?

The JOIN condition `r.student_id = s.student_id` connects each tutoring request to the matching student row. It follows the foreign key so the result can show the student's name and email next to request details without storing that student data again in every request row.

### What is the difference between the purpose of JOIN and WHERE?

JOIN combines related rows from two tables based on a matching key. WHERE filters which rows are returned after that combination (or from a single table). For example, JOIN brings student and request data together, while `WHERE status = 'Open'` would limit the result to open requests only.

### Why should the application retrieve one request by request_id instead of by topic alone?

`request_id` uniquely identifies one request. A topic like "Forms" could match more than one request, so looking up by topic alone could return the wrong row or multiple rows. Using `request_id` makes confirmation and edit pages load exactly one intended request.

## Part 4: Update one request

### The two UPDATE statements

```sql
UPDATE tutoring_requests
SET topic = 'Forms and validation',
    preferred_date = '2026-11-16',
    preferred_time = '15:00'
WHERE request_id = 1;

UPDATE tutoring_requests
SET status = 'Cancelled'
WHERE request_id = 3;
```

### Before-and-after for the revised request (request_id = 1)

Before:

```
request_id  topic  preferred_date  preferred_time  status
----------  -----  --------------  --------------  ------
1           Forms  2026-11-15      10:00           Open
```

After:

```
request_id  topic                 preferred_date  preferred_time  status
----------  --------------------  --------------  --------------  ------
1           Forms and validation  2026-11-16      15:00           Open
```

### Avery's Cancelled status

```
request_id  student_id  topic        status
----------  ----------  -----------  ---------
3           2           SQLite CRUD  Cancelled
```

### Why is a specific WHERE clause essential in an UPDATE statement?

Without a specific WHERE clause, SQLite would update every row in the table. Using `WHERE request_id = ...` limits the change to one request so other students' data is not changed by accident.

### Why does the Peer Tutoring Hub use a Cancelled status instead of immediately deleting a real request?

Cancelling keeps the request history in the database. Staff can still see that the request existed, when it was made, and that the student cancelled it. Deleting the row would remove that record and make reporting and follow-up harder.

## Part 5: Delete one test request

### INSERT for the test request

```sql
INSERT INTO tutoring_requests
  (student_id, course, topic, preferred_date, preferred_time)
VALUES
  (1, 'IS 6465', 'Delete Practice', '2026-11-22', '09:00');
```

### DELETE statement used

```sql
DELETE FROM tutoring_requests
WHERE request_id = 4;
```

### Output verifying the test record was removed

After insert (test row present as request_id 4):

```
request_id  topic
----------  --------------------
1           Forms and validation
2           SQL SELECT
3           SQLite CRUD
4           Delete Practice
```

After delete (test row gone; other requests remain):

```
request_id  topic                 status
----------  --------------------  ---------
1           Forms and validation  Open
2           SQL SELECT            Open
3           SQLite CRUD           Cancelled
```

### Why is a WHERE clause essential in a DELETE statement?

Without WHERE, DELETE would remove every row in the table. The WHERE clause targets only the test request so the real tutoring requests stay in the database.

## Part 6: Reflect on the CRUD workflow

| CRUD action | SQL statement used in this lab | Peer Tutoring Hub example |
|---|---|---|
| Create | `INSERT INTO students ...` and `INSERT INTO tutoring_requests ...` | A student submits the tutoring request form and a new request row is saved |
| Read | `SELECT ... JOIN ... WHERE ...` | The requests list or confirmation page shows request details with the student name and email |
| Update | `UPDATE tutoring_requests SET ... WHERE request_id = ...` | A student revises topic/date/time, or a request status is changed to Cancelled |
| Delete | `DELETE FROM tutoring_requests WHERE request_id = ...` | Removing a test record during development or cleanup (real cancels usually update status instead) |

### How does the database preserve the connection between a student and that student's requests?

It stores `student_id` as a foreign key on each tutoring request. That ID points back to the matching primary key in `students`, so every request stays linked to the student who submitted it even though the name and email live in only one place.

### Which database constraint prevents two student rows from using the same email address?

The UNIQUE constraint on `student_email` prevents duplicate email addresses.

### What could happen if an UPDATE or DELETE statement did not include a WHERE clause?

Every row in the table could be changed or deleted. For example, all requests could become Cancelled, or the entire `tutoring_requests` table could be emptied.

### When the application later receives values from an HTML form, why should PHP send those values as parameters instead of placing them directly into SQL text?

Putting form values directly into SQL text opens the door to SQL injection, because a user could submit malicious SQL as input. Prepared statements with parameters keep the SQL command separate from the submitted values, so the database treats the input as data instead of executable SQL.
