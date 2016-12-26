module Main exposing (..)

import Phoenix.Socket
import Phoenix.Channel
import Html
import Task
import Json.Encode
import Json.Decode as Decode
import Json.Decode exposing (field, Decoder)
import Json.Decode.Extra exposing ((|:))
import Html exposing (..)


-- MAIN


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type Msg
    = PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveProjects Json.Encode.Value
    | JoinChannel


type alias Project =
    { name : String
    }


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , projects : List Project
    }


type alias Flags =
    { websocketUrl : String }


initPhxSocket : Flags -> Phoenix.Socket.Socket Msg
initPhxSocket flags =
    Phoenix.Socket.init flags.websocketUrl
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "projects" "gitlab:lobby" ReceiveProjects


initModel : Flags -> Model
initModel flags =
    Model (initPhxSocket flags) []


init : Flags -> ( Model, Cmd Msg )
init flags =
    (initModel flags) ! [ Task.perform identity (Task.succeed JoinChannel) ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg



-- UPDATE


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



-- VIEW


view : Model -> Html Msg
view model =
    div [] <| List.map viewProject model.projects


viewProject : Project -> Html Msg
viewProject project =
    div [] [ text project.name ]
