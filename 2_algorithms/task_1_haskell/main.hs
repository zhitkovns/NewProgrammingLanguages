match :: String -> String -> Bool
match [] [] = True
match [] _  = False
match ('?':ps) (_:ts) = match ps ts
match ('*':ps) ts = match ps ts || (not (null ts) && match ('*':ps) (tail ts))
match (p:ps) (t:ts) = p == t && match ps ts
match _ _ = False

main :: IO ()
main = do
    let testCases = [
            ("a*b?c", "a123bXc"),
            ("a*b?c", "a123bc"),
            ("hello*", "hello world"),
            ("*world", "hello world"),
            ("*", "anything"),
            ("h?llo", "hello"),
            ("h?llo", "hllo")
            ]
    mapM_ (\(pattern, str) -> putStrLn (show pattern ++ " matches " ++ show str ++ ": " ++ show (match pattern str))) testCases