module Data.User exposing (User, decoder, encode, specs)

import Expect
import Fuzz exposing (Fuzzer)
import Iso8601 exposing (decoder)
import Json.Decode as Dec exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Enc exposing (Value)
import Misc exposing (optionalMaybe)
import Test exposing (Test)


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
        [ ( "user"
          , Enc.object
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
          )
        ]



-- Test


exampleUserStr : String
exampleUserStr =
    """
{
    "user": {
        "email": "jake@jake.jake",
        "token": "jwt.token.here",
        "username": "jake",
        "bio": "I work at statefarm",
        "image": null
    }
}
"""


exampleUser : User
exampleUser =
    { email = "jake@jake.jake"
    , token = "jwt.token.here"
    , username = "jake"
    , bio = "I work at statefarm"
    , image = Nothing
    }


fuzzer : Fuzzer User
fuzzer =
    Fuzz.constant User
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)


specs : Test
specs =
    Test.concat
        [ Test.test "decoding example from docs" <|
            \() -> Expect.equal (Dec.decodeString decoder exampleUserStr) (Ok exampleUser)
        , Test.test "encoding" <|
            \() -> Misc.expectIso decoder encode exampleUser
        , Test.fuzz fuzzer "encoding iso fuzzing" <|
            Misc.expectIso decoder encode
        ]
