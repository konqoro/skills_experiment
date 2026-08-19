## C56_BAD: A field name declared in one variant branch cannot be redeclared
## in another branch. Variant branches do not create separate field namespaces.
## This file MUST fail to compile with "attempt to redefine".

type
  EntryKind = enum
    File
    Dir

  Entry = object
    case kind: EntryKind
    of File:
      name: string
    of Dir:
      name: string
