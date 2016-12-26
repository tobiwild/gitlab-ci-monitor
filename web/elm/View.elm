module View exposing (..)

import Models exposing (Project, Model, Msg(..))
import Html exposing (..)


view : Model -> Html Msg
view model =
    div [] <| List.map viewProject model.projects


viewProject : Project -> Html Msg
viewProject project =
    div [] [ text project.name ]
