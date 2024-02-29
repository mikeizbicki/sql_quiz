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
SELECT count(*) FROM basket_a
EXCEPT
SELECT count(*) FROM basket_b;








-- Problem 2
SELECT count(DISTINCT fruit_b)
FROM basket_b
WHERE id NOT IN (
    SELECT id
    FROM basket_a
    WHERE fruit_a LIKE 'a%'
);










-- Problem 3
SELECT count(fruit_a)
FROM basket_a
WHERE id < (SELECT max(id) FROM basket_b)
  AND id > (SELECT min(id) FROM basket_b);









-- Problem 4
SELECT count(*)
FROM basket_a a1
LEFT JOIN basket_a a2 ON a1.id > a2.id;
