module Models exposing (..)

import Json.Encode
import Date exposing (Date)
import Time exposing (Time)


type Msg
    = ReceiveProjects Json.Encode.Value
    | SetError String
    | Tick Time
    | SetUpdated Date


type alias Pipeline =
    { createdAt : Date
    }


type alias Project =
    { name : String
    , image : String
    , status : String
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
    , updatedAt : Maybe Date
    , error : Maybe String
    }
