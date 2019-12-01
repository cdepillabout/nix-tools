module Stack2nix.Cache
  ( readCache
  , appendCache
  , cacheHits
  ) where

import Control.Exception (catch, SomeException(..))

readCache :: FilePath
          -> IO [( String -- url
                 , String -- rev
                 , String -- subdir
                 , String -- sha256
                 , String -- pkgname
                 , String -- nixexpr-path
                 )]
readCache f = fmap (toTuple . words) . lines <$> readFile f
  where toTuple [ url, rev, subdir, sha256, pkgname, exprPath ]
          = ( url, rev, subdir, sha256, pkgname, exprPath )

appendCache :: FilePath -> String -> String -> String -> String -> String -> String -> IO ()
appendCache f url rev subdir sha256 pkgname exprPath = do
  appendFile f $ unwords [ url, rev, subdir, sha256, pkgname, exprPath ]
  appendFile f "\n"

cacheHits :: FilePath -> String -> String -> String -> IO [ (String, String) ]
cacheHits f url rev subdir
  = do
       -- putStrLn $ "###################### in cacheHits..." <> show rev
       putStrLn $ "###################### in cacheHits..."
       rawCacheFile <- readFile f
       putStrLn $ "###################### in cacheHits, raw cache file: " <> rawCacheFile
       cache <- catch' (readCache f) (const (pure []))
       putStrLn $ "###################### in cacheHits, cache: " <> show cache
       let res = [ ( pkgname, exprPath )
              | ( url', rev', subdir', sha256, pkgname, exprPath ) <- cache
              , url == url'
              , rev == rev'
              , subdir == subdir' ]
       putStrLn $ "###################### in cacheHits, res: " <> show res
       return res
  where catch' :: IO a -> (SomeException -> IO a) -> IO a
        catch' = catch
