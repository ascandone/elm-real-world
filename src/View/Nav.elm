module View.Nav exposing (view)

import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Lazy exposing (lazy2)
import Misc
import Page exposing (Page)
import Route exposing (Route)



-- TODO complete


isLinkActive : Route -> Page -> Bool
isLinkActive route page =
    case ( route, page ) of
        ( Route.Home, Page.Home _ ) ->
            False

        _ ->
            False


navItem : Route -> List (Html msg) -> Page -> Html msg
navItem to_ children current =
    li [ class "nav-item" ]
        [ a
            [ class "nav-link active"
            , A.classList [ ( "active", isLinkActive to_ current ) ] -- TODO active?
            , A.href ""
            ]
            children
        ]


view_ : Maybe User -> Page -> Html msg
view_ mUser page =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a
                [ class "navbar-brand"
                , A.href "index.html"
                ]
                [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ]
                (List.map (\f -> f page) <|
                    navItem Route.Home [ text "Home" ]
                        :: (case mUser of
                                Nothing ->
                                    [ navItem Route.Home [ text "Sign in" ]
                                    , navItem Route.Home [ text "Sign up" ]
                                    ]

                                Just u ->
                                    [ navItem Route.Home
                                        [ i [ class "ion-compose" ] []
                                        , text "New Post"
                                        ]
                                    , navItem Route.Home
                                        [ i [ class "ion-gear-a" ] []
                                        , text "Settings"
                                        ]
                                    , navItem Route.Home
                                        [ img [ A.src <| Misc.defaultImage u.image ] []
                                        , text "Home"
                                        ]
                                    , navItem Route.Home [ text "Sign out" ]
                                    ]
                           )
                )
            ]
        ]


view : { r | mUser : Maybe User, page : Page } -> Html msg
view props =
    lazy2 view_ props.mUser props.page
