port module Update exposing (..)

import Models exposing (Project, DomElement, Pipeline, Model, Msg(..), Status(..))
import Json.Decode as Decode
import Json.Decode exposing (field, Decoder)
import Json.Decode.Extra exposing ((|:))
import Task
import Date


decodePipeline : Decoder Pipeline
decodePipeline =
    Decode.succeed Pipeline
        |: (field "created_at" Json.Decode.Extra.date)


decodeProject : Decoder Project
decodeProject =
    Decode.succeed Project
        |: (field "id" Decode.string)
        |: (field "name" Decode.string)
        |: (field "image" Decode.string)
        |: (field "status" (Decode.maybe Decode.string))
        |: (field "duration" Decode.float)
        |: (field "last_commit_author" Decode.string)
        |: (field "last_commit_message" Decode.string)
        |: (field "updated_at" Json.Decode.Extra.date)
        |: (field "pipelines" (Decode.list decodePipeline))


decodeProjects : Decoder (List Project)
decodeProjects =
    field "list" (Decode.list decodeProject)


decodeProjectDomElement : Decoder DomElement
decodeProjectDomElement =
    Decode.succeed DomElement
        |: field "projectId" Decode.string
        |: field "outerHeight" Decode.float


decodeProjectDomElements : Decoder (List DomElement)
decodeProjectDomElements =
    Decode.list decodeProjectDomElement


port fetchDomElements : String -> Cmd msg


fetchProjectDomElements : Cmd msg
fetchProjectDomElements =
    fetchDomElements "#container .project"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDomElements raw ->
            case Decode.decodeValue decodeProjectDomElements raw of
                Ok domElements ->
                    { model | projectDomElements = domElements } ! []

                Err _ ->
                    model ! []

        SetStatusUpdated updated ->
            { model | status = Updated updated } ! []

        SetStatusError error ->
            { model | status = Error error } ! []

        Resize ->
            model ! [ fetchProjectDomElements ]

        ReceiveProjects raw ->
            case Decode.decodeValue decodeProjects raw of
                Ok projects ->
                    { model
                        | projects = projects
                    }
                        ! [ Task.perform SetStatusUpdated Date.now, fetchProjectDomElements ]

                Err _ ->
                    { model
                        | status = Error "Could not parse response"
                    }
                        ! []

        Tick newTime ->
            { model | now = newTime } ! []
