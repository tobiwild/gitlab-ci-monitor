module Models exposing (..)

import Json.Encode
import Json.Decode
import Date exposing (Date)
import Time exposing (Time)


type Msg
    = ReceiveProjects Json.Encode.Value
    | ReceiveDomElements Json.Decode.Value
    | Tick Time
    | SetStatusUpdated Date
    | SetStatusError String
    | Resize


type Status
    = Updated Date
    | Error String


type alias Pipeline =
    { createdAt : Date
    }


type alias DomElement =
    { id : String
    , offsetHeight : Float
    }


type alias Project =
    { id : String
    , name : String
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
    , projectDomElements : List DomElement
    , now : Time
    , status : Status
    }
