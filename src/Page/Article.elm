module Page.Article exposing
    ( Event
    , Model
    , Msg
    , init
    , update
    , view
    )

import Api
import Api.Articles exposing (author)
import Api.Articles.Slug_
import Api.Articles.Slug_.Comments
import Api.Articles.Slug_.Favorite
import Api.Profiles.Username_.Follow
import App
import Browser.Navigation
import Data.Article exposing (Article)
import Data.Comment exposing (Comment)
import Data.Profile exposing (Profile)
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as A exposing (class, href)
import Html.Events exposing (onClick, onInput)
import Markdown
import Misc exposing (defaultImage)
import Route
import Time
import View.ArticleMeta
import View.Posix


type alias Event =
    Never


type alias Model =
    { slug : String
    , asyncArticle : Maybe (Api.Response Article)
    , asyncComments : Maybe (Api.Response (List Comment))
    , comment : String
    }


type Msg
    = GotArticle (Api.Response Article)
    | GotComments (Api.Response (List Comment))
    | ClickedFavorite
    | ClickedFollow
    | GotFollowResponse (Api.Response Profile)
    | GotFavoriteResponse (Api.Response Article)
    | InputComment String
    | SubmitComment User
    | GotCommentResponse (Api.Response Comment)
    | DeletedComment User String Int
    | GotDeleteCommentResponse Int (Api.Response ())
    | ClickedDeleteArticle Article User
    | GotDeleteArticleResponse (Api.Response ())


init : String -> ( Model, Cmd Msg )
init slug =
    ( { slug = slug
      , asyncArticle = Nothing
      , asyncComments = Nothing
      , comment = ""
      }
    , Cmd.batch
        [ Api.Articles.Slug_.get slug |> Api.send GotArticle
        , Api.Articles.Slug_.Comments.get slug |> Api.send GotComments
        ]
    )


update :
    { r
        | key : Browser.Navigation.Key
        , mUser : Maybe User
    }
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Maybe Event )
update { key, mUser } msg model =
    case msg of
        GotComments res ->
            App.pure { model | asyncComments = Just res }
                |> App.withCmd (Api.logIfError res)

        InputComment str ->
            App.pure { model | comment = str }

        SubmitComment user ->
            App.pure model
                |> App.withCmd
                    (Api.Articles.Slug_.Comments.post user { body = model.comment } model.slug
                        |> Api.send GotCommentResponse
                    )

        GotCommentResponse response ->
            case ( response, model.asyncComments ) of
                ( Ok comment, Just (Ok comments) ) ->
                    App.pure
                        { model
                            | asyncComments = Just (Ok (comment :: comments))
                            , comment = ""
                        }

                ( Ok _, _ ) ->
                    App.pure { model | comment = "" }

                _ ->
                    App.pure model

        GotArticle response ->
            App.pure { model | asyncArticle = Just response }

        ClickedFollow ->
            case ( model.asyncArticle, mUser ) of
                ( Just (Ok article), Just user ) ->
                    let
                        action =
                            if article.author.following then
                                Api.Profiles.Username_.Follow.delete

                            else
                                Api.Profiles.Username_.Follow.post
                    in
                    App.pure model
                        |> App.withCmd
                            (action user article.author.username
                                |> Api.send GotFollowResponse
                            )

                ( _, Nothing ) ->
                    App.pure model
                        |> App.withCmd (Browser.Navigation.pushUrl key (Route.toHref Route.Login))

                _ ->
                    App.pure model

        ClickedFavorite ->
            case ( model.asyncArticle, mUser ) of
                ( Just (Ok article), Just user ) ->
                    let
                        action =
                            if article.favorited then
                                Api.Articles.Slug_.Favorite.delete

                            else
                                Api.Articles.Slug_.Favorite.post
                    in
                    App.pure model
                        |> App.withCmd
                            (action user article.slug
                                |> Api.send GotFavoriteResponse
                            )

                ( _, Nothing ) ->
                    App.pure model
                        |> App.withCmd (Browser.Navigation.pushUrl key (Route.toHref Route.Login))

                _ ->
                    App.pure model

        GotFollowResponse res ->
            case ( model.asyncArticle, res ) of
                ( _, Err _ ) ->
                    Debug.todo "handle err"

                ( Just (Ok article), Ok profile ) ->
                    App.pure { model | asyncArticle = Just (Ok { article | author = profile }) }

                _ ->
                    App.pure model

        GotFavoriteResponse res ->
            case ( model.asyncArticle, res ) of
                ( _, Err _ ) ->
                    App.pure model

                ( Just (Ok _), Ok article ) ->
                    App.pure { model | asyncArticle = Just (Ok article) }

                _ ->
                    App.pure model

        DeletedComment user slug id ->
            App.pure model
                |> App.withCmd
                    (Api.Articles.Slug_.Comments.delete user slug id
                        |> Api.send (GotDeleteCommentResponse id)
                    )

        GotDeleteCommentResponse id res ->
            case ( res, model.asyncComments ) of
                ( Ok (), Just (Ok comments) ) ->
                    let
                        filtered =
                            comments |> List.filter (\comment -> comment.id /= id)
                    in
                    App.pure { model | asyncComments = Just (Ok filtered) }

                ( Err err, _ ) ->
                    App.pure model
                        |> App.withCmd (Api.logError err)

                _ ->
                    App.pure model

        ClickedDeleteArticle article user ->
            App.pure model
                |> App.withCmd
                    (Api.Articles.Slug_.delete user article.slug
                        |> Api.send GotDeleteArticleResponse
                    )

        GotDeleteArticleResponse res ->
            case res of
                Ok () ->
                    App.pure model
                        |> App.withCmd (Browser.Navigation.pushUrl key (Route.toHref Route.Home))

                Err err ->
                    App.pure model
                        |> App.withCmd (Api.logError err)


