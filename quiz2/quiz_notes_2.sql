-- A "subquery" is a SELECT statement that is inside another SELECT statement;
-- Subqueries can also be placed anywhere a tablename can be placed;
-- Subqueries used in this way must be given a name

SELECT count(*) FROM (
    SELECT mid FROM message
) AS t; -- the AS is optional

/*
The above query is equivalent to

SELECT count(*) FROM message;
*/

-- JOINs combine tables "horizontally" whereas set operations combine tables "vertically"
-- column types must match between the two select statements,
-- but the final column names will be the column names of the first query

-- UNION ALL concatenates the results of two queries
-- UNION also removes duplicates

SELECT count(*) FROM (
    SELECT model_id FROM message
    UNION ALL
    SELECT name FROM session
) t;

-- NOTE:
-- sqlite3 is "weakly typed", and postgres is "strongly typed";
-- the types from a UNION need not match in sqlite3,
-- but they must match in postgres;
-- see: <https://www.sqlite.org/quirks.html>

/*
The following query is not allowed in postgres, but is allowed in sqlite3

SELECT count(*) FROM (
    SELECT model_id FROM message
    UNION ALL
    SELECT sid FROM session
) t;
*/

-- UNION removes duplicates, so changing the columns can change the number of rows
-- UNION ALL: changing the columns will never change the number of rows

SELECT count(*) FROM (
    SELECT model_id FROM message
    UNION
    SELECT name FROM session
) t;

SELECT count(*) FROM (
    SELECT mid, model_id FROM message
    UNION
    SELECT sid, name FROM session
) t;

SELECT count(*) FROM (
    SELECT model_id FROM message
    WHERE mid < 15
    UNION ALL
    SELECT name FROM session
    WHERE sid > 1 AND name LIKE '%a%'
) t;

SELECT count(sid) FROM (
    SELECT DISTINCT sid FROM message
    UNION ALL
    SELECT sid FROM session
) t;

SELECT count(sid) FROM (
    SELECT DISTINCT sid FROM message
    UNION ALL
    SELECT DISTINCT sid FROM session
) t;

SELECT count(sid) FROM (
    SELECT sid FROM message
    UNION ALL
    SELECT sid FROM session
) t;

SELECT count(DISTINCT sid) FROM (
    SELECT sid FROM message
    UNION ALL
    SELECT sid FROM session
) t;

SELECT count(DISTINCT mid) FROM (
    SELECT mid FROM message
    WHERE model_id LIKE '%a%'
    UNION ALL
    SELECT sid FROM session
    WHERE name LIKE '%A%'
) t;

SELECT 'gpt' UNION SELECT 'claude';
SELECT 'gpt' UNION SELECT 'gpt';

-- INTERSECT ALL returns all rows that are in both queries
-- INTERSECT also removes duplicates

SELECT count(*) FROM (
    SELECT model_id FROM message
    INTERSECT
    SELECT name FROM session
) t;

SELECT count(*) FROM (
    SELECT mid, model_id FROM message
    INTERSECT
    SELECT sid, name FROM session
) t;

SELECT count(*) FROM (
    SELECT model_id FROM message
    INTERSECT ALL
    SELECT name FROM session
) t;

SELECT count(*) FROM (
    SELECT model_id FROM message
    INTERSECT
    SELECT model_id FROM price
) t;

SELECT count(*) FROM (
    SELECT model_id FROM message
    INTERSECT
    SELECT model_id FROM message
    WHERE mid < 15
) t;

-- EXCEPT ALL returns all rows that are in the first query but not the second
-- EXCEPT also removes duplicates

SELECT count(*)
FROM (
    SELECT model_id FROM message
    EXCEPT ALL
    SELECT name FROM session
) t;

SELECT count(DISTINCT model_id)
FROM (
    SELECT model_id FROM message
    EXCEPT
    SELECT name FROM session
    WHERE name IS NOT NULL
) t;

SELECT count(*)
FROM (
    SELECT name FROM session
    EXCEPT
    SELECT model_id FROM message
    WHERE model_id IS NOT NULL
) t;

