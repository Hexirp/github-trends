{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude

 import Data.ByteString.Lazy.Char8 (ByteString)
 import Network.HTTP.Simple (httpLBS, getResponseBody, Response)
 import Text.HTML.DOM
 import Text.XML.Cursor

 main :: IO ()
 main = do
  res <- request
  print $ (fromDocument $ parseLBS $ getResponseBody res)
   $// element "h3"
   >=> child
   >=> element "a"
   >=> attribute "href"

 request :: IO (Response ByteString)
 request = httpLBS "https://github.com/trending/haskell"
