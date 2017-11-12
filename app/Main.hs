{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude

 import Data.ByteString.Lazy.Char8 (ByteString)
 import Data.Text (Text)
 import Network.HTTP.Simple (httpLBS, getResponseBody)
 import Text.XML (Document)
 import Text.XML.Cursor
 import Text.HTML.DOM (parseLBS)

 main :: IO ()
 main = do
  res <- request
  print $ scrape $ parseLBS $ res

 request :: IO ByteString
 request = getResponseBody <$> httpLBS "https://github.com/trending/haskell"

 scrape :: Document -> [Text]
 scrape doc = fromDocument doc
  $// element "h3"
  >=> child
  >=> element "a"
  >=> attribute "href"
