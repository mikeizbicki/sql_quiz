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


CREATE TABLE actor (
    actor_id serial NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE customer (
    customer_id serial NOT NULL,
    store_id integer NOT NULL,
    first_name text NULL,
    last_name text NULL,
    email text,
    address_id integer NOT NULL,
    activebool boolean DEFAULT true NOT NULL,
    create_date date DEFAULT CURRENT_DATE NOT NULL,
    last_update timestamp with time zone DEFAULT now(),
    active integer
);

INSERT INTO customer (store_id, address_id) VALUES
    (5, 6);

INSERT INTO customer VALUES
    ( 1
    , 1
    , NULL
    , NULL
    , NULL
    , 1
    , false
    , '2016-01-25 10:10:10.55555-05:00'
    , '2016-01-25 10:10:10.55555-05:00'
    , 5
    );
