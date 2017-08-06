module View exposing (..)

import Models exposing (Project, Pipeline, Model, Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Date exposing (Date)
import Time
import Date.Extra.Config.Config_en_au as DateConfig
import Date.Extra.Format as DateFormat


type alias ViewPipeline =
    { progressSeconds : Int
    , remainingSeconds : Int
    , progressPercent : Float
    }


type alias ViewProject =
    { name : String
    , image : String
    , status : String
    , lastCommitAuthor : String
    , lastCommitMessage : String
    , updatedAt : Date.Date
    , pipelines : List ViewPipeline
    }


createViewPipeline : Model -> Project -> Pipeline -> ViewPipeline
createViewPipeline model project pipeline =
    let
        progressSeconds =
            (Time.inSeconds model.now)
                - (Time.inSeconds (Date.toTime pipeline.createdAt))
                |> Basics.max 0

        progressPercent =
            case project.duration of
                0 ->
                    0

                _ ->
                    progressSeconds
                        / project.duration
                        * 100
                        |> Basics.min 100
                        |> Basics.max 0

        remainingSeconds =
            project.duration - progressSeconds |> Basics.max 0
    in
        ViewPipeline
            (round progressSeconds)
            (round remainingSeconds)
            progressPercent


projectsSelector : Model -> List ViewProject
projectsSelector model =
    List.map
        (\p ->
            ViewProject
                p.name
                p.image
                p.status
                p.lastCommitAuthor
                p.lastCommitMessage
                p.updatedAt
                (List.map
                    (\pipeline ->
                        createViewPipeline model p pipeline
                    )
                    p.pipelines
                )
        )
        model.projects


view : Model -> Html Msg
view model =
    div []
        [ viewProjects (projectsSelector model)
        , viewStatus model
        ]


viewStatus : Model -> Html Msg
viewStatus model =
    div
        [ id "statusPanel"
        , title (model.error |> Maybe.map (\e -> "Error: " ++ e) |> Maybe.withDefault "")
        , classList [ ( "error", model.error /= Nothing ) ]
        ]
        [ text (statusText model.updatedAt)
        ]


statusText : Maybe Date -> String
statusText =
    Maybe.map formatDate
        >> Maybe.map (\d -> "updated at " ++ d)
        >> Maybe.withDefault "Not updated yet"


viewProjects : List ViewProject -> Html Msg
viewProjects =
    div [ id "container" ] << List.map viewProject


viewProject : ViewProject -> Html Msg
viewProject project =
    [ img [ class "project-image", src project.image ] []
    , div [ class "project-content" ]
        [ div [ class "project-header" ]
            [ h2 [] [ text project.name ]
            , span [ classList [ ( "badge", True ), ( project.status, True ) ] ] [ text project.status ]
            ]
        , p [ class "project-commit" ]
            [ div [] [ text project.lastCommitMessage ]
            , div [ class "info" ]
                [ text
                    (String.join " "
                        [ "by"
                        , project.lastCommitAuthor
                        , "at"
                        , formatDate project.updatedAt
                        ]
                    )
                ]
            ]
        , div [] <| List.map viewPipeline project.pipelines
        ]
    ]
        |> div [ class "project" ]
        |> List.singleton
        |> div [ class "project-wrap" ]


viewPipeline : ViewPipeline -> Html Msg
viewPipeline pipeline =
    div []
        [ progress [ Html.Attributes.max "100", value (toString pipeline.progressPercent) ] []
        , div []
            [ span [ class "col4" ] [ text (formatTime pipeline.progressSeconds) ]
            , span [ class "col4 center" ] [ text ((toString (round pipeline.progressPercent)) ++ "%") ]
            , span [ class "col4 right" ] [ text (formatTime pipeline.remainingSeconds) ]
            ]
        ]


formatDate : Date -> String
formatDate =
    DateFormat.format DateConfig.config "%d/%m/%Y %H:%M:%S"


{-| Format 72 seconds as "1:12"
-}
formatTime : Int -> String
formatTime seconds =
    let
        m =
            seconds // 60

        s =
            seconds - m * 60
    in
        toString m ++ ":" ++ (toString s |> String.padLeft 2 '0')
