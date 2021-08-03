module View.Footer exposing (view)

import Html exposing (..)
import Html.Attributes as A exposing (class)
import Route


view : Html msg
view =
    footer []
        [ div [ class "container" ]
            [ a [ A.href (Route.toHref Route.Home), class "logo-font" ] [ text "conduit" ]
            , span [ class "attribution" ]
                [ text "An interactive learning project from"
                , a [ A.href "https://thinkster.io" ] [ text "Thinkster" ]
                , text ". Code & design licensed under MIT."
                ]
            ]
        ]
