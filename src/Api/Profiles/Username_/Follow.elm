module Api.Profiles.Username_.Follow exposing (delete, post)

import Api.Internal
import Data.Profile as Profile exposing (Profile)
import Data.User exposing (User)


post : User -> String -> Api.Internal.Request Profile
post user username =
    Api.Internal.post Profile.decoderSingle [ "profiles", username, "follow" ]
        |> Api.Internal.withAuth user


delete : User -> String -> Api.Internal.Request Profile
delete user username =
    Api.Internal.delete Profile.decoderSingle [ "profiles", username, "follow" ]
        |> Api.Internal.withAuth user
