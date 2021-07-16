module Api.Internal exposing
    ( Config
    , Request(..)
    , delete
    , get
    , post
    , put
    , withAuth
    , withBody
    , withParams
    )

import Data.User exposing (User)
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)
import Url.Builder exposing (QueryParameter)


type alias Config data =
    { queryParameters : List QueryParameter
    , auth : Maybe User
    , body : Maybe Value
    , method : String
    , decoder : Decoder data
    , path : List String
    }



-- TODO proper incapsulation


type Request data
    = Request (Config data)


builder : (Config data -> Config data) -> Request data -> Request data
builder f (Request config) =
    Request (f config)


withBody : Value -> Request data -> Request data
withBody x =
    builder (\c -> { c | body = Just x })


withAuth : User -> Request data -> Request data
withAuth x =
    builder (\c -> { c | auth = Just x })


withParams : List QueryParameter -> Request data -> Request data
withParams x =
    builder (\c -> { c | queryParameters = x })


request : String -> Decoder data -> List String -> Request data
request method decoder path =
    Request
        { method = method
        , decoder = decoder
        , path = path
        , queryParameters = []
        , auth = Nothing
        , body = Nothing
        }


get : Decoder data -> List String -> Request data
get =
    request "GET"


delete : Decoder data -> List String -> Request data
delete =
    request "DELETE"


put : Decoder data -> List String -> Request data
put =
    request "PUT"


post : Decoder data -> List String -> Request data
post =
    request "POST"
