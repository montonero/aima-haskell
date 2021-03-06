{-# LANGUAGE MultiParamTypeClasses #-} --{-# LANGUAGE FlexibleInstances #-}

module AI.Search.Example.NPuzzle where

--ToDo:Fix imports
import AI.Search.Core
import AI.Search.Informed

import qualified Data.Set as S
import Math.Algebra.Group.PermutationGroup
----------------------
-- N Puzzle Problem --
----------------------

-- |Data structure to define an N-Puzzle problem (the problem is defined by
--  the length of the board).
data NPuzzle s a = NP { sizeNP :: Int , initialNP :: [Int]} deriving (Show)

data NPMove = Ri | Do | Le | Up deriving (Show,Eq,Enum,Ord)

data NPState = NPS { boardNP :: Permutation Int , movesNP :: [NPMove] } deriving (Show,Eq,Ord)

inbound :: Int -> Int -> NPMove -> Bool
inbound n m Ri = (m `mod` n) /= n-1
inbound n m Do = m < n*(n-1) 
inbound n m Le = (m `mod` n) /= 0
inbound n m Up = m >= n

-- |N-Puzzle is an instance of Problem. 
instance Problem NPuzzle NPState NPMove where
    initial (NP n i) = NPS (fromList i) []    --fromList creates a permutation sorting i, might need the inverse

    successor (NP n _) (NPS b m) = [(x,NPS (move x) (x:m)) | x <- [Ri .. Up], valid x] where
        blnkpos = 0 .^ b
        valid m = inbound n blnkpos m
        move  m = b * p [[blnkpos,newpos m]] where
            newpos Ri = blnkpos+1
            newpos Do = blnkpos+n
            newpos Le = blnkpos-1
            newpos Up = blnkpos-n

    goalTest _ (NPS b _) = b == p [[]]

    heuristic (NP n _) (Node (NPS b m) _ _ _ _ _) = 
        fromIntegral . sum $ map manhattendist [1..n*n-1] where
            manhattendist i = abs (x i - xs i) + abs (y i - ys i) where
                x i = i `mod` n
                y i = i `div` n
                xs i = pos i `mod` n
                ys i = pos i `div` n
                pos i = i .^ b

--subproblems8 :: (Problem p s a) => p s a -> [s -> s]
--subproblems8 _ = [id]

--bfpdbgen

-- The depth 26 example 8Puzzle problem from page 103
puzzle8 :: NPuzzle NPState NPMove
puzzle8 = NP 3 [7,2,4,5,0,6,8,3,1]
--puzzle8 = NP 3 [1,2,0,3,4,5,6,7,8]
--puzzle8 = NP 3 [0,4,2,1,3,5,6,7,8]

--main = print . show $ aStarSearch' puzzle8

--very ugly code to map a permutation to it's lexicographic index 
--factorials from n to 0 as a list.
factorials :: Int -> [Integer]
factorials n = reverse $ scanl (*) 1 [1..(fromIntegral n)]

toIndex :: Int -> Permutation Int -> Integer
toIndex n p = fst $ foldl f (0, S.empty) $ zip (map (.^ p) [0..n-1]) (factorials (n-1)) where
    f (i,s) (j,k) = (\sn -> (i + k * fromIntegral (j - S.findIndex j sn), sn)) $ S.insert j s

fromIndex :: Int -> Integer -> Permutation Int
fromIndex n i = g $ foldl f (i,S.fromList [0..n-1],[]) (factorials (n-1)) where
    f (j,s,l) k = (\(d,m) -> (m, S.deleteAt (fromIntegral d) s, (S.elemAt (fromIntegral d) s):l)) $ divMod j k
    g (_,_,x)   = fromPairs $ zip [n-1,n-2..0] x
