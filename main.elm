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
  { files =
    [ { name = "test", md5 = "AAA" }
    , { name = "xxxx", md5 = "999" }
    ]
  }

type Action
  = NoOp
  | AddFile String String

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    AddFile name md5 -> { model | files = (File name md5) :: model.files }

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
               , readonly True
               ] []
             ]
        ]
  in
    section
      []
      [ title
      , input [ id "ff", type' "file", on "input" targetValue (\_ -> Signal.message address NoOp)] []
      , table [] list
      ]

main = Signal.map (view userActions.address) model

userActions : Signal.Mailbox Action
userActions =
  Signal.mailbox NoOp

actions : Signal Action
actions =
  Signal.merge userActions.signal addFileAction

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
port addFile : Signal (String, String)

addFileAction : Signal Action
addFileAction =
  Signal.map (\(x, y) -> AddFile x y) addFile

