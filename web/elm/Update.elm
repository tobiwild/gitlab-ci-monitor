module Update exposing (..)

import Models exposing (Project, Pipeline, Model, Msg(..))
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
        |: (field "name" Decode.string)
        |: (field "image" Decode.string)
        |: (field "status" Decode.string)
        |: (field "duration" Decode.float)
        |: (field "last_commit_author" Decode.string)
        |: (field "last_commit_message" Decode.string)
        |: (field "updated_at" Json.Decode.Extra.date)
        |: (field "pipelines" (Decode.list decodePipeline))


decodeProjects : Decoder (List Project)
decodeProjects =
    field "list" (Decode.list decodeProject)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetError errorMsg ->
            { model | error = Just errorMsg } ! []

        ReceiveProjects raw ->
            case Decode.decodeValue decodeProjects raw of
                Ok projects ->
                    { model
                        | projects = projects
                        , error = Nothing
                    }
                        ! [ Task.perform SetUpdated Date.now ]

                Err error ->
                    { model
                        | error = Just error
                    }
                        ! []

        SetUpdated newDate ->
            { model | updatedAt = Just newDate } ! []

        Tick newTime ->
            { model | now = newTime } ! []
