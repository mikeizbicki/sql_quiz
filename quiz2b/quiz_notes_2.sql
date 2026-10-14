/* The queries below are the quiz2 notes rewritten for the quiz2b schema.
 * That schema has three tables -- `message`, `session` and `price` -- in
 * place of the two baskets, and is described at the top of
 * `create_tables.sql`.  Every query below tests the same concept as the
 * query it replaces; only the table and column names have changed.
 *
 * The mapping is
 *
 *     basket_a   ->  message       (the row that has a parent)
 *     basket_b   ->  session       (the row that has a name)
 *     a.id       ->  message.sid
 *     b.id       ->  session.sid
 *     a.fruit_a  ->  message.model_id
 *     b.fruit_b  ->  session.name
 */

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

SELECT count(*)                 FROM message WHERE model_id IN (SELECT model_id  FROM price);
SELECT count(*)                 FROM message WHERE model_id IN (SELECT DISTINCT model_id  FROM price);

-- adding the DISTINCT keyword into the subquery to the right of an IN clause will never change the results

SELECT count(*)                 FROM message WHERE sid      IN (SELECT sid       FROM session);
SELECT count(model_id)           FROM message WHERE sid      IN (SELECT sid       FROM session);
SELECT count(DISTINCT model_id)  FROM message WHERE sid      IN (SELECT sid       FROM session);

-- `NOT IN` is where the NULLs bite hardest.  The subquery below returns every
-- session id, the NULL one included, and
--
--     sid NOT IN (1, 2, NULL)
--
-- is `sid != 1 AND sid != 2 AND sid != NULL`, whose last conjunct is NULL for
-- every row.  The result is empty in both engines.

SELECT count(*)
FROM message
WHERE sid NOT IN (SELECT sid FROM session);

-- Filtering the NULL out of the subquery is not the fix, because the message
-- side has NULLs of its own: the messages whose own sid is NULL are still
-- dropped, and the query still does not answer "which messages have no
-- session".  A LEFT JOIN says what was meant:

SELECT count(*)
FROM message m
LEFT JOIN session s ON m.sid = s.sid
WHERE s.sid IS NULL;

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
--

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

-- outer joins can be chained together,
-- and the same table can be used multiple times

SELECT count(*)
FROM message a1
LEFT JOIN message a2 USING (sid)
LEFT JOIN message a3 USING (sid);

SELECT count(*)
FROM session b1
LEFT JOIN session b2 USING (sid)
LEFT JOIN session b3 USING (sid);

-- OUTER JOIN order is not commutative

SELECT count(*)
FROM message a
LEFT JOIN session b1 USING (sid)
LEFT JOIN session b2 USING (sid);

SELECT count(*)
FROM session b1
LEFT JOIN message a USING (sid)
LEFT JOIN session b2 USING (sid);

SELECT count(*)
FROM session b1
LEFT JOIN session b2 USING (sid)
LEFT JOIN message a USING (sid);

-- when an outer join is combined with any other type of join,
-- then the joins are no longer associative

SELECT count(*) FROM session b1 LEFT JOIN message a USING (sid) JOIN session b2 USING (sid);
SELECT count(*) FROM (session b1 LEFT JOIN message a USING (sid)) JOIN session b2 USING (sid);
SELECT count(*) FROM session b1 LEFT JOIN (message a JOIN session b2 USING (sid)) USING (sid);

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

-- Every query so far has used two tables and a single join.  A real query
-- threads one row through several tables, and the interesting part is which
-- of those hops is inner and which is outer.  Joins are left-associative:
-- each JOIN combines everything to its left with the table to its right.

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

-- The four counts above are all different, and only the first is symmetric in
-- the tables.  Reversing the order of two joins of different kinds changes the
-- answer, which is the same non-associativity seen earlier with two tables.

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

-- the version that shows the rows instead of counting them.  Every column of
-- every table is named, so which join produced a NULL is visible.

SELECT s.name, m.mid, m.model_id, p.per_tok
FROM message
LEFT JOIN session USING (sid)
LEFT JOIN price USING (model_id)
ORDER BY m.mid, s.name;

