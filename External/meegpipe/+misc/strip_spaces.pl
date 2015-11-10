#!/usr/bin/perl -w

# Strips leading and trailing white-spaces from a text file

# perl strip_spaces.pl filename_orig filename_stripped


use strict;
use warnings;

unless ($ARGV[0] && $ARGV[1]){
  die "Please provide an input and output filename";
}

open(FILE_IN, $ARGV[0]) || die "Could not open $ARGV[0]\n";

open(FILE_OUT, ">$ARGV[1]") || die "Could not open $ARGV[1]\n";



$/ = "\r"; 

while (my $line = <FILE_IN>){
  $line =~ s/^\s+//;
  $line =~ s/\s+$//; 
  print FILE_OUT $line;
}

close(FILE_IN);
close(FILE_OUT);


