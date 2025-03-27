/* quiz_3.sql
 *
 * You are allowed to use a computer in order to:
 * - connect to a running database and run arbitrary commands
 * - reference arbitrary documentation on the internet
 * - ask AI systems arbitrary questions
 *
 * For each CREATE TABLE statement:
 * Reorder the columns to use the least amount of disk space.
 *
 * For each INSERT statement:
 * State the total number of bytes required to store the inserted row.
 * Ensure that your total includes any needed header, data, and padding.
 */


CREATE TABLE category (
    category_id integer NOT NULL,
    name text NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE foo (
    a BIGSERIAL,
    b INT4,
    c BOOLEAN,
    d SMALLINT NOT NULL,
    e TIMESTAMP NOT NULL,
    f DATE,
    g TIMESTAMP WITH TIME ZONE DEFAULT now(),
    h TEXT,
    i BIGINT
);

INSERT INTO foo (d,e) VALUES
    (2, '2016-01-25 10:10:10.555555-05:00');

INSERT INTO foo VALUES
    ( 4
    , 4
    , NULL
    , 4
    , '2016-01-25 10:10:10.55555-05:00'
    , '2016-01-25'
    , '2016-01-25 10:10:10.55555-05:00'
    , NULL
    , NULL
    );
