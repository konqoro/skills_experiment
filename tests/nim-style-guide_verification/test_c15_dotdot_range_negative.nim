## C15_BAD: range[0 ..< n] does not compile.
## This file MUST fail to compile.

const size = 6
type A = range[0 ..< size]
echo A
