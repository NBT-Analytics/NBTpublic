#!/usr/bin/perl -w

# Replaces decimal commas with decimal dots and replaces empty values with NaNs

# perl dc2dd fi fo delim

open(FILE, $ARGV[0]) || die "Could not open $ARGV[0]\n";
open(FILE_OUT, ">$ARGV[1]") || die "Could not open $ARGV[1]\n";

my $delim = $ARGV[2] || ',';
my $matchStr = "$delim$delim";
my $replaceStr = $delim."NaN".$delim;

while($line = <FILE>){    
    # Don't do this! It breaks if you have a comma-separated file with 
    # numeric entries
    #$line =~ s/(\d+),(\d+)/$1.$2/gi;
    $line =~ s/$matchStr/$replaceStr/gi;
    print FILE_OUT $line;
}
close(FILE);
close(FILE_OUT);

