/* This database is inspired by the tables that the `dic` tool
 * uses to store its LLM conversation history.
 * It is deliberately simplified so that every row can be read
 * and every query can be calculated by hand.
 */

-- stores the "name" of the terminal that "owns" the conversation
CREATE TABLE session (
    sid INT,
    name TEXT
);

/* A message is one round of a conversation: a prompt and the reply it got.
 *
 * mid       the message's id; it sorts in the order the turns happened
 * prev_mid  the mid of the message this one replies to,
 *           or NULL for a message that begins a conversation
 * sid       the session the round was written under
 * model_id  the model that answered
 * user      the user's prompt
 * response  the model's reply
 *
 * Every message with a NULL prev_mid is a root, so the whole table is a
 * forest and not a single tree.
 */
CREATE TABLE message (
    mid INT,
    prev_mid INT,
    sid INT,
    model_id TEXT,
    user TEXT,
    response TEXT
);

/* A price is what one token costs for that model.
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
    (NULL, 'a/c'),
    (4,   'ab'),
    (5,   'a/b/c');

INSERT INTO message (mid, prev_mid, sid, model_id, user, response)
VALUES
    (10, NULL, 1,    'gpt',    'how do I reverse a linked list in python?',
                               'walk it once with three pointers: prev, cur and next'),
    (11, 10,   1,    'gpt',    'can you show the recursive version instead?',
                               'here it is, with a helper that returns the new head'),
    (12, 11,   2,    'claude', 'why does the recursive version blow the stack?',
                               'python stops at a thousand frames by default'),
    (13, 11,   2,    'claude', 'can you show it with an explicit stack instead?',
                               'push each node as you pass it, then pop to relink'),
    (14, 12,   2,    NULL,     'how do I raise that limit?',
                               'sys.setrecursionlimit, but an explicit stack is safer'),
    (15, NULL, 3,    'gpt',    'what is the time complexity of quicksort?',
                               'average is O(n log n), worst case is O(n^2)'),
    (15, NULL, 3,    'gpt',    'what is the time complexity of quicksort?',
                               'average is O(n log n), worst case is O(n^2)'),
    (16, 15,   NULL, 'gpt',    'when does the worst case actually happen?',
                               'when the pivot is always the smallest or largest item left'),
    (17, 13,   2,    'claude', 'does that use less memory?',
                               'each frame moves to the heap, so the C stack stays flat'),
    (17, 13,   2,    'claude', 'does that use less memory?',
                               'each frame moves to the heap, so the C stack stays flat'),
    (18, 16,   NULL, 'gpt',    'how do I avoid that?',
                               'pick a random pivot, or the median of three'),
    (19, NULL, 3,    'claude', 'write me a haiku about sql',
                               'tables wait in rows, a join returns the pairs, the index still hums'),
    (20, 19,   3,    'claude', 'now one about NULL',
                               'unknown is not false, the row that never matched, waits for a join'),
    (21, 20,   3,    'claude', 'one about indexes',
                               'a b-tree of keys, the planner picks a path, seq scan in the rain'),
    (22, 21,   3,    'claude', 'one about transactions',
                               'all or none commits, the lock waits for the other, then the world moves on'),
    (23, 18,   NULL, 'gpt',    'does that help for already sorted input?',
                               'it helps most there, which is where you need it'),
    (24, 13,   2,    NULL,     'which one would you write in production?',
                               NULL),
    (25, 24,   2,    'claude', 'so should I just use a loop?',
                               'in python, yes; the loop is the faster one'),
    (26, 18,   9,    'gpt',    'does that help for already sorted input?',
                               'it helps most there, which is where you need it'),
    (27, 11,   1,    'mistral','what if the model is not in the price table?',
                               'then it is charged nothing; the table has no rule for it'),
    (28, 27,   1,    'mistral','should the report show it anyway?',
                               'it shows the tokens, and zero dollars beside them');

INSERT INTO price (model_id, per_tok)
VALUES
    ('gpt',    1.0),
    ('claude', 3.0),
    ('llama',  0.5);
