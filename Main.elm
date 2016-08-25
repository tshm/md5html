port module Md5html exposing (main)
{-| md5html implemented in Elm.
-}

import Html exposing (..)
import Navigation
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import String exposing (words)

main : Program Never
main = Navigation.program urlParser
  { init = init
  , view = view
  , update = update
  , urlUpdate = urlUpdate
  , subscriptions = subscriptions
  }

-- URL Handlers

toUrl : String -> String
toUrl algoname =
  "#/" ++ algoname

fromUrl : String -> Result String String
fromUrl url =
  let
    algoname = String.dropLeft 2 url
  in
    if List.member algoname algonames
    then Ok algoname
    else Err ""

urlParser : Navigation.Parser (Result String String)
urlParser =
  Navigation.makeParser (fromUrl << .hash)

-- MODEL

type alias Model =
  { files : List File
  , algoname : String
  }

init : Result String String -> (Model, Cmd Msg)
init result =
  urlUpdate result {algoname = "MD5", files = []}

type alias File =
  { name : String
  , hash : String
  }

algonames : List String
algonames = ["MD5","SHA1","SHA256","SHA512","RMD160"]


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
      { files = [], algoname = algoname } ! [ Navigation.newUrl (toUrl algoname)]

urlUpdate : Result String String -> Model -> (Model, Cmd Msg)
urlUpdate result model =
  case result of
    Ok algoname ->
      ({ model | algoname = algoname }, Cmd.none)
    Err _ ->
      (model, Navigation.modifyUrl (toUrl "MD5"))

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
    algoselector algoname =
      let
        menuitem name = option [value name, selected (algoname == name)] [text name]
      in Html.label
        [ class "algorithms" ]
        [ text "Hash algorithm: "
        , Html.select
            [ on "change" <| Json.map ChangeHashAlgo targetValue
            , disabled (not <| List.isEmpty model.files)
            ]
            (algonames |> List.map menuitem)
        ]
  in
    Html.div [ class "container" ]
      [ header
      , section []
          [ algoselector model.algoname
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
              [ i [ class "fa fa-folder-open"] []
              , text " Drop files OR Click to open file select dialog."
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
      [ li [] [ text "html5 (FILE API)" ]
      , li []
        [ a
          [ href "https://github.com/h2non/jshashes" ]
          [ text " jshashes library "
          , i [ class "fa fa-link"] []
          ]
        , span [] [ text " to accomplish the job." ]
        ]
      , li []
        [ a
          [ href "http://elm-lang.org/" ]
          [ text "Elm (functional programming language for browser)"
          , i [ class "fa fa-link"] []
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

