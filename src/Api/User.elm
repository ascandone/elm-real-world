module Api.User exposing (PutBody, get, put)

import Api.Internal
import Data.User as User exposing (User)
import Json.Encode as Enc exposing (Value)
import Misc exposing (encodeMaybe)


get : User -> Api.Internal.Request User
get user =
    Api.Internal.get User.decoder [ "user" ]
        |> Api.Internal.withAuth user


type alias PutBody =
    { email : Maybe String
    , username : Maybe String
    , password : Maybe String
    , image : Maybe String
    , bio : Maybe String
    }


encodeBody : PutBody -> Value
encodeBody body =
    Enc.object
        [ ( "email", encodeMaybe Enc.string body.email )
        , ( "username", encodeMaybe Enc.string body.username )
        , ( "password", encodeMaybe Enc.string body.password )
        , ( "image", encodeMaybe Enc.string body.image )
        , ( "bio", encodeMaybe Enc.string body.bio )
        ]


put : User -> PutBody -> Api.Internal.Request User
put user body =
    Api.Internal.put User.decoder [ "user" ]
        |> Api.Internal.withAuth user
        |> Api.Internal.withBody (encodeBody body)
