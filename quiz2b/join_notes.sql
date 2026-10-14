/* This set of notes explains the behavior of outer joins.
 * It uses a simplified version of the `create_tables.sql` data to make visualization easier.
 * For your quiz, you will still need to work with the full version of the data.
 *
 * COMMON SOURCES OF ERRORS
 *  - behavior when there are duplicate rows
 *  - behavior of NULL values
 */

CREATE TABLE message (mid INTEGER, sid INTEGER, model_id TEXT);
INSERT INTO message (mid, sid, model_id) VALUES
    (10, 1,    'gpt'),
    (10, 1,    'gpt'),
 -- (11, 1,    'gpt'),
    (12, 2,    'claude'),
 -- (13, 2,    'claude'),
    (14, NULL, 'mistral'),
 -- (15, 3,    'gpt'),
 -- (16, NULL, 'gpt'),
 -- (17, 2,    'claude'),
 -- (19, 3,    'claude'),
 -- (24, 2,    NULL),
 -- (27, 1,    'mistral')
    ;

CREATE TABLE session (sid INTEGER, name TEXT);
INSERT INTO session (sid, name) VALUES
    (1,    'gpt'),
    (2,    'gpt'),
    (3,    'llama'),
    (NULL, 'claude')
 -- (2, 'a/b'),
 -- (4, 'ab'),
 -- (5, 'a/b/c')
    ;


SELECT * FROM session, message;
/*
  | sid | name   | mid | sid | model_id |
  |-----|--------|-----|-----|----------|
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  12 | 2   | claude   |
  | 1   | gpt    |  14 |     | mistral  |
  | 2   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  12 | 2   | claude   |
  | 2   | gpt    |  14 |     | mistral  |
  | 3   | llama  |  10 | 1   | gpt      |
  | 3   | llama  |  10 | 1   | gpt      |
  | 3   | llama  |  12 | 2   | claude   |
  | 3   | llama  |  14 |     | mistral  |
  |     | claude |  10 | 1   | gpt      |
  |     | claude |  10 | 1   | gpt      |
  |     | claude |  12 | 2   | claude   |
  |     | claude |  14 |     | mistral  |
*/

SELECT * FROM session JOIN message;
/*
  | sid | name   | mid | sid | model_id |
  |-----|--------|-----|-----|----------|
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  12 | 2   | claude   |
  | 1   | gpt    |  14 |     | mistral  |
  | 2   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  12 | 2   | claude   |
  | 2   | gpt    |  14 |     | mistral  |
  | 3   | llama  |  10 | 1   | gpt      |
  | 3   | llama  |  10 | 1   | gpt      |
  | 3   | llama  |  12 | 2   | claude   |
  | 3   | llama  |  14 |     | mistral  |
  |     | claude |  10 | 1   | gpt      |
  |     | claude |  10 | 1   | gpt      |
  |     | claude |  12 | 2   | claude   |
  |     | claude |  14 |     | mistral  |
*/

----------------------------------------
-- EXAMPLE: JOIN on sid
----------------------------------------

SELECT * FROM session JOIN message ON session.sid = message.sid;
/*
  | sid | name   | mid | sid | model_id |
  |-----|--------|-----|-----|----------|
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  12 | 2   | claude   |
*/

SELECT * FROM session LEFT JOIN message ON session.sid = message.sid;
/*
  | sid | name   | mid | sid | model_id |
  |-----|--------|-----|-----|----------|
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  12 | 2   | claude   |
  | 3   | llama  |     |     |          |
  |     | claude |     |     |          |
*/

SELECT * FROM session RIGHT JOIN message ON session.sid = message.sid;
/*
  | sid | name   | mid | sid | model_id |
  |-----|--------|-----|-----|----------|
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  12 | 2   | claude   |
+ |     |        |  14 |     | mistral  |
*/

----------------------------------------
-- EXAMPLE: JOIN on model_id = name
----------------------------------------

SELECT * FROM session JOIN message ON session.name = message.model_id;
/*
  | sid | name   | mid | sid | model_id |
  |-----|--------|-----|-----|----------|
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  |     | claude |  12 | 2   | claude   |
*/

SELECT * FROM session LEFT JOIN message ON session.name = message.model_id;
/*
  | sid | name   | mid | sid | model_id |
  |-----|--------|-----|-----|----------|
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  |     | claude |  12 | 2   | claude   |
  | 3   | llama  |     |     |          |
*/

SELECT * FROM session RIGHT JOIN message ON session.name = message.model_id;
/*
  | sid | name   | mid | sid | model_id |
  |-----|--------|-----|-----|----------|
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  |     | claude |  12 | 2   | claude   |
  |     |        |  14 |     | mistral  |
*/

SELECT * FROM session FULL JOIN message ON session.name = message.model_id;
/*
  | sid | name   | mid | sid | model_id |
  |-----|--------|-----|-----|----------|
  | 1   | gpt    |  10 | 1   | gpt      |
  | 1   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  |     | claude |  12 | 2   | claude   |
  | 3   | llama  |     |     |          |    -- LEFT
  |     |        |  14 |     | mistral  |    -- RIGHT
*/

----------------------------------------
-- intuition:
-- LEFT/RIGHT JOIN + IS NULL "like" WHERE NOT IN + subquery
----------------------------------------

SELECT message.* FROM session RIGHT JOIN message ON session.name = message.model_id
WHERE name IS NULL;

/*
| mid | sid | model_id |
|-----|-----|----------|
|  14 |     | mistral  |
*/

SELECT * FROM message WHERE model_id NOT IN (SELECT name FROM session);

/*
| mid | sid | model_id |
|-----|-----|----------|
|  14 |     | mistral  |
*/

-- the intuition will be violated when there are NULL values in columns

SELECT session.* FROM session LEFT JOIN message ON session.sid = message.sid
WHERE model_id IS NULL;

/*
| sid | name   |
|-----|--------|
| 3   | llama  |
|     | claude |
*/

SELECT * FROM session WHERE sid NOT IN (SELECT sid FROM message);

/*
This query returns no rows. Why? Look at the subquery:

SELECT sid FROM message
| sid |
|-----|
| 1   |
| 1   |
| 2   |
|     | <-- NULL

So the expression

WHERE sid NOT IN (SELECT sid FROM message);

is equivalent to

WHERE sid != 1 AND sid != 1 AND sid != 2 AND sid != NULL

which always evaluates to NULL.

----------

This problem is not easy to fix by modifying the subquery.  For example, 

SELECT * FROM session
WHERE sid NOT IN (SELECT sid FROM message WHERE sid IS NOT NULL);

still does not work.

----------

TAKE AWAY POINT:
If you actually want to capture rows in one table, but not in another table,
then you should probably use a LEFT/RIGHT JOIN.
The NOT IN + subquery pattern is a "code smell" and likely cause for bugs.
*/

----------------------------------------
-- EXAMPLE: "complex" join clauses
----------------------------------------

SELECT * FROM session FULL JOIN message ON session.sid > message.sid;
/*
  | sid | name   | mid | sid | model_id |
  |-----|--------|-----|-----|----------|
  | 2   | gpt    |  10 | 1   | gpt      |
  | 2   | gpt    |  10 | 1   | gpt      |
  | 3   | llama  |  10 | 1   | gpt      |
  | 3   | llama  |  10 | 1   | gpt      |
  | 3   | llama  |  12 | 2   | claude   |
  | 1   | gpt    |     |     |          |    -- LEFT
  |     | claude |     |     |          |    -- LEFT
  |     |        |  14 |     | mistral  |    -- RIGHT
*/
