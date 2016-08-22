port module Md5html exposing (main)
{-| md5html implemented in Elm.
-}

import Html exposing (..)
import Http
import Task
import Navigation
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StyledHtml exposing (icon, button, div)
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
toUrl userid =
  "#/user/" ++ userid

urlParser : Navigation.Parser (Result String String)
urlParser =
  let
    fromUrl url =
      let
        userid = Debug.log "fromUrl called" <| String.dropLeft 7 url
      in
        Ok userid
  in Navigation.makeParser (fromUrl << .hash)

-- MODEL

type alias Model =
  { files : List File
  , algoname : String
  , user : String
  }

init : Result String String -> (Model, Cmd Msg)
init result =
  urlUpdate result {algoname = "MD5", files = [], user = ""}

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
  | FetchSucceed String
  | FetchFail Http.Error

port openFileDialog : Bool -> Cmd msg

port openFiles : { files: Json.Value, algoname: String } -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    x = Debug.log "Msg" msg
  in case msg of
    FetchFail _ -> (model, Cmd.none)
    FetchSucceed u -> ({ model | user = u }, Cmd.none)
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
    ChangeHashAlgo userid ->
      { model | files = [], algoname = userid } ! [ Navigation.newUrl (toUrl userid)]

urlUpdate : Result String String -> Model -> (Model, Cmd Msg)
urlUpdate result model =
  let
    x = Debug.log "urlUpdate called" result
  in case result of
    Ok algoname ->
      ({ model | algoname = algoname }, getUserInfo algoname)
    Err _ ->
      (model, Navigation.modifyUrl (toUrl "/user/3"))

-- api call

getUserInfo : String -> Cmd Msg
getUserInfo str =
  let
    decodeUserInfo = Json.at ["args", "userid"] Json.string
    url = "https://httpbin.org/get?userid=" ++ str
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeUserInfo url)


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
      , text "userid is "
      , text model.user
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
    [ h5 [] [text "test"]
    ]

footer : Html msg
footer =
  Html.div []
    [ hr [] []
    , ul []
      [ li [] [ a [href "#/user/3"] [text "user 3"] ]
      , li [] [ a [href "#/user/6"] [text "user 6"] ]
      ]
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

