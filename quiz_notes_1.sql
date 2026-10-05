--------------------------------------------------------------------------------
-- Section 1: Syntax
--------------------------------------------------------------------------------

/*
SQL has lots of weird syntax compared to other languages.
This is because:
1. SQL was designed in the 70s before current conventions were standardized; and
1. these conventions have not been changed for backwards compatibility reasons.
*/

-- commands case insensitive, but text case sensitive
sElEcT 'hello world';
SELECT 'Hello' = 'hello';

-- string concatenation uses || not +
-- + used only for "real" math
SELECT 'hello' || 'world';
SELECT 1 + 2;

-- escape quotations by doubling the quote marked
SELECT 'isn''t SQL weird?';
-- SELECT 'isn\'t SQL weird?';          /* syntax error */

-- sql supports the "dollar quoted string literal" syntax
SELECT $$isn't SQL great?$$;
SELECT $blah$isn't SQL great?$blah$;

-- double quotes for column/relation names
-- they are optional if no special characters are used in the name
SELECT 'hello world';
SELECT 'hello world' AS greeting;
SELECT 'hello world' AS "the greeting";

--------------------------------------------------------------------------------
-- Section 2: Basic Semantics
--------------------------------------------------------------------------------

-- aggregate functions "merge" all rows in the table into a single row
-- aggregate functions will ignore rows that evaluate to null
-- for the quiz, you are responsible for: count, sum, max, min

SELECT count(*) FROM basket_a;
SELECT count(1) FROM basket_a;
SELECT count(fruit_a) FROM basket_a;
SELECT count(id) FROM basket_a;
SELECT count(id || fruit_a) FROM basket_a;

SELECT sum(1) FROM basket_a;
SELECT sum(id) FROM basket_a;

SELECT max(id) FROM basket_a;
SELECT min(id) FROM basket_a;

-- When the results are returning an entire table instead of a single row,
-- the resulting ordering is *non-deterministic*;
-- these notes will always use the ORDER BY clause to make the results deterministic.
-- the default ordering is ASC, but DESC can also be specified to reverse the order
-- postgres and sqlite treat the ordering of NULL values differently:
--   postgres: NULL values are treated as "larger"
--   sqlite3: NULL values are treated as "smaller"
-- this behavior can be overridden with the NULLS FIRST / NULLS LAST syntax

SELECT id FROM basket_a ORDER BY id;
SELECT id FROM basket_a ORDER BY id DESC;
SELECT id FROM basket_a ORDER BY id DESC NULLS FIRST;
SELECT id FROM basket_a ORDER BY id DESC NULLS LAST;

SELECT fruit_a FROM basket_a ORDER BY id;
SELECT fruit_a FROM basket_a ORDER BY id DESC;
SELECT fruit_a FROM basket_a ORDER BY id DESC NULLS FIRST;
SELECT fruit_a FROM basket_a ORDER BY id DESC NULLS LAST;

-- CAUTION: max/min are not aggregates when they have >1 param
SELECT max(id, 1) FROM basket_a ORDER BY id;
SELECT min(id, 1) FROM basket_a ORDER BY id;

-- the DISTINCT operator removes duplicates before passing to the aggregate function

SELECT count(DISTINCT fruit_a) FROM basket_a;
SELECT count(DISTINCT id) FROM basket_a;
SELECT count(DISTINCT 1) FROM basket_a;
SELECT sum(DISTINCT id) FROM basket_a;

-- operators on NULL values always return NULL
-- A NULL condition in a WHERE clause causes the row to not be selected

SELECT count(*) FROM basket_a WHERE fruit_a = NULL;
SELECT count(*) FROM basket_a WHERE fruit_a IS NULL;
SELECT count(*) FROM basket_a WHERE fruit_a != NULL;
SELECT count(*) FROM basket_a WHERE fruit_a IS NOT NULL;

SELECT count(*) FROM basket_a WHERE id < 3;
SELECT count(*) FROM basket_a WHERE id < 3 OR id IS NULL;
SELECT count(id) FROM basket_a WHERE id < 3;
SELECT count(DISTINCT id) FROM basket_a WHERE id < 3;

