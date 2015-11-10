#!/usr/bin/perl -w

# Splits an ASCII file into two files. 

# perl line_split filename linenumber fileout1 fileout2

open(FILE, $ARGV[0]) || die "Could not open $ARGV[0]\n";
$nlines = $ARGV[1];

if ($ARGV[2]){
    open(FILE_OUT1, ">$ARGV[2]") || die "Could not open $ARGV[2]\n";
}

if ($ARGV[3]) {
    open(FILE_OUT2, ">$ARGV[3]") || die "Could not open $ARGV[3]\n";
}

if ($ARGV[3]) {
    print $nlines;
    while ($line = <FILE>){
        print FILE_OUT2 $line; 
        if ($.>=$nlines){last;};
    }
    close(FILE_OUT2);
} else {
    while ($line = <FILE>){
        push(@out,$line);
        if ($.>=$nlines){last;};
    }
    print @out;
}

if ($ARGV[2]) {
    while ($line = <FILE>){
        print FILE_OUT1 $line;      
    }
    close(FILE_OUT1);
}

close(FILE);