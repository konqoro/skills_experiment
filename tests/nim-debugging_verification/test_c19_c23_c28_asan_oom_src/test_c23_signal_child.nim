proc crash() =
  let p = cast[ptr int](1)
  echo p[]

crash()
