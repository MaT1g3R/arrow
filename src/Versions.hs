{-# LANGUAGE TemplateHaskell #-}

module Versions where

import           Data.Aeson
import           Data.Aeson.TH
import           Data.Map.Strict (Map)
import qualified Data.Map.Strict as SMap
import           Text.Casing     (quietSnake)

data MatrixVersion =
  MatrixVersion
    { versions         :: [String]
    , unstableFeatures :: Map String Bool
    }
  deriving (Eq, Show)

deriveJSON defaultOptions {fieldLabelModifier = quietSnake} ''MatrixVersion

matrixClientVersion :: MatrixVersion
matrixClientVersion = MatrixVersion {versions = ["r0.6.0"], unstableFeatures = SMap.fromList []}
