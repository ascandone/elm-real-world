module Api exposing
    ( ApiError
    , Response
    , ResponseErr(..)
    , apiBase
    , logError
    , logIfError
    , send
    )

import Api.Internal exposing (Request(..))
import Effect exposing (Effect)
import Http
import Json.Decode as Dec exposing (Decoder)
import Url.Builder


apiBase : String
apiBase =
    "https://conduit.productionready.io"


type alias ApiError =
    { body : List String
    }


type ResponseErr
    = ApiError_ ApiError
    | HttpError Http.Error
    | DecodingError Dec.Error



-- TODO


errToString : ResponseErr -> String
errToString _ =
    "TODO"


logError : ResponseErr -> Effect msg
logError =
    Effect.PortLogError << errToString


type alias Response data =
    Result ResponseErr data


logIfError : Response data -> Effect msg
logIfError res =
    case res of
        Ok _ ->
            Effect.Noop

        Err err ->
            logError err


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


handleResponse : Decoder data -> Result Http.Error String -> Result ResponseErr data
handleResponse decoder res =
    res
        |> Result.mapError HttpError
        |> Result.map (Dec.decodeString (responseDecoder decoder))
        |> Result.andThen (Result.mapError DecodingError)
        |> Result.andThen (Result.mapError ApiError_)


send : (Response data -> msg) -> Request data -> Effect msg
send onResponse (Request config) =
    Effect.HttpRequest
        { method = config.method
        , headers =
            case config.auth of
                Nothing ->
                    []

                Just user ->
                    [ Http.header "Authorization" ("Token " ++ user.token) ]
        , url =
            Url.Builder.crossOrigin
                apiBase
                ("api" :: config.path)
                config.queryParameters
        , body =
            case config.body of
                Nothing ->
                    Http.emptyBody

                Just body ->
                    Http.jsonBody body
        , onResult = onResponse << handleResponse config.decoder
        }
