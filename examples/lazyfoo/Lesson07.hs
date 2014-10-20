{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
module Lazyfoo.Lesson07 where

import Control.Applicative
import Control.Concurrent (threadDelay)
import Control.Monad
import Linear
import Linear.Affine (Point(P))
import qualified SDL

(screenWidth, screenHeight) = (640, 480)

loadSurface :: FilePath -> SDL.Surface -> IO SDL.Surface
loadSurface path screenSurface = do
  loadedSurface <- SDL.loadBMP path
  desiredFormat <- SDL.surfaceFormat screenSurface
  SDL.convertSurface loadedSurface desiredFormat <* SDL.freeSurface loadedSurface

main :: IO ()
main = do
  SDL.init [SDL.InitVideo]

  hintSet <- SDL.setHint SDL.HintRenderScaleQuality SDL.ScaleLinear
  unless hintSet $
    putStrLn "Warning: Linear texture filtering not enabled!"

  window <-
    SDL.createWindow
      "SDL Tutorial"
      SDL.defaultWindow {SDL.windowSize = V2 screenWidth screenHeight}
  SDL.showWindow window

  renderer <-
    SDL.createRenderer
      window
      (-1)
      (SDL.RendererConfig
         { SDL.rendererAccelerated = True
         , SDL.rendererSoftware = False
         , SDL.rendererTargetTexture = False
         , SDL.rendererPresentVSync = False
         })

  SDL.setRenderDrawColor renderer (V4 maxBound maxBound maxBound maxBound)

  xOutSurface <- SDL.loadBMP "examples/lazyfoo/texture.bmp"
  texture <- SDL.createTextureFromSurface renderer xOutSurface
  SDL.freeSurface xOutSurface

  let loop = do
        let collectEvents = do
              e <- SDL.pollEvent
              case e of
                Nothing -> return []
                Just e' -> (e' :) <$> collectEvents
        events <- collectEvents

        let quit =
              any (\case SDL.QuitEvent -> True
                         _ -> False) $
              map SDL.eventPayload events

        SDL.renderClear renderer
        SDL.renderCopy renderer texture Nothing Nothing
        SDL.renderPresent renderer

        unless quit loop

  loop

  SDL.destroyRenderer renderer
  SDL.destroyWindow window
  SDL.quit
