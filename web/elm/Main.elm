module Main exposing (..)

import Models exposing (Model, Msg(..))
import Update exposing (update)
import View exposing (view)
import Phoenix.Socket
import Html
import Task
import Time exposing (Time, second)


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
        |> Phoenix.Socket.on "projects" "gitlab:lobby" ReceiveProjects


initModel : Flags -> Model
initModel flags =
    { phxSocket = (initPhxSocket flags)
    , projects = []
    , now = 0
    , updatedAt = Nothing
    , error = Nothing
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    (initModel flags) ! [ Task.perform identity (Task.succeed JoinChannel) ]


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pipelineCount =
            List.map (\p -> List.length p.pipelines) model.projects
                |> List.foldr (+) 0
    in
        case pipelineCount of
            0 ->
                Phoenix.Socket.listen model.phxSocket PhoenixMsg

            _ ->
                Sub.batch
                    [ Phoenix.Socket.listen model.phxSocket PhoenixMsg
                    , Time.every second Tick
                    ]
