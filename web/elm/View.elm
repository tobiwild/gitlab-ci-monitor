module View exposing (..)

import Models exposing (Project, Pipeline, Model, Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Date
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
view =
    viewProjects << projectsSelector


viewProjects : List ViewProject -> Html Msg
viewProjects projects =
    div [ id "container" ] <| List.map viewProject projects


viewProject : ViewProject -> Html Msg
viewProject project =
    div [ class "project" ]
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
                            , (DateFormat.format DateConfig.config "%-d/%m/%Y %-H:%M" project.updatedAt)
                            ]
                        )
                    ]
                ]
            , div [] <| List.map viewPipeline project.pipelines
            ]
        ]


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
