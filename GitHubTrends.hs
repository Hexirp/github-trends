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

 import Network.HTTP.Simple (httpLBS, getResponseBody, setRequestBodyURLEncoded)
 import Text.XML (Document)
 import Text.XML.Cursor (fromDocument, child, descendant, element, attribute)
 import Text.HTML.DOM (parseLBS)

 main :: IO ()
 main = getArgs >>= \case
  (token : []) -> run token
  _ -> exitFailure
 
 run :: String -> IO ()
 run token = request >>= post token

 request :: IO ByteString
 request = fmap getResponseBody . httpLBS
  $ flip setRequestBodyURLEncoded "https://github.com/trending/haskell" [
   ("since", "weekly")]

 post :: String -> ByteString -> IO ()
 post token res = fmap (const ()) . httpLBS
  $ flip setRequestBodyURLEncoded "https://slack.com/api/chat.postMessage" [
   ("token", fromString token),
   ("channel", "C85U8HH0V"),
   ("as_user", "false"),
   ("username", "GitHub Trends"),
   ("text", "Today's GitHub trends!"),
   ("attachments", encodeUtf8 $ analyze res)]

 analyze :: ByteString -> Text
 analyze = format . scrape . parseLBS

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