--------------------------------------------------------------------------------
-- Section: LATERAL joins
--------------------------------------------------------------------------------

-- A LATERAL join is a CROSS JOIN whose right side may mention the current row
-- of the left side.  That is the whole of it:
--
--     SELECT * FROM a,             (SELECT ...) b                -- b is fixed
--     SELECT * FROM a, LATERAL     (SELECT ... WHERE x = a.x) b  -- one b per row of a
--
-- Without LATERAL, a subquery in the FROM clause is evaluated once, before the
-- join, and cannot mention `a` at all.  With it, the subquery is evaluated once
-- per row of `a`, which is the "for loop" intuition of the CROSS JOIN made
-- literal: `a` is the loop variable and the subquery is the loop body.  It is
-- the one place SQL lets the body of a loop see the variable.
--
-- A LEFT JOIN LATERAL is then the same decomposition as any other left outer
-- join: a CROSS JOIN LATERAL, plus every left row that matched nothing with
-- NULLs in every column of the right side.  `ON true` is required by postgres
-- when LATERAL is written with the JOIN keyword.
--
-- sqlite3 has no LATERAL keyword, so every query below is a syntax error
-- there, in both the comma form and the JOIN form.  What sqlite3 has instead,
-- since 3.38, is that a FROM-clause subquery may refer to an earlier table
-- without being told it may:
--
--     SELECT * FROM session s, (SELECT ... WHERE message.sid = s.sid) m
--
-- and that form is an error in postgres, which requires the keyword.  The two
-- engines have the same capability and no syntax in common.

-- the newest message in each session.  The subquery runs once per session row,
-- and LIMIT 1 picks that session's newest message and no other's.

SELECT count(*)
FROM session s
LEFT JOIN LATERAL (
    SELECT * FROM message WHERE message.sid = s.sid ORDER BY mid DESC LIMIT 1
) m ON true;

-- which sessions have no messages at all?

SELECT count(*)
FROM session s
LEFT JOIN LATERAL (
    SELECT * FROM message WHERE message.sid = s.sid
) m ON true
WHERE m.mid IS NULL;

-- the two newest messages in each session.  This is the case a WHERE clause
-- cannot express, because LIMIT 2 has to happen once per session and not once
-- per query: a plain CROSS JOIN with a WHERE would apply the limit to the
-- whole result.

SELECT count(*)
FROM session s
LEFT JOIN LATERAL (
    SELECT * FROM message WHERE message.sid = s.sid ORDER BY mid DESC LIMIT 2
) m ON true;

-- to see what the join produced, print it instead of counting it.  `session`
-- has two rows named 'a/b', so the newest message of that session is printed
-- twice.  (The ordering of the NULL name is the one place sqlite3 and postgres
-- disagree by default; see `quiz_notes_1.sql`.)

SELECT s.name, m.mid, m.model_id
FROM session s
LEFT JOIN LATERAL (
    SELECT * FROM message WHERE message.sid = s.sid ORDER BY mid DESC LIMIT 1
) m ON true
ORDER BY s.name, m.mid;

-- the same newest-per-session query with a comma instead of the keyword, which
-- parses as a CROSS JOIN and so keeps only the sessions that had a match

SELECT count(*)
FROM session s,
LATERAL (SELECT * FROM message WHERE message.sid = s.sid ORDER BY mid DESC LIMIT 1) m;

--------------------------------------------------------------------------------
-- Section: recursive CTEs
--------------------------------------------------------------------------------

