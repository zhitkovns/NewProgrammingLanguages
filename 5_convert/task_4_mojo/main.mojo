def extract_zip_catalog(zip_path: String, csv_path: String) raises:
    # Открываем файл и читаем его как сырые байты
    var file = open(zip_path, "r")
    var data = file.read_bytes()
    file.close()

    var output = open(csv_path, "w")
    output.write("filename,compressed_size,uncompressed_size,compression_method\n")

    var i = 0
    var length = len(data)

    while i < length - 4:
        if data[i] == 0x50 and data[i+1] == 0x4b and data[i+2] == 0x01 and data[i+3] == 0x02:
            var method = Int(data[i+10]) | (Int(data[i+11]) << 8)
            var comp_size = Int(data[i+20]) | (Int(data[i+21]) << 8) | (Int(data[i+22]) << 16) | (Int(data[i+23]) << 24)
            var uncomp_size = Int(data[i+24]) | (Int(data[i+25]) << 8) | (Int(data[i+26]) << 16) | (Int(data[i+27]) << 24)
            var name_len = Int(data[i+28]) | (Int(data[i+29]) << 8)
            var extra_len = Int(data[i+30]) | (Int(data[i+31]) << 8)
            var comment_len = Int(data[i+32]) | (Int(data[i+33]) << 8)

            var name = String()
            for j in range(i+46, i+46+name_len):
                name += chr(Int(data[j]))

            output.write(name + "," + String(comp_size) + "," + String(uncomp_size) + "," + String(method) + "\n")

            i += 46 + name_len + extra_len + comment_len
        else:
            i += 1

    output.close()
    print("Successfully extracted catalog to " + csv_path)

def main() raises:
    extract_zip_catalog("test.zip", "output.csv")