SELECT count(*) FROM (
    SELECT model_id FROM message
    EXCEPT
    SELECT NULL
) t;

-- The IN operator lets you compare to a "list"
-- See: <https://www.postgresql.org/docs/15/functions-comparisons.html#FUNCTIONS-COMPARISONS-IN-SCALAR>
/*
A IN (a, b, c)
is syntactic sugar for
A = a OR A = b OR A = c
*/

SELECT count(*) FROM message WHERE mid      IN (13, 14);
SELECT count(*) FROM message WHERE model_id IN ('gpt', 'claude');
SELECT count(*) FROM message WHERE model_id IN (NULL);

SELECT count(*) FROM message WHERE mid      NOT IN (13, 14);
SELECT count(*) FROM message WHERE model_id NOT IN ('gpt', 'claude');
SELECT count(*) FROM message WHERE model_id NOT IN (NULL);

SELECT count(*) FROM message WHERE NOT mid      IN (13, 14);
SELECT count(*) FROM message WHERE NOT model_id IN ('gpt', 'claude');
SELECT count(*) FROM message WHERE NOT model_id IN (NULL);

-- A common use-case for subqueries is to populate the "list" to the right of the IN operator
-- These subqueries can only have a single column and do not require a name

SELECT count(*) FROM message WHERE mid      IN (SELECT 13 UNION SELECT 14);
SELECT count(*) FROM message WHERE model_id IN (SELECT 'gpt' UNION SELECT 'claude');

SELECT count(*) FROM message WHERE model_id IN (SELECT model_id  FROM price);
SELECT count(*) FROM message WHERE model_id IN (SELECT DISTINCT model_id  FROM price);

-- adding the DISTINCT keyword into the subquery to the right of an IN clause will never change the results

SELECT count(*)                  FROM message
    WHERE sid      IN (SELECT sid       FROM session);
SELECT count(model_id)           FROM message
    WHERE sid      IN (SELECT sid       FROM session);
SELECT count(DISTINCT model_id)  FROM message
    WHERE sid      IN (SELECT sid       FROM session);

-- We've already seen that the INNER JOIN is syntactic sugar over the cross join plus a condition;
-- that is, the following two statements are equivalent:
--
--     SELECT * FROM a JOIN b ON (condition);
--     SELECT * FROM a,b WHERE condition;
--
-- Outer joins are syntactic sugar for INNER JOIN plus a set operation;
-- The left outer join given by
--
--     SELECT * FROM a LEFT JOIN b ON (condition);
--
-- is equivalent to
--
--     SELECT * FROM a JOIN b ON (condition)
--     UNION ALL
--     (
--     SELECT a.*,NULL,NULL,NULL,... FROM a         -- there should be one NULL for each column in b
--     EXCEPT ALL
--     SELECT a.*,NULL,NULL,NULL,... FROM a JOIN b ON (condition)
--     );
--
-- when `condition` is an equality of the form `a.c1=b.c2`, then the following is also equivalent:
--
--     SELECT * FROM a JOIN b ON (a.c1 = b.c2)
--     UNION ALL
--     SELECT * FROM a WHERE a.c1 NOT IN (SELECT b.c2 FROM b);

SELECT count(*)
FROM message
LEFT JOIN session USING (sid);

SELECT count(name)
FROM message
LEFT JOIN session USING (sid);

SELECT count(DISTINCT name)
FROM message
LEFT JOIN session USING (sid);

SELECT count(*)
FROM message
LEFT JOIN session USING (sid)
WHERE
    name LIKE '%a%';

SELECT count(*)
FROM message
LEFT JOIN session USING (sid)
WHERE
    sid > 1;

SELECT count(*)
FROM message
LEFT JOIN session ON (model_id = name);

SELECT count(*)
FROM message
LEFT JOIN session ON (model_id = name AND message.sid = session.sid);

SELECT count(*)
FROM message
LEFT JOIN session ON (model_id = name OR message.sid = session.sid);

