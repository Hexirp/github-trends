{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude hiding (concat)
 import Control.Monad ((>=>))

 import Data.ByteString.Lazy.Char8 (ByteString, unpack)
 import Data.ByteString.Builder (toLazyByteString)
 import Data.Text (Text, intercalate, append, pack)
 import Data.Text.Encoding (encodeUtf8Builder)

 import Network.HTTP.Simple (httpLBS, getResponseBody)
 import Text.XML (Document)
 import Text.XML.Cursor (fromDocument, child, descendant, element, attribute)
 import Text.HTML.DOM (parseLBS)

 main :: IO ()
 main = do
  res <- request
  putStr $ unpack $ analyze res

 request :: IO ByteString
 request = getResponseBody <$> httpLBS "https://github.com/trending/haskell"

 analyze :: ByteString -> ByteString
 analyze = toLazyByteString . encodeUtf8Builder . format . scrape . parseLBS

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

 sandwich :: Text -> Text -> Text -> Text
 sandwich a b c = a `append` c `append` b
