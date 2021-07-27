module Data.User exposing (User, decoder, encode)

import Json.Decode as Dec exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Enc exposing (Value)
import Misc exposing (optionalMaybe)


type alias User =
    { email : String
    , token : String
    , username : String
    , bio : String
    , image : Maybe String
    }


decoder : Decoder User
decoder =
    Dec.field "user"
        (Dec.succeed User
            |> required "email" string
            |> required "token" string
            |> required "username" string
            |> required "bio" string
            |> optionalMaybe "image" string
        )


encode : User -> Value
encode user =
    Enc.object
        [ ( "email", Enc.string user.email )
        , ( "token", Enc.string user.token )
        , ( "username", Enc.string user.username )
        , ( "bio", Enc.string user.bio )
        , ( "image"
          , case user.image of
                Nothing ->
                    Enc.null

                Just str ->
                    Enc.string str
          )
        ]
