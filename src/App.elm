module App exposing (..)


pure : model -> ( model, Cmd msg, Maybe evt )
pure model =
    ( model, Cmd.none, Nothing )


withCmd : Cmd msg -> ( model, Cmd msg, Maybe evt ) -> ( model, Cmd msg, Maybe evt )
withCmd cmd ( model, _, evt ) =
    ( model, cmd, evt )


withEvt : evt -> ( model, Cmd msg, Maybe evt ) -> ( model, Cmd msg, Maybe evt )
withEvt evt ( model, cmd, _ ) =
    ( model, cmd, Just evt )


batchWith : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
batchWith cmd ( model, cmd1 ) =
    ( model, Cmd.batch [ cmd, cmd1 ] )
