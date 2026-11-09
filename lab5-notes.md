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

`student_id` is the primary key in `students`. `request_id` is the primary key in `tutoring_requests`. That ID is what uniquely identifies each row.

### Which column is the foreign key, and what relationship does it represent?

`student_id` in `tutoring_requests` is the foreign key. It points to `students(student_id)`. One student can have many requests. Each request belongs to one student.

### Why is student_email marked UNIQUE?

So two students cannot share the same email. That keeps each person as one row, and later the app can look someone up by email without creating duplicates.

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

Jordan is one person, so he only needs one row in `students`. He submitted two tutoring requests, so those are two rows in `tutoring_requests`. Both use `student_id = 1` to point back to him. That way we do not copy his name and email into every request.

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

`r.student_id = s.student_id` matches each request to the right student. That is how we can show the student name and email next to the request without storing that info twice.

### What is the difference between the purpose of JOIN and WHERE?

JOIN pulls related rows from two tables together using a matching key. WHERE filters the rows you get back. JOIN connects the tables. WHERE narrows the result, like only showing Open requests.

### Why should the application retrieve one request by request_id instead of by topic alone?

`request_id` is unique. A topic like Forms could show up more than once. If you search by topic only, you might get the wrong request or more than one. Using `request_id` gets the exact row you need for a confirmation or edit page.

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

If you leave WHERE out, SQLite updates every row in the table. `WHERE request_id = ...` keeps the change on one request so you do not mess up everyone else's data.

### Why does the Peer Tutoring Hub use a Cancelled status instead of immediately deleting a real request?

Cancel keeps the history. You can still see that the request happened and that it was cancelled. If you delete it, that record is gone and you lose that trail.

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

Without WHERE, DELETE wipes the whole table. The WHERE clause makes sure you only remove the test request and leave the real ones alone.

## Part 6: Reflect on the CRUD workflow

| CRUD action | SQL statement used in this lab | Peer Tutoring Hub example |
|---|---|---|
| Create | `INSERT INTO students ...` and `INSERT INTO tutoring_requests ...` | Student fills out the request form and a new request gets saved |
| Read | `SELECT ... JOIN ... WHERE ...` | Requests list or confirmation page shows the request plus the student name and email |
| Update | `UPDATE tutoring_requests SET ... WHERE request_id = ...` | Student edits topic/date/time, or status gets changed to Cancelled |
| Delete | `DELETE FROM tutoring_requests WHERE request_id = ...` | Removing a test row while practicing (real cancels usually just change status) |

### How does the database preserve the connection between a student and that student's requests?

Each request stores a `student_id` foreign key. That ID matches the primary key in `students`. So the request stays tied to the right person even though the name and email only live in the students table.

### Which database constraint prevents two student rows from using the same email address?

The UNIQUE constraint on `student_email`.

### What could happen if an UPDATE or DELETE statement did not include a WHERE clause?

You could change or delete every row. All requests could get set to Cancelled, or the whole `tutoring_requests` table could get wiped.

### When the application later receives values from an HTML form, why should PHP send those values as parameters instead of placing them directly into SQL text?

If you drop form input straight into SQL, someone can submit malicious SQL (SQL injection). Parameters keep the command and the user values separate, so the database treats the input as data, not as code to run.
