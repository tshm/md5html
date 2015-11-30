module Md5html (main) where
{-| md5html implemented in Elm.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Signal, Address)
import Json.Decode as Json
import Debug exposing (..)

type alias Model =
  { files : List File
  }

type alias File =
  { name : String
  , md5 : String
  }

initModel : Model
initModel =
  { files = [] }

type Action
  = NoOp
  | AddOrUpdateFile File

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    AddOrUpdateFile file ->
      let
        doesExist = List.any (\f -> f.name == file.name) model.files
        files' = 
          if doesExist
          then List.map (\f -> if f.name == file.name then { f | md5 = file.md5 } else f ) model.files
          else (file :: model.files)
      in { model | files = files' }

view : Address Action -> Model -> Html
view address model =
  let
    title = h2 [] [text "title"]
    list = List.map formatRow model.files
    formatRow file =
      tr []
        [ td []
             [ text file.name ]
        , td []
             [ input
               [ value file.md5
               , size 32
               , readonly True
               ] []
             ]
        ]
  in
    section
      []
      [ title
      , input
        [ id "ff"
        , multiple True
        , type' "file"
        , on "input" targetValue (\_ -> Signal.message address NoOp)
        ] []
      , table [] list
      ]

main = Signal.map (view userActions.address) model

userActions : Signal.Mailbox Action
userActions =
  Signal.mailbox NoOp

actions : Signal Action
actions =
  Signal.merge userActions.signal (Signal.map AddOrUpdateFile file)

model : Signal Model
model =
  Signal.foldp update initModel actions

--onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address contentToValue =
  let
    aa str = 
      let 
          x = Debug.watch "x: " str
      in Signal.message address NoOp
    --aa str = Signal.message address (contentToValue <| Debug.watch "x:" str)
  in
    on "input" targetValue aa

{-| ports
-}
port file : Signal { name: String, md5: String }


