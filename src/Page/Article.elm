module Page.Article exposing
    ( Event
    , Model
    , Msg
    , init
    , update
    , view
    )

import App
import Html exposing (..)
import Html.Attributes as A exposing (class, href)


type alias Event =
    Never


type alias Model =
    {}


type Msg
    = Noop


init : ( Model, Cmd Msg )
init =
    ( {}
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Event )
update msg model =
    case msg of
        _ ->
            App.pure model


view : Model -> Html Msg
view model =
    div [ class "article-page" ]
        [ div [ class "banner" ]
            [ div [ class "container" ]
                [ h1 []
                    [ text "How to build webapps that scale" ]
                , div [ class "article-meta" ]
                    [ a [ href "" ]
                        [ img [ A.src "http://i.imgur.com/Qr71crq.jpg" ]
                            []
                        ]
                    , div [ class "info" ]
                        [ a [ class "author", href "" ]
                            [ text "Eric Simons" ]
                        , span [ class "date" ]
                            [ text "January 20th" ]
                        ]
                    , button [ class "btn btn-sm btn-outline-secondary" ]
                        [ i [ class "ion-plus-round" ]
                            []
                        , text "           Follow Eric Simons "
                        , span [ class "counter" ]
                            [ text "(10)" ]
                        ]
                    , text "          "
                    , button [ class "btn btn-sm btn-outline-primary" ]
                        [ i [ class "ion-heart" ]
                            []
                        , text "           Favorite Post "
                        , span [ class "counter" ]
                            [ text "(29)" ]
                        ]
                    ]
                ]
            ]
        , div [ class "container page" ]
            [ div [ class "row article-content" ]
                [ div [ class "col-md-12" ]
                    [ p []
                        [ text "Web development technologies have evolved at an incredible clip over the past few years.        " ]
                    , h2 [ A.id "introducing-ionic" ]
                        [ text "Introducing RealWorld." ]
                    , p []
                        [ text "It's a great solution for learning how other frameworks work." ]
                    ]
                ]
            , hr []
                []
            , div [ class "article-actions" ]
                [ div [ class "article-meta" ]
                    [ a [ href "profile.html" ]
                        [ img [ A.src "http://i.imgur.com/Qr71crq.jpg" ]
                            []
                        ]
                    , div [ class "info" ]
                        [ a [ class "author", href "" ]
                            [ text "Eric Simons" ]
                        , span [ class "date" ]
                            [ text "January 20th" ]
                        ]
                    , button [ class "btn btn-sm btn-outline-secondary" ]
                        [ i [ class "ion-plus-round" ]
                            []
                        , text "           Follow Eric Simons "
                        , span [ class "counter" ]
                            [ text "(10)" ]
                        ]
                    , text "         "
                    , button [ class "btn btn-sm btn-outline-primary" ]
                        [ i [ class "ion-heart" ]
                            []
                        , text "           Favorite Post "
                        , span [ class "counter" ]
                            [ text "(29)" ]
                        ]
                    ]
                ]
            , div [ class "row" ]
                [ div [ class "col-xs-12 col-md-8 offset-md-2" ]
                    [ form [ class "card comment-form" ]
                        [ div [ class "card-block" ]
                            [ textarea [ class "form-control", A.placeholder "Write a comment...", A.rows 3 ]
                                []
                            ]
                        , div [ class "card-footer" ]
                            [ img [ class "comment-author-img", A.src "http://i.imgur.com/Qr71crq.jpg" ]
                                []
                            , button [ class "btn btn-sm btn-primary" ]
                                [ text "Post Comment            " ]
                            ]
                        ]
                    , div [ class "card" ]
                        [ div [ class "card-block" ]
                            [ p [ class "card-text" ]
                                [ text "With supporting text below as a natural lead-in to additional content." ]
                            ]
                        , div [ class "card-footer" ]
                            [ a [ class "comment-author", href "" ]
                                [ img [ class "comment-author-img", A.src "http://i.imgur.com/Qr71crq.jpg" ]
                                    []
                                , text "            "
                                ]
                            , text "             "
                            , a [ class "comment-author", href "" ]
                                [ text "Jacob Schmidt" ]
                            , span [ class "date-posted" ]
                                [ text "Dec 29th" ]
                            ]
                        ]
                    , div [ class "card" ]
                        [ div [ class "card-block" ]
                            [ p [ class "card-text" ]
                                [ text "With supporting text below as a natural lead-in to additional content." ]
                            ]
                        , div [ class "card-footer" ]
                            [ a [ class "comment-author", href "" ]
                                [ img [ class "comment-author-img", A.src "http://i.imgur.com/Qr71crq.jpg" ]
                                    []
                                , text "            "
                                ]
                            , text "             "
                            , a [ class "comment-author", href "" ]
                                [ text "Jacob Schmidt" ]
                            , span [ class "date-posted" ]
                                [ text "Dec 29th" ]
                            , span [ class "mod-options" ]
                                [ i [ class "ion-edit" ]
                                    []
                                , i [ class "ion-trash-a" ]
                                    []
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
