module Page.Profile exposing
    ( Event
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


type alias Event =
    Never


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}
    , Cmd.none
    )


type Msg
    = Noop


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Event )
update msg model =
    case msg of
        _ ->
            App.pure model


view : Model -> ( Maybe String, Html Msg )
view model =
    ( Nothing
      --TODO
    , div [ class "profile-page" ]
        [ div [ class "user-info" ]
            [ div [ class "container" ]
                [ div [ class "row" ]
                    [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                        [ img [ class "user-img", A.src "http://i.imgur.com/Qr71crq.jpg" ]
                            []
                        , h4 []
                            [ text "Eric Simons" ]
                        , p []
                            [ text "Cofounder @GoThinkster, lived in Aol's HQ for a few months, kinda looks like Peeta from the Hunger Games          " ]
                        , button [ class "btn btn-sm btn-outline-secondary action-btn" ]
                            [ i [ class "ion-plus-round" ]
                                []
                            , text "             Follow Eric Simons           "
                            ]
                        ]
                    ]
                ]
            ]
        , div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                    [ div [ class "articles-toggle" ]
                        [ ul [ class "nav nav-pills outline-active" ]
                            [ li [ class "nav-item" ]
                                [ a [ class "nav-link active", A.href "" ]
                                    [ text "My Articles" ]
                                ]
                            , li [ class "nav-item" ]
                                [ a [ class "nav-link", A.href "" ]
                                    [ text "Favorited Articles" ]
                                ]
                            ]
                        ]
                    , div [ class "article-preview" ]
                        [ div [ class "article-meta" ]
                            [ a [ A.href "" ]
                                [ img [ A.src "http://i.imgur.com/Qr71crq.jpg" ]
                                    []
                                ]
                            , div [ class "info" ]
                                [ a [ class "author", A.href "" ]
                                    [ text "Eric Simons" ]
                                , span [ class "date" ]
                                    [ text "January 20th" ]
                                ]
                            , button [ class "btn btn-outline-primary btn-sm pull-xs-right" ]
                                [ i [ class "ion-heart" ]
                                    []
                                , text "29            "
                                ]
                            ]
                        , a [ class "preview-link", A.href "" ]
                            [ h1 []
                                [ text "How to build webapps that scale" ]
                            , p []
                                [ text "This is the description for the post." ]
                            , span []
                                [ text "Read more..." ]
                            ]
                        ]
                    , div [ class "article-preview" ]
                        [ div [ class "article-meta" ]
                            [ a [ A.href "" ]
                                [ img [ A.src "http://i.imgur.com/N4VcUeJ.jpg" ]
                                    []
                                ]
                            , div [ class "info" ]
                                [ a [ class "author", A.href "" ]
                                    [ text "Albert Pai" ]
                                , span [ class "date" ]
                                    [ text "January 20th" ]
                                ]
                            , button [ class "btn btn-outline-primary btn-sm pull-xs-right" ]
                                [ i [ class "ion-heart" ]
                                    []
                                , text "32            "
                                ]
                            ]
                        , a [ class "preview-link", A.href "" ]
                            [ h1 []
                                [ text "The song you won't ever stop singing. No matter how hard you try." ]
                            , p []
                                [ text "This is the description for the post." ]
                            , span []
                                [ text "Read more..." ]
                            , ul [ class "tag-list" ]
                                [ li [ class "tag-default tag-pill tag-outline" ]
                                    [ text "Music" ]
                                , li [ class "tag-default tag-pill tag-outline" ]
                                    [ text "Song" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    )
