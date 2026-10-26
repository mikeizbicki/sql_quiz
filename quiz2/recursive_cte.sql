/*
 * The examples below show the basic syntax of a recursive CTE in sql.
 *
 * - The RECURSIVE keyword is required in postgres and optional in sqlite3.
 * - The recursive CTE must have a UNION or UNION ALL set operation.
 *   - one side must not mention the CTE
 *   - one side must mention the CTE
 */

-- CTE = common table expression
-- "local variables" "local tables" in sql
WITH n(i) AS (
    SELECT 1  -- we start here at the
              -- non-recursive part
  UNION ALL
    SELECT i+1 FROM n WHERE i<5
)
-- every recursive iteration:
-- we take all the new rows from the previous
-- recursions and those go into the n table
SELECT * FROM n
ORDER BY i;


WITH RECURSIVE n(i) AS (
    SELECT 1 UNION ALL SELECT 3
  UNION ALL
    SELECT i+1 FROM n WHERE i<5
)
SELECT * FROM n
ORDER BY i;

/*
iter0:
 1
 3
iter1:
 2
 4
iter2:
 3
 5
iter3:
 4
iter4:
 5
iter5:
 - add nothing end recursion
*/
WITH RECURSIVE n(i) AS (
    SELECT 1 UNION ALL SELECT 3
  UNION
    SELECT i+1 FROM n WHERE i<5
)
SELECT * FROM n
ORDER BY i;


/*
 * Recursive CTEs are most commonly used when the data forms a tree/graph structure.
 * They are the only way to traverse the structure in a single query.
 */

-- the query below shows how to get a full conversation history based on a single "leaf"

WITH RECURSIVE history AS (
    SELECT mid, prev_mid, user, response
    FROM message WHERE mid = 25
  UNION ALL
    SELECT m.mid, m.prev_mid, m.user, m.response
    FROM message m
    JOIN history ON m.mid = history.prev_mid
)
SELECT * FROM history
ORDER BY mid;

iter0:
  mid, prev_mid
  25,  24
iter1:
  24,  13
iter2:
  13,  11
iter3:
  11,  10
iter4:
  10,  NULL


WITH RECURSIVE history AS (
    SELECT mid, prev_mid
    FROM message WHERE mid = 17
  UNION ALL
    SELECT m.mid, m.prev_mid
    FROM message m
    JOIN history ON m.mid = history.prev_mid
)
SELECT * FROM history
ORDER BY mid;


-- we can get multiple conversation histories at once,
-- and this requires care with the UNION / UNION ALL choice

WITH RECURSIVE history AS (
    SELECT mid, prev_mid
    FROM message WHERE mid = 25
  UNION ALL
    SELECT mid, prev_mid
    FROM message WHERE mid = 17
  UNION ALL
    SELECT m.mid, m.prev_mid
    FROM message m
    JOIN history ON m.mid = history.prev_mid
)
SELECT * FROM history
ORDER BY mid;


WITH RECURSIVE history AS (
    SELECT mid, prev_mid
    FROM message WHERE mid = 25 OR mid = 17
  UNION ALL
    SELECT m.mid, m.prev_mid
    FROM message m
    JOIN history ON m.mid = history.prev_mid
)
SELECT * FROM history
ORDER BY mid;


WITH RECURSIVE history AS (
    SELECT mid, prev_mid
    FROM message WHERE mid = 25
  UNION ALL
    SELECT mid, prev_mid
    FROM message WHERE mid = 17
  UNION
    SELECT m.mid, m.prev_mid
    FROM message m
    JOIN history ON m.mid = history.prev_mid
)
SELECT * FROM history
ORDER BY mid;


WITH RECURSIVE history AS (
    SELECT mid, prev_mid
    FROM message WHERE mid = 25
  UNION
    SELECT mid, prev_mid
    FROM message WHERE mid = 17
  UNION ALL
    SELECT m.mid, m.prev_mid
    FROM message m
    JOIN history ON m.mid = history.prev_mid
)
SELECT * FROM history
ORDER BY mid;

-- if we traverse the history "in reverse" we can go from the root node to all leaves

WITH RECURSIVE history AS (
    SELECT mid, prev_mid
    FROM message WHERE mid = 10
  UNION ALL
    SELECT m.mid, m.prev_mid
    FROM message m
    JOIN history ON history.mid = m.prev_mid
)
SELECT * FROM history
ORDER BY mid;


WITH RECURSIVE history AS (
    SELECT mid, prev_mid
    FROM message WHERE mid = 12
  UNION ALL
    SELECT m.mid, m.prev_mid
    FROM message m
    JOIN history ON history.mid = m.prev_mid
)
SELECT * FROM history
ORDER BY mid;


-- The queries below combine the recursive CTEs above
-- with other SQL features for semantically meaningful queries

WITH RECURSIVE history AS (
    SELECT mid, prev_mid, model_id
    FROM message WHERE mid = 10
  UNION ALL
    SELECT m.mid, m.prev_mid, m.model_id
    FROM message m
    JOIN history ON history.mid = m.prev_mid
)
SELECT count(*) FROM history;


WITH RECURSIVE history AS (
    SELECT mid, prev_mid, model_id
    FROM message WHERE mid = 10
  UNION ALL
    SELECT m.mid, m.prev_mid, m.model_id
    FROM message m
    JOIN history ON history.mid = m.prev_mid
)
SELECT model_id, count(*) FROM history
GROUP BY model_id
ORDER BY model_id;


WITH RECURSIVE history AS (
    SELECT mid, prev_mid, model_id
    FROM message WHERE mid = 10
  UNION ALL
    SELECT m.mid, m.prev_mid, m.model_id
    FROM message m
    JOIN history ON history.mid = m.prev_mid
)
SELECT sum(per_tok) FROM history
LEFT JOIN price USING(model_id)
ORDER BY mid;
