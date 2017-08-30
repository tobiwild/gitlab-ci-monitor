module Models exposing (..)

import Date exposing (Date)
import Json.Decode
import Json.Encode
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
    , commitAuthor : String
    , commitMessage : String
    , commitCreatedAt : Date
    , commitSha : String
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
    , commitAuthor : String
    , commitMessage : String
    , commitCreatedAt : Date
    , commitSha : String
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
