port module Md5html exposing (main)
{-| md5html implemented in Elm.
-}

import Html exposing (..)
import Navigation
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import String exposing (words)

main : Program Never Model Msg
main = Navigation.program updateLocation
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

-- URL Handlers

toUrl : Algorithm -> String
toUrl algo =
  "#/" ++ (toString algo)

updateLocation : Navigation.Location -> Msg
updateLocation { hash } =
  ChangeHashAlgo <| parseAlgoname (String.dropLeft 2 hash)

-- MODEL

type alias Model =
  { files : List File
  , algo : Algorithm
  }

init : Navigation.Location -> (Model, Cmd Msg)
init location =
  update
    (updateLocation location)
    { algo = MD5, files = [] }

type alias File =
  { name : String
  , hash : String
  }

type Algorithm = MD5 | SHA1 | SHA256 | SHA512 | RMD160

algonames : List String
algonames = List.map toString [MD5, SHA1, SHA256, SHA512, RMD160]

parseAlgoname : String -> Algorithm
parseAlgoname name =
  case name of
    "SHA1" -> SHA1
    "SHA256" -> SHA256
    "SHA512" -> SHA512
    "RMD160" -> RMD160
    _ -> MD5

-- UPDATE

type Msg
  = NoOp
  | Clear
  | OpenFiles Json.Value  -- Elm cannot natively handle FileList object.
  | AddOrUpdateFile File
  | ChangeHashAlgo Algorithm

port openFiles : { files: Json.Value, algoname: String } -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  -- case msg of
  case Debug.log "update" msg of
    NoOp -> (model, Cmd.none)
    Clear -> ({ model | files = [] }, Cmd.none)
    OpenFiles filelistobj ->
      (model, openFiles { files = filelistobj, algoname = toString model.algo })
    AddOrUpdateFile file ->
      let
        (files, hit) = List.foldl updateHash ([], False) model.files
        updateHash f (fs, hit) =
          if f.name == file.name
          then (file :: fs, True)
          else (f :: fs, hit)
      in ({ model | files = if hit then files else file :: files}, Cmd.none)
    ChangeHashAlgo algo ->
      if algo == model.algo
      then ( model, Cmd.none )
      else { model | files = [], algo = algo } ! [ Navigation.newUrl (toUrl algo)]

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
      thead []
      [ tr []
          [ th [] [ text "Filename" ]
          , th [] [ text "Hash" ]
          ]
      ]
    isDLReady =
      List.isEmpty model.files ||
      (List.any (\f -> f.hash == "...") model.files)
    buttons =
      Html.div [ class (if isDLReady then "hidden" else "") ]
        [ button
          [ id "download"
          , class "pure-button"
          , download True
          , downloadAs "hash.csv"
          ]
          [ i [ class "fa fa-download"] []
          , text " download"
          ]
        , text " "
        , button
          [ onClick Clear
          , class "pure-button"
          ]
          [ i [ class "fa fa-trash"] []
          , text " clear"
          ]
        ]
    inputOrSpinner hash elem =
      if hash == "..."
      then (i [class "fa fa-refresh fa-spin"] [])
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
    algoselector algo =
      let
        menuitem name = option [value name, selected ((toString algo) == name)] [text name]
      in Html.label
        [ class "algorithms" ]
        [ text "Hash algorithm: "
        , Html.select
            [ on "change" <| Json.map (ChangeHashAlgo << parseAlgoname) targetValue
            , disabled (not <| List.isEmpty model.files)
            ]
            (algonames |> List.map menuitem)
        ]
  in
    Html.div [ class "container" ]
      [ header
      , section []
          [ algoselector model.algo
          , input
              [ id "fileopener"
              , class "hidden"
              , type_ "file"
              , multiple True
              , on "change" (Json.map OpenFiles targetFiles)
              ] []
          , Html.label [ for "fileopener" ]
            [ Html.div (
                [ class "box"
                , id "dropbox"
                ] ++ dndAttributes )
                [ i [ class "fa fa-folder-open"] []
                , text " Drop files OR Click to open file select dialog."
                ]
            ]
          , buttons
          , table
              [ class <|
                  "pure-table " ++ (if List.isEmpty filelist then "hidden" else "")
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
      [ li []
        [ a [ href "https://github.com/h2non/jshashes" ]
            [ i [ class "fa fa-link"]
              [ text " jshashes library "]
            ]
        , span [] [ text " to accomplish the job." ]
        ]
      , li [] [ text "html5 (FILE API)" ]
      , li []
        [ a [ href "http://elm-lang.org/" ]
            [ i [ class "fa fa-link"]
              [ text " Elm (functional programming language for browser)" ]
            ]
        ]
      ]
    , text "[note] Due to the FILE API limitation, it may not work for large files."
    , hr [] []
    , Html.div []
      [ text "Visit "
      , a
        [ href "http://github.com/tshm/md5html"]
        [ i [ class "fa fa-github"] []
        , text " source repository."
        ]
      ]
    ]

