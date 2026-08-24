# C63: Nim 2.3.1 finds private hooks of an exported field type when it lifts
# destruction and moves into a wrapper declared in a client module.

import test_c63_private_hooks_src/private_owner

type Outer = object
  token: Token

proc main =
  block:
    var a = Outer(token: makeToken())
    var b = move(a)
    doAssert a.token.value == -1
    doAssert b.token.value == 42
  doAssert destroyedCount() == 1

main()
echo "C63: PASS"
