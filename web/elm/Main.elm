module Main exposing (..)

import Models exposing (Model, Flags, Msg(..), Status(..))
import Update exposing (update)
import View exposing (view)
import Phoenix
import Phoenix.Channel
import Phoenix.Socket
import Html
import Time exposing (Time, second)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


initModel : Flags -> Model
initModel flags =
    { flags = flags
    , projects = []
    , now = 0
    , status = Error "Not connected"
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    (initModel flags) ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pipelineCount =
            List.map (\p -> List.length p.pipelines) model.projects
                |> List.foldr (+) 0
    in
        case pipelineCount of
            0 ->
                phoenixSubs model

            _ ->
                Sub.batch
                    [ phoenixSubs model
                    , Time.every second Tick
                    ]


phoenixSubs : Model -> Sub Msg
phoenixSubs model =
    let
        socket =
            Phoenix.Socket.init model.flags.websocketUrl

        channel =
            Phoenix.Channel.init "gitlab:lobby"
                |> Phoenix.Channel.on "projects" ReceiveProjects
                |> Phoenix.Channel.onJoinError (SetStatusError "Could not join channel" |> always)
                |> Phoenix.Channel.onError (SetStatusError "Channel process crashed")
                |> Phoenix.Channel.onDisconnect (SetStatusError "Server disconnected")
    in
        Phoenix.connect (socket) [ channel ]
