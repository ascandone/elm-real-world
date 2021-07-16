module Api.Tags exposing (get)

import Api.Internal as Api exposing (Request)
import Json.Decode as Dec exposing (Decoder)


tagsDecoder : Decoder (List String)
tagsDecoder =
    Dec.list Dec.string


get : Request (List String)
get =
    Api.get tagsDecoder [ "tags" ]
