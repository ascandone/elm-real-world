module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Url


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , property : String
    }


type alias Flags =
    ()


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model key url "modelInitialValue", Cmd.none )


type Msg
    = Msg1
    | Msg2
    | UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg1 ->
            ( model, Cmd.none )

        Msg2 ->
            ( model, Cmd.none )

        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Browser.Document Msg
view _ =
    { title = "Application Title"
    , body =
        [ viewNav
        , viewFooter
        ]
    }


viewNav : Html msg
viewNav =
    nav
        [ class "navbar navbar-light"
        ]
        [ div
            [ class "container"
            ]
            [ a
                [ class "navbar-brand"
                , A.href "index.html"
                ]
                [ text "conduit" ]
            , ul
                [ class "nav navbar-nav pull-xs-right"
                ]
                [ li
                    [ class "nav-item"
                    ]
                    [ {- Add "active" class when you're on that page" -}
                      a
                        [ class "nav-link active"
                        , A.href ""
                        ]
                        [ text "Home" ]
                    ]
                , li
                    [ class "nav-item"
                    ]
                    [ a
                        [ class "nav-link"
                        , A.href ""
                        ]
                        [ i
                            [ class "ion-compose"
                            ]
                            []
                        , text "New Post"
                        ]
                    ]
                , li
                    [ class "nav-item"
                    ]
                    [ a
                        [ class "nav-link"
                        , A.href ""
                        ]
                        [ i
                            [ class "ion-gear-a"
                            ]
                            []
                        , text "Settings"
                        ]
                    ]
                , li
                    [ class "nav-item"
                    ]
                    [ a
                        [ class "nav-link"
                        , A.href ""
                        ]
                        [ text "Sign up" ]
                    ]
                ]
            ]
        ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div
            [ class "container"
            ]
            [ a
                [ A.href "/"
                , class "logo-font"
                ]
                [ text "conduit" ]
            , span
                [ class "attribution"
                ]
                [ text "An interactive learning project from"
                , a
                    [ A.href "https://thinkster.io"
                    ]
                    [ text "Thinkster" ]
                , text ". Code & design licensed under MIT."
                ]
            ]
        ]