SELECT count(*) FROM basket_a WHERE (fruit_a = NULL) IS NULL;
SELECT count(*) FROM basket_a WHERE NOT (fruit_a = NULL) IS NULL;

SELECT sum(id) FROM basket_a WHERE fruit_a IS NULL;
SELECT sum(id) FROM basket_a WHERE id IS NOT NULL;

-- CASE is SQL's if/else expression
-- if no branch matches and there is no ELSE, the result is NULL

SELECT CASE
    WHEN id IS NULL THEN 'no id'
    ELSE 'has id'
    END
FROM basket_a;

SELECT CASE
    WHEN id < 3 THEN 1
    WHEN id < 5 THEN 2
    ELSE 3
    END
FROM basket_a;

SELECT CASE
    WHEN id < 3 THEN 1
    WHEN id < 5 THEN 2
    END
FROM basket_a;

-- CASE has a "simple" form that compares one expression against a list of values

SELECT CASE fruit_a WHEN 'Apple' THEN 1 WHEN 'Orange' THEN 2 END FROM basket_a;
SELECT CASE fruit_a WHEN 'Apple' THEN 1 WHEN NULL THEN 2 END FROM basket_a;

-- CASE is often used alongside aggregates to make them "conditional"

SELECT count(CASE WHEN id IS NULL THEN 1 END) FROM basket_a;
SELECT sum(CASE WHEN fruit_a = 'Apple' THEN 1 ELSE 0 END) FROM basket_a;

-- COALESCE returns its first non-NULL argument
-- (or NULL if all arguments are NULL)

SELECT COALESCE(id, 0) FROM basket_a;
SELECT COALESCE(fruit_a, id, -1) FROM basket_a;
SELECT COALESCE(NULL, NULL) FROM basket_a;

-- In the ANSI SQL standard:
-- (1) the LIKE operator is case sensitive
-- (2) % behaves in the same way as the POSIX glob
--
-- Case sensitive operations are usually more efficient to implement;
-- case in-sensitive operations, are usually more useful.
--
-- In postgres:
-- (1) LIKE is case sensitive
-- (2) ILIKE is case insensitive
--
-- In sqlite3:
-- (1) LIKE is case insensitive
-- (2) ILIKE does not exist and results in an error

SELECT count(*) FROM basket_a WHERE fruit_a LIKE '%a%';
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE '%a%';
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE 'a%';
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE 'a';
SELECT count(DISTINCT fruit_a) FROM basket_a WHERE fruit_a ILIKE '%a%';

-- GROUP BY considers NULL values to be their own group
SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
ORDER BY fruit_a DESC;

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
ORDER BY fruit_a ASC;

-- the WHERE clause happens before the GROUP BY, the HAVING clause happens after the GROUP BY
-- the WHERE clause cannot contain aggregate functions, but the HAVING clause can
-- the HAVING clause cannot contain columns that are not included in the SELECT statement's column list, but the WHERE clause can

SELECT fruit_a, count(*)
FROM basket_a
WHERE id IS NULL
GROUP BY fruit_a
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
WHERE id = NULL
GROUP BY fruit_a
ORDER BY fruit_a;

SELECT fruit_a, count(fruit_a)
FROM basket_a
WHERE id < 5 AND id >= 3
GROUP BY fruit_a
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
WHERE id < 5 AND id >= 3
GROUP BY fruit_a
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
HAVING count(*) > 1
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
HAVING count(*) > 1
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
HAVING count(fruit_a) = 1
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
WHERE fruit_a LIKE '%a%'
GROUP BY fruit_a
HAVING fruit_a LIKE '%a%'
ORDER BY fruit_a;

--------------------------------------------------------------------------------
-- Section 3: JOINs
--------------------------------------------------------------------------------

-- JOINs construct a new table by combining two separate tables.
-- All JOINs are constructed internally from a CROSS JOIN,
-- but CROSS JOINs are rarely directly used in practice.
-- The CROSS JOIN joins every row from the first table with every other row from the second table.

