module Update exposing (..)

import Models exposing (Project, Model, Msg(..))
import Phoenix.Socket
import Phoenix.Channel
import Json.Decode as Decode
import Json.Decode exposing (field, Decoder)
import Json.Decode.Extra exposing ((|:))


decodeProject : Decoder Project
decodeProject =
    Decode.succeed Project
        |: (field "project" Decode.string)


decodeProjects : Decoder (List Project)
decodeProjects =
    field "list" (Decode.list decodeProject)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        ReceiveProjects raw ->
            case Decode.decodeValue decodeProjects raw of
                Ok projects ->
                    ( { model | projects = projects }
                    , Cmd.none
                    )

                Err error ->
                    let
                        _ =
                            Debug.crash error
                    in
                        ( model, Cmd.none )

        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init "gitlab:lobby"

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )
