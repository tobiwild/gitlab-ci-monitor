port module Main exposing (..)

import Html
import Json.Decode as Decode
import Models exposing (Flags, Model, Msg(..), Status(..))
import Phoenix
import Phoenix.Channel
import Phoenix.Socket
import Time exposing (Time, second)
import Update exposing (update)
import View exposing (view)
import Window


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
    , projectDomElements = []
    , now = 0
    , status = Error "Not connected"
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    initModel flags ! []


port domElements : (Decode.Value -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        defaultSubs =
            [ phoenixSubs model
            , domElements ReceiveDomElements
            , Window.resizes (\_ -> Resize)
            ]

        pipelineCount =
            List.map (\p -> List.length p.pipelines) model.projects
                |> List.foldr (+) 0

        subs =
            if pipelineCount > 0 then
                Time.every second Tick :: defaultSubs
            else
                defaultSubs
    in
    Sub.batch subs


phoenixSubs : Model -> Sub Msg
phoenixSubs model =
    let
        socket =
            Phoenix.Socket.init model.flags.websocketUrl

        channel =
            Phoenix.Channel.init "gitlab:lobby"
                |> Phoenix.Channel.on "projects" ReceiveProjects
                |> Phoenix.Channel.onJoinError (\_ -> SetStatusError "Could not join channel")
                |> Phoenix.Channel.onError (SetStatusError "Channel process crashed")
                |> Phoenix.Channel.onDisconnect (SetStatusError "Server disconnected")
    in
    Phoenix.connect socket [ channel ]
