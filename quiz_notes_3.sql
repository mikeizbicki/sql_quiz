/*
 * This quiz will test your understanding of how much disk space a row uses.
 * You will be allowed to use a computer.
 * The only thing disallowed is communicating with another human.
 * Examples of things you are allowed to do include:
 * - connect to a running database
 * - reference arbitrary documentation on the internet
 * - ask AI systems arbitrary questions
 *
 * For each CREATE TABLE statement:
 * reorder the columns to use the least amount of disk space.
 *
 * For each INSERT statement:
 * state the total number of bytes required to store the inserted row.
 *
 * For the actual quiz, expect 2 CREATE TABLE commands and 2 INSERT commands.
 * At least one of the tables will be taken from the pagila database.
 */

--------------------------------------------------------------------------------

CREATE TABLE example1 (
    a INTEGER
);

INSERT INTO example1 (1);

-- header:
-- data:
-- padding:
-- total:

INSERT INTO example1 (NULL);

-- header:
-- data:
-- padding:
-- total:

--------------------------------------------------------------------------------

CREATE TABLE example2 (
    a SMALLINT,
    b BIGINT,
    c INTEGER
);

INSERT INTO example2 (1,2,3);

INSERT INTO example2 (1,NULL,3);

INSERT INTO example2 (NULL,NULL,NULL);

--------------------------------------------------------------------------------

CREATE TABLE example3 (
    b BIGINT,
    c INTEGER,
    a SMALLINT
);

INSERT INTO example3 (2,3,1);

INSERT INTO example3 (NULL,3,1);

INSERT INTO example3 (NULL,NULL,NULL);

--------------------------------------------------------------------------------

CREATE TABLE example4 (
    c1 SMALLINT,
    c2 SMALLINT,
    c3 SMALLINT,
    c4 SMALLINT,
    c5 SMALLINT,
    c6 SMALLINT,
    c7 SMALLINT,
    c8 SMALLINT,
    c9 SMALLINT
);

INSERT INTO example4 (1,2,3,4,5,6,7,8,9);

INSERT INTO example4 (1,2,NULL,4,5,6,7,8,9);

INSERT INTO example4 (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--------------------------------------------------------------------------------

CREATE TABLE example5 (
    id INT8,
    a CHAR,
    b INT4,
    c INT2,
    d LINE,
    e JSONB
);


INSERT INTO example5 VALUES (0, 'a', 0, 0, '{1, 2, 3}', NULL);


INSERT INTO example5 VALUES (NULL, NULL, NULL, NULL, NULL, NULL);


INSERT INTO example5 VALUES (0, NULL, 0, NULL, '{1, 2, 3}', NULL);


INSERT INTO example5 VALUES (0, 'a', 0, NULL, '{1, 2, 3}', NULL);


INSERT INTO example5 VALUES (0, NULL, 0, 0, '{1, 2, 3}', NULL);


INSERT INTO example5 VALUES (NULL, NULL, 0, 0, '{1, 2, 3}', NULL);


INSERT INTO example5 VALUES (NULL, NULL, 0, 0, NULL, NULL);

--------------------------------------------------------------------------------

CREATE TABLE network_connection (
    id BIGSERIAL PRIMARY KEY,
    source MACADDR NOT NULL,
    dest MACADDR NOT NULL,
    bytes_sent SMALLINT NOT NULL,
    starttime TIMESTAMP WITH TIME ZONE NOT NULL
);

INSERT INTO network_connection (source, dest, starttime, bytes_sent) VALUES 
    ('13:37:DE:AD:BE:EF', 'FF:FF:FF:FF:FF:FF', '2016-01-25 10:10:10.555555-05:00', 10);

--------------------------------------------------------------------------------

CREATE TABLE event (
    id BIGSERIAL,
    name TEXT,
    public BOOLEAN,
    max_guests SMALLINT,
    location_id INTEGER NOT NULL,
    starttime timestamp with time zone NOT NULL,
    endtime timestamp with time zone,
    a INT,
    b INT,
    c INT,
    d INT,
    e INT,
    f INT,
    g INT,
    h INT
);
 

INSERT INTO event (location_id, starttime) VALUES (0, '2016-01-25 10:10:10.555555-05:00');


INSERT INTO event (location_id, starttime, max_guests) VALUES (0, '2016-01-25 10:10:10.555555-05:00', 10);


INSERT INTO event (location_id, starttime, h) VALUES (0, '2016-01-25 10:10:10.555555-05:00', 1);
