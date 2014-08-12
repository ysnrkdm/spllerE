module SpellCorrector where
    import qualified Data.Text as Text
    import Data.Text ()
    import qualified Data.List as List
    import qualified Data.Map as Map
    import qualified Data.Ord as Ord

    wordsFromText :: Text.Text -> [Text.Text]
    wordsFromText textStr = Text.split (`elem` " ,\"\'\r\n!@#$%^&*-_=+()") (Text.toLower textStr)

    train :: [Text.Text] -> Map.Map Text.Text Int
    train =
        List.foldl' (\map_a element -> Map.insertWithKey (\_ v y -> v + y) element 1 map_a) Map.empty

    substr :: Text.Text -> Int -> Int -> Text.Text
    substr s i j = Text.take (j - i) $ Text.drop i s

    edits1 :: Text.Text -> [Text.Text]
    edits1 word =
        let
            l = Text.length word
            alphabet = "abcdefghijklmnopqrstuvwxyz"
        in
        [ substr word 0 i `Text.append` substr word (i + 1) l | i <- [0..l-1] ] ++
            [ substr word 0 i `Text.snoc` (word `Text.index` (i+1)) `Text.snoc` (word `Text.index` i) `Text.append` substr word (i + 2) l | i <- [0..l-2] ] ++
            [ substr word 0 i `Text.snoc` (alphabet !! c) `Text.append` substr word (i + 1) l | c <- [0..25], i <- [0..l-1] ] ++
            [ substr word 0 i `Text.snoc` (alphabet !! c) `Text.append` substr word i l | c <- [0..25], i <- [0..l-1] ]

    edits2 :: Text.Text -> [Text.Text]
    edits2 word =
        [e2 | e1 <- edits1 word, e2 <- edits1 e1]

    known :: [Text.Text] -> Map.Map Text.Text Int -> [Text.Text]
    known wordList knownWords = List.foldl' (\z x -> if x `Map.member` knownWords then x:z else z) [] wordList

    knownEdits2 :: Text.Text -> Map.Map Text.Text Int -> [Text.Text]
    knownEdits2 word = known (edits2 word)

    orSet :: [a] -> [a] -> [a]
    orSet a b = if not (null a) then a else b

    correct :: Text.Text -> Map.Map Text.Text Int -> ((Text.Text, Int), [(Text.Text, Int)])
    correct word knownWords =
        let
            candidate =
                known [word] knownWords `orSet`
                known (edits1 word) knownWords `orSet`
                knownEdits2 word knownWords `orSet`
                [word]
        in
            let
                candidatePacked = List.sortBy (flip $ Ord.comparing snd) (map (\x -> (x, Map.findWithDefault 0 x knownWords)) candidate)
            in
                (List.head candidatePacked, candidatePacked)
