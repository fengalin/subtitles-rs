module Subtitle
  (Model, startTime, endTime, init, Action, update, view, decode) where

import Effects
import Html exposing (div, text, p, input)
import Html.Attributes exposing (class, type', checked)
import Html.Events exposing (onDoubleClick)
import Json.Decode as Json exposing ((:=))
import Signal exposing (Address)

import Util exposing (listFromMaybes, checkbox)
import VideoPlayer

type alias Model =
  { period: (Float, Float)
  , foreignText: Maybe String
  , nativeText: Maybe String
  , selected: Bool
  }

startTime : Model -> Float
startTime model = fst model.period

endTime : Model -> Float
endTime model = snd model.period

init : (Float, Float) -> Maybe String -> Maybe String -> Model
init period foreignText nativeText =
  Model period foreignText nativeText False

type Action = Selected Bool

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Selected val -> ({ model | selected = val }, Effects.none)

view
  : Address VideoPlayer.Action -> Address Action -> Bool -> Model
  -> Html.Html
view playerAddress address current model =
  let
    onclick = onDoubleClick playerAddress (VideoPlayer.seek (startTime model))
    check = checkbox address model.selected Selected
    arrow =
      if current then
        Just (p [class "arrow"] [text "▶"])
      else
        Nothing
    foreignHtml =
      Maybe.map (\t -> p [class "foreign"] [text t]) model.foreignText
    nativeHtml =
      Maybe.map (\t -> p [class "native"] [text t]) model.nativeText
    children = 
      [check] ++ listFromMaybes [arrow, foreignHtml, nativeHtml]
  in div [class "subtitle", onclick] children

decode : Json.Decoder Model
decode =
  Json.object3 init
    ("period" := Json.tuple2 (,) Json.float Json.float)
    (Json.maybe ("foreign" := Json.string))
    (Json.maybe ("native" := Json.string))
