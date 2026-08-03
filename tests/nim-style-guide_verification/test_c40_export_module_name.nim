## C40: export takes only the module name, not the path.

import test_c40_export_module_name_src/foo/bar/baz
export baz

doAssert bazValue() == 42

echo "C40: PASS"
