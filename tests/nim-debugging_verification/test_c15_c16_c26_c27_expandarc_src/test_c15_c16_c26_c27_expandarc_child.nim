type
  FileEntry = tuple[
    path: string,
    data: seq[byte]]

  FileEntries = array[3, FileEntry]

proc drainByCopy(source: var FileEntries; dest: var FileEntries) =
  for i in 0..high(dest):
    dest[i] = source[i]
    source[i] = default(FileEntry)

proc drainByMove(source: var FileEntries; dest: var FileEntries) =
  for i in 0..high(dest):
    dest[i] = move(source[i])

proc sampleEntries(): FileEntries =
  result = [
    (path: "one.txt", data: @[1'u8, 2]),
    (path: "two.txt", data: @[3'u8, 4]),
    (path: "three.txt", data: @[5'u8, 6])]

proc main =
  var copySource = sampleEntries()
  var copied: FileEntries
  copySource.drainByCopy(copied)
  doAssert copied == sampleEntries()

  var moveSource = sampleEntries()
  var moved: FileEntries
  moveSource.drainByMove(moved)
  doAssert moveSource == default(FileEntries)

main()
