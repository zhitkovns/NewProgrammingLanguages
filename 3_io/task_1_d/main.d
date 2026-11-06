import std.stdio;
import std.file;
import std.string;
import std.algorithm : sort;
import std.array : array;

int main(string[] args) {
    string inputFile = args.length > 1 ? args[1] : "input.txt";
    string outputFile = "output.txt";

    try {
        string content = readText(inputFile).toLower;
        int[string] freq;

        foreach (word; content.split) {
            string clean;
            foreach (c; word) {
                if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
                    clean ~= c;
                }
            }
            if (clean.length > 0) {
                freq[clean]++;
            }
        }

        auto pairs = freq.byKeyValue.array;
        pairs.sort!((a, b) =>
            a.value > b.value || (a.value == b.value && a.key < b.key));

        auto out = File(outputFile, "w");
        foreach (p; pairs) {
            out.writefln("%-20s %d", p.key, p.value);
        }
        out.close;

        writeln("unique words: ", freq.length);
        writeln("written to ", outputFile);
        return 0;
    } catch (Exception e) {
        stderr.writeln("error: ", e.msg);
        return 1;
    }
}