import std.stdio;
import std.file;
import std.string;
import std.conv;

uint readUint32(ubyte[] data, size_t offset) {
    return data[offset] | 
           (data[offset + 1] << 8) | 
           (data[offset + 2] << 16) | 
           (data[offset + 3] << 24);
}

ushort readUint16(ubyte[] data, size_t offset) {
    return data[offset] | (data[offset + 1] << 8);
}

void main(string[] args) {
    string filename = args.length > 1 ? args[1] : "test.wav";
    
    try {
        ubyte[] data = cast(ubyte[]) read(filename);
        
        if (data.length < 44) {
            throw new Exception("file too small to be a valid wav");
        }

        string riff = cast(string) data[0 .. 4];
        string wave = cast(string) data[8 .. 12];
        
        if (riff != "RIFF" || wave != "WAVE") {
            throw new Exception("invalid wav format: missing RIFF or WAVE signature");
        }

        string fmt = cast(string) data[12 .. 16];
        if (fmt != "fmt ") {
            throw new Exception("invalid wav format: missing fmt chunk");
        }

        ushort audioFormat = readUint16(data, 20);
        ushort channels = readUint16(data, 22);
        uint sampleRate = readUint32(data, 24);
        uint byteRate = readUint32(data, 28);
        ushort bitsPerSample = readUint16(data, 34);
        
        uint dataSize = 0;
        size_t dataOffset = 36;
        while (dataOffset + 8 <= data.length) {
            string chunkId = cast(string) data[dataOffset .. dataOffset + 4];
            uint chunkSize = readUint32(data, dataOffset + 4);
            if (chunkId == "data") {
                dataSize = chunkSize;
                break;
            }
            dataOffset += 8 + chunkSize;
        }

        if (dataSize == 0) {
            throw new Exception("no data chunk found in wav file");
        }

        double duration = cast(double) dataSize / byteRate;

        writeln("WAV file: ", filename);
        writeln("Audio format: ", audioFormat == 1 ? "PCM" : "Other");
        writeln("Channels: ", channels);
        writeln("Sample rate: ", sampleRate, " Hz");
        writeln("Bits per sample: ", bitsPerSample);
        writeln("Duration: ", duration, " seconds");

    } catch (FileException e) {
        stderr.writeln("error reading file: ", e.msg);
    } catch (Exception e) {
        stderr.writeln("error: ", e.msg);
    }
}