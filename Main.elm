port module Md5html exposing (main)
{-| md5html implemented in Elm.
-}

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StyledHtml exposing (icon, button, div)
import Json.Decode as Json
import String exposing (words)
--import Debug exposing (..)

main : Program Never
main = Html.program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }


-- MODEL

type alias Model =
  { files : List File
  }

init : (Model, Cmd Msg)
init =
  (Model [], Cmd.none)

type alias File =
  { name : String
  , md5 : String
  }


-- UPDATE

type Msg
  = NoOp
  | Clear
  | OpenFileDialog
  | OpenFiles Json.Value   -- Elm cannot natively handle FileList object.
  | AddOrUpdateFile File

port openFileDialog : Bool -> Cmd msg

port openFiles : Json.Value -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)
    Clear -> ({ model | files = [] }, Cmd.none)
    OpenFileDialog -> (model, openFileDialog True)
    OpenFiles filelistobj -> (model, openFiles filelistobj)
    AddOrUpdateFile file ->
      let
        (files, hit) = List.foldl updateMd5 ([], False) model.files
        updateMd5 f (fs, hit) =
          if f.name == file.name
          then (file :: fs, True)
          else (f :: fs, hit)
      in ({ model | files = if hit then files else file :: files}, Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  file AddOrUpdateFile

port file : (File -> msg) -> Sub msg


-- VIEW

view : Model -> Html Msg
view model =
  let
    filelist = List.map formatRow model.files
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
          [ onClick Clear
          ]
          [ icon ["delete"]
          , text " clear"
          ]
        ]
    box = 
      [ i [] [ icon ["add_circle"] ]
      , text "Drop files OR "
      , text "Click to open file select dialog."
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
    targetFiles : Json.Decoder Json.Value
    targetFiles =
      Json.at ["target", "files"] Json.value
    dndAttributes : List (Attribute Msg)
    dndAttributes = 
      let
        eventnames = words "dragenter dragstart dragend dragleave dragover drag"
        disableBubble = Options True True
        handle name = onWithOptions name disableBubble (Json.succeed NoOp)
        ondropHandler = onWithOptions "drop" disableBubble
          (Json.map OpenFiles droppedFiles)
        droppedFiles =
          Json.at ["dataTransfer", "files"] Json.value
      in ondropHandler :: (List.map handle eventnames)
  in
    Html.div [ class "container" ]
      [ header
      , section
          []
          [ input
              [ id "fileopener"
              , class "hidden"
              , type' "file"
              , multiple True
              , on "change" (Json.map OpenFiles targetFiles)
              ] []
          , Html.div (
              [ class "box"
              , id "dropbox"
              , on "click" (Json.succeed OpenFileDialog)
              ] ++ dndAttributes )
              box
          , buttons
          , table
              [ class <|
                  "table " ++ (if List.isEmpty filelist then "hidden" else "")
              ]
              ( tableHeader :: filelist )
          ]
      , footer
      ]

header : Html msg
header =
  Html.div []
    [ h2 [] [text "Offline MD5 Calcurator WebApp."]
    ]

footer : Html msg
footer =
  Html.div []
    [ hr [] []
    , text ("The server-less web application for calculating MD5 digest "
           ++ "for the given files.  It uses:")
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

