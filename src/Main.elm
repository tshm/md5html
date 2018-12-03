port module Md5html exposing (main)

{-| md5html implemented in Elm.
-}

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import String exposing (words)
import Url
import Url.Builder


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = (\model -> { title = "title" , body = [ view model ] })
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChange
        , onUrlRequest = UrlRequest
        }


-- MODEL


type alias Model =
    { files : List File
    , algo : Algorithm
    , key : Nav.Key
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    { algo = MD5, files = [], key = key }
    |> update (UrlChange url)


type alias File =
    { name : String
    , hash : Maybe String
    }


type Algorithm
    = MD5
    | SHA1
    | SHA256
    | SHA512
    | RMD160


algonames : List String
algonames =
    List.map Debug.toString [ MD5, SHA1, SHA256, SHA512, RMD160 ]


parseAlgoname : String -> Algorithm
parseAlgoname name =
    case name of
        "SHA1" ->
            SHA1

        "SHA256" ->
            SHA256

        "SHA512" ->
            SHA512

        "RMD160" ->
            RMD160

        _ ->
            MD5



-- UPDATE


type Msg
    = NoOp
    | Clear
    | OpenFiles Json.Value
      -- Navigation handlers
    | UrlChange Url.Url
    | UrlRequest Browser.UrlRequest
      -- Elm cannot natively handle FileList object.
    | AddFile String
    | UpdateFile File
    | ChangeHashAlgo Algorithm


port openFiles : { files : Json.Value, algoname : String } -> Cmd msg


port clearFiles : () -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    -- case msg of
    case Debug.log "update" msg of
        NoOp ->
            ( model, Cmd.none )

        UrlRequest req ->
            let
                x = Debug.log "UrlRequest" req
            in
            ( model, Cmd.none )

        UrlChange url ->
            let
                algo = Maybe.withDefault "MD5" url.fragment |> parseAlgoname
            in
                ({ model | algo = algo }, Cmd.none)

        Clear ->
            ( { model | files = [] }, clearFiles () )

        OpenFiles filelistobj ->
            ( model, openFiles { files = filelistobj, algoname = Debug.toString model.algo } )

        AddFile filename ->
            let
                files =
                    if List.member filename (List.map .name model.files) then
                        model.files

                    else
                        File filename Nothing :: model.files
            in
            ( { model | files = files }, Cmd.none )

        UpdateFile file ->
            let
                files =
                    List.map updateHash model.files

                updateHash f =
                    if f.name == file.name then
                        { f | hash = file.hash }

                    else
                        f
            in
            ( { model | files = files }, Cmd.none )

        ChangeHashAlgo algo ->
            if algo == model.algo then
                ( model, Cmd.none )

            else
                ( { model | files = [], algo = algo }
                , Nav.pushUrl model.key (Url.Builder.relative ["#" ++ (Debug.toString algo)] [])
                )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ addfile AddFile
        , updatefile UpdateFile
        ]


port addfile : (String -> msg) -> Sub msg


port updatefile : (File -> msg) -> Sub msg



-- VIEW

view : Model -> Html Msg
view model =
    let
        filelist =
            List.map formatRow model.files

        tableHeader =
            thead []
                [ tr []
                    [ th [] [ text "Filename" ]
                    , th [] [ text "Hash" ]
                    ]
                ]

        isDLReady =
            model.files
                /= []
                && List.all (\{ hash } -> hash /= Nothing) model.files

        buttons =
            Html.div
                [ class
                    (if isDLReady then
                        ""

                     else
                        "hidden"
                    )
                ]
                [ button
                    [ onClick Clear
                    , class "pure-button"
                    ]
                    [ i [ class "fa fa-trash" ] []
                    , text " clear"
                    ]
                ]

        formatRow file =
            tr []
                [ td []
                    [ text file.name ]
                , td []
                    [ input
                        [ value (Maybe.withDefault "..." file.hash)
                        , size 32
                        , readonly True
                        ]
                        []
                    ]
                ]

        targetFiles : Json.Decoder Json.Value
        targetFiles =
            Json.at [ "target", "files" ] Json.value

        dndAttributes : List (Attribute Msg)
        dndAttributes =
            let
                eventnames =
                    words "dragenter dragstart dragend dragleave dragover drag"

                onWith name decoder =
                    custom
                        name
                        (Json.map2
                            (\msgDecoder off ->
                                { message = msgDecoder
                                , stopPropagation = off
                                , preventDefault = off
                                })
                            decoder (Json.succeed True))

                handle name =
                    onWith name (Json.succeed NoOp)

                ondropHandler =
                    onWith "drop" (Json.map OpenFiles droppedFiles)

                droppedFiles =
                    Json.at [ "dataTransfer", "files" ] Json.value
            in
            ondropHandler :: List.map handle eventnames

        algoselector algo =
            let
                menuitem name =
                    option [ value name, selected (Debug.toString algo == name) ] [ text name ]
            in
            Html.label
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
                ]
                []
            , Html.label [ for "fileopener" ]
                [ Html.div
                    ([ class "box"
                     , id "dropbox"
                     ]
                        ++ dndAttributes
                    )
                    [ i [ class "fa fa-folder-open" ] []
                    , text " Drop files OR Click to open file select dialog."
                    ]
                ]
            , buttons
            , table
                [ class <|
                    "pure-table "
                        ++ (if List.isEmpty filelist then
                                "hidden"

                            else
                                ""
                           )
                ]
                (tableHeader :: filelist)
            ]
        , footer
        ]


header : Html msg
header =
    Html.div []
        [ h2 [] [ text "Offline MD5 Calcurator WebApp." ]
        ]


footer : Html msg
footer =
    Html.div []
        [ hr [] []
        , text
            ("The server-less web application for calculating MD5 digest "
                ++ "for the given files.  It uses:"
            )
        , ul []
            [ li []
                [ a [ href "https://code.google.com/archive/p/crypto-js/" ]
                    [ i [ class "fa fa-link" ]
                        [ text " CryptoJS library " ]
                    ]
                , span [] [ text " to accomplish the hashing." ]
                ]
            , li [] [ text "html5 (FILE API)" ]
            , li []
                [ a [ href "http://elm-lang.org/" ]
                    [ i [ class "fa fa-link" ]
                        [ text " Elm (functional programming language for browser)" ]
                    ]
                ]
            , li []
                [ a [ href "https://workboxjs.org/" ]
                    [ i [ class "fa fa-link" ]
                        [ text " WorkBox (Libraries for Progressive Web Apps)" ]
                    ]
                ]
            ]
        , text "[note] Due to the FILE API limitation, it may not work for large files."
        , hr [] []
        , Html.div []
            [ text "Visit "
            , a
                [ href "http://github.com/tshm/md5html" ]
                [ i [ class "fa fa-github" ] []
                , text " source repository."
                ]
            ]
        ]
