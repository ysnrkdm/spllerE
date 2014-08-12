module Main where
    import Test.HUnit
    import Test.Framework
    import Test.Framework.Providers.HUnit
    import qualified Control.Exception as Ex
    import qualified Data.Text as Text
    import qualified Data.Text.IO as TextIO
    import qualified Data.List as List
    import qualified Data.Map as Map
    import Control.Monad
    import qualified CachedHttpData as CHD
    import qualified SpellCorrector as SC


    corpusFilePath :: String
    corpusFilePath = "/Users/yoshinori/Downloads/0643/0643"

    dictUrl :: String
    dictUrl = "http://norvig.com/big.txt"

    main :: IO ()
    main = do
        corpus <- getCorpus "FAWTHROP1DAT.643"
        print $ List.take 5 corpus
        respStr <- CHD.getUrl dictUrl
        let trained = SC.train $ SC.wordsFromText respStr
        print $ List.take 5 $ Map.toList trained
        defaultMain $ hUnitTestToTests $ TestList
            [
                TestLabel "hoge" $ TestCase assertOne,
                TestLabel "spellTest1" $ TestCase (spellTestOne corpus trained)
            ]

    assertOne = do
        10 @=? sum [1,2,3,4]
        24 @=? product [1,2,3,4]
        "hoge" @=? "HOGE"

    loadFile :: String -> String -> IO Text.Text
    loadFile fileName "" = loadFile fileName corpusFilePath
    loadFile fileName dir = do
        let filePath = dir ++ "/" ++ fileName
        TextIO.readFile filePath

    parseLine :: Text.Text -> [Text.Text]
    parseLine textStr = Text.split (`elem` ",\n") (Text.toLower textStr)

    parsePair :: Text.Text -> [Text.Text]
    parsePair pairStr = Text.split (`elem` " ") (Text.toLower pairStr)

    parsePairs :: [Text.Text] -> [(Text.Text, Text.Text)]
    parsePairs list = List.map (\x -> (x!!0,x!!1)) (List.map (List.filter (\x -> Text.length x > 0)) (List.map parsePair list))

    getCorpus :: String -> IO [(Text.Text, Text.Text)]
    getCorpus fileName = liftM (parsePairs . parseLine) $ loadFile fileName ""

    spellTestOne corpus trained = do
        (fst (corpus!!2)) @=? (fst (fst (SC.correct (snd (corpus!!2)) trained)))