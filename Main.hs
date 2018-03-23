{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}

module Main where
 import Prelude
 import Data.List ((\\))
 import Data.String (IsString(fromString))
 import Control.Monad ((>=>))
 import System.Environment (getArgs)
 import System.Exit (exitFailure)

 import Data.ByteString.Lazy.Char8 (ByteString)
 import Data.Text (Text, intercalate, append, pack, unpack)
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
 run token = make >>= putStrLn . unpack

 make :: IO Text
 make = do
  scraped_daily <- scrape . parseLBS <$> request_daily
  scraped_week <- scrape . parseLBS <$> request_weekly
  return $ format scraped_daily scraped_week

 request_daily :: IO ByteString
 request_daily = fmap getResponseBody
  $ httpLBS "https://github.com/trending/haskell?since=daily"

 request_weekly :: IO ByteString
 request_weekly = fmap getResponseBody
  $ httpLBS "https://github.com/trending/haskell?since=weekly"

 post :: String -> Text -> IO ()
 post token text = fmap (const ()) . httpLBS
  $ flip setRequestBodyURLEncoded "https://slack.com/api/chat.postMessage" [
   ("token", fromString token),
   ("channel", "C85U8HH0V"),
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
 format daily weekly = pack . read . unpack . sandwich "\"" "\""
  $ listing (daily \\ weekly) `append` "\\n\\n" `append` listing daily

 listing :: [Text] -> Text
 listing x = intercalate "\\n" $ zipWith append
  (pack <$> (++ ". ") <$> show <$> [1 :: Int .. ])
  (sandwich "<" ">" <$> append "https://github.com" <$> x)

 sandwich :: Text -> Text -> Text -> Text
 sandwich a b c = a `append` c `append` b
