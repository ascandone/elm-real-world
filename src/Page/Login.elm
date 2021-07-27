module Page.Login exposing
    ( Event(..)
    , Model
    , Msg
    , init
    , update
    , view
    )

import App
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Events as E
import Route


type Event
    = SubmitForm Form


type alias Form =
    { email : String
    , password : String
    }


type alias Model =
    { form : Form
    , error : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { form = Form "" ""
      , error = Nothing
      }
    , Cmd.none
    )


type Msg
    = OnInput Form
    | Submit



-- TODO validation


validateForm : Form -> Bool
validateForm _ =
    True


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Event )
update msg model =
    case msg of
        OnInput form ->
            App.pure { model | form = form }

        Submit ->
            if validateForm model.form then
                App.pure model
                    |> App.withEvt (SubmitForm model.form)

            else
                App.pure model


view : Model -> Html Msg
view ({ form } as model) =
    div [ class "auth-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ] [ text "Sign in" ]
                    , p [ class "text-xs-center" ]
                        [ a [ A.href (Route.toHref Route.Register) ] [ text "Need an account?" ] ]
                    , case model.error of
                        Nothing ->
                            text ""

                        Just _ ->
                            ul [ class "error-messages" ] [ li [] [ text "That email is already taken" ] ]
                    , Html.form [ E.onSubmit Submit ] <|
                        List.map (Html.map OnInput)
                            [ fieldset [ class "form-group" ]
                                [ input
                                    [ class "form-control form-control-lg"
                                    , A.type_ "text"
                                    , A.placeholder "Email"
                                    , E.onInput (\s -> { form | email = s })
                                    ]
                                    []
                                ]
                            , fieldset [ class "form-group" ]
                                [ input
                                    [ class "form-control form-control-lg"
                                    , A.type_ "password"
                                    , A.placeholder "Password"
                                    , E.onInput (\s -> { form | password = s })
                                    ]
                                    []
                                ]
                            , button
                                [ A.type_ "submit", class "btn btn-lg btn-primary pull-xs-right" ]
                                [ text "Sign in" ]
                            ]
                    ]
                ]
            ]
        ]
