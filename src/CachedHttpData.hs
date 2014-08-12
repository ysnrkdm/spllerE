module CachedHttpData where
    import Text.Printf (printf)
    import System.IO
    import Network.HTTP
    import qualified Data.Text as Text
    import qualified Data.Digest.Pure.MD5 as MD5
    import qualified Data.ByteString.Lazy.Char8 as B8
    import qualified Data.Text.IO as TextIO
    import System.Environment
    import qualified Control.Exception as Ex

    hashedString :: String -> String
    hashedString str = show $ MD5.md5 $ B8.pack str

    writeAndReadFile :: FilePath -> String -> IO Text.Text
    writeAndReadFile filePath url = do
        printf "Loading file from %s...\n" url
        contents <- fetchUrl url
        printf "And writing to %s...\n" filePath
        TextIO.writeFile filePath contents
        TextIO.readFile filePath

    fetchUrl :: String -> IO Text.Text
    fetchUrl url = do
        eitherResponse <- (simpleHTTP . getRequest) url
        case eitherResponse of
            Left _ -> do
                hPutStrLn stderr $ "Error connecting to " ++ show url
                return $ Text.pack ""
            Right response ->
                return $ Text.pack (rspBody response)

    getUrl :: String -> IO Text.Text
    getUrl url = do
        let hashedName = hashedString url
        tmpdir <- getEnv "TMPDIR"
        let filePath = tmpdir ++ "/spllercache" ++ hashedName
        TextIO.readFile filePath `Ex.catch` (\e -> return (e::Ex.SomeException) >> writeAndReadFile filePath url)