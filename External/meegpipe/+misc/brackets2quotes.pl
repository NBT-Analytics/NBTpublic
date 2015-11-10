#!/usr/bin/perl -w

# Replaces [] with "" 

# perl dc2dd fi fo 

open(FILE, $ARGV[0]) || die "Could not open $ARGV[0]\n";
open(FILE_OUT, ">$ARGV[1]") || die "Could not open $ARGV[1]\n";

while($line = <FILE>){    
    $line =~ s/[\[\]]/"/gi;       
    print FILE_OUT $line;
}
close(FILE);
close(FILE_OUT);

