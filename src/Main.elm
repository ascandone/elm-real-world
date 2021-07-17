module Main exposing (..)

import Browser
import Browser.Dom exposing (Error(..))
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Page exposing (Page)
import Page.Home
import Page.NotFound
import Route as Route exposing (Route(..))
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
    , page : Page
    }


type alias Flags =
    ()


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    { key = key
    , page = Page.NotFound
    }
        |> update (UrlChanged url)


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Page.Home.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        handleInit : (subModel -> Page) -> (msg -> Msg) -> ( subModel, Cmd msg ) -> ( Model, Cmd Msg )
        handleInit constr toMsg ( subModel, cmd ) =
            ( { model | page = constr subModel }
            , Cmd.map toMsg cmd
            )

        handleUpdate : (subModel -> Page) -> (msg -> Msg) -> ( subModel, Cmd msg, Maybe evt ) -> (evt -> ( Model, Cmd Msg )) -> ( Model, Cmd Msg )
        handleUpdate constr toMsg ( subModel, cmd, mEvt ) handleEvent =
            case mEvt of
                Nothing ->
                    ( { model | page = constr subModel }
                    , Cmd.map toMsg cmd
                    )

                Just evt ->
                    let
                        ( newModel, cmd1 ) =
                            handleEvent evt
                    in
                    ( { newModel | page = constr subModel }
                    , Cmd.batch
                        [ Cmd.map toMsg cmd
                        , cmd1
                        ]
                    )
    in
    case ( model.page, msg ) of
        ( _, UrlRequested urlRequest ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( _, UrlChanged url ) ->
            case Route.parse url of
                Nothing ->
                    ( { model | page = Page.NotFound }, Cmd.none )

                Just Home ->
                    handleInit Page.Home HomeMsg Page.Home.init

                Just (Profile _) ->
                    Debug.todo "profile"

        ( Page.Home subModel, HomeMsg subMsg ) ->
            handleUpdate Page.Home HomeMsg (Page.Home.update subMsg subModel) never

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


viewMain : Model -> ( Maybe String, Html Msg )
viewMain model =
    case model.page of
        Page.Home subModel ->
            ( Nothing, Html.map HomeMsg <| Page.Home.view subModel )

        Page.NotFound ->
            ( Just "Not found", Page.NotFound.view )


view : Model -> Browser.Document Msg
view model =
    let
        ( mTitle, body ) =
            viewMain model
    in
    { title =
        case mTitle of
            Nothing ->
                "Conduit"

            Just title ->
                title ++ " | Conduit"
    , body =
        [ viewNav
        , body
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
