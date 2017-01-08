module Models exposing (..)

import Phoenix.Socket
import Json.Encode
import Date
import Time exposing (Time)


type Msg
    = PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveProjects Json.Encode.Value
    | JoinChannel
    | Tick Time


type alias Pipeline =
    { createdAt : Date.Date
    }


type alias Project =
    { name : String
    , image : String
    , status : String
    , duration : Float
    , lastCommitAuthor : String
    , lastCommitMessage : String
    , updatedAt : Date.Date
    , pipelines : List Pipeline
    }


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , projects : List Project
    , now : Time
    }
