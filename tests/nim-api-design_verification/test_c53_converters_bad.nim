# Test: C53 - exported converters apply implicitly at every call site in any
# importing module, do not chain transitively, and a second converter for the
# same type pair is silently ignored. Public APIs should use explicit toX()
# conversions instead.
import test_c53_converters_bad_src/converter_mod

proc wantsFoo(f: Foo): int = f.x
proc wantsStr(s: string): int = s.len

# 1. Implicit application: a call that needs the conversion compiles with no
#    conversion marker at the call site.
doAssert compiles(wantsFoo(42))
doAssert wantsFoo(42) == 42

# 2. Non-transitive: Foo -> string applies, but int -> Foo -> string does not
#    chain, so the implicit behavior stops after one step.
doAssert compiles(wantsStr(Foo(x: 7)))
doAssert not compiles(wantsStr(42))

# 3. Silent shadowing: two converters from int to Foo coexist; the first one
#    wins (toFooB is reported as unused), with no error at the call site.
doAssert wantsFoo(21) == 21

echo "C53: PASS"
