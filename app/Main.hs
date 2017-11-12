{-# LANGUAGE OverloadedStrings #-}

module Main where
 import Prelude

 import Network.HTTP.Simple
 import qualified Data.ByteString.Lazy.Char8 as L8

 main :: IO ()
 main = do
  res <- httpLBS "https://github.com/trending/haskell"
  L8.putStrLn $ getResponseBody res
