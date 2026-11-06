fn int_to_hex(n: Int) -> String:
    if n == 0:
        return "0"
    let digits = String("0123456789abcdef")
    var result = String("")
    var x = n
    while x > 0:
        let d = x % 16
        result = String(digits[d]) + result
        x = x // 16
    return result

fn hex_digit_value(c: String) raises -> Int:
    let code = ord(c)
    let zero = ord("0")
    let nine = ord("9")
    let a = ord("a")
    let f = ord("f")
    let upper_a = ord("A")
    let upper_f = ord("F")
    if code >= zero and code <= nine:
        return code - zero
    if code >= a and code <= f:
        return code - a + 10
    if code >= upper_a and code <= upper_f:
        return code - upper_a + 10
    raise Error("invalid hex digit: " + c)

fn hex_to_int(s: String) raises -> Int:
    if len(s) == 0:
        raise Error("empty hex string")
    var result = 0
    for i in range(len(s)):
        let c = String(s[i])
        let d = hex_digit_value(c)
        result = result * 16 + d
    return result

fn main() raises:
    let n: Int = 255
    print("decimal:", n, "-> hex:", int_to_hex(n))

    let hex_str: String = "ff"
    print("hex:", hex_str, "-> decimal:", hex_to_int(hex_str))

    let f: Float64 = 3.14159
    let i = Int(f)
    print("float:", f, "-> int:", i)
    print("int:", i, "-> float:", Float64(i))

    try:
        let bad = hex_to_int("xyz")
        print("unexpected success:", bad)
    except e:
        print("error caught:", e)