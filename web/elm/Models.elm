module Models exposing (..)

import Json.Encode
import Date exposing (Date)
import Time exposing (Time)


type Msg
    = ReceiveProjects Json.Encode.Value
    | Tick Time
    | SetStatusUpdated Date
    | SetStatusError String


type Status
    = Updated Date
    | Error String


type alias Pipeline =
    { createdAt : Date
    }


type alias Project =
    { name : String
    , image : String
    , status : Maybe String
    , duration : Float
    , lastCommitAuthor : String
    , lastCommitMessage : String
    , updatedAt : Date
    , pipelines : List Pipeline
    }


type alias Flags =
    { websocketUrl : String }


type alias Model =
    { flags : Flags
    , projects : List Project
    , now : Time
    , status : Status
    }
