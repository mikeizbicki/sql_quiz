/* This database is inspired by the tables that the `dic` tool
 * (github.com/mikeizbicki/geni) uses to store its LLM conversation
 * history.  It is deliberately simplified so that every row can be read
 * and every query can be calculated by hand.
 *
 * Three tables:
 *
 *   session  a shell session that a conversation belongs to
 *   message  one turn of a conversation
 *   price    what one token costs, per model
 *
 * The schema is intentionally missing several things, and their absence
 * is part of the quiz:
 *
 *   - no PRIMARY KEY or UNIQUE constraint, so one row may be duplicated
 *   - no FOREIGN KEY and no NOT NULL, so an id may refer to nothing and
 *     any column may be NULL
 *   - no timestamp columns (dic stores t_start and t_done), so the order
 *     of two turns is given by mid alone
 *   - no token counts (dic stores tok_in and tok_out), so a turn cannot
 *     be priced from its own row; price says only what one token costs
 *   - no table for attachments, and none for the raw API response
 */

/* A session is a shell that ran `dic`.
 *
 * A session's name is a path, so sessions nest: the session named 'a/b'
 * is a child of the session named 'a'.  That naming convention is what
 * lets one LIKE expression ask for a session and everything under it.
 *
 * sid is NULL for a turn that was not written under any session.
 */
CREATE TABLE session (
    sid INT,
    name TEXT
);

/* A message is one turn of one conversation.
 *
 * mid       the message's id; it sorts in the order the turns happened
 * prev_mid  the mid of the message this one replies to, or NULL for a
 *           message that begins a conversation
 * sid       the session the turn was written under, or NULL if none
 * model_id  the model that answered, or NULL if the record lost it
 * message   the first sentence of the prompt or of the reply
 *
 * Several messages may share one prev_mid: a conversation is a tree and
 * not a list.  Every message with a NULL prev_mid is a root, so the whole
 * table is a forest and not a single tree.
 */
CREATE TABLE message (
    mid INT,
    prev_mid INT,
    sid INT,
    model_id TEXT,
    message TEXT
);

/* A price is what one token costs, for one model.  This is the tool's
 * configuration file flattened into a table, so that it can be joined.
 *
 * A model may have no row here, and a row here may name a model that no
 * message used.  Both cases come up below.
 */
CREATE TABLE price (
    model_id TEXT,
    per_tok REAL
);

INSERT INTO session (sid, name)
VALUES
    (1,   'a'),
    (2,   'a/b'),
    (2,   'a/b'),
    (3,   'c'),
    (NULL, 'a/c');

INSERT INTO message (mid, prev_mid, sid, model_id, message)
VALUES
    (10, NULL, 1,    'gpt',    'how do I reverse a linked list in python?'),
    (11, 10,   1,    'gpt',    'walk it once with three pointers: prev, cur and next'),
    (12, 11,   2,    'claude', 'can you show the recursive version instead?'),
    (13, 11,   2,    NULL,     'why does the recursive version blow the stack?'),
    (14, 12,   2,    'claude', 'here it is, with a helper that returns the new head'),
    (15, NULL, 3,    'gpt',    'what is the time complexity of quicksort?'),
    (15, NULL, 3,    'gpt',    'what is the time complexity of quicksort?'),
    (16, 15,   NULL, 'gpt',    'average is O(n log n), worst case is O(n^2)'),
    (17, 13,   2,    'claude', 'python stops at a thousand frames by default'),
    (18, 17,   2,    'claude', 'how do I raise that limit?'),
    (19, 16,   NULL, 'gpt',    'when does the worst case actually happen?'),
    (20, NULL, 3,    'claude', 'write me a haiku about sql'),
    (21, 20,   3,    'claude', 'tables wait in rows, a join returns the pairs, the index still hums'),
    (22, 21,   3,    'claude', 'now one about NULL'),
    (23, 22,   3,    'claude', 'unknown is not false, the row that never matched, waits for a join');

INSERT INTO price (model_id, per_tok)
VALUES
    ('gpt',    1.0),
    ('claude', 3.0),
    ('llama',  0.5);
