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
SELECT count(id) FROM basket_a WHERE (fruit_a = NULL) IS NULL;








-- Problem 2
SELECT fruit_a, count(*)
FROM basket_a
WHERE fruit_a ILIKE '%e%'
GROUP BY fruit_a
HAVING count(*) > 0
ORDER BY fruit_a;









-- Problem 3
SELECT count(a1.id)
FROM basket_a AS a1
JOIN basket_b AS b1 ON (a1.fruit_a = b1.fruit_b)
JOIN basket_b AS b2 ON (a1.id = b2.id)
WHERE a1.id IS NULL;









-- Problem 4
SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b ON (basket_a.id > basket_b.id);
