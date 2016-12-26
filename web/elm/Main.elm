module Main exposing (..)

import Models exposing (Model, Msg(..))
import Update exposing (update)
import View exposing (view)
import Phoenix.Socket
import Html
import Task


type alias Flags =
    { websocketUrl : String }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg
