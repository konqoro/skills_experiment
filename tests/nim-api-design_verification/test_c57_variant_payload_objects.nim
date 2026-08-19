## C57: When variant branches need fields with the same name, wrap each
## branch's payload in its own named object type and give the branch a single
## field of that type. The shared attribute names live in separate payload
## types, so the variant keeps one field namespace.

type
  EntryKind = enum
    File
    Dir
    Device

  EntryFile = object
    name: string
    modified: float64
    size: int64

  EntryDir = object
    name: string
    modified: float64

  EntryDevice = object
    name: string

  Entry = ref object
    case kind: EntryKind
    of File:
      file: EntryFile
    of Dir:
      dir: EntryDir
    of Device:
      device: EntryDevice

let fileEntry = Entry(
  kind: File,
  file: EntryFile(name: "a.txt", modified: 1.5, size: 42))
let dirEntry = Entry(
  kind: Dir,
  dir: EntryDir(name: "src", modified: 2.5))
let deviceEntry = Entry(
  kind: Device,
  device: EntryDevice(name: "sda"))

block payload_objects_may_repeat_attribute_names:
  doAssert fileEntry.file.name == "a.txt"
  doAssert dirEntry.dir.name == "src"
  doAssert deviceEntry.device.name == "sda"

block branch_fields_have_distinct_names:
  doAssert fileEntry.file.size == 42
  doAssert dirEntry.dir.modified == 2.5

block dispatch_reads_the_discriminator:
  var total = 0
  for entry in [fileEntry, dirEntry, deviceEntry]:
    case entry.kind
    of File:
      total += int(entry.file.size)
    of Dir:
      total += 1
    of Device:
      total += 2
  doAssert total == 45

echo "C57: PASS"
