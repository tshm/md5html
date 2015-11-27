module Md5html.Main where
{-| md5html implemented in Elm.
-}

import Html exposing (..)
import Signal exposing (Signal, Address)

type alias Model =
  { files : List File
  }

type alias File = String

initModel : Model
initModel =
  { files = ["test", "file"]
  }

type Action
  = NoOp

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

view : Address Action -> Model -> Html
view address model =
  div
    [
    ]
    <| List.map (\f -> text f) model.files


main = Signal.map (view actions.address) model

actions : Signal.Mailbox Action
actions =
  Signal.mailbox NoOp

model : Signal Model
model =
  Signal.foldp update initModel actions.signal