viewCardCommentForm :
    { value : String
    , onInput : String -> msg
    , onSubmit : msg
    }
    -> User
    -> Html msg
viewCardCommentForm props user =
    form [ class "card comment-form" ]
        [ div [ class "card-block" ]
            [ textarea
                [ class "form-control"
                , A.placeholder "Write a comment..."
                , A.rows 3
                , onInput props.onInput
                , A.value props.value
                ]
                []
            ]
        , div [ class "card-footer" ]
            [ img [ class "comment-author-img", A.src (defaultImage user.image) ] []
            , button
                [ A.type_ "button"
                , onClick props.onSubmit
                , class "btn btn-sm btn-primary"
                ]
                [ text "Post Comment" ]
            ]
        ]


viewCommentCard : Maybe Time.Zone -> Maybe User -> Article -> Comment -> Html Msg
viewCommentCard mTimeZone mUser article ({ author } as comment) =
    div [ class "card" ]
        [ div [ class "card-block" ]
            [ p [ class "card-text" ] [ text comment.body ]
            ]
        , div [ class "card-footer" ]
            [ a [ class "comment-author", href (Route.toHref (Route.Profile author.username)) ]
                [ img [ class "comment-author-img", A.src (Misc.defaultImage author.image) ] []
                ]
            , a [ class "comment-author", href (Route.toHref (Route.Profile author.username)) ]
                [ text author.username ]
            , span [ class "date-posted" ] [ View.Posix.view mTimeZone comment.createdAt ]
            , case mUser of
                Nothing ->
                    text ""

                Just user ->
                    if user.username /= author.username then
                        text ""

                    else
                        span
                            [ class "mod-options"
                            , onClick (DeletedComment user article.slug comment.id)
                            ]
                            [ i [ class "ion-trash-a" ] [] ]
            ]
        ]


view : { r | mUser : Maybe User, timeZone : Maybe Time.Zone } -> Model -> ( Maybe String, Html Msg )
view { mUser, timeZone } model =
    ( case model.asyncArticle of
        Just (Ok article) ->
            Just article.title

        _ ->
            Just "Article"
    , case model.asyncArticle of
        Nothing ->
            text "Loading..."

        Just (Err _) ->
            text "Error"

        Just (Ok article) ->
            let
                articleMeta =
                    View.ArticleMeta.view
                        { onClickedFavorite = ClickedFavorite
                        , onClickedFollow = ClickedFollow
                        , onClickedDeleteArticle = ClickedDeleteArticle article
                        }
                        timeZone
                        mUser
                        article
            in
            div [ class "article-page" ]
                [ div [ class "banner" ]
                    [ div [ class "container" ]
                        [ h1 [] [ text article.title ]
                        , articleMeta
                        ]
                    ]
                , div [ class "container page" ]
                    [ div [ class "row article-content" ]
                        [ Markdown.toHtml [ class "col-md-12" ] article.body ]
                    , hr [] []
                    , div [ class "article-actions" ]
                        [ articleMeta ]
                    , div [ class "row" ]
                        [ div [ class "col-xs-12 col-md-8 offset-md-2" ] <|
                            List.append
                                [ case mUser of
                                    Nothing ->
                                        text ""

                                    Just user ->
                                        viewCardCommentForm
                                            { onInput = InputComment
                                            , onSubmit = SubmitComment user
                                            , value = model.comment
                                            }
                                            user
                                ]
                                (case model.asyncComments of
                                    Nothing ->
                                        []

                                    Just (Err _) ->
                                        [ text "Error" ]

                                    Just (Ok comments) ->
                                        comments
                                            |> List.map (viewCommentCard timeZone mUser article)
                                )
                        ]
                    ]
                ]
    )
