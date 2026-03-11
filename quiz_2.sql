/*
 * For each problem below,
 * write the output of the SELECT statement.
 * 
 * Each problem is worth 2^1 points instead of 2^0 points,
 * so the quiz will overall is worth 2^3 points.
 */


-- Problem 1
SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    INTERSECT
    SELECT fruit_b FROM basket_b
) t;







-- Problem 2
SELECT count(*)
FROM basket_b
WHERE basket_b.id = (
    SELECT count(id)
    FROM basket_a
    RIGHT JOIN basket_b USING (id)
    WHERE id < 5
);





-- Problem 3
SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (fruit_a = fruit_b AND basket_a.id = basket_b.id);






-- Problem 4
SELECT count(*) FROM basket_a NATURAL RIGHT OUTER JOIN basket_b;
