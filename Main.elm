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
  , algoname : String
  }

init : (Model, Cmd Msg)
init =
  (Model [] "MD5", Cmd.none)

type alias File =
  { name : String
  , hash : String
  }

algonames : List String
algonames = ["MD5","SHA1","SHA256","SHA512","RIPEMD","HMAC"]


-- UPDATE

type Msg
  = NoOp
  | Clear
  | OpenFileDialog
  | OpenFiles Json.Value  -- Elm cannot natively handle FileList object.
  | AddOrUpdateFile File
  | ChangeHashAlgo String

port openFileDialog : Bool -> Cmd msg

port openFiles : { files: Json.Value, algoname: String } -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)
    Clear -> ({ model | files = [] }, Cmd.none)
    OpenFileDialog -> (model, openFileDialog True)
    OpenFiles filelistobj ->
      let
        algoname = model.algoname
      in (model, openFiles { files = filelistobj, algoname = algoname })
    AddOrUpdateFile file ->
      let
        (files, hit) = List.foldl updateHash ([], False) model.files
        updateHash f (fs, hit) =
          if f.name == file.name
          then (file :: fs, True)
          else (f :: fs, hit)
      in ({ model | files = if hit then files else file :: files}, Cmd.none)
    ChangeHashAlgo algoname ->
      ({ files = [], algoname = algoname }, Cmd.none)


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
        [ th [] [ text "Filename" ]
        , th [] [ text "Hash" ]
        ]
    isDLReady =
      List.isEmpty model.files ||
      (List.any (\f -> f.hash == "...") model.files)
    buttons =
      Html.div [ class (if isDLReady then "hidden" else "") ]
        [ StyledHtml.button "mdl-button--colored"
          [ id "download"
          , download True
          , downloadAs "hash.csv"
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
    inputOrSpinner hash elem =
      if hash == "..."
      then StyledHtml.spinner
      else elem
    formatRow file =
      tr []
        [ td []
             [ text file.name ]
        , td []
             [ inputOrSpinner file.hash <|
               input
               [ value file.hash
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
      , section []
          [ label [ class "algorithms" ]
            [ text "Hash algorithm: "
            , select [ on "change" (Json.map ChangeHashAlgo targetValue) ]
              <| List.map
                (\n -> option [ selected (n == model.algoname) ] [ text n ])
                algonames
            ]
          , input
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
          [ href "https://github.com/h2non/jshashes" ]
          [ text " jshashes library" ]
        , span [] [ text " to accomplish the job." ]
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

