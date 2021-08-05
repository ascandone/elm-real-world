module Page.NewPost exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Api
import Api.Articles
import App
import Data.Article exposing (Article)
import Data.User exposing (User)
import Effect exposing (Effect)
import Html exposing (..)
import Route
import View.Editor exposing (ArticleForm)


type alias Model =
    { article : ArticleForm
    }


type Msg
    = InputForm ArticleForm
    | Submit User ArticleForm
    | SubmitResponse (Api.Response Article)


init : ( Model, List (Effect Msg) )
init =
    ( { article = View.Editor.emptyForm
      }
    , []
    )


update : Msg -> Model -> ( Model, List (Effect Msg), Maybe Never )
update msg model =
    case msg of
        InputForm article ->
            App.pure { model | article = article }

        Submit user article ->
            let
                postBody =
                    { title = article.title
                    , description = article.description
                    , body = article.body
                    , tagList =
                        case article.tags of
                            "" ->
                                Nothing

                            str ->
                                Just (String.split " " str)
                    }
            in
            App.pure model
                |> App.withEff (Api.Articles.post user postBody |> Api.send SubmitResponse)

        SubmitResponse res ->
            case res of
                Err err ->
                    App.pure model
                        |> App.withEff (Api.logError err)

                Ok article ->
                    let
                        url =
                            Route.toHref (Route.Article article.slug)
                    in
                    App.pure model
                        |> App.withEff (Effect.NavPushUrl url)


view : { r | mUser : Maybe User } -> Model -> ( Maybe String, Html Msg )
view { mUser } model =
    ( Just "New Post"
    , case mUser of
        Nothing ->
            text "You must be logged in to access this page"

        Just user ->
            View.Editor.view
                { onInput = InputForm
                , onSubmit = Submit user
                }
                model.article
    )
