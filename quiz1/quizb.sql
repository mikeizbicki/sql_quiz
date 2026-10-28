/*
 * Makeup/alternate version of quiz1.
 * Same schema and same concepts as quiz.sql,
 * each problem adds one orthogonal wrinkle
 * (DISTINCT / LIKE-vs-ILIKE / multi-column USING / lead).
 */


-- Problem 1
SELECT sum(DISTINCT COALESCE(id, 1)) FROM basket_a;





-- Problem 2
SELECT count(*)
FROM basket_a
WHERE fruit_a LIKE 'A%';





-- Problem 3
SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (id, fruit_a);





-- Problem 4
SELECT
    id,
    lead(id) OVER (ORDER BY id)
FROM basket_a
ORDER BY id;
