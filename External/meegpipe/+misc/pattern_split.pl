#!/usr/bin/perl -w

# Splits an ASCII file into two files. The first file contains the lines  
# that match the given criterion while the second contains only the lines
# that do not match the criterion

# perl pattern_split filename_in pattern filename_out1 filename_out2 

open(FILE, $ARGV[0]) || die "Could not open $ARGV[0]\n";
$pattern = $ARGV[1];

open(FILE_OUT1, ">$ARGV[2]") || die "Could not open $ARGV[2]\n";

if ($ARGV[3]) {
    open(FILE_OUT2, ">$ARGV[3]") || die "Could not open $ARGV[3]\n";
}

if ($ARGV[3]) {
    while ($line = <FILE>){
        if  ($line =~ m/$pattern/) {
            $line =~ s/$pattern//;
            print FILE_OUT2 $line;
        }else{
            print FILE_OUT1 $line;
        }
    }
    close(FILE_OUT2);
}else{
    while ($line = <FILE>){
        if  ($line =~ m/$pattern/) {
             $line =~ s/$pattern//;
             push(@out,$line); 
        }else{             
             print FILE_OUT1 $line;
        }
    }
    print @out; 
    
}
close(FILE);
close(FILE_OUT1);


