def int_to_hex(n: Int) -> String:
    if n == 0:
        return "0"
    var digits = String("0123456789abcdef")
    var result = String("")
    var x = n
    while x > 0:
        var d = x % 16
        result = String(digits[byte=d]) + result
        x = x // 16
    return result

def hex_digit_value(c: UInt8) raises -> Int:
    var zero = UInt8(ord("0"))
    var nine = UInt8(ord("9"))
    var a = UInt8(ord("a"))
    var f = UInt8(ord("f"))
    var upper_a = UInt8(ord("A"))
    var upper_f = UInt8(ord("F"))
    
    if c >= zero and c <= nine:
        return Int(c - zero)
    if c >= a and c <= f:
        return Int(c - a) + 10
    if c >= upper_a and c <= upper_f:
        return Int(c - upper_a) + 10
    
    var err_char = chr(Int(c))
    raise Error("invalid hex digit: " + err_char)

def hex_to_int(s: String) raises -> Int:
    if s.byte_length() == 0:
        raise Error("empty hex string")
    
    var result = 0
    for b in s.as_bytes():
        var d = hex_digit_value(b)
        result = result * 16 + d
    return result

def main() raises:
    var n: Int = 255
    print("decimal:", n, "-> hex:", int_to_hex(n))

    var hex_str = "ff"
    print("hex:", hex_str, "-> decimal:", hex_to_int(hex_str))

    var f: Float64 = 3.14159
    var i = Int(f)
    print("float:", f, "-> int:", i)
    print("int:", i, "-> float:", Float64(i))

    try:
        var bad = hex_to_int("xyz")
        print("unexpected success:", bad)
    except e:
        print("error caught:", e)