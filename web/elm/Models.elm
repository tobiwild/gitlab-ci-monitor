module Models exposing (..)

import Phoenix.Socket
import Json.Encode
import Date


type Msg
    = PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveProjects Json.Encode.Value
    | JoinChannel


type alias Project =
    { name : String
    , image : String
    , status : String
    , duration : Float
    , lastCommitAuthor : String
    , lastCommitMessage : String
    , updatedAt : Date.Date
    }


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , projects : List Project
    }
