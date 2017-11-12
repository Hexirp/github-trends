{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude

 import Network.HTTP.Simple (httpLBS, getResponseBody)
 import Text.HTML.DOM (parseLBS)
 import Text.XML.Cursor

 main :: IO ()
 main = do
  res <- httpLBS "https://github.com/trending/haskell"
  print $ (fromDocument $ parseLBS $ getResponseBody res)
   $// element "h3"
   >=> child
   >=> element "a"
   >=> attribute "href"
