module Api.Users exposing (post)

import Api.Internal exposing (Request)
import Data.User as User exposing (User)
import Json.Encode as Enc exposing (Value)


encCreds : { username : String, email : String, password : String } -> Value
encCreds creds =
    Enc.object
        [ ( "user"
          , Enc.object
                [ ( "username", Enc.string creds.username )
                , ( "email", Enc.string creds.email )
                , ( "password", Enc.string creds.password )
                ]
          )
        ]


post : { username : String, email : String, password : String } -> Request User
post creds =
    Api.Internal.post User.decoder [ "users" ]
        |> Api.Internal.withBody (encCreds creds)
