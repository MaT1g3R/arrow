{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module Routes where

import           Servant
import           Versions

type API = Health :<|> ClientVersions

type Health = "health" :> Get '[ PlainText] String

health :: Server Health
health = return ""

type ClientVersions = "_matrix" :> "client" :> "versions" :> Get '[ JSON] MatrixVersion

clientVersions :: Server ClientVersions
clientVersions = return matrixClientVersion

server :: Server API
server = health :<|> clientVersions
