module Md5html (main) where
{-| md5html implemented in Elm.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Signal, Address)
import StyledHtml exposing (icon, button, div)
--import Json.Decode as Json
--import Debug exposing (..)

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
  | Clear

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    Clear -> { model | files = [] }
    AddOrUpdateFile file ->
      let
        doesExist = List.any (\f -> f.name == file.name) model.files
        files' = 
          if doesExist
          then List.map (\f -> if f.name == file.name
                               then { f | md5 = file.md5 }
                               else f
                        ) model.files
          else (file :: model.files)
      in { model | files = files' }

view : Address Action -> Model -> Html
view address model =
  let
    list = List.map formatRow model.files
    tableHeader =
      tr []
        [ th [] [ text "filename" ]
        , th [] [ text "MD5" ]
        ]
    isDLReady =
      List.isEmpty model.files ||
      (List.any (\f -> f.md5 == "...") model.files)
    buttons =
      Html.div [ class (if isDLReady then "hidden" else "") ]
        [ StyledHtml.button "mdl-button--colored"
          [ id "download"
          , download True
          , downloadAs "md5.csv"
          ]
          [ icon ["get_app"]
          , text " download"
          ]
        , text " "
        , StyledHtml.button ""
          [ onClick address Clear
          ]
          [ icon ["delete"]
          , text " clear"
          ]
        ]
    box = 
      [ i [] 
        [ icon ["add_circle"]
        , text "Drop files OR "
        , text "Click to open file select dialog."
        ]
      ]
    inputOrSpinner md5 elem =
      if md5 == "..."
      then StyledHtml.spinner
      else elem
    formatRow file =
      tr []
        [ td []
             [ text file.name ]
        , td []
             [ inputOrSpinner file.md5 <|
               input
               [ value file.md5
               , size 32
               , readonly True
               ] []
             ]
        ]
  in
    Html.div [ class "container" ]
      [ header
      , section
        []
        [ input
          [ id "ff"
          , class "hidden"
          , multiple True
          , type' "file"
          , on "input" targetValue (\_ -> Signal.message address NoOp)
          ] []
        , Html.div [ class "box", id "dropbox" ] box
        , buttons
        , table
          [ class <| "table " ++ (if List.isEmpty list then "hidden" else "") ]
          ( tableHeader :: list )
        ]
      , footer
      ]

header : Html
header =
  Html.div []
    [ h2 [] [text "Offline MD5 Calcurator WebApp."]
    ]

footer : Html
footer =
  Html.div []
    [ hr [] []
    , text "The server-less web application for calculating MD5 digest for the given files.  It uses:"
    , ul []
      [ li [] [ text "html5 (FILE API)" ]
      , li []
        [ a
          [ href "http://labs.cybozu.co.jp/blog/mitsunari/2007/07/24/js/md5.js" ]
          [ text "Cyboze Labs' MD5 library " ]
        , text "to accomplish the job."
        ]
      , li []
        [ a
          [ href "http://elm-lang.org/" ]
          [ text "Elm" ]
        ]
      ]
    , text "[note] Due to the FILE API limitation, it may not work for large files."
    , hr [] []
    , Html.div []
      [ text "Visit "
      , a
        [ href "http://github.com/tshm/md5html" ]
        [ icon ["link"]
        , text "source repository."
        ]
      ]
    ]

main : Signal Html
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

{-| ports
-}
port file : Signal { name: String, md5: String }

port md5 : Signal (List File)
port md5 = Signal.map .files model

