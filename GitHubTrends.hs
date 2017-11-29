{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude hiding (concat)

 import Data.ByteString.Lazy.Char8 (ByteString)
 import Data.Text (Text, intercalate, append, pack, unpack)

 import Network.HTTP.Simple (httpLBS, getResponseBody)
 import Text.XML (Document)
 import Text.XML.Cursor (fromDocument, child, descendant, element, attribute, (>=>))
 import Text.HTML.DOM (parseLBS)

 main :: IO ()
 main = request >>= putStr . unpack . make . format . scrape . parse

 request :: IO ByteString
 request = getResponseBody <$> httpLBS "https://github.com/trending/haskell"

 parse :: ByteString -> Document
 parse = parseLBS

 -- | Scrape 'Document'.
 --
 -- Represented by XPath:
 --
 -- > //h3/a/@href
 scrape :: Document -> [Text]
 scrape = return . fromDocument
  >=> descendant
  >=> element "h3"
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

 -- | Sandwich one string between two strings.
 --
 -- >>> unpack $ sandwich "aaa" "bbb" "ccc"
 -- "aaacccbbb"
 sandwich :: Text -> Text -> Text -> Text
 sandwich a b c = a `append` c `append` b
