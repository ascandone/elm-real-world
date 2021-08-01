module View.Nav exposing (view)

import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Lazy exposing (lazy2)
import Misc
import Page exposing (Page)
import Route exposing (Route)


isLinkActive : Route -> Page -> Bool
isLinkActive route page =
    case ( route, page ) of
        ( Route.Home, Page.Home _ ) ->
            True

        ( Route.Login, Page.Login _ ) ->
            True

        ( Route.Register, Page.Register _ ) ->
            True

        ( Route.Settings, Page.Settings _ ) ->
            True

        ( Route.NewPost, Page.NewPost _ ) ->
            True

        ( Route.Editor _, Page.Editor _ ) ->
            True

        ( Route.Article _, Page.Article _ ) ->
            True

        ( Route.Profile _, Page.Profile _ ) ->
            True

        _ ->
            False


navItem : Route -> List (Html msg) -> Page -> Html msg
navItem to_ children current =
    li [ class "nav-item" ]
        [ a
            [ class "nav-link"
            , A.classList [ ( "active", isLinkActive to_ current ) ]
            , A.href (Route.toHref to_)
            ]
            children
        ]


view_ : Maybe User -> Page -> Html msg
view_ mUser page =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a
                [ class "navbar-brand"
                , A.href (Route.toHref Route.Home)
                ]
                [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ]
                (List.map (\f -> f page) <|
                    navItem Route.Home [ text "Home" ]
                        :: (case mUser of
                                Nothing ->
                                    [ navItem Route.Login [ text "Sign in" ]
                                    , navItem Route.Register [ text "Sign up" ]
                                    ]

                                Just u ->
                                    [ navItem Route.NewPost
                                        [ i [ class "ion-compose" ] []
                                        , text "New Post"
                                        ]
                                    , navItem Route.Settings
                                        [ i [ class "ion-gear-a" ] []
                                        , text "Settings"
                                        ]
                                    , navItem (Route.Profile u.username)
                                        [ img [ class "user-pic", A.src <| Misc.defaultImage u.image ] []
                                        , text u.username
                                        ]
                                    ]
                           )
                )
            ]
        ]


view : { r | mUser : Maybe User, page : Page } -> Html msg
view props =
    lazy2 view_ props.mUser props.page
