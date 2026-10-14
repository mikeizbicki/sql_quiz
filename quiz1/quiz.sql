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
SELECT sum(COALESCE(id, 1)) FROM basket_a;







-- Problem 2
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE '%a%';







-- Problem 3
SELECT count(*) FROM basket_a a1 JOIN basket_a a2 USING (id, fruit_a);







-- Problem 4
SELECT id, lag(id, 1, 0) OVER (PARTITION BY fruit_a ORDER BY id) FROM basket_a;

