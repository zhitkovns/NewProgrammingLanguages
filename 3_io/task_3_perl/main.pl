use strict;
use warnings;

my @crc_table;
for my $n (0 .. 255) {
    my $c = $n;
    for (1 .. 8) {
        if ($c & 1) {
            $c = 0xedb88320 ^ ($c >> 1);
        } else {
            $c = $c >> 1;
        }
    }
    $crc_table[$n] = $c;
}

sub calculate_crc32 {
    my ($data) = @_;
    my $crc = 0xffffffff;
    for my $byte (unpack("C*", $data)) {
        $crc = $crc_table[($crc ^ $byte) & 0xff] ^ ($crc >> 8);
    }
    return $crc ^ 0xffffffff;
}

my $filename = $ARGV[0] // 'test.png';

open(my $fh, '<:raw', $filename) or die "cannot open $filename: $!";

my $signature;
read($fh, $signature, 8);

my $expected_sig = "\x89PNG\r\n\x1a\n";
if ($signature ne $expected_sig) {
    die "invalid png signature\n";
}

print "PNG signature: valid\n";
print "Chunks:\n";

while (read($fh, my $header, 8)) {
    my ($length, $type) = unpack("Na4", $header);
    
    my $data;
    if ($length > 0) {
        read($fh, $data, $length);
    } else {
        $data = "";
    }
    
    my $crc_bytes;
    read($fh, $crc_bytes, 4);
    my $expected_crc = unpack("N", $crc_bytes);
    
    my $calculated_crc = calculate_crc32($type . $data);
    
    my $crc_status = ($expected_crc == $calculated_crc) ? "OK" : "FAILED";
    
    printf "  %s: %d bytes, CRC %s\n", $type, $length, $crc_status;
    
    if ($type eq "IEND") {
        last;
    }
}

close($fh);