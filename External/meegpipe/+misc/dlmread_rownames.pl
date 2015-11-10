#!/usr/bin/perl -w

# Replaces decimal commas with decimal dots and replaces empty values with NaNs

# perl dc2dd fi fo delim

open(FILE, $ARGV[0]) || die "Could not open $ARGV[0]\n";

my $delim = $ARGV[1] || ',';
my $matchStr = "(.+?)$delim";

while($line = <FILE>){    
    $line =~ m/$matchStr/;   
    print "$1$delim";
}
close(FILE);

