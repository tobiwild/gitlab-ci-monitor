module View exposing (..)

import Models exposing (Project, Model, Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Date.Extra.Config.Config_en_au as DateConfig
import Date.Extra.Format as DateFormat


view : Model -> Html Msg
view model =
    div [ id "container" ] <| List.map viewProject model.projects


viewProject : Project -> Html Msg
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
            ]
        ]
