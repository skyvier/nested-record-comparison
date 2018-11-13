{-# LANGUAGE TemplateHaskell, TypeSynonymInstances #-}
{-# LANGUAGE TypeFamilies, PolyKinds, FlexibleInstances, UndecidableInstances #-}
{-# LANGUAGE StandaloneDeriving, MultiParamTypeClasses #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Record.Comparable.Lib where

import ClassyPrelude hiding (compare)

import Data.Void

import Language.Haskell.TH

import Record.Comparable.Types
import Record.Comparable.TH

$(deriveComparable ''NestedF ''Nested ''NestedCompared)
$(deriveComparable ''TestF ''Test ''TestCompared)
