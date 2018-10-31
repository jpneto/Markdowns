-- HaskellLib.hs
{-# LANGUAGE ForeignFunctionInterface #-}
module HaskellLib where

-- ref: http://neilmitchell.blogspot.pt/2011/10/calling-haskell-from-r.html
-- ref: https://wiki.haskell.org/Foreign_Function_Interface
import Foreign
import Foreign.C.Types

foreign export ccall sumRootsR :: Ptr Int -> Ptr Double -> Ptr Double -> IO ()
foreign export ccall factR :: Ptr CULLong  -> Ptr CULLong  -> IO ()

-------------------------------

sumRootsR :: Ptr Int -> Ptr Double -> Ptr Double -> IO ()
sumRootsR n xs result = 
  do
    n <- peek n
    xs <- peekArray n xs
    poke result $ sumRoots xs

sumRoots :: [Double] -> Double
sumRoots xs = sum (map sqrt xs)

--------------------------------

factR :: Ptr CULLong  -> Ptr CULLong  -> IO ()
factR n result = 
  do
    n <- peek n
    poke result $ fact n

fact :: (Integral a) => a -> a
fact n = product [1..n]