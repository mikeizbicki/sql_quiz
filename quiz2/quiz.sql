/*
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
    UNION ALL
    SELECT sid FROM session
) t;







-- Problem 2
SELECT count(*)
FROM session
WHERE sid NOT IN (SELECT sid FROM message);







-- Problem 3
SELECT count(*)
FROM session
LEFT JOIN message USING (sid)
WHERE message.mid IS NULL;







-- Problem 4
WITH RECURSIVE history AS (
    SELECT mid, prev_mid
    FROM message WHERE mid = 25
  UNION ALL
    SELECT m.mid, m.prev_mid
    FROM message m
    JOIN history ON m.mid = history.prev_mid
)
SELECT count(*) FROM history;
