{-# LANGUAGE TypeFamilies, PolyKinds, FlexibleInstances, UndecidableInstances #-}
{-# LANGUAGE StandaloneDeriving, MultiParamTypeClasses, DataKinds  #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Record.Comparable.Types where

import ClassyPrelude hiding (compare)

import Data.Void
import Data.Proxy

data ConfigState a = Verified a | Mismatch a a deriving (Show, Eq)

toChange :: Eq a => a -> a -> ConfigState a
toChange x y = if x == y then Verified x else Mismatch x y

type family Field (a :: l) b = k --  | a b -> k
type instance Field Void a = a
type instance Field ConfigState a = ConfigState a

type Test = TestF Void
type TestCompared = TestF ConfigState

data TestF a = Test { a :: Field a String, b :: Field a String, nested :: NestedF a }

type Nested = NestedF Void
type NestedCompared = NestedF ConfigState

data NestedF a = Nested { c :: Field a String, d :: Field a String }

compareField :: Eq a => a -> a -> ConfigState a
compareField = toChange

type family (IsNested a) :: Bool where
   IsNested Test   = 'True
   IsNested Nested = 'True
   IsNested a      = 'False

class Comparable a where
   compare :: a -> a -> Comparison (IsNested a) a

instance (IsNested a ~ flag, Comparable' flag a) => Comparable a where
   compare = compare' (Proxy :: Proxy flag)

class Comparable' (flag :: Bool) a where
   type Comparison flag a
   compare' :: Proxy flag -> a -> a -> Comparison flag a

instance Eq a => Comparable' 'False a where
   type Comparison 'False a = ConfigState a
   compare' _ = toChange

deriving instance Show Test
deriving instance Show TestCompared

deriving instance Show Nested
deriving instance Show NestedCompared
