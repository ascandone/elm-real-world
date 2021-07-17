module Page.Home exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Api
import Api.Tags
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Http
import Process
import Task


type alias Model =
    Int


type Msg
    = Noop
    | GotResponse (Result Http.Error (Api.Response (List String)))


init : ( Model, Cmd Msg )
init =
    ( 0
    , Cmd.batch
        [ Process.sleep 1000 |> Task.perform (\_ -> Noop)
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model + 1, Cmd.none )

        GotResponse _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        [ class "home-page"
        ]
        [ div
            [ class "banner"
            ]
            [ div
                [ class "container"
                ]
                [ h1
                    [ class "logo-font"
                    ]
                    [ text "conduit" ]
                , p []
                    [ text "A place to share your knowledge." ]
                ]
            ]
        , div
            [ class "container page"
            ]
            [ div
                [ class "row"
                ]
                [ div
                    [ class "col-md-9"
                    ]
                    [ div
                        [ class "feed-toggle"
                        ]
                        [ ul
                            [ class "nav nav-pills outline-active"
                            ]
                            [ li
                                [ class "nav-item"
                                ]
                                [ a
                                    [ class "nav-link disabled"
                                    , A.href ""
                                    ]
                                    [ text "Your Feed" ]
                                ]
                            , li
                                [ class "nav-item"
                                ]
                                [ a
                                    [ class "nav-link active"
                                    , A.href ""
                                    ]
                                    [ text "Global Feed" ]
                                ]
                            ]
                        ]
                    , div
                        [ class "article-preview"
                        ]
                        [ div
                            [ class "article-meta"
                            ]
                            [ a
                                [ A.href "profile.html"
                                ]
                                [ img
                                    [ A.src "http://i.imgur.com/Qr71crq.jpg"
                                    ]
                                    []
                                ]
                            , div
                                [ class "info"
                                ]
                                [ a
                                    [ A.href ""
                                    , class "author"
                                    ]
                                    [ text "Eric Simons" ]
                                , span
                                    [ class "date"
                                    ]
                                    [ text "January 20th" ]
                                ]
                            , button
                                [ class "btn btn-outline-primary btn-sm pull-xs-right"
                                ]
                                [ i
                                    [ class "ion-heart"
                                    ]
                                    []
                                , text "29"
                                ]
                            ]
                        , a
                            [ A.href ""
                            , class "preview-link"
                            ]
                            [ h1 []
                                [ text "How to build webapps that scale" ]
                            , p []
                                [ text "This is the description for the post." ]
                            , span []
                                [ text "Read more..." ]
                            ]
                        ]
                    , div
                        [ class "article-preview"
                        ]
                        [ div
                            [ class "article-meta"
                            ]
                            [ a
                                [ A.href "profile.html"
                                ]
                                [ img
                                    [ A.src "http://i.imgur.com/N4VcUeJ.jpg"
                                    ]
                                    []
                                ]
                            , div
                                [ class "info"
                                ]
                                [ a
                                    [ A.href ""
                                    , class "author"
                                    ]
                                    [ text "Albert Pai" ]
                                , span
                                    [ class "date"
                                    ]
                                    [ text "January 20th" ]
                                ]
                            , button
                                [ class "btn btn-outline-primary btn-sm pull-xs-right"
                                ]
                                [ i
                                    [ class "ion-heart"
                                    ]
                                    []
                                , text "32"
                                ]
                            ]
                        , a
                            [ A.href ""
                            , class "preview-link"
                            ]
                            [ h1 []
                                [ text "The song you won't ever stop singing. No matter how hard you try." ]
                            , p []
                                [ text "This is the description for the post." ]
                            , span []
                                [ text "Read more..." ]
                            ]
                        ]
                    ]
                , div
                    [ class "col-md-3"
                    ]
                    [ div
                        [ class "sidebar"
                        ]
                        [ p []
                            [ text "Popular Tags" ]
                        , div
                            [ class "tag-list"
                            ]
                            [ a
                                [ A.href ""
                                , class "tag-pill tag-default"
                                ]
                                [ text "programming" ]
                            , a
                                [ A.href ""
                                , class "tag-pill tag-default"
                                ]
                                [ text "javascript" ]
                            , a
                                [ A.href ""
                                , class "tag-pill tag-default"
                                ]
                                [ text "emberjs" ]
                            , a
                                [ A.href ""
                                , class "tag-pill tag-default"
                                ]
                                [ text "angularjs" ]
                            , a
                                [ A.href ""
                                , class "tag-pill tag-default"
                                ]
                                [ text "react" ]
                            , a
                                [ A.href ""
                                , class "tag-pill tag-default"
                                ]
                                [ text "mean" ]
                            , a
                                [ A.href ""
                                , class "tag-pill tag-default"
                                ]
                                [ text "node" ]
                            , a
                                [ A.href ""
                                , class "tag-pill tag-default"
                                ]
                                [ text "rails" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
