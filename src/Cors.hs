{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedStrings #-}

-- | https://matrix.org/docs/spec/client_server/r0.6.0#web-browser-clients
module Cors where

import           Data.ByteString
import           Data.Text
import           Network.HTTP.Types.Header (ResponseHeaders)
import           Servant

newtype ByteStringHeader =
  ByteStringHeader
    { a :: ByteString
    }

allowOrigin :: ByteStringHeader
allowOrigin = ByteStringHeader "*"

allowMethods :: ByteStringHeader
allowMethods = ByteStringHeader "GET, POST, PUT, DELETE, OPTIONS"

allowHeaders :: ByteStringHeader
allowHeaders = ByteStringHeader "Origin, X-Requested-With, Content-Type, Accept, Authorization"

toUrlPiece_ :: ByteStringHeader -> Text
toUrlPiece_ = toUrlPiece . show . a

toQueryParam_ :: ByteStringHeader -> Text
toQueryParam_ = toQueryParam . show . a

instance ToHttpApiData ByteStringHeader where
  toUrlPiece = toUrlPiece_
  toQueryParam = toQueryParam_

type AllowOriginHeader = Header "Access-Control-Allow-Origin" ByteStringHeader

type AllowMethodsHeader = Header "Access-Control-Allow-Methods" ByteStringHeader

type AllowHeadersHeader = Header "Access-Control-Allow-Headers" ByteStringHeader

type CORSHeaders = Headers '[ AllowOriginHeader, AllowMethodsHeader, AllowHeadersHeader]

addCorsHeaders ::
     ( Monad m
     , AddHeader "Access-Control-Allow-Origin" ByteStringHeader orig1 a
     , AddHeader "Access-Control-Allow-Methods" ByteStringHeader orig2 orig1
     , AddHeader "Access-Control-Allow-Headers" ByteStringHeader orig3 orig2
     )
  => orig3
  -> m a
addCorsHeaders x =
  return $ addHeader allowOrigin $ addHeader allowMethods $ addHeader allowHeaders x

corsHeaders :: ResponseHeaders
corsHeaders =
  [ ("Access-Control-Allow-Origin", a allowOrigin)
  , ("Access-Control-Allow-Methods", a allowMethods)
  , ("Access-Control-Allow-Headers", a allowHeaders)
  ]
