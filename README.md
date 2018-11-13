# Comparing nested records

An adventure into the quirks of Template Haskell.

In Haskell, algebraic data types (ADTs) are used to define all common data structures from binary 
trees to linked lists. A special subset of ADTs, records, fills the role of a general composite data 
type similar to `struct`s in the C programming language. In detail, records are product types, 
or ADTs with a nullary type constructor and a singular data constructor that names the individual 
constructor arguments (record fields).

Similarly to `struct`s in C, Haskell records are often used to define application specific data structures 
such as configurations and message payloads. Comparison of two such records is an absolutely necessary
utility. While comparing two records of the same type for overall equality is easy, it is more complicated
to construct detailed account on the differences between the records on a field-to-field level. 
In practice, these records can consist of dozens of named fields and writing manual functions for
field-to-field comparison is impractical and - frankly - an atrocious waste of work hours towards
a fundamentally mundane task. Fortunately, even a modest understanding of Template Haskell enables
delegating this task to the compiler. 

The simple TH approach is sufficient as long as no field-by-field comparison is required on a separate 
record that is nested within the original record as a field. If nested field-by-field comparison is
desired, there must be some way for the compiler to distinguish between types that should be compared
traditionally and types that should be compared field-by-field.

This repository presents a solution to this problem. It was inspired by solution 3 to [advanced overlapping instances](https://wiki.haskell.org/GHC/AdvancedOverlap) on Haskell Wiki.

## Hands-on guide

Build the library with `stack build`. Run `stack ghci` to open ghci with the library loaded in. Then, evaluate the following expressions in ghci:

```
> let actualNested  = Nested { c = "c", d = "d" } :: Nested
> let deducedNested = Nested { c = "c", d = "X" } :: Nested

> let actual  = Test { a = "a", b = "b", nested = actualNested } :: Test
> let deduced = Test { a = "a", b = "X", nested = deducedNested } :: Test
```

The above expressions create two records, `actual` and `deduced`, that differ in the fields `b` and `d`. Field `d` is nested within a `Nested` type (field `nested` in `Test`).

To compare these nested records field by field, run the following expression in ghci:

```
> let comparison = compare actual deduced
```

It results in a `comparison :: TestCompared` which looks something like this:

```
Test { a = Verified "a"
     , b = Mismatch "b" "X"
     , nested = Nested { c = Verified "c"
                       , d = Mismatch "d" "X"}
     }
```

## Details 

To instruct the compiler which types must be considered 'container types' (with further fields nested inside them), [`src/Record/Comparable/Types.hs:33-36`](https://github.com/skyvier/nested-record-comparison/blob/b031d8f95ccd4b79f2336b8e37d29473cd37e749/src/Record/Comparable/Types.hs#L33-L36) defines a closed type family which specifies all nested structures:

```
type family (IsNested a) :: Bool where
   IsNested Test   = 'True
   IsNested Nested = 'True
   IsNested a      = 'False
```

Also, [`src/Record/Comparable/Lib.hs:17-18`](https://github.com/skyvier/nested-record-comparison/blob/b031d8f95ccd4b79f2336b8e37d29473cd37e749/src/Record/Comparable/Lib.hs#L17-L18) derives instances of `Comparable` for both `Test` and `Nested` data types using TH:

```
$(deriveComparable ''NestedF ''Nested ''NestedCompared)
$(deriveComparable ''TestF ''Test ''TestCompared)
```

The TH magic can be found in `src/Record/Comparable/TH.hs`. In retrospect, the same functionality could be achieved more reliably with plain old generics.
