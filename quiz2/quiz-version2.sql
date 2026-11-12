/*
 * Makeup/alternate version of quiz2.
 * Same schema and same concepts as quiz.sql,
 * each problem adds one orthogonal wrinkle
 * (UNION dedup / NOT IN with a filtered subquery /
 *  mirrored LEFT JOIN / reversed recursion with UNION).
 *
 * For each problem below,
 * write the output of the SELECT statement in both sqlite3 and postgres.
 * If the command does not result in an error, you should provide the full table of the output.
 * (The names of columns are unimportant.)
 * If the command does result in an error, just write "error".
 * (You do not need to provide the full error message.)
 * If the output of both sqlite3 and postgres is the same,
 * you can just write "sqlite3 and postgres are the same" instead of redrawing the output.
 */


-- Problem 1
SELECT count(*) FROM (
    SELECT model_id FROM message
    UNION
    SELECT sid FROM session
) t;


-- Problem 2
SELECT count(*)
FROM session
WHERE sid NOT IN (
    SELECT sid FROM message WHERE sid IS NOT NULL
);


-- Problem 3
SELECT count(*)
FROM message
LEFT JOIN session USING (sid)
WHERE session.name IS NULL;


-- Problem 4
WITH RECURSIVE d AS (
    SELECT mid, prev_mid
    FROM message WHERE mid = 10
  UNION
    SELECT m.mid, m.prev_mid
    FROM message m
    JOIN d ON d.mid = m.prev_mid
)
SELECT count(*) FROM d;

