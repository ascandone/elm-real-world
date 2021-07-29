module Page.Article exposing
    ( Event
    , Model
    , Msg
    , init
    , update
    , view
    )

import Api
import App
import Data.Article exposing (Article)
import Data.Comment exposing (Comment)
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as A exposing (class, href)
import Markdown
import View.ArticleMeta


type alias Event =
    Never


type alias Model =
    { asyncArticle : Maybe (Api.Response Article)
    , asyncComments : Maybe (Api.Response Comment)
    }


type Msg
    = Noop


init : ( Model, Cmd Msg )
init =
    ( { asyncArticle = Nothing
      , asyncComments = Nothing
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Event )
update msg model =
    case msg of
        _ ->
            App.pure model


view : { r | mUser : Maybe User } -> Model -> Html Msg
view { mUser } model =
    case model.asyncArticle of
        Nothing ->
            text "Loading..."

        Just (Err _) ->
            text "Error"

        Just (Ok article) ->
            div [ class "article-page" ]
                [ div [ class "banner" ]
                    [ div [ class "container" ]
                        [ h1 [] [ text article.title ]
                        , View.ArticleMeta.view article
                        ]
                    ]
                , div [ class "container page" ]
                    [ div [ class "row article-content" ]
                        [ Markdown.toHtml [ class "col-md-12" ] article.body ]
                    , hr [] []
                    , div [ class "article-actions" ]
                        [ View.ArticleMeta.view article ]
                    , div [ class "row" ]
                        [ div [ class "col-xs-12 col-md-8 offset-md-2" ]
                            [ form [ class "card comment-form" ]
                                [ div [ class "card-block" ]
                                    [ textarea [ class "form-control", A.placeholder "Write a comment...", A.rows 3 ] []
                                    ]
                                , div [ class "card-footer" ]
                                    [ img [ class "comment-author-img", A.src "http://i.imgur.com/Qr71crq.jpg" ] []
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
                                        [ img [ class "comment-author-img", A.src "http://i.imgur.com/Qr71crq.jpg" ] []
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
                                        [ img [ class "comment-author-img", A.src "http://i.imgur.com/Qr71crq.jpg" ] []
                                        ]
                                    , a [ class "comment-author", href "" ] [ text "Jacob Schmidt" ]
                                    , span [ class "date-posted" ] [ text "Dec 29th" ]
                                    , span [ class "mod-options" ]
                                        [ i [ class "ion-edit" ] []
                                        , i [ class "ion-trash-a" ] []
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
