# purecript-halogen-use-websocket

A hook for using websockets in Halogen. Allows subscription to messages and
handlers associated with those messages:

```purescript
let
  handleWebSocketMessage Increment = Hooks.modify_ _ {value = value + 1}
  handleWebSocketMessage Decrement = Hooks.modify_ _ {value = value - 1}

useWebSocket socket handleWebSocketMessage
```

`useWebSocket` requires that your type has a `ReadForeign` instance, since it
will automatically try to decode that type `a` and act only if it's a valid `a`.
