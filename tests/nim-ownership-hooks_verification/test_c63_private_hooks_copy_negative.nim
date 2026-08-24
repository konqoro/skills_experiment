# C63 companion: private =copy/=dup {.error.} still rejects copying a client
# wrapper type.

import test_c63_private_hooks_src/private_owner

type Outer = object
  token: Token

var a = Outer(token: makeToken())
var b = a
doAssert a.token.value == b.token.value
