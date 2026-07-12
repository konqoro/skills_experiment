## C29: Nim strips a leading newline right after the opening """ of a
##      triple-quoted string, so starting on the next line produces the same
##      value as starting on the same line.
## C30: Triple-quoted literals are preferable to "a\n" & "b\n" concatenation;
##      the two forms produce equivalent values.
## C31: In a & join around an interpolated value, omitting the leading newline
##      of the following literal merges adjacent tokens.
## C32: strutils.dedent strips only the indentation shared by all lines,
##      preserving relative indentation.

import std/[strutils, assertions]

block leading_newline_stripped:
  let a = """
foo
bar
"""
  let b = """foo
bar
"""
  doAssert a == b
  doAssert a == "foo\nbar\n"

block concatenation_equivalence:
  let triple = """
foo
bar
"""
  let joined = "foo\n" & "bar\n"
  doAssert triple == joined

block concat_newline_separator:
  let tableName = "documents"
  let withNewline = """SELECT id
FROM """ & tableName & """

WHERE id = ?"""
  doAssert withNewline ==
    "SELECT id\nFROM documents\nWHERE id = ?"

block concat_missing_newline_merges:
  let tableName = "documents"
  let noNewline = """SELECT id
FROM """ & tableName & """WHERE id = ?"""
  doAssert noNewline ==
    "SELECT id\nFROM documentsWHERE id = ?"

block dedent_shared_indentation:
  let x = """
      Hello
        There
    """.dedent()
  doAssert x == "Hello\n  There\n"

echo "C29_C30_C31_C32: PASS"
