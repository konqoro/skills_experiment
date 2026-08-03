Choose parameter modes from caller-visible reading, element mutation,
resizing, ownership transfer, and borrowed return behavior.

```nim
type
  Message* = object
    topic*: string
    payload*: seq[byte]
    queued*: bool

  MessageQueue* = object
    messages: seq[Message]

func totalBytes*(msgs: openArray[Message]): int =
  for msg in msgs:
    result += msg.payload.len

proc markQueued*(msgs: var openArray[Message]) =
  for msg in msgs.mitems:
    msg.queued = true

proc clear*(msgs: var seq[Message]) =
  msgs.setLen 0

proc add*(q: var MessageQueue; msg: sink Message) =
  q.messages.add msg

proc messages*(q: MessageQueue): lent seq[Message] {.inline.} =
  q.messages

var pending = @[
  Message(topic: "build", payload: @[1'u8, 2'u8]),
  Message(topic: "test", payload: @[3'u8])
]
doAssert totalBytes(pending) == 3
markQueued(pending)
doAssert pending[0].queued

var q: MessageQueue
var retained = pending[0]
q.add retained
retained.topic = "caller-owned"
doAssert q.messages[0].topic == "build"

q.add Message(topic: "deploy", payload: @[4'u8])
doAssert q.messages.len == 2
clear(pending)
doAssert pending.len == 0
```

## Key points

- `openArray` supports read-only traversal of several caller container shapes.
- `var openArray` mutates elements without permitting resize or replacement.
- `var seq` exposes caller-visible resizing.
- `sink` allows move-or-copy ownership transfer; retained values may be
  copied.
- `lent` returns storage borrowed from the queue.
