#!/usr/bin/env stack
{- stack
 --resolver lts-9.13
 --install-ghc
 runghc
 --package bytestring
 --package text
 --package http-conduit
 --package xml-conduit
 --package html-conduit
-}

{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude hiding (unlines, concat)

 import Data.ByteString.Lazy.Char8 (ByteString)
 import Data.Text (Text, unlines, append, pack, unpack)
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
 format x = unlines
  $ zipWith append
   (pack <$> (++ ". ") <$> show <$> [1 :: Int .. ])
   (append "https://github.com" <$> x)
