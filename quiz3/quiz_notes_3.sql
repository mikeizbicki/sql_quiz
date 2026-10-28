/* quiz_practice_3.sql
 *
 * This quiz will test your understanding of how much disk space a row uses.
 * You will be allowed to use a computer in order to:
 * - connect to a running database
 * - reference arbitrary documentation on the internet
 *
 * For each CREATE TABLE statement:
 * reorder the columns to use the least amount of disk space.
 *
 * For each INSERT statement:
 * state the total number of bytes required to store the inserted row.
 *
 * For the actual quiz:
 * - Expect 2 CREATE TABLE commands and 2 INSERT commands.
 * - You must write the correct answer for both postgres and sqlite3.
 */

CREATE TABLE example (
    id INT8,
    b INT4,
    c INT2,
    a CHAR, -- MOVED CHAR AFTER INT2 => save 8ish bytes
            -- in postgres: must list columns in "most efficient order"
            -- general rule: largest to smallest
    d LINE, -- if we add a NOT NULL then column doesn't count towards null bitmap
    e JSONB -- in the example below null bitmap would be 5 bits instead of 6
);
-- order of the columns above has disk usage / runtime implications in postgres


INSERT INTO example VALUES (0, 'a', 0, 0, '{1, 2, 3}', NULL);

- Header
    - 23 bytes from the struct
    - we do have NULL bitmap
        - 6 columns => 6 bits (either 0 or 1)
        - padded to 1 byte (1 byte = 8 bits)
    - overall size (before padding) = 23 + 1 = 24
    - 24 % 8 == 0 => no more padding needed
    - if we have 9 columns:
        - bitmap will be 9 bits => 2 bytes
        - unpadded size 23 + 2 = 25
        - 25 % 8 = 1 => 7 more bytes of padding added => 32 bytes

    - 9 col all nullable => 32 byte header
      9 col >=1 not nullable => 24 byte header

- Data 
   - each column: typealign | typelen | offset starts at | offset ends at |
      int8         d = 8       8         0                  8
      char         c = 1       1         8                  9
      int4         i = 4       4         12                 16
      int2         s = 2       2         16                 18
      line         d = 8       24        24                 48
(null)jsonb        i = 4       -1
                               ^ indicates variable size
                                 => complex formula for # of bytes
                                 => you don't need to know for quiz
                                 => will always be a NULL value on quiz

# In postgres => TOAST
    - if the size is <2048 bytes 
    - if size is >2048 bytes pointer into another "hidden table"
      automatically gzipped 
   - total bytes = 48

- Padding: header + data = 24 + 48 = 72
  - already %8 == 0, so no padding

final size: 72

INSERT INTO example VALUES (NULL, NULL, NULL, NULL, NULL, NULL);

- whole data section = 0 bytes
- overall size = 24 bytes

INSERT INTO example VALUES (0, NULL, 0, NULL, '{1, 2, 3}', NULL);


INSERT INTO example VALUES (0, 'a', 0, NULL, '{1, 2, 3}', NULL);


INSERT INTO example VALUES (0, NULL, 0, 0, '{1, 2, 3}', NULL);


INSERT INTO example VALUES (NULL, NULL, 0, 0, '{1, 2, 3}', NULL);


INSERT INTO example VALUES (NULL, NULL, 0, 0, NULL, NULL);









CREATE TABLE network_connection (
    id BIGSERIAL PRIMARY KEY,
    source MACADDR NOT NULL,
    dest MACADDR NOT NULL,
    bytes_sent SMALLINT NOT NULL,
    starttime TIMESTAMP WITH TIME ZONE NOT NULL
);



INSERT INTO network_connection (source, dest, starttime, bytes_sent) VALUES 
    ('13:37:DE:AD:BE:EF', 'FF:FF:FF:FF:FF:FF', '2016-01-25 10:10:10.555555-05:00', 10);









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