SELECT count(*)
FROM message
LEFT JOIN session ON (message.sid < session.sid);

-- A RIGHT JOIN B is equivalent to B LEFT JOIN A

SELECT count(*)
FROM message
RIGHT JOIN session USING (sid);

-- A FULL JOIN is like a "right join plus a left join"

SELECT count(*)
FROM message
FULL JOIN session USING (sid);

-- The LEFT, RIGHT, and FULL JOINs are all examples of OUTER JOINs.
-- The OUTER keyword can be added without changing the meaning.

SELECT count(*)
FROM message
FULL OUTER JOIN session USING (sid);

SELECT count(*)
FROM message
LEFT OUTER JOIN session USING (sid);

SELECT count(*)
FROM message
RIGHT OUTER JOIN session USING (sid);

-- The "natural" join is syntactic sugar over the USING clause:
-- it is equivalent to using the USING clause over all columns with the same name;
-- The natural join is not a separate type of join, and can be combined with INNER/LEFT/RIGHT joins

SELECT count(*) FROM message NATURAL JOIN session;
SELECT count(*) FROM message NATURAL LEFT JOIN session;
SELECT count(*) FROM message NATURAL LEFT OUTER JOIN session;
SELECT count(*) FROM message NATURAL RIGHT JOIN session;
SELECT count(*) FROM message NATURAL RIGHT OUTER JOIN session;
SELECT count(*) FROM message NATURAL FULL JOIN session;
SELECT count(*) FROM message NATURAL FULL OUTER JOIN session;

SELECT sum(DISTINCT sid) FROM message NATURAL RIGHT JOIN session;

-- As discussed above, every LEFT/RIGHT JOIN can be written in terms of a subquery;
-- subqueries are strictly more powerful, however;
-- if a subquery contains an aggregate function, then it cannot be re-written as a join

SELECT count(*) FROM (
    SELECT sum(mid) FROM message
    UNION
    SELECT sum(sid) FROM session
) t;

SELECT count(*) FROM (
    SELECT sum(DISTINCT mid) FROM message
    UNION
    SELECT sum(sid) FROM session WHERE sid < 5
) t;

SELECT count(*) FROM (
    SELECT count(mid) FROM message
    UNION
    SELECT sid FROM session
) t;

SELECT count(*)
FROM message
WHERE sid NOT IN (SELECT sum(sid) FROM session WHERE name ILIKE '%a%');

SELECT count(*)
FROM session
WHERE sid IN (SELECT count(sid) FROM session WHERE name ILIKE '%a%');

SELECT count(*)
FROM session
WHERE sid IN (SELECT count(sid) FROM message WHERE sid < 5);

-- subqueries can be combined with JOINs

SELECT count(*)
FROM session
WHERE sid IN (
    SELECT count(sid)
    FROM message
    JOIN session USING (sid)
    WHERE sid < 5
);

SELECT count(*)
FROM session, message
WHERE session.sid IN (
    SELECT count(sid)
    FROM message
    JOIN session USING (sid)
    WHERE sid < 5
);

SELECT count(*)
FROM session
LEFT JOIN message USING (sid)
WHERE session.sid IN (
    SELECT count(sid)
    FROM message
    JOIN session USING (sid)
    WHERE sid < 5
);

SELECT count(*)
FROM session
RIGHT JOIN message USING (sid)
WHERE session.sid IN (
    SELECT count(sid)
    FROM message
    JOIN session USING (sid)
    WHERE sid < 5
);

SELECT count(*)
FROM session
RIGHT JOIN message USING (sid)
WHERE session.sid IN (SELECT sid FROM message WHERE sid < 5);

SELECT count(*)
FROM session
LEFT JOIN message USING (sid)
WHERE session.sid IN (SELECT sid FROM message WHERE sid < 5);

SELECT count(*)
FROM session
LEFT JOIN message ON (model_id = name)
WHERE session.sid IN (SELECT sid FROM message WHERE sid < 5);

SELECT count(*)
FROM session
RIGHT JOIN message ON (model_id = name)
WHERE session.sid IN (SELECT sid FROM message WHERE sid < 5);

