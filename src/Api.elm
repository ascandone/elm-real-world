module Api exposing
    ( Error
    , Response(..)
    , send
    )

import Api.Internal exposing (Request(..))
import Http
import Json.Decode as Dec exposing (Decoder)
import Json.Encode exposing (Value)
import Url.Builder


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


send : (Result Http.Error (Response data) -> msg) -> Request data -> Cmd msg
send onResponse (Request config) =
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