SELECT count(*)
FROM basket_a, basket_b;

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;

SELECT count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id OR (basket_a.id IS NULL AND basket_b.id IS NULL);

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id;

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b;

SELECT count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b;

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b;

SELECT fruit_a, count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b
GROUP BY fruit_a
ORDER BY fruit_a DESC;

SELECT fruit_a, count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b
GROUP BY fruit_a
HAVING count(basket_a.id) > 3
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id
GROUP BY fruit_a
ORDER BY fruit_a;

-- The INNER JOIN is syntactic sugar for a CROSS JOIN plus a WHERE clause

SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b ON basket_a.id = basket_b.id;

/*
the above query is equivalent to 

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;
*/

SELECT fruit_a, count(*)
FROM basket_a
JOIN basket_b ON basket_a.id > basket_b.id
GROUP BY fruit_a
ORDER BY fruit_a;

/*
the above query is equivalent to 

SELECT fruit_a, count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id
GROUP BY fruit_a
ORDER BY fruit_a;
*/

-- The USING clause is syntactic sugar for an INNER JOIN that:
-- (1) uses an equality condition
-- (2) has identical column names in both tables
--
-- WARNING:
-- Ensure that you understand the behavior of NULL values.

SELECT count(DISTINCT id)
FROM basket_a
JOIN basket_b USING (id);

/*
the above query is equivalent to

SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b ON basket_a.id = basket_b.id

Note that in the column list for JOINs with the ON clause,
we must use "fully qualified names" to refer to columns.
When we use the USING clause,
we do not need to specify the table of the "id" column.
*/

SELECT count(*)
FROM basket_a
JOIN basket_b USING (id)
WHERE id IS NOT NULL;

-- The NATURAL JOIN is syntactic sugar for a USING clause.
-- It joins the tables on all columns with shared names.

SELECT count(DISTINCT id)
FROM basket_a
NATURAL JOIN basket_b;

-- A "self join" is a join of a table with itself.
-- Self joins are not their own special join type;
-- any type of join (e.g. CROSS, INNER, NATURAL) can be called a self join.
-- To be syntactically valid, a self join must specify a "table alias".
-- (Table aliases are always allowed, but required for self joins.)
-- Aliases disambiguate which column of the table we are referring to.

SELECT count(*)
FROM basket_a AS a1
   , basket_a AS a2
WHERE a1.id > a2.id;

SELECT count(*)
FROM basket_a AS a1
   , basket_a AS a2
WHERE a1.id = a2.id;

SELECT count(*)
FROM basket_a a1 -- the AS keyword is optional
   , basket_a a2
WHERE a1.id = a2.id;

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (id);

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (id, fruit_a);

SELECT count(*)
FROM basket_a a1
NATURAL JOIN basket_a a2;

-- All joins are "binary operations" and involve exactly two tables.
-- But multiple joins can be combined together.
-- CROSS JOINS, INNER JOINS, and NATURAL JOINS are associative and commutative (up to the ordering of column results).

SELECT count(*)
FROM basket_a a1, basket_a a2, basket_b
WHERE a1.id = a2.id
  AND a1.fruit_a = basket_b.fruit_b;

/*
the above query is the same as

SELECT count(*)
FROM basket_a a1, basket_b, basket_a a2
WHERE a1.id = a2.id
  AND a1.fruit_a = basket_b.fruit_b;

SELECT count(*)
FROM basket_b, basket_a a2, basket_a a1 
WHERE a1.id = a2.id
  AND a1.fruit_a = basket_b.fruit_b;
*/

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 ON a1.id = a2.id
JOIN basket_b ON a1.fruit_a = basket_b.fruit_b;

/*
the above query is equivalent to

SELECT count(*)
FROM basket_a a1
JOIN basket_b ON a1.fruit_a = basket_b.fruit_b
JOIN basket_a a2 ON a1.id = a2.id;

SELECT count(*)
FROM basket_b 
JOIN basket_a a1 ON a1.fruit_a = basket_b.fruit_b
JOIN basket_a a2 ON a1.id = a2.id;
*/

