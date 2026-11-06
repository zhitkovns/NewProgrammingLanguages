use strict;
use warnings;
use feature 'say';

my $input_file = shift @ARGV // 'access.log';
my $output_file = shift @ARGV // 'output.txt';

open(my $in, '<', $input_file) or die "cannot open $input_file: $!";

my $total = 0;
my %status_count;
my %ip_count;

while (my $line = <$in>) {
    chomp $line;
    if ($line =~ /^(\S+)\s+\S+\s+\S+\s+(\d{3})\b/) {
        my $ip = $1;
        my $status = $2;
        $total++;
        $status_count{$status}++;
        $ip_count{$ip}++;
    } else {
        warn "unrecognized line: $line\n";
    }
}
close($in) or die "cannot close $input_file: $!";

open(my $out, '>', $output_file) or die "cannot open $output_file: $!";

say $out "Total requests: $total";

say $out "By status:";
for my $s (sort keys %status_count) {
    say $out "  $s: $status_count{$s}";
}

say $out "Top 5 IPs:";
my @ips = sort { $ip_count{$b} <=> $ip_count{$a} || $a cmp $b } keys %ip_count;
my $top = @ips > 5 ? 5 : scalar @ips;
for my $i (0 .. $top - 1) {
    say $out "  $ips[$i]: $ip_count{$ips[$i]}";
}

close($out) or die "cannot close $output_file: $!";

say "report written to $output_file";