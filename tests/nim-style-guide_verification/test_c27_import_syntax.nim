## C27: Grouped imports and selective imports work with any directory.

import test_c27_import_syntax_src/[alpha, beta]
from test_c27_import_syntax_src/gamma import gammaTwo

doAssert alphaOne() == 1
doAssert alphaTwo() == 2
doAssert betaOne() == 3
doAssert betaTwo() == 4
doAssert gammaTwo() == 6

echo "C27: PASS"
