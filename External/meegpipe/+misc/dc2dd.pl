#!/usr/bin/perl -w

# Replaces decimal commas with decimal dots in an ascii file

# perl dc2dd fi fo 

open(FILE, $ARGV[0]) || die "Could not open $ARGV[0]\n";
open(FILE_OUT, ">$ARGV[1]") || die "Could not open $ARGV[1]\n";

while($line = <FILE>){    
    $line =~ s/(\d+),(\d+)/$1.$2/gi;
    print FILE_OUT $line;
}
close(FILE);
close(FILE_OUT);

