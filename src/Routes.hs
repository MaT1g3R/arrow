{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Routes where

import           Cors                      (CORSHeaders, addCorsHeaders,
                                            corsHeaders)
import           Network.HTTP.Types.Method (parseMethod)
import           Network.HTTP.Types.Status
import           Network.Wai
import           Servant
import           Versions

type API = Health :<|> ClientAPI :<|> Raw

type ClientAPI = ClientVersions

type Health = "health" :> Get '[ PlainText] NoContent

type MatrixAPI innerAPI = "_matrix" :> innerAPI

type MatrixClientAPI innerAPI = MatrixAPI ("client" :> innerAPI)

type ClientVersions = MatrixClientAPI ("versions" :> Get '[ JSON] (CORSHeaders MatrixVersion))

health :: Server Health
health = return NoContent

clientVersions :: Server ClientVersions
clientVersions = addCorsHeaders matrixClientVersion

clientAPI :: Server ClientAPI
clientAPI = clientVersions

server :: Server API
server = health :<|> clientAPI :<|> Tagged catchAll

catchAll :: Application
catchAll req respond =
  case parseMethod $ requestMethod req of
    Right OPTIONS -> respond $ responseLBS status204 corsHeaders ""
    _             -> respond $ responseLBS status404 [] ""
