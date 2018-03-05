module View exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style, height, width)
import Model exposing (Model)
import Messages exposing (Msg)
import WebGL exposing (Texture, Shader, Mesh, Entity)
import WebGL.Texture as Texture
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)


type alias SpriteInfo =
    { x : Float
    , y : Float
    , w : Float
    , h : Float
    }


box : Mesh Vertex
box =
    WebGL.triangles
        [ ( Vertex (vec2 0 0), Vertex (vec2 1 1), Vertex (vec2 1 0) )
        , ( Vertex (vec2 0 0), Vertex (vec2 0 1), Vertex (vec2 1 1) )
        ]


type Sprite
    = Sprite String SpriteInfo


type alias Vertex =
    { position : Vec2 }


type alias Uniform =
    { offset : Vec3
    , texture : Texture
    , textureSize : Vec2
    , size : Vec2
    , frameSize : Vec2
    , textureOffset : Vec2
    }


type alias Varying =
    { texturePos : Vec2 }


type alias UniformTextured a =
    { a
        | texture : Texture
        , textureSize : Vec2
        , textureOffset : Vec2
        , frameSize : Vec2
    }


texturedFragmentShader : Shader {} (UniformTextured a) Varying
texturedFragmentShader =
    [glsl|
        precision mediump float;
        uniform sampler2D texture;
        uniform vec2 textureSize;
        uniform vec2 textureOffset;
        uniform vec2 frameSize;
        varying vec2 texturePos;
        void main () {
          vec2 pos = vec2(
            float(int(texturePos.x) - int(texturePos.x) / int(frameSize.x) * int(frameSize.x)),
            float(int(texturePos.y) - int(texturePos.y) / int(frameSize.y) * int(frameSize.y))
          );
          vec2 offset = (pos + textureOffset) / textureSize;
          gl_FragColor = texture2D(texture, offset);
          if (gl_FragColor.a == 0.0) discard;
        }
    |]


texturedVertexShader : Shader Vertex Uniform Varying
texturedVertexShader =
    [glsl|
        precision mediump float;
        attribute vec2 position;
        uniform vec2 size;
        uniform vec3 offset;
        varying vec2 texturePos;
        void main () {
            vec2 clipSpace = position * size + offset.xy - size/2.0;
            gl_Position = vec4(clipSpace.x, -clipSpace.y, offset.z, size.x/2.0);
            texturePos = position * size;
        }
    |]


view : Model -> Html Msg
view model =
    WebGL.toHtmlWith
        [ WebGL.depth 1
        , WebGL.stencil 0
        , WebGL.clearColor (22 / 255) (17 / 255) (22 / 255) 0
        ]
        [ width model.size.width
        , height model.size.height
        ]
        (renderGame model)



{-
   TODO: add matrix based approach to rendering
-}


renderGame : Model -> List Entity
renderGame model =
    let
        character =
            (Sprite "character" { x = 0, y = 0, w = 257, h = 259 })
    in
        (Maybe.map
            (\texture ->
                [ render character texture ( 0.0, 0.0, 0.0 ) ]
            )
            model.sprite
        )
            |> Maybe.withDefault []


render : Sprite -> Texture -> ( Float, Float, Float ) -> Entity
render (Sprite _ { x, y, w, h }) texture offset =
    WebGL.entity
        texturedVertexShader
        texturedFragmentShader
        box
        { offset = Vec3.fromTuple offset
        , texture = texture
        , size = vec2 w h
        , frameSize = vec2 w h
        , textureOffset = vec2 x y
        , textureSize =
            vec2
                (toFloat (Tuple.first (Texture.size texture)))
                (toFloat (Tuple.second (Texture.size texture)))
        }
