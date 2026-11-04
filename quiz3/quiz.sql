/*
 * For each problem below,
 * write the answer for both sqlite3 and postgres.
 *
 * For each CREATE TABLE statement:
 * reorder the columns to use the least amount of disk space.
 * (In sqlite3, the order of columns does not affect row size;
 * leave the table unchanged.)
 *
 * For each INSERT statement:
 * state the total number of bytes required to store the inserted row.
 */


-- Problem 1
CREATE TABLE probe (
    id BIGSERIAL PRIMARY KEY,
    n  SMALLINT NOT NULL DEFAULT 0,
    a  INT      NOT NULL DEFAULT 0,
    b  INT      NOT NULL DEFAULT 0,
    c  INT      NOT NULL DEFAULT 0,
    d  INT      NOT NULL DEFAULT 0,
    e  INT      NOT NULL DEFAULT 0,
    f  INT      NOT NULL DEFAULT 0,
    g  CHAR     NOT NULL DEFAULT ''
);

-- Problem 2
CREATE TABLE ledger (
    id    BIGSERIAL PRIMARY KEY,
    amt   NUMERIC(8,2) NOT NULL,
    tag   BOOLEAN,
    note  VARCHAR(13),
    ts    TIMESTAMPTZ NOT NULL,
    raw   JSONB
);

-- Problem 3
INSERT INTO ledger (amt, tag, note, ts, raw) VALUES
    (0.1, FALSE, 'xxxxxxxxxxx', '2016-01-25 10:10:10.555555-05:00', NULL);

-- Problem 4
INSERT INTO ledger (amt, tag, note, ts, raw) VALUES
    (128, NULL, 'xxxxxxxxxxxx', '2016-01-25 10:10:10.555555-05:00', '{"a":1}');
