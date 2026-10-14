--------------------------------------------------------------------------------
-- Section: LATERAL joins
--------------------------------------------------------------------------------

-- We can use any type of join on subqueries just like we can on tables.
-- Normally, the subquery must not mention any columns from another table.
-- In a LATERAL join, the subquery is allowed to depend on the current row
-- of the left most table.
--
--     SELECT * FROM a,             (SELECT ...) b                -- b is fixed
--     SELECT * FROM a, LATERAL     (SELECT ... WHERE x = a.x) b  -- one b per row of a
--
-- All join types (INNER, LEFT, etc.) can be made LATERAL by adding the keyword after the join type.

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

-- A recursive CTE is a WITH clause that refers to itself.
-- It has the same two-part shape as any other set operation:
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
