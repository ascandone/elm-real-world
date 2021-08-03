module Page.Settings exposing
    ( Model
    , Msg
    , update
    , view
    )

import App
import Html exposing (..)
import Html.Attributes as A exposing (class)


type alias Model =
    {}


type Msg
    = Noop


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Never )
update msg model =
    case msg of
        _ ->
            App.pure model


view : Model -> Html Msg
view _ =
    div [ class "settings-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ]
                        [ text "Your Settings" ]
                    , form []
                        [ fieldset []
                            [ fieldset [ class "form-group" ]
                                [ input
                                    [ class "form-control"
                                    , A.placeholder "URL of profile picture"
                                    , A.type_ "text"
                                    ]
                                    []
                                ]
                            , fieldset [ class "form-group" ]
                                [ input
                                    [ class "form-control form-control-lg"
                                    , A.placeholder "Your Name"
                                    , A.type_ "text"
                                    ]
                                    []
                                ]
                            , fieldset [ class "form-group" ]
                                [ textarea
                                    [ class "form-control form-control-lg"
                                    , A.placeholder "Short bio about you"
                                    , A.rows 8
                                    ]
                                    []
                                ]
                            , fieldset [ class "form-group" ]
                                [ input
                                    [ class "form-control form-control-lg"
                                    , A.placeholder "Email"
                                    , A.type_ "text"
                                    ]
                                    []
                                ]
                            , fieldset [ class "form-group" ]
                                [ input
                                    [ class "form-control form-control-lg"
                                    , A.placeholder "Password"
                                    , A.type_ "password"
                                    ]
                                    []
                                ]
                            , button [ class "btn btn-lg btn-primary pull-xs-right" ]
                                [ text "Update Settings" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
