module View.NavPills exposing (view)

import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Events exposing (onClick)


view : item -> { onSelected : item -> msg } -> List { item : item, text : String } -> Html msg
view active { onSelected } items =
    ul [ class "nav nav-pills outline-active" ] <|
        (items
            |> List.map
                (\data ->
                    li
                        [ class "nav-item"
                        ]
                        [ a
                            [ class "nav-link" -- disabled
                            , A.href "#"
                            , onClick (onSelected data.item)
                            , A.classList [ ( "active", data.item == active ) ]
                            ]
                            [ text data.text ]
                        ]
                )
        )