--------------------------------------------------------------------------------
-- Section: non-equality join conditions
--------------------------------------------------------------------------------

-- Every join condition so far has been an equality, but nothing requires one.
-- A non-equality condition answers a question an equality cannot: which value
-- is bigger, which value came first, and which value is contained in which.
-- They are also where the NULL rules bite hardest, because `NULL < 3` and
-- `NULL > 3` are both NULL, so a non-equality join drops NULL rows even when
-- the columns on both sides are perfectly good.

-- 1. Containment: which session is a descendant of which other session?
--    A session name is a path, so 'a/b/c' LIKE 'a' || '/%' is true while
--    'ab' LIKE 'a' || '/%' is false.  This is the query `dic --cost-session`
--    uses to total a session together with everything nested under it.

SELECT count(*)
FROM session child
JOIN session parent ON (child.name LIKE parent.name || '/%');

-- the same question as an outer join: which sessions are nobody's ancestor?

SELECT count(*)
FROM session parent
LEFT JOIN session child ON (child.name LIKE parent.name || '/%')
WHERE child.name IS NULL;

-- 2. Ordering: which pairs of messages are in the same session, in order?
--    This is a rank without a window function: it counts how many messages
--    a message comes after within its own session.

SELECT count(*)
FROM message a
JOIN message b ON (a.sid = b.sid AND a.mid > b.mid);

-- the outer version asks for the first message of each session.  Note that a
-- duplicated row changes the answer, because both copies count as first.

SELECT count(*)
FROM message a
LEFT JOIN message b ON (a.sid = b.sid AND a.mid > b.mid)
WHERE b.mid IS NULL;

-- 3. Threshold: which models cost no more than which other models?

SELECT count(*)
FROM price a
JOIN price b ON (a.per_tok <= b.per_tok);

-- and the outer version: which model is strictly the cheapest?

SELECT count(*)
FROM price a
LEFT JOIN price b ON (b.per_tok < a.per_tok)
WHERE b.model_id IS NULL;

-- 4. The NULL trap.  `a.mid > b.mid` is NULL whenever either side is NULL,
--    so the inner join above does not count the three messages whose sid is
--    NULL, while the left join counts all three as "first" in their session.
--    In query 2 the equality `a.sid = b.sid` decides which rows are
--    candidates and the non-equality decides which of them survive, so the
--    two operators fail in different ways and have to be reasoned about
--    separately.

--------------------------------------------------------------------------------
-- Section: inner and outer joins mixed across all three tables
--------------------------------------------------------------------------------

-- Every query so far has used two tables and a single join.
-- A real query threads one row through several tables.
-- The important rule to remember is that all JOINs are left-associative,
-- and so you work through a problem left -> right / top -> bottom.

-- all inner: a message must have a session, and its model must be priced

SELECT count(*)
FROM message
JOIN session USING (sid)
JOIN price USING (model_id);

-- all outer: nothing is dropped, so every message appears

SELECT count(*)
FROM message
LEFT JOIN session USING (sid)
LEFT JOIN price USING (model_id);

-- inner then outer: the session join drops the messages that have no session,
-- and then every remaining message is kept whether or not it is priced

SELECT count(*)
FROM message
JOIN session USING (sid)
LEFT JOIN price USING (model_id);

-- outer then inner: the session join keeps everything, and then the price join
-- drops the messages whose model is NULL or has no price row

SELECT count(*)
FROM message
LEFT JOIN session USING (sid)
JOIN price USING (model_id);

-- The four counts above are all different.
-- Only INNER JOINs are commutative;
-- all outer joins are non-commutative,
-- and so changing the order of the joins changes the result.

-- an outer join onto the third table, so that a session no message used still
-- appears in the output

SELECT count(*)
FROM session
LEFT JOIN message USING (sid)
LEFT JOIN price USING (model_id);

-- a full join, to see both unmatched sides at once

SELECT count(*)
FROM message
FULL JOIN session USING (sid)
FULL JOIN price USING (model_id);
