module Main exposing (..)

import Browser
import Browser.Dom exposing (Error(..))
import Browser.Navigation as Nav
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Json.Decode exposing (decodeString)
import Json.Encode as Enc
import Page exposing (Page)
import Page.Article
import Page.Editor
import Page.Home
import Page.Login
import Page.NewPost
import Page.NotFound
import Page.Profile
import Page.Register
import Page.Settings
import Ports
import Route as Route exposing (Route(..))
import Url
import View.Nav


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
    , mUser : Maybe User
    }


type alias Flags =
    { user : Maybe String
    }


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    { key = key
    , page = Page.NotFound
    , mUser =
        flags.user
            |> Maybe.andThen (decodeString User.decoder >> Result.toMaybe)
    }
        |> update (UrlChanged url)


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Page.Home.Msg
    | LoginMsg Page.Login.Msg
    | RegisterMsg Page.Register.Msg
    | ArticleMsg Page.Article.Msg
    | ProfileMsg String Page.Profile.Msg
    | SettingsMsg Page.Settings.Msg
    | NewPostMsg Page.NewPost.Msg
    | EditorMsg Page.Editor.Msg


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
                    case url.fragment of
                        Nothing ->
                            ( model, Cmd.none )

                        Just _ ->
                            ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( _, UrlChanged url ) ->
            case Route.parse url of
                Nothing ->
                    ( { model | page = Page.NotFound }, Cmd.none )

                Just Route.Home ->
                    handleInit Page.Home HomeMsg Page.Home.init

                Just Route.Login ->
                    handleInit Page.Login LoginMsg Page.Login.init

                Just Route.Register ->
                    handleInit Page.Register RegisterMsg Page.Register.init

                Just (Route.Profile username) ->
                    handleInit (Page.Profile username) (ProfileMsg username) (Page.Profile.init { username = username })

                Just (Route.Article slug) ->
                    handleInit Page.Article ArticleMsg (Page.Article.init slug)

                Just Route.NewPost ->
                    handleInit Page.NewPost NewPostMsg Page.NewPost.init

                Just (Route.Editor slug) ->
                    handleInit Page.Editor EditorMsg Page.Editor.init

                Just Route.Settings ->
                    handleInit Page.Settings SettingsMsg (Page.Settings.init model)

        ( Page.Home subModel, HomeMsg subMsg ) ->
            handleUpdate
                Page.Home
                HomeMsg
                (Page.Home.update model subMsg subModel)
                never

        ( Page.Login subModel, LoginMsg subMsg ) ->
            handleUpdate Page.Login
                LoginMsg
                (Page.Login.update subMsg subModel)
                (\(Page.Login.LoggedIn user) ->
                    ( { model | mUser = Just user }
                    , Cmd.batch
                        [ Ports.serializeUser <| Enc.encode 2 (User.encode user)
                        , Nav.pushUrl model.key (Route.toHref Route.Home)
                        ]
                    )
                )

        ( Page.Register subModel, RegisterMsg subMsg ) ->
            handleUpdate Page.Register
                RegisterMsg
                (Page.Register.update subMsg subModel)
                (\(Page.Register.Registered user) ->
                    ( { model | mUser = Just user }
                    , Cmd.batch
                        [ Ports.serializeUser <| Enc.encode 2 (User.encode user)
                        , Nav.pushUrl model.key (Route.toHref Route.Home)
                        ]
                    )
                )

        ( Page.Article subModel, ArticleMsg subMsg ) ->
            handleUpdate Page.Article
                ArticleMsg
                (Page.Article.update model subMsg subModel)
                never

        ( Page.Profile username subModel, ProfileMsg msgUsername subMsg ) ->
            if username /= msgUsername then
                ( model, Cmd.none )

            else
                handleUpdate (Page.Profile username)
                    (ProfileMsg username)
                    (Page.Profile.update model { username = username } subMsg subModel)
                    never

        ( Page.Settings subModel, SettingsMsg subMsg ) ->
            handleUpdate Page.Settings
                SettingsMsg
                (Page.Settings.update model subMsg subModel)
                never

        ( Page.NewPost subModel, NewPostMsg subMsg ) ->
            handleUpdate Page.NewPost
                NewPostMsg
                (Page.NewPost.update model subMsg subModel)
                never

        ( Page.Editor subModel, EditorMsg subMsg ) ->
            handleUpdate Page.Editor
                EditorMsg
                (Page.Editor.update model subMsg subModel)
                never

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


viewMain : Model -> ( Maybe String, Html Msg )
viewMain model =
    let
        mapMsg toMsg ( title, h ) =
            ( title, Html.map toMsg h )
    in
    case model.page of
        Page.Home subModel ->
            mapMsg HomeMsg (Page.Home.view model subModel)

        Page.Login subModel ->
            mapMsg LoginMsg (Page.Login.view subModel)

        Page.Register subModel ->
            mapMsg RegisterMsg (Page.Register.view subModel)

        Page.Settings subModel ->
            mapMsg SettingsMsg (Page.Settings.view subModel)

        Page.NewPost subModel ->
            mapMsg NewPostMsg (Page.NewPost.view model subModel)

        Page.Editor subModel ->
            mapMsg EditorMsg (Page.Editor.view model subModel)

        Page.Article subModel ->
            mapMsg ArticleMsg (Page.Article.view model subModel)

        Page.Profile username subModel ->
            mapMsg (ProfileMsg username) (Page.Profile.view subModel)

        Page.NotFound ->
            mapMsg never Page.NotFound.view


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
        [ View.Nav.view model
        , body
        , viewFooter
        ]
    }


viewFooter : Html msg
viewFooter =
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
