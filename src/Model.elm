module Model exposing (Model, initial, update)

import Messages exposing (..)
import Time exposing (Time)
import WebGL exposing (Texture)
import Window exposing (Size)


type alias Model =
    { deltaTime : Time
    , sprite : Maybe Texture
    , size : Size
    }


initial : Model
initial =
    { deltaTime = 0
    , sprite = Nothing
    , size = Size 400 400
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate deltaTime ->
            ( { model | deltaTime = deltaTime }
            , Cmd.none
            )

        SpriteLoaded sprite ->
            ( { model | sprite = Result.toMaybe sprite }
            , Cmd.none
            )

        Resize size ->
            ( { model | size = size }
            , Cmd.none
            )
