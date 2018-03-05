module Messages exposing (..)

import Time exposing (Time)
import WebGL.Texture exposing (Error, Texture)
import Window exposing (Size)


type Msg
    = Animate Time
    | SpriteLoaded (Result Error Texture)
    | Resize Size
