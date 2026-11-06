data Token = TNum Int | TPlus | TMinus | TMul | TDiv | TLParen | TRParen
    deriving (Show, Eq)

tokenize :: String -> [Token]
tokenize [] = []
tokenize (c:cs)
    | c `elem` " \t\n" = tokenize cs
    | c == '+' = TPlus : tokenize cs
    | c == '-' = TMinus : tokenize cs
    | c == '*' = TMul : tokenize cs
    | c == '/' = TDiv : tokenize cs
    | c == '(' = TLParen : tokenize cs
    | c == ')' = TRParen : tokenize cs
    | c >= '0' && c <= '9' =
        let (digits, rest) = span (`elem` ['0' .. '9']) (c:cs)
        in TNum (read digits) : tokenize rest
    | otherwise = error ("unexpected character: " ++ [c])

parseExpr :: [Token] -> (Int, [Token])
parseExpr = parseAdd

parseAdd :: [Token] -> (Int, [Token])
parseAdd ts =
    let (v1, rest) = parseMul ts
    in parseAddRest v1 rest

parseAddRest :: Int -> [Token] -> (Int, [Token])
parseAddRest v (TPlus:ts)  = let (v2, r) = parseMul ts in parseAddRest (v + v2) r
parseAddRest v (TMinus:ts) = let (v2, r) = parseMul ts in parseAddRest (v - v2) r
parseAddRest v ts          = (v, ts)

parseMul :: [Token] -> (Int, [Token])
parseMul ts =
    let (v1, rest) = parseAtom ts
    in parseMulRest v1 rest

parseMulRest :: Int -> [Token] -> (Int, [Token])
parseMulRest v (TMul:ts) = let (v2, r) = parseAtom ts in parseMulRest (v * v2) r
parseMulRest v (TDiv:ts) =
    let (v2, r) = parseAtom ts
    in if v2 == 0 then error "division by zero" else parseMulRest (v `div` v2) r
parseMulRest v ts = (v, ts)

parseAtom :: [Token] -> (Int, [Token])
parseAtom (TNum n:ts) = (n, ts)
parseAtom (TLParen:ts) =
    let (v, rest) = parseExpr ts
    in case rest of
        TRParen:r -> (v, r)
        _         -> error "expected closing paren"
parseAtom _ = error "expected number or paren"

evaluate :: String -> Int
evaluate s =
    let (v, rest) = parseExpr (tokenize s)
    in case rest of
        [] -> v
        _  -> error "trailing tokens after expression"

main :: IO ()
main = do
    let inputs = ["1+2*3", "(1+2)*3", "10-4/2", "2*(3+4)-5", "7"]
    mapM_ (\s -> putStrLn (s ++ " = " ++ show (evaluate s))) inputs