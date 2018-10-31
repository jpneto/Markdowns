ghc -c HaskellLib.hs
ghc -c StartEnd.c
ghc -shared -o HaskellLib.dll HaskellLib.o StartEnd.o
del *.o
del *.h
del *.hi
del *.a
pause