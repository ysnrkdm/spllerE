module Paths_spllerE (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch


version :: Version
version = Version {versionBranch = [1,0], versionTags = []}
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/yoshinori/.cabal/bin"
libdir     = "/Users/yoshinori/.cabal/lib/x86_64-osx-ghc-7.6.3/spllerE-1.0"
datadir    = "/Users/yoshinori/.cabal/share/x86_64-osx-ghc-7.6.3/spllerE-1.0"
libexecdir = "/Users/yoshinori/.cabal/libexec"
sysconfdir = "/Users/yoshinori/.cabal/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "spllerE_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "spllerE_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "spllerE_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "spllerE_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "spllerE_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
