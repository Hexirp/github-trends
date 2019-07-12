{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}

module Main where
 import Prelude
 import Data.String (IsString(fromString))
 import Control.Monad ((>=>))
 import System.Environment (getArgs)
 import System.Exit (exitFailure)

 import Data.ByteString.Lazy.Char8 (ByteString)
 import Data.Text (Text, intercalate, append, pack)
 import Data.Text.Encoding (encodeUtf8)

 import Network.HTTP.Simple (
  httpLBS,
  getResponseBody,
  setRequestBodyURLEncoded,
  addRequestHeader)
 import Text.XML (Document)
 import Text.XML.Cursor (fromDocument, child, descendant, element, attribute)
 import Text.HTML.DOM (parseLBS)

 main :: IO ()
 main = getArgs >>= \case
  (token : []) -> run token
  _ -> exitFailure
 
 run :: String -> IO ()
 run token = make >>= post token

 make :: IO Text
 make = do
  scraped <- scrape . parseLBS <$> request
  return $ format scraped

 request :: IO ByteString
 request = fmap getResponseBody . httpLBS
  $ addRequestHeader
   "User-Agent"
   "github-trends/0.2.0.0 (+https://github.com/Hexirp/github-trends)"
   "https://github.com/trending/haskell?since=weekly"

 post :: String -> Text -> IO ()
 post token text = fmap (const ()) . httpLBS
  $ flip setRequestBodyURLEncoded "https://slack.com/api/chat.postMessage" [
   ("token", fromString token),
   ("channel", "C85U8HH0V"),
   ("as_user", "false"),
   ("username", "GitHub Trends"),
   ("text", "This week's trend is this!"),
   ("attachments", encodeUtf8 text)]

 scrape :: Document -> [Text]
 scrape = return . fromDocument
  >=> descendant
  >=> element "h3"
  >=> child
  >=> element "a"
  >=> attribute "href"

 format :: [Text] -> Text
 format scraped = sandwich "[{\"text\": \"" "\"}]" $ listing scraped

 listing :: [Text] -> Text
 listing x = intercalate "\\n" $ zipWith append
  (pack <$> (++ ". ") <$> show <$> [1 :: Int .. ])
  (sandwich "<" ">" <$> append "https://github.com" <$> x)

 sandwich :: Text -> Text -> Text -> Text
 sandwich a b c = a `append` c `append` b
