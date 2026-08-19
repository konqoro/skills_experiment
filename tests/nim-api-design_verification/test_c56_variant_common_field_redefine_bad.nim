## C56_BAD: A variant branch field cannot reuse the name of a field declared
## before the `case` selector. The whole object has one field namespace.
## This file MUST fail to compile with "attempt to redefine".

type
  EntryKind = enum
    File
    Dir

  Entry = object
    name: string
    case kind: EntryKind
    of File:
      size: int64
    of Dir:
      name: string
