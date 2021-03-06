module Page.Settings exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Api
import Api.User
import App
import Data.Async exposing (Async(..))
import Data.User exposing (User)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as A exposing (class, value)
import Html.Events exposing (onInput, onSubmit)
import Route


type alias SettingsForm =
    { email : String
    , username : String
    , bio : String
    , image : String
    , password : String
    }


getPutBody : SettingsForm -> Api.User.PutBody
getPutBody settings =
    { email = Just settings.email
    , username = Just settings.username
    , bio = Just settings.bio
    , image = Just settings.image
    , password = Just settings.password
    }


type alias Model =
    { asyncUserSettings : Async SettingsForm
    }


type Msg
    = GotUserResponse (Api.Response User)
    | InputForm SettingsForm
    | SubmitSettings SettingsForm
    | GotSubmitResponse (Api.Response User)


init : { r | mUser : Maybe User } -> ( Model, List (Effect Msg) )
init { mUser } =
    ( { asyncUserSettings = Pending
      }
    , [ case mUser of
            Just user ->
                Api.User.get user |> Api.send GotUserResponse

            Nothing ->
                Effect.NavReplaceUrl (Route.toHref Route.Login)
      ]
    )


getSettings : User -> SettingsForm
getSettings user =
    { email = user.email
    , username = user.username
    , bio = user.bio
    , image = Maybe.withDefault "" user.image
    , password = ""
    }


update :
    { r | mUser : Maybe User }
    -> Msg
    -> Model
    -> ( Model, List (Effect Msg), Maybe Never )
update { mUser } msg model =
    case msg of
        GotUserResponse res ->
            App.pure
                { model
                    | asyncUserSettings =
                        res
                            |> Result.map getSettings
                            |> Data.Async.fromResponse
                }
                |> App.withEff (Api.logIfError res)

        SubmitSettings settings ->
            case mUser of
                Just user ->
                    App.pure model
                        |> App.withEff (Api.User.put user (getPutBody settings) |> Api.send GotSubmitResponse)

                Nothing ->
                    App.pure model
                        |> App.withEff (Effect.NavReplaceUrl (Route.toHref Route.Login))

        InputForm settings ->
            App.pure { model | asyncUserSettings = GotData settings }

        GotSubmitResponse res ->
            App.pure
                { model
                    | asyncUserSettings =
                        res
                            |> Result.map getSettings
                            |> Data.Async.fromResponse
                }
                |> App.withEff (Api.logIfError res)


view : Model -> ( Maybe String, Html Msg )
view model =
    ( Just "Settings"
    , case model.asyncUserSettings of
        Pending ->
            text ""

        GotErr _ ->
            text "Error while loading settings"

        GotData settings ->
            viewUserSettings settings
    )


viewForm : SettingsForm -> Html SettingsForm
viewForm settings =
    fieldset []
        [ fieldset [ class "form-group" ]
            [ input
                [ class "form-control"
                , A.placeholder "URL of profile picture"
                , A.type_ "text"
                , onInput (\s -> { settings | image = s })
                , value settings.image
                ]
                []
            ]
        , fieldset [ class "form-group" ]
            [ input
                [ class "form-control form-control-lg"
                , A.placeholder "Your Name"
                , A.type_ "text"
                , onInput (\s -> { settings | username = s })
                , value settings.username
                ]
                []
            ]
        , fieldset [ class "form-group" ]
            [ textarea
                [ class "form-control form-control-lg"
                , A.placeholder "Short bio about you"
                , A.rows 8
                , onInput (\s -> { settings | bio = s })
                , value settings.bio
                ]
                []
            ]
        , fieldset [ class "form-group" ]
            [ input
                [ class "form-control form-control-lg"
                , A.placeholder "Email"
                , A.type_ "text"
                , onInput (\s -> { settings | email = s })
                , value settings.email
                ]
                []
            ]
        , fieldset [ class "form-group" ]
            [ input
                [ class "form-control form-control-lg"
                , A.placeholder "Password"
                , A.type_ "password"
                , onInput (\s -> { settings | password = s })
                , value settings.password
                ]
                []
            ]
        , button [ A.type_ "submit", class "btn btn-lg btn-primary pull-xs-right" ]
            [ text "Update Settings" ]
        ]


viewUserSettings : SettingsForm -> Html Msg
viewUserSettings settings =
    div [ class "settings-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ]
                        [ text "Your Settings" ]
                    , form [ onSubmit (SubmitSettings settings) ]
                        [ Html.map InputForm (viewForm settings) ]
                    ]
                ]
            ]
        ]
