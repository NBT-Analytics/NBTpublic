#!/usr/bin/perl -w

# Replaces all the patterns ma

# perl regex_rep regex fi fo 

use strict;
use warnings;

my ($regex, $rep, $fileIn, $fileOut) = (shift, shift, shift, shift);
open(FILE, $fileIn) || die "Could not open $fileIn\n";
open(FILE_OUT, ">$fileOut") || die "Could not open $fileOut\n";

while(my $line = <FILE>){    
    $line =~ s/$regex/$rep/gi;
    print FILE_OUT $line;
}
close(FILE);
close(FILE_OUT);

