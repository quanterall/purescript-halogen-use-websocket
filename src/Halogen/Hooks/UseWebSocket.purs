module Halogen.Hooks.UseWebSocket
  ( useWebSocket
  , UseWebSocket
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect)
import Foreign as Foreign
import Halogen.Hooks (class HookNewtype, type (<>), Hook, HookM, UseEffect)
import Halogen.Hooks as Hooks
import Halogen.Query.Event as HQE
import Simple.JSON (class ReadForeign)
import Simple.JSON as Json
import Web.Socket.Event.EventTypes as WebsocketEventTypes
import Web.Socket.Event.MessageEvent as MessageEvent
import Web.Socket.WebSocket (WebSocket)
import Web.Socket.WebSocket as WebSocket

foreign import data UseWebSocket :: Hooks.HookType

type UseWebSocket' = UseEffect <> Hooks.Pure

instance HookNewtype UseWebSocket UseWebSocket'

-- | Subscribes the component to a `WebSocket`. If a received message cannot be decoded as an `a` it
-- | is ignored. The following code snippet will subscribe the component to `Increment` and
-- | `Decrement` messages and modify its state accordingly.
--
-- | ```purescript
-- | let
-- |   handleWebSocketMessage Increment = Hooks.modify_ _ {count = count + 1}
-- |   handleWebSocketMessage Decrement = Hooks.modify_ _ {count = count - 1}
-- | useWebSocket socket handleWebSocketMessage
-- | ```
useWebSocket
  :: forall m message
   . MonadEffect m
  => ReadForeign message
  => WebSocket
  -> (message -> HookM m Unit)
  -> Hook m UseWebSocket Unit
useWebSocket socket handler = Hooks.wrap hook
  where
  hook :: Hook m UseWebSocket' _
  hook = Hooks.do
    Hooks.useLifecycleEffect do
      _subscriptionId <- Hooks.subscribe do
        HQE.eventListener WebsocketEventTypes.onMessage (WebSocket.toEventTarget socket) \e -> do
          messageEvent <- MessageEvent.fromEvent e
          let data_ = MessageEvent.data_ messageEvent
          if Foreign.tagOf data_ == "String" then do
            case data_ # Foreign.unsafeFromForeign # Json.readJSON of
              Right message -> Just $ handler message
              Left _err -> Just $ pure unit
          else Just $ pure unit
      pure Nothing
    Hooks.pure unit

