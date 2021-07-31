module Data.Async exposing (Async(..), fromResponse)

import Api exposing (ResponseErr)


type Async data
    = Pending
    | GotErr ResponseErr
    | GotData data


fromResponse : Api.Response data -> Async data
fromResponse res =
    case res of
        Ok data ->
            GotData data

        Err err ->
            GotErr err
