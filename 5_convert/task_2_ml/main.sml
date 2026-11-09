local
    exception ParseError of string

    fun joinInts [] = ""
      | joinInts [x] = Int.toString x
      | joinInts (x::xs) = Int.toString x ^ " " ^ joinInts xs

    fun listToSexp lst = "(" ^ joinInts lst ^ ")"

    fun parseInt s =
        case Int.fromString s of
            SOME v => v
          | NONE => raise ParseError ("not a number: " ^ s)

    fun sexpToList str =
        let
            val len = String.size str
        in
            if len < 2 orelse String.sub(str, 0) <> #"(" orelse String.sub(str, len - 1) <> #")" then
                raise ParseError "missing parentheses"
            else
                let
                    val inner = String.substring(str, 1, len - 2)
                    val tokens = String.tokens Char.isSpace inner
                in
                    List.map parseInt tokens
                end
        end

    fun main () =
        let
            val original = [1, 2, 3, 4, 5]
            val encoded = listToSexp original
        in
            print ("original list: [" ^ String.concatWith ", " (List.map Int.toString original) ^ "]\n");
            print ("encoded sexp: " ^ encoded ^ "\n");
            
            (case sexpToList encoded of
                parsed => print ("parsed back: [" ^ String.concatWith ", " (List.map Int.toString parsed) ^ "]\n"))
            handle ParseError msg => print ("parse error: " ^ msg ^ "\n");
            
            (case sexpToList "(1 2 abc 4)" of
                _ => print ("unexpected success\n"))
            handle ParseError msg => print ("expected error caught: " ^ msg ^ "\n")
        end
in
    val _ = main ()
end