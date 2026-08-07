type
  Foo* = object
    x*: int

converter toFooA*(i: int): Foo = Foo(x: i)
converter toFooB*(i: int): Foo = Foo(x: i * 100)
converter toStringX*(f: Foo): string = $f.x
