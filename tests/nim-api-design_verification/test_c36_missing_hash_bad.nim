import std/tables

type MissingHashSku = distinct string

proc `==`(a, b: MissingHashSku): bool {.borrow.}
proc `$`(sku: MissingHashSku): string {.borrow.}

var table: Table[MissingHashSku, int]
table[MissingHashSku("hammer")] = 3
