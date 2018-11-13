{-# LANGUAGE TupleSections #-}
module Record.Comparable.TH where

import ClassyPrelude hiding (compare)

import Language.Haskell.TH

deriveComparable :: Name -> Name -> Name -> Q [Dec]
deriveComparable baseName inputName outputName = reify baseName >>= \case
   TyConI (DataD ctx parentName tyvars mkind cons derivs) -> do
         let instanceTypeFamily = generateTypeFamInstance inputName outputName
             instanceFunctions  = generateCompare baseName
         let declarations = instanceTypeFamily ++ instanceFunctions
         instanceDeclaration <- generateInstance ctx declarations
         return [instanceDeclaration]

      where
         generateInstance :: Cxt -> [DecQ] -> Q Dec
         generateInstance cxt decs = do
            let flagName     = mkName "True" 
                instanceName = mkName "Comparable'"
                instanceType = conT instanceName `appT` conT flagName `appT` conT inputName
            instanceD (return cxt) instanceType decs

generateCompare :: Name -> [DecQ]
generateCompare typeName = 
   let name = mkName "compare'" 
       actualName = mkName "compare" 
   in [funD name [cl actualName name]]

   where
         cl :: Name -> Name -> Q Clause
         cl actualName name = do
            xs       <- replicateM 1 $ newName "x"
            let expression = compareFields actualName typeName

            let patterns = fmap varP xs
            clause patterns (normalB expression) []

generateTypeFamInstance :: Name -> Name -> [DecQ]
generateTypeFamInstance typeName resultName = 
   let synEq = tySynEqn [conT flagName, conT typeName] $ conT resultName
   in [tySynInstD className synEq]
   where flagName  = mkName "True" 
         className = mkName "Comparison"

compareFields :: Name -> Name -> Q Exp
compareFields fname typename =
   reify typename >>= \case
      TyConI (DataD _ _ _ _ [RecC conNm fields] _) -> do
         a <- newName "a"
         b <- newName "b"

         lamE [varP a, varP b] $
            let go (fieldNm, _, fieldType) = 
                  let apply fn = (fieldNm,) <$> appsE [varE fn, appE (varE fieldNm) (varE a), appE (varE fieldNm) (varE b)]
                  in apply fname
            in recConE conNm (map go fields)
      _ -> error "invalid input"
