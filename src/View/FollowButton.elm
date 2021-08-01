module View.FollowButton exposing (view)

import Data.Profile exposing (Profile)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy)


type Msg
    = ClickedFollow


view : { onFollow : msg } -> Profile -> Html msg
view { onFollow } profile =
    Html.map (\ClickedFollow -> onFollow)
        (lazy view_ profile)


view_ : Profile -> Html Msg
view_ profile =
    button
        [ class "btn btn-sm"
        , class <|
            if profile.following then
                "btn-secondary"

            else
                "btn-outline-secondary"
        , onClick ClickedFollow
        ]
        [ i [ class "ion-plus-round" ] []
        , text <|
            if profile.following then
                "Unfollow "

            else
                "Follow "
        , text profile.username
        ]
