module Page.Editor exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Api
import Api.Articles.Slug_
import App
import Browser.Navigation
import Data.Article exposing (Article)
import Data.Async as Async exposing (Async(..))
import Data.User exposing (User)
import Html exposing (..)
import Route
import View.Editor exposing (ArticleForm)


type alias Model =
    { article : Async ArticleForm
    }


type Msg
    = InputForm ArticleForm
    | GotArticleResponse (Api.Response Article)
    | Submit User ArticleForm
    | SubmitResponse (Api.Response Article)


init : String -> ( Model, Cmd Msg )
init slug =
    ( { article = Async.Pending
      }
    , Api.Articles.Slug_.get slug |> Api.send GotArticleResponse
    )


articleToForm : Article -> ArticleForm
articleToForm article =
    { title = article.title
    , description = article.description
    , body = article.body
    , tags = String.join " " article.tagList
    }


update : { r | key : Browser.Navigation.Key } -> String -> Msg -> Model -> ( Model, Cmd Msg, Maybe Never )
update { key } slug msg model =
    case msg of
        InputForm article ->
            App.pure { model | article = Async.GotData article }

        GotArticleResponse res ->
            App.pure
                { model
                    | article =
                        res
                            |> Result.map articleToForm
                            |> Async.fromResponse
                }

        Submit user article ->
            let
                --TODO tagList ?
                putBody =
                    { title = Just article.title
                    , description = Just article.description
                    , body = Just article.body
                    }
            in
            App.pure model
                |> App.withCmd (Api.Articles.Slug_.put user slug putBody |> Api.send SubmitResponse)

        SubmitResponse res ->
            case res of
                Err err ->
                    App.pure model
                        |> App.withCmd (Api.logError err)

                Ok article ->
                    let
                        url =
                            Route.toHref (Route.Article article.slug)
                    in
                    App.pure model
                        |> App.withCmd (Browser.Navigation.pushUrl key url)


view : { r | mUser : Maybe User } -> Model -> ( Maybe String, Html Msg )
view { mUser } model =
    ( Just "New Post"
    , case ( mUser, model.article ) of
        ( Nothing, _ ) ->
            text "You must be logged in to access this page"

        ( Just _, Async.Pending ) ->
            text "Loading.."

        ( Just _, Async.GotErr _ ) ->
            text "Error while loading article"

        ( Just user, Async.GotData article ) ->
            View.Editor.view
                { onInput = InputForm
                , onSubmit = Submit user
                }
                article
    )
