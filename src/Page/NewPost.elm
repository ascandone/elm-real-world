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
import Browser.Navigation
import Data.Article exposing (Article)
import Data.User exposing (User)
import Html exposing (..)
import Route
import View.Editor exposing (ArticleForm)


type alias Model =
    { article : ArticleForm
    }


type Msg
    = InputForm ArticleForm
    | Submit User
    | SubmitResponse (Api.Response Article)


init : ( Model, Cmd Msg )
init =
    ( { article = View.Editor.emptyForm
      }
    , Cmd.none
    )


update : { r | key : Browser.Navigation.Key } -> Msg -> Model -> ( Model, Cmd Msg, Maybe Never )
update { key } msg model =
    case msg of
        InputForm article ->
            App.pure { model | article = article }

        Submit user ->
            let
                { article } =
                    model

                postBody =
                    { title = article.title
                    , description = article.title
                    , body = article.title
                    , tagList =
                        case article.tags of
                            "" ->
                                Nothing

                            str ->
                                Just (String.split " " str)
                    }
            in
            App.pure model
                |> App.withCmd (Api.Articles.post user postBody |> Api.send SubmitResponse)

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
    , case mUser of
        Nothing ->
            Debug.todo "auth msg"

        Just user ->
            View.Editor.view
                { onInput = InputForm
                , onSubmit = Submit user
                }
                model.article
    )
