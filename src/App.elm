module App exposing
    ( App
    , batchWith
    , getApplication
    , pure
    , withEff
    , withEvt
    )

import Browser exposing (Document, UrlRequest)
import Browser.Navigation
import Effect exposing (Effect)
import Url exposing (Url)


pure : model -> ( model, List (Effect msg), Maybe evt )
pure model =
    ( model, [], Nothing )


withEff : Effect msg -> ( model, List (Effect msg), Maybe evt ) -> ( model, List (Effect msg), Maybe evt )
withEff eff ( model, effs, evt ) =
    ( model, eff :: effs, evt )


withEvt : evt -> ( model, List (Effect msg), Maybe evt ) -> ( model, List (Effect msg), Maybe evt )
withEvt evt ( model, effs, _ ) =
    ( model, effs, Just evt )


batchWith : Effect msg -> ( model, List (Effect msg) ) -> ( model, List (Effect msg) )
batchWith effs ( model, effs1 ) =
    ( model, effs :: effs1 )


type alias App model =
    { key : Browser.Navigation.Key
    , model : model
    }


runEffects : Browser.Navigation.Key -> List (Effect msg) -> Cmd msg
runEffects key effs =
    Cmd.batch (List.map (Effect.run key) effs)


getApplication :
    { init : flags -> Url -> ( model, List (Effect msg) )
    , view : model -> Document msg
    , update : msg -> model -> ( model, List (Effect msg) )
    , subscriptions : model -> Sub msg
    , onUrlRequest : UrlRequest -> msg
    , onUrlChange : Url -> msg
    }
    ->
        { init : flags -> Url -> Browser.Navigation.Key -> ( App model, Cmd msg )
        , view : App model -> Document msg
        , update : msg -> App model -> ( App model, Cmd msg )
        , subscriptions : App model -> Sub msg
        , onUrlRequest : UrlRequest -> msg
        , onUrlChange : Url -> msg
        }
getApplication props =
    let
        init flags url key =
            let
                ( model, effs ) =
                    props.init flags url
            in
            ( App key model
            , runEffects key effs
            )

        update msg app =
            let
                ( model, effs ) =
                    props.update msg app.model
            in
            ( App app.key model
            , runEffects app.key effs
            )
    in
    { init = init
    , view = .model >> props.view
    , update = update
    , subscriptions = .model >> props.subscriptions
    , onUrlRequest = props.onUrlRequest
    , onUrlChange = props.onUrlChange
    }
