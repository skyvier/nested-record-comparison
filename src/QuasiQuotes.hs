module QuasiQuotes where

-- | Build type polymorphic records `TestF` and `NestedF`, a closed type
-- family `IsNested` and derive `Comparable'` for both records.

-- [comparable|
-- 
-- Test
--    first String
--    second String
--    nested Nested
-- 
-- Nested
--    inner String
--    param Int
-- 
-- |]


