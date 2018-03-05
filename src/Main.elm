module Main exposing (main)

import Html exposing (text)
import Model exposing (Model)
import Messages exposing (..)
import View


-- import AnimationFrame

import Sprite
import Window
import Task


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ -- AnimationFrame.diffs Animate
          Window.resizes Resize

        -- , Keyboard.downs (KeyChange True)
        -- , Keyboard.ups (KeyChange False)
        -- , PageVisibility.visibilityChanges VisibilityChange
        ]


init : ( Model, Cmd Msg )
init =
    ( Model.initial
    , Cmd.batch
        [ --     Sprite.loadTexture TextureLoaded
          Sprite.loadSprite SpriteLoaded

        --   , Font.load FontLoaded
        , Task.perform Resize Window.size
        ]
    )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = View.view
        , subscriptions = subscriptions
        , update = Model.update
        }
