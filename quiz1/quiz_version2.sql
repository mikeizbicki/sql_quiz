/*
 * Alternate makeup version of quiz1.
 * Same schema and same concepts as quiz.sql,
 * each problem adds one orthogonal wrinkle
 * (count-DISTINCT-COALESCE / LIKE-vs-ILIKE / self-join on a non-id column / lag default).
 */


-- Problem 1
SELECT count(DISTINCT COALESCE(id, -1)) FROM basket_a;




-- Problem 2
SELECT count(*)
FROM basket_a
WHERE fruit_a LIKE '%A%';




-- Problem 3
SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (fruit_a);




-- Problem 4
SELECT
    id,
    lag(id, 1, -1) OVER (ORDER BY id)
FROM basket_a
ORDER BY id;
