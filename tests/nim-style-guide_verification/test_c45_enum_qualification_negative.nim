# Test: C45 (negative) - a bare enum name shared by two non-pure enums with no
# type context does not compile; this is the only case that needs qualification.
type
  A = enum aa, bb
  B = enum aa, cc

echo aa   # must fail: ambiguous which enum's `aa` is meant
