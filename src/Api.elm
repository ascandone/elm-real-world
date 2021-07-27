module Api exposing
    ( ApiError
    , Response
    , ResponseErr(..)
    , send
    )

import Api.Internal exposing (Request(..))
import Http
import Json.Decode as Dec exposing (Decoder)
import Url.Builder


type alias ApiError =
    { body : List String
    }


type ResponseErr
    = ApiError_ ApiError
    | HttpError Http.Error


type alias Response data =
    Result ResponseErr data


errorDecoder : Decoder ApiError
errorDecoder =
    Dec.map ApiError
        (Dec.field "errors"
            (Dec.field "body" (Dec.list Dec.string))
        )


responseDecoder : Decoder data -> Decoder (Result ApiError data)
responseDecoder decoder =
    Dec.oneOf
        [ Dec.map Result.Err errorDecoder
        , Dec.map Result.Ok decoder
        ]


send : (Response data -> msg) -> Request data -> Cmd msg
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
            Http.expectJson
                (\result ->
                    onResponse <|
                        case result of
                            Ok (Ok data) ->
                                Ok data

                            Ok (Err apiErr) ->
                                Err <| ApiError_ apiErr

                            Err httpErr ->
                                Err <| HttpError httpErr
                )
                (responseDecoder config.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }
