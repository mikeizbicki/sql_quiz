/* quiz_3.sql
 *
 * You are allowed to use a computer in order to:
 * - connect to a running database and run arbitrary commands
 * - reference arbitrary documentation on the internet
 *
 * For each CREATE TABLE statement:
 * reorder the columns to use the least amount of disk space.
 *
 * For each INSERT statement:
 * state the total number of bytes required to store the inserted row.
 */


CREATE TABLE category (
    category_id SERIAL NOT NULL,
    name text NOT NULL,
    last_update TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);





CREATE TABLE foo (
    a BIGINT,
    b BOOLEAN,
    c BOOLEAN,
    d SMALLINT,
    e TIMESTAMP,
    f DATE,
    g TIME,
    h INT,
    i INT2
);

INSERT INTO foo VALUES
    ( 1
    , TRUE
    , FALSE
    , 0
    , '2024-03-24 09:41:10.555555-05:00'
    , '2024-03-24'
    , '09:41:10.555555-05:00'
    , 2345
    , -2345
    );

INSERT INTO foo VALUES
    ( NULL
    , NULL
    , FALSE
    , 0
    , NULL
    , NULL
    , NULL
    , 0
    , NULL
    );