-- NOTE:
-- SQL is based mathematically on "relational algebra".
-- If this were a database theory course,
-- we would cover relational algebra in detail and prove the associative and commutative properties above.

--------------------------------------------------------------------------------
-- Section 4: Window Functions
--------------------------------------------------------------------------------

-- A window function is a generalization of an aggregate function.
-- Recall that an aggregate function "merges" all rows of a group into one row.
-- A window function instead computes a function of the rows in a "window frame"
-- and returns that value *for each row*.
--
-- The syntax is:
--
--     f(...) OVER (PARTITION BY ... ORDER BY ... ROWS BETWEEN ...)

-- An empty OVER () means that the window frame is the entire table;
-- compare each window function to the corresponding aggregate function below

SELECT id, fruit_a, sum(id) OVER () FROM basket_a ORDER BY id;
SELECT sum(id) FROM basket_a ORDER BY fruit_a;

SELECT id, fruit_a, count(*) OVER () FROM basket_a ORDER BY id;
SELECT count(*) FROM basket_a ORDER BY fruit_a;

-- the PARTITION BY syntax is like GROUP BY inside of the frame

SELECT id, fruit_a, sum(id) OVER (PARTITION BY fruit_a) FROM basket_a ORDER BY fruit_a;
SELECT fruit_a, sum(id) FROM basket_a GROUP BY fruit_a ORDER BY fruit_a;

SELECT id, fruit_a, count(*) OVER (PARTITION BY fruit_a) FROM basket_a ORDER BY fruit_a;
SELECT fruit_a, count(*) FROM basket_a GROUP BY fruit_a ORDER BY fruit_a;

-- ORDER BY inside OVER does two things:
-- (1) it determines the ordering of rows within each partition
-- (2) it changes the default frame to include only those rows before the current row
-- note that the outer ORDER BY is unrelated to the inner one

SELECT id, fruit_a, sum(id) OVER (ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, fruit_a, sum(id) OVER (ORDER BY id) FROM basket_a ORDER BY fruit_a;
SELECT id, fruit_a, sum(id) OVER (ORDER BY fruit_a) FROM basket_a ORDER BY fruit_a;
SELECT id, fruit_a, sum(id) OVER (ORDER BY fruit_a) FROM basket_a ORDER BY id;

SELECT id, fruit_a, sum(id) OVER (ORDER BY id DESC) FROM basket_a ORDER BY id ASC;
SELECT id, fruit_a, sum(id) OVER (ORDER BY id DESC) FROM basket_a ORDER BY fruit_a ASC;
SELECT id, fruit_a, sum(id) OVER (ORDER BY fruit_a DESC) FROM basket_a ORDER BY fruit_a ASC;
SELECT id, fruit_a, sum(id) OVER (ORDER BY fruit_a DESC) FROM basket_a ORDER BY id ASC;

-- CAUTION: when ORDER BY has ties, RANGE includes all tied peers;
-- use ROWS if you want a strict prefix

SELECT id, fruit_a, sum(id) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) FROM basket_a;

SELECT id, fruit_a, sum(id) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) FROM basket_a ORDER BY id;
SELECT id, fruit_a, sum(id) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) FROM basket_a ORDER BY fruit_a;
SELECT id, fruit_a, sum(id) OVER (ORDER BY fruit_a ROWS UNBOUNDED PRECEDING) FROM basket_a ORDER BY fruit_a;
SELECT id, fruit_a, sum(id) OVER (ORDER BY fruit_a ROWS UNBOUNDED PRECEDING) FROM basket_a ORDER BY id;

SELECT id, fruit_a, sum(id) OVER (ORDER BY id DESC ROWS UNBOUNDED PRECEDING) FROM basket_a ORDER BY id ASC;
SELECT id, fruit_a, sum(id) OVER (ORDER BY id DESC ROWS UNBOUNDED PRECEDING) FROM basket_a ORDER BY fruit_a ASC;
SELECT id, fruit_a, sum(id) OVER (ORDER BY fruit_a DESC ROWS UNBOUNDED PRECEDING) FROM basket_a ORDER BY fruit_a ASC;
SELECT id, fruit_a, sum(id) OVER (ORDER BY fruit_a DESC ROWS UNBOUNDED PRECEDING) FROM basket_a ORDER BY id ASC;

