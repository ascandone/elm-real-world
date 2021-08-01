module Page.Profile exposing
    ( Event
    , Model
    , Msg
    , init
    , update
    , view
    )

import Api
import Api.Articles
import Api.Profiles.Username_
import App
import Data.Article as Article exposing (Article)
import Data.Async as Async exposing (Async(..))
import Data.Profile exposing (Profile)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Misc
import View.ArticlePreview
import View.FollowButton


type alias Event =
    Never


type alias Model =
    { username : String
    , asyncProfile : Async Profile
    , asyncArticles : Async (List Article)
    }


init : { username : String } -> ( Model, Cmd Msg )
init { username } =
    ( { username = username
      , asyncProfile = Pending
      , asyncArticles = Pending
      }
    , Cmd.batch
        [ Api.Profiles.Username_.get username |> Api.send (GotProfile username)
        , Api.Articles.get [] |> Api.send (GotArticles username)
        ]
    )


type Msg
    = GotProfile String (Api.Response Profile)
    | GotArticles String (Api.Response Article.Collection)
    | ClickedFollow
    | ToggleFavorite


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Event )
update msg model =
    case msg of
        ToggleFavorite ->
            Debug.todo "toggle fav"

        GotProfile username res ->
            if username /= model.username then
                App.pure model

            else
                App.pure { model | asyncProfile = Async.fromResponse res }
                    |> App.withCmd (Api.logIfError res)

        ClickedFollow ->
            Debug.todo "clickedFollow"

        GotArticles _ _ ->
            Debug.todo "gotArticles"


view : Model -> ( Maybe String, Html Msg )
view model =
    ( Just <|
        case model.asyncProfile of
            Async.GotData { username } ->
                username

            _ ->
                "Profile"
    , div [ class "profile-page" ]
        [ case model.asyncProfile of
            Async.GotData profile ->
                viewUserInfo profile

            _ ->
                text ""
        , div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-12 col-md-10 offset-md-1" ] <|
                    List.append
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
                        ]
                        (case model.asyncArticles of
                            Pending ->
                                [ text "Loading..." ]

                            GotData articles ->
                                articles
                                    |> List.map
                                        (View.ArticlePreview.view
                                            { onToggleFavorite = ToggleFavorite }
                                        )

                            GotErr _ ->
                                Debug.todo "handle err"
                        )
                ]
            ]
        ]
    )


viewUserInfo : Profile -> Html Msg
viewUserInfo profile =
    div [ class "user-info" ]
        [ div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                    [ img [ class "user-img", A.src (Misc.defaultImage profile.image) ] []
                    , h4 [] [ text profile.username ]
                    , case profile.bio of
                        Nothing ->
                            text ""

                        Just bio ->
                            p [] [ text bio ]
                    , View.FollowButton.view
                        { onFollow = ClickedFollow }
                        profile
                    ]
                ]
            ]
        ]
