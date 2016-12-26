module Models exposing (..)

import Phoenix.Socket
import Json.Encode


type Msg
    = PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveProjects Json.Encode.Value
    | JoinChannel


type alias Project =
    { name : String
    }


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , projects : List Project
    }