-- CAUTION: recall that NULLS are ordered differently in the sqlite3 and postgres

SELECT id, sum(id) OVER (ORDER BY id) FROM basket_a;
SELECT id, sum(id) OVER (ORDER BY id DESC) FROM basket_a;

-- an explicit ROWS frame restricts the window to a fixed-size sliding range

SELECT id, sum(id) OVER (ORDER BY id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) FROM basket_a;

-- there are many useful functions that can only be used as window functions

SELECT id, row_number()    OVER (ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, rank()          OVER (ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, dense_rank()    OVER (ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, lag(id)         OVER (ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, lead(id)        OVER (ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, first_value(id) OVER (ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, last_value(id)  OVER (ORDER BY id) FROM basket_a ORDER BY id;

SELECT id, row_number()    OVER (PARTITION BY fruit_a ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, rank()          OVER (PARTITION BY fruit_a ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, dense_rank()    OVER (PARTITION BY fruit_a ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, lag(id)         OVER (PARTITION BY fruit_a ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, lead(id)        OVER (PARTITION BY fruit_a ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, first_value(id) OVER (PARTITION BY fruit_a ORDER BY id) FROM basket_a ORDER BY id;
SELECT id, last_value(id)  OVER (PARTITION BY fruit_a ORDER BY id) FROM basket_a ORDER BY id;

--------------------------------------------------------------------------------
-- Section 5: Reusing SQL — CTEs, VIEWs, and SQL Functions
--------------------------------------------------------------------------------

-- SQL offers three main tools for reusing code:
--
--     SQL function   global and accepts parameters
--     VIEW           global, no parameters
--     CTE            local,  no parameters
--
-- We will explore these from most powerful to least powerful.

----------------------------------------
-- Section 5a: functions
----------------------------------------

-- There is no standard way for writing functions in SQL engines.
-- Postgres allows functions written in the SQL dialect itself.
--
--     CREATE FUNCTION name(args) RETURNS type LANGUAGE sql AS $$ ... $$;
--
-- sqlite3 requires functions be written in C and included as an extension.
-- Here is an example postgres function and how to call it.
-- You will not be asked to every write sqlite3 functions.

CREATE FUNCTION count_in_a(min_id INT) RETURNS INT
LANGUAGE sql AS $$
    SELECT count(*)::INT FROM basket_a WHERE id >= min_id;
$$;

SELECT count_in_a(2), count_in_a(3);

-- -------------------------------------
-- Section 5b: VIEWs
-- -------------------------------------
--
-- A VIEW is a like a function without any arguments.
-- It is a (usually complex) query that is "copy and pasted"
-- into your final query.
-- The contents of a VIEW are always reevaluated when you run your SELECT command;
-- so, VIEWs never reduce runtime, they only make code more readable.

CREATE VIEW apples AS SELECT * FROM basket_a WHERE fruit_a = 'Apple';

SELECT count(*) FROM apples;

-- VIEWs compose with all the other constructs; a VIEW can be used
-- wherever a table is used.

SELECT count(*) FROM apples NATURAL JOIN basket_b;

-- -------------------------------------
-- Section 5c: Common Table Expressions (CTEs)
-- -------------------------------------
--
-- A CTE is a "local view" that only exists within the SELECT statement.
-- The syntax is WITH name AS (SELECT ...) SELECT ... FROM name;

WITH large_a AS (
    SELECT * FROM basket_a WHERE id >= 2
)
SELECT count(*) FROM large_a;

-- multiple CTEs can be chained by separating with commas,
-- and later CTEs may refer to earlier ones

WITH
    large_a AS (SELECT * FROM basket_a WHERE id >= 2),
    small_b AS (SELECT * FROM basket_b WHERE id <  2)
SELECT (SELECT count(*) FROM large_a), (SELECT count(*) FROM small_b);
