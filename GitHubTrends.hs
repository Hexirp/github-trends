{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude hiding (concat)

 import Data.ByteString.Lazy.Char8 (ByteString)
 import Data.Text (Text, intercalate, append, pack, unpack)

 import Network.HTTP.Simple (httpLBS, getResponseBody)
 import Text.XML (Document)
 import Text.XML.Cursor
 import Text.HTML.DOM (parseLBS)

 main :: IO ()
 main = request >>= putStr . unpack . make . format . scrape . parseLBS

 request :: IO ByteString
 request = getResponseBody <$> httpLBS "https://github.com/trending/haskell"

 scrape :: Document -> [Text]
 scrape doc = fromDocument doc
  $// element "h3"
  >=> child
  >=> element "a"
  >=> attribute "href"

 format :: [Text] -> Text
 format x = intercalate "\\n"
  $ zipWith append
   (pack <$> (++ ". ") <$> show <$> [1 :: Int .. ])
   (sandwich "<" ">" <$> append "https://github.com" <$> x)

 make :: Text -> Text
 make = sandwich "[{\"text\": \"" "\"}]"

 sandwich a b c = a `append` c `append` b