-- A recursive CTE is a WITH clause that refers to itself.  It has the same
-- two-part shape as any other set operation:
--
--     WITH RECURSIVE r AS (
--         SELECT ...                          -- the seed: where the walk starts
--       UNION ALL
--         SELECT ... FROM t JOIN r ON ...     -- the step: how the walk continues
--     )
--     SELECT * FROM r;
--
-- `message` is a forest.  `prev_mid` names the round this one replies to, and
-- a NULL `prev_mid` means the round begins a conversation, so following
-- `prev_mid` upward reconstructs a conversation.  That is exactly what `dic`
-- does to rebuild the history it sends to a model, and the CTE column list is
-- the same idea as the explicit column list a subquery gets with AS.
--
-- postgres requires the RECURSIVE keyword whenever the CTE refers to itself;
-- sqlite3 accepts it but does not require it.  Always write it and both
-- engines agree.  Both forbid aggregates and DISTINCT inside the recursive
-- term; postgres additionally forbids GROUP BY, ORDER BY, LIMIT and OFFSET
-- there, so a recursive query can run in sqlite3 and be rejected by postgres.
--
-- The order of the rows a recursive CTE produces is not defined by the
-- standard and differs between engines.  An ORDER BY belongs outside the CTE.

-- every message that the conversation beginning at mid 10 reaches

WITH RECURSIVE thread(mid) AS (
    SELECT mid FROM message WHERE mid = 10
  UNION ALL
    SELECT m.mid FROM message m JOIN thread t ON m.prev_mid = t.mid
)
SELECT count(*) FROM thread;

-- the duplicate row for mid 17 makes the step visit 17 twice, so changing
-- UNION ALL to UNION changes the answer without the data changing at all

WITH RECURSIVE thread(mid) AS (
    SELECT mid FROM message WHERE mid = 10
  UNION
    SELECT m.mid FROM message m JOIN thread t ON m.prev_mid = t.mid
)
SELECT count(*) FROM thread;

-- a root that is itself duplicated doubles the whole walk, because the seed
-- produces two identical starting points and every step is applied to both

WITH RECURSIVE thread(mid) AS (
    SELECT mid FROM message WHERE mid = 15
  UNION ALL
    SELECT m.mid FROM message m JOIN thread t ON m.prev_mid = t.mid
)
SELECT count(*) FROM thread;

-- walking the other way: the conversation that mid 25 belongs to, upward, with
-- the depth of each message

WITH RECURSIVE chain(mid, prev_mid, depth) AS (
    SELECT mid, prev_mid, 0 FROM message WHERE mid = 25
  UNION ALL
    SELECT m.mid, m.prev_mid, chain.depth + 1
      FROM message m JOIN chain ON m.mid = chain.prev_mid
)
SELECT count(*), max(depth) FROM chain;

-- every conversation in the table, each row tagged with the root it belongs to

WITH RECURSIVE forest(root, mid) AS (
    SELECT mid, mid FROM message WHERE prev_mid IS NULL
  UNION ALL
    SELECT f.root, m.mid FROM message m JOIN forest f ON m.prev_mid = f.mid
)
SELECT count(*) FROM forest;

-- the same walk with a depth cap, so that a tree with a cycle in it terminates
-- instead of looping forever.  `dic` caps its own ancestor walk the same way,
-- and a hand-written models file that nests an entry inside itself is exactly
-- the bug the cap is there for.

WITH RECURSIVE thread(mid, depth) AS (
    SELECT mid, 0 FROM message WHERE mid = 10
  UNION ALL
    SELECT m.mid, t.depth + 1
      FROM message m JOIN thread t ON m.prev_mid = t.mid
     WHERE t.depth < 3
)
SELECT count(*) FROM thread;

-- The session tree asks the same kind of question and needs no recursion at
-- all, because a session name is a path and a LIKE can express ancestry:
--
--     child.name LIKE parent.name || '/%'
--
-- Recursion is needed when the parent is named by a column and not by the
-- child.  The two trees in this schema are the same idea stored two different
-- ways, and comparing the queries is the point of the exercise.

SELECT count(*)
FROM session
WHERE name = 'a' OR name LIKE 'a' || '/%';

-- and the same query against `message`, where it cannot be written this way
-- at all: `prev_mid` names the parent, so the only way to ask is to walk

WITH RECURSIVE subtree(mid) AS (
    SELECT mid FROM message WHERE mid = 10
  UNION ALL
    SELECT m.mid FROM message m JOIN subtree s ON m.prev_mid = s.mid
)
SELECT count(*) FROM subtree;
