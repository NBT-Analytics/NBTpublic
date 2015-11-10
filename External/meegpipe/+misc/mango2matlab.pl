#!/usr/bin/perl -w

# Converts a Mango .csv file with fiducial and sensor coordinates into a
# numeric .dlm file that can easily imported to MATLAB

# perl mango2matlab filename_in filename_out


open(FILE_IN, $ARGV[0]) || die "Could not open $ARGV[0]\n";
open(FILE_OUT, ">$ARGV[1]") || die "Could not open $ARGV[1]\n";

# skip header lines
while ($line = <FILE_IN>)
{
    if ($line =~ /t"\s*,\s*"\d"\s*,\s*"\d"\s*,\s*"(\d+)"\s*,\s*"(\d+)"\s*,\s*"(\d+)"/)
    {
        print FILE_OUT "$1 $2 $3 \n";
    }  
}
close(FILE_IN);
close(FILE_OUT);
