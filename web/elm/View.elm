module View exposing (..)

import Models exposing (Project, Model, Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)


view : Model -> Html Msg
view model =
    div [ id "container" ] <| List.map viewProject model.projects


viewProject : Project -> Html Msg
viewProject project =
    div [ classList [ ( "project", True ), ( project.status, True ) ] ]
        [ img [ class "project-image", src project.image ] []
        , div [ class "project-content" ]
            [ h2 [] [ text project.name ]
            ]
        ]
