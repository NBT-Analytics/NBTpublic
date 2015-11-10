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

while (my $line = <FILE_IN>){
  # For some reason chomp does not seem to do the trick here, at least in Windows
  $line =~ s/\r?\n$//;
  print FILE_OUT $line;
}

close(FILE_IN);
close(FILE_OUT);


