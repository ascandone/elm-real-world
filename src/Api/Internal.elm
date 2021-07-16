module Api.Internal exposing
    ( Error
    , Request
    , Response(..)
    , delete
    , get
    , post
    , put
    , send
    , withAuth
    , withBody
    , withParams
    )

import Data.User exposing (User)
import Http
import Json.Decode as Dec exposing (Decoder)
import Json.Encode exposing (Value)
import Url.Builder exposing (QueryParameter)


type alias Error =
    { body : List String
    }


type Response data
    = Ok data
    | Err Error


errorDecoder : Decoder Error
errorDecoder =
    Dec.map Error
        (Dec.field "errors"
            (Dec.field "body" (Dec.list Dec.string))
        )


responseDecoder : Decoder data -> Decoder (Response data)
responseDecoder decoder =
    Dec.oneOf
        [ Dec.map Err errorDecoder
        , Dec.map Ok decoder
        ]


type alias Config data =
    { queryParameters : List QueryParameter
    , auth : Maybe User
    , body : Maybe Value
    , method : String
    , decoder : Decoder data
    , path : List String
    }


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


send : Request data -> (Result Http.Error (Response data) -> msg) -> Cmd msg
send (Request config) onResponse =
    Http.request
        { method = config.method
        , headers =
            case config.auth of
                Nothing ->
                    []

                Just user ->
                    [ Http.header "Authorization" ("Token " ++ user.token) ]
        , url =
            Url.Builder.crossOrigin
                "https://conduit.productionready.io"
                ("api" :: config.path)
                config.queryParameters
        , body =
            case config.body of
                Nothing ->
                    Http.emptyBody

                Just body ->
                    Http.jsonBody body
        , expect =
            Http.expectJson onResponse
                (responseDecoder config.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }


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
