fun listToSexp (lst : int list) : string =
    case lst of
        [] => "()"
      | _ => "(" ^ String.concatWith " " (List.map Int.toString lst) ^ ")"

fun sexpToList (s : string) : int list =
    let
        val trimmed = s
        val len = size trimmed
        fun isSpace c = c = #" " orelse c = #"\t"
    in
        if len < 2
           orelse String.sub (trimmed, 0) <> #"("
           orelse String.sub (trimmed, len - 1) <> #")"
        then
            raise Fail "expected sexp of form ( ... )"
        else
            let
                val inner = String.substring (trimmed, 1, len - 2)
                val tokens = String.tokens isSpace inner
            in
                List.map
                    (fn t =>
                        case Int.fromString t of
                            SOME n => n
                          | NONE => raise Fail ("not a number: " ^ t))
                    tokens
            end
    end

fun sum (lst : int list) : int =
    List.foldl (op +) 0 lst

fun main () =
    let
        val input = [1, 2, 3, 4, 5]
        val encoded = listToSexp input
        val _ = print ("input list: [1,2,3,4,5]\n")
        val _ = print ("encoded: " ^ encoded ^ "\n")
        val decoded = sexpToList encoded
        val _ = print ("decoded: [" ^ String.concatWith "," (List.map Int.toString decoded) ^ "]\n")
        val _ = print ("decoded sum: " ^ Int.toString (sum decoded) ^ "\n")
        val empty = listToSexp []
        val _ = print ("empty encoded: " ^ empty ^ "\n")
        val emptyBack = sexpToList empty
        val _ = print ("empty decoded length: " ^ Int.toString (List.length emptyBack) ^ "\n")
    in
        ()
    end

val _ = main ()