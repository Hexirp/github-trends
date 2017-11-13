{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude hiding (unlines, concat)

 import Data.ByteString.Lazy.Char8 (ByteString)
 import Data.Text (Text, unlines, concat, unpack)
 import Network.HTTP.Simple (httpLBS, getResponseBody)
 import Text.XML (Document)
 import Text.XML.Cursor
 import Text.HTML.DOM (parseLBS)

 main :: IO ()
 main = request >>= putStr . unpack . format . scrape . parseLBS

 request :: IO ByteString
 request = getResponseBody <$> httpLBS "https://github.com/trending/haskell"

 scrape :: Document -> [Text]
 scrape doc = fromDocument doc
  $// element "h3"
  >=> child
  >=> element "a"
  >=> attribute "href"

 format :: [Text] -> Text
 format = unlines . map f where
  f x = concat ["1. [", x, "](https://github.com", x, ")"]
