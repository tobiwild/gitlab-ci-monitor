module View exposing (..)

import Models exposing (Project, Pipeline, Model, Msg(..), Status(..))
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
    , status : Maybe String
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
        , viewStatusPanel model
        ]


viewStatusPanel : Model -> Html Msg
viewStatusPanel model =
    div
        [ id "statusPanel"
        , classList [ ( "error", isStatusError model.status ) ]
        ]
        [ text (statusText model.status)
        ]


isStatusError : Status -> Bool
isStatusError status =
    case status of
        Error _ ->
            True

        _ ->
            False


statusText : Status -> String
statusText status =
    case status of
        Updated date ->
            "Updated " ++ (formatDate date)

        Error error ->
            "Error: " ++ error


viewProjects : List ViewProject -> Html Msg
viewProjects =
    List.map viewProject
        >> columnize
        >> div [ id "container" ]


columnize : List (Html Msg) -> List (Html Msg)
columnize =
    List.indexedMap (,)
        >> List.partition (\( i, _ ) -> i % 2 == 0)
        >> (\( left, right ) ->
                [ div [ class "column" ] (List.unzip left |> Tuple.second)
                , div [ class "column" ] (List.unzip right |> Tuple.second)
                ]
           )


viewProject : ViewProject -> Html Msg
viewProject project =
    [ img [ class "project-image", src project.image ] []
    , div [ class "project-content" ]
        [ div [ class "project-header" ] <|
            [ h2 [] [ text project.name ]
            ]
                ++ viewStatus project.status
        , p [ class "project-commit" ]
            [ div [] [ text project.lastCommitMessage ]
            , div [ class "info" ]
                [ text
                    (String.join " "
                        [ "by"
                        , project.lastCommitAuthor
                        , formatDate project.updatedAt
                        ]
                    )
                ]
            ]
        , div [] <| List.map viewPipeline project.pipelines
        ]
    ]
        |> div [ class "project" ]


viewStatus : Maybe String -> List (Html Msg)
viewStatus status =
    case status of
        Just s ->
            [ span [ class ("badge " ++ s) ] [ text s ]
            ]

        Nothing ->
            []


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
    DateFormat.format DateConfig.config "on %d/%m/%Y at %H:%M:%S"


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
