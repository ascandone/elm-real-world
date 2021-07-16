module Api.Users.Login exposing (post)

import Api.Internal as Api
import Data.User as User exposing (User)
import Json.Encode as Enc exposing (Value)


encCreds : { email : String, password : String } -> Value
encCreds creds =
    Enc.object
        [ ( "user"
          , Enc.object
                [ ( "email", Enc.string creds.email )
                , ( "password", Enc.string creds.password )
                ]
          )
        ]


post : { email : String, password : String } -> Api.Request User
post creds =
    Api.post User.decoder [ "users", "login" ]
        |> Api.withBody (encCreds creds)
