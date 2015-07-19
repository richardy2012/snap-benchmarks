{-# LANGUAGE BangPatterns #-}

module Main where

import           System.Environment
import           Blaze.ByteString.Builder
import           Blaze.ByteString.Builder.Char8
import           Snap.Http.Server
import           Snap.Http.Server.Config
import           Snap.Core


tdOp, tdCl, trOp, trCl :: Builder
tdOp   = fromByteString "<td>"
tdCl   = fromByteString "</td>"
trOp   = fromByteString "<tr>"
trCl   = fromByteString "</tr>\n"


tableRow :: Int -> Builder
tableRow = go mempty
  where
    col !x = mconcat [ tdOp, fromShow x, tdCl ]

    go !bldr !x | x <= 50 = let b' = bldr `mappend` col x
                            in go b' (x+1)
                | otherwise = bldr


tableBody :: Int -> Builder
tableBody = go mempty
  where
    row !x = mconcat [ trOp
                     , tdOp
                     , fromShow x
                     , tdCl
                     , tableRow 1
                     , trCl ]

    go !bldr !x | x <= 1000 = let b' = bldr `mappend` row x
                              in go b' (x+1)
                | otherwise = bldr


tableServer :: Snap ()
tableServer = do
    writeBuilder $ mconcat [ fromByteString "<html><body><table>\n"
                           , tableBody 1
                           , fromByteString "</table></body></html>" ]


main :: IO ()
main = do
    args <- getArgs
    let port = case args of
                   []  -> 3000
                   p:_ -> read p
    httpServe (setBind "0.0.0.0" . setPort port $ defaultConfig) tableServer
