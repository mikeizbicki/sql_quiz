/*
 * For each problem below,
 * write the answer for both sqlite3 and postgres.
 *
 * For each CREATE TABLE statement:
 * reorder the columns to use the least amount of disk space.
 *
 * For each INSERT statement:
 * state the total number of bytes required to store the inserted row.
 *
 * You must provide the answers for both sqlite3 and postgres.
 */


-- Problem 1
CREATE TABLE ledger (
    id    BIGSERIAL PRIMARY KEY,
    amt   NUMERIC(8,2) NOT NULL,
    tag   BOOLEAN,
    note  VARCHAR(13),
    ts    TIMESTAMPTZ NOT NULL,
    raw   JSONB
);


-- Problem 2
CREATE TABLE probe (
    id BIGSERIAL PRIMARY KEY,
    n  SMALLINT DEFAULT 0,
    a  SERIAL,
    b  INT      DEFAULT 1,
    c  INT2     DEFAULT 2,
    d  BIGINT   DEFAULT 3,
    e  INT      DEFAULT 4,
    f  INT      DEFAULT 5,
    g  CHAR     NULL
);




-- Problem 3
INSERT INTO probe (id, a) VALUES (3, 3);







-- Problem 4
INSERT INTO probe
    (id,n,a,b,c,d,e,f,g)
    VALUES
    (0, 1, 2, 3, 4, 5, 6, 7, NULL);
