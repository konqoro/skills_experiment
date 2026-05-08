## C29: echo flushes automatically; stdout.write does not.
## echo appends a newline and flushes. stdout.write does neither.
## We verify that echo output appears immediately and that
## stdout.write + flushFile also appears.

import std/[syncio]

# echo should flush automatically — just verify it runs
echo "C29_ECHO"

# stdout.write requires explicit flush
stdout.write("C29_WRITE")
stdout.flushFile()

# Also verify that stdout.write without flushFile is valid
# (we just don't rely on it appearing before a crash)
stdout.write("\n")
stdout.flushFile()

echo "C29: PASS"
