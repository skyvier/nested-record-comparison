{-# LANGUAGE TemplateHaskell, TypeSynonymInstances #-}
{-# LANGUAGE TypeFamilies, PolyKinds, FlexibleInstances, UndecidableInstances #-}
{-# LANGUAGE StandaloneDeriving, MultiParamTypeClasses #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Lib where

import ClassyPrelude hiding (compare)

import Data.Void

import Language.Haskell.TH

import Types
import TH

$(deriveComparable ''NestedF ''Nested ''NestedCompared)
$(deriveComparable ''TestF ''Test ''TestCompared)
