{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TupleSections #-}

module Main where
 import Prelude
 import Data.List ((\\))
 import Data.String (IsString(fromString))
 import Control.Monad ((>=>))
 import Control.Concurrent (threadDelay)
 import System.Environment (getArgs)
 import System.Exit (exitFailure)

 import Data.ByteString.Lazy.Char8 (ByteString)
 import Data.Text (Text, intercalate, append, pack)
 import Data.Text.Encoding (encodeUtf8)

 import Network.HTTP.Simple (httpLBS, getResponseBody, setRequestBodyURLEncoded)
 import Text.XML (Document)
 import Text.XML.Cursor (fromDocument, child, descendant, element, attribute)
 import Text.HTML.DOM (parseLBS)

 import Debug.Trace (traceShow)

 main :: IO ()
 main = getArgs >>= \case
  (token : []) -> run token
  _ -> exitFailure
 
 run :: String -> IO ()
 run token = make >>= post token

 make :: IO Text
 make = do
  scraped <- scrape . parseLBS <$> request
  threadDelay (10 * 1000 * 1000)
  scraped_week <- scrape . parseLBS <$> request2
  return $ format scraped scraped_week

 request :: IO ByteString
 request = fmap getResponseBody . httpLBS
  $ flip setRequestBodyURLEncoded "https://github.com/trending/haskell" [
   ("since", "daily")]

 request2 :: IO ByteString
 request2 = fmap getResponseBody . httpLBS
  $ flip setRequestBodyURLEncoded "https://github.com/trending/haskell" [
   ("since", "weekly")]

 post :: String -> Text -> IO ()
 post token text = fmap (const ()) . httpLBS
  $ flip setRequestBodyURLEncoded "https://slack.com/api/chat.postMessage" [
   ("token", fromString token),
   ("channel", "@hexirp"),
   ("as_user", "false"),
   ("username", "GitHub Trends"),
   ("text", "Today's GitHub trends!"),
   ("attachments", encodeUtf8 text)]

 scrape :: Document -> [Text]
 scrape = return . fromDocument
  >=> descendant
  >=> element "h3"
  >=> child
  >=> element "a"
  >=> attribute "href"

 format :: [Text] -> [Text] -> Text
 format daily weekly = traceShow (daily, weekly) $ sandwich "[{\"text\": \"" "\"}]"
  $ listing (daily \\ weekly) `append` "\\n\\n" `append` listing daily

 listing :: [Text] -> Text
 listing x = intercalate "\\n" $ zipWith append
   (pack <$> (++ ". ") <$> show <$> [1 :: Int .. ])
   (sandwich "<" ">" <$> append "https://github.com" <$> x)

 sandwich :: Text -> Text -> Text -> Text
 sandwich a b c = a `append` c `append` b
