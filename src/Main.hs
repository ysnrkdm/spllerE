{-# LANGUAGE OverloadedStrings #-}

module Main where
    import Text.Printf (printf)
    import System.Environment (getArgs)
    import qualified Data.Text as Text
    import Data.Text ()
    import qualified Data.List as List
    import qualified CachedHttpData as CHD
    import qualified SpellCorrector as SC
    import Control.Monad

    main :: IO ()
    main = do
        word:url:_ <- liftM (++ ["http://norvig.com/big.txt"]) getArgs
        respStr <- CHD.getUrl url
        let (corrected,candidates) = SC.correct (Text.pack word) $ SC.train $ SC.wordsFromText respStr
        printf "Corrected : "
        print corrected
        printf "Candidates : "
        print $ List.take 5 candidates
        printf "...\n"

