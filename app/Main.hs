{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude

 import Network.HTTP.Simple (httpLBS, getResponseBody)
 import Text.HTML.DOM (parseLBS)

 main :: IO ()
 main = do
  res <- httpLBS "https://github.com/trending/haskell"
  print $ parseLBS $ getResponseBody res
