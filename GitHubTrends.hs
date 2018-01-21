{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude hiding (concat)
 import Data.String (IsString(fromString))
 import Control.Monad ((>=>))
 import System.Environment (getArgs)
 import System.Exit (exitFailure)

 import Data.ByteString.Lazy.Char8 (ByteString, fromStrict, toStrict)
 import Data.Text (Text, intercalate, append, pack)
 import Data.Text.Encoding (encodeUtf8)

 import Network.HTTP.Simple (httpLBS, getResponseBody, setRequestBodyURLEncoded)
 import Text.XML (Document)
 import Text.XML.Cursor (fromDocument, child, descendant, element, attribute)
 import Text.HTML.DOM (parseLBS)

 main :: IO ()
 main = do
  res <- request
  args <- getArgs
  case args of
   [] -> exitFailure
   (token : _) -> fmap (const ()) . httpLBS $
    flip setRequestBodyURLEncoded "https://slack.com/api/chat.postMessage" [
     ("token", fromString token),
     ("channel", "@hexirp"),
     ("as_user", "false"),
     ("username", "GitHub Trends"),
     ("text", "Today's GitHub trends!"),
     ("attachments", toStrict $ analyze res)]

 request :: IO ByteString
 request = getResponseBody <$> httpLBS "https://github.com/trending/haskell"

 analyze :: ByteString -> ByteString
 analyze = fromStrict . encodeUtf8 . format . scrape . parseLBS

 scrape :: Document -> [Text]
 scrape = return . fromDocument
  >=> descendant
  >=> element "h3"
  >=> child
  >=> element "a"
  >=> attribute "href"

 format :: [Text] -> Text
 format x = sandwich "[{\"text\": \"" "\"}]" . intercalate "\\n"
  $ zipWith append
   (pack <$> (++ ". ") <$> show <$> [1 :: Int .. ])
   (sandwich "<" ">" <$> append "https://github.com" <$> x)

 sandwich :: Text -> Text -> Text -> Text
 sandwich a b c = a `append` c `append` b
