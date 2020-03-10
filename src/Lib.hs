module Lib
  ( startApp
  ) where

import           Network.Wai.Handler.Warp
import           Routes                   (API, server)
import           Servant
import           System.Exit
import           System.Posix.Env         (getEnvDefault)
import           Text.Read                (readEither)

startApp :: IO ()
startApp = do
  portEnv <- getEnvDefault "PORT" "8082"
  case readEither portEnv :: Either String Int of
    Left msg   -> die msg
    Right port -> run port app

app :: Application
app = serve api server

api :: Proxy API
api = Proxy
