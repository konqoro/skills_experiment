## Test C25: import brings symbols into scope without qualification.
## Qualified module.symbol access is needed only to resolve ambiguities
## between imported modules or conflicting symbols.

import ./test_c25_namespacing_src/module_a
import ./test_c25_namespacing_src/module_b

# Unique symbols from each module are accessible without qualification
doAssert uniqueA() == "A"
doAssert uniqueB() == "B"

# When both modules export 'shared', qualified access resolves the ambiguity
doAssert module_a.shared() == "sharedA"
doAssert module_b.shared() == "sharedB"

# Unqualified 'shared' is ambiguous and does not compile
static: doAssert not compiles(shared())

echo "C25: PASS"
