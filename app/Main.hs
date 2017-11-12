{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude

 import qualified Data.ByteString.Lazy.Char8 as L8
 import Network.HTTP.Simple
 import Text.HTML.DOM

 main :: IO ()
 main = do
  res <- httpLBS "https://github.com/trending/haskell"
  print $ parseLBS $ getResponseBody res
