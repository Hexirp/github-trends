{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TupleSections #-}

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
 run token = make >>= post token

 make :: IO Text
 make = do
  scraped <- scrape . parseLBS <$> request
  state <- return "" -- readFile "hoge"
  (formatted, state') <- return $ format scraped state
  return $ const () state' -- writeFile "hoge" state'
  return formatted

 request :: IO ByteString
 request = fmap getResponseBody . httpLBS
  $ flip setRequestBodyURLEncoded "https://github.com/trending/haskell" [
   ("since", "weekly")]

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

 format :: [Text] -> String -> (Text, String)
 format x s = (, s) . sandwich "[{\"text\": \"" "\"}]" . intercalate "\\n"
  $ zipWith append
   (pack <$> (++ ". ") <$> show <$> [1 :: Int .. ])
   (sandwich "<" ">" <$> append "https://github.com" <$> x)

 sandwich :: Text -> Text -> Text -> Text
 sandwich a b c = a `append` c `append` b
