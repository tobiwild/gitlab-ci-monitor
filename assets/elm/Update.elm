port module Update exposing (..)

import Date
import Json.Decode as Decode exposing (Decoder, field)
import Json.Decode.Extra exposing ((|:))
import Models exposing (DomElement, Model, Msg(..), Pipeline, Project, Status(..))
import Task


decodePipeline : Decoder Pipeline
decodePipeline =
    Decode.succeed Pipeline
        |: field "created_at" Json.Decode.Extra.date
        |: field "commit_author" Decode.string
        |: field "commit_message" Decode.string
        |: field "commit_created_at" Json.Decode.Extra.date
        |: field "commit_sha" Decode.string


decodeProject : Decoder Project
decodeProject =
    Decode.succeed Project
        |: field "id" Decode.string
        |: field "name" Decode.string
        |: field "image" Decode.string
        |: field "status" (Decode.maybe Decode.string)
        |: field "duration" Decode.float
        |: field "commit_author" Decode.string
        |: field "commit_message" Decode.string
        |: field "commit_created_at" Json.Decode.Extra.date
        |: field "commit_sha" Decode.string
        |: field "pipelines" (Decode.list decodePipeline)


decodeProjects : Decoder (List Project)
decodeProjects =
    field "list" (Decode.list decodeProject)


decodeProjectDomElement : Decoder DomElement
decodeProjectDomElement =
    Decode.succeed DomElement
        |: field "projectId" Decode.string
        |: field "offsetHeight" Decode.float


decodeProjectDomElements : Decoder (List DomElement)
decodeProjectDomElements =
    Decode.list decodeProjectDomElement


port fetchDomElements : String -> Cmd msg


fetchProjectDomElements : Cmd msg
fetchProjectDomElements =
    fetchDomElements "#container .project-wrap"


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

                Err error ->
                    { model
                        | status = Error ("Could not parse response: " ++ error)
                    }
                        ! []

        Tick newTime ->
            { model | now = newTime } ! []
