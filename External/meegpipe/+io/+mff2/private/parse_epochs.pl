#!/usr/bin/perl

# German Gomez-Herrero, <german.gomezherrero@kasku.org>
 

use File::Spec;

my $mff = shift;

if (-e File::Spec->catfile($mff, 'epochs.xml')){
    $mff = File::Spec->catfile($mff, 'epochs.xml');
} else {
    die;
}

open my $fh, "<", $mff or die "Could not open $mff : $!";
local $/; # enable localizing slurp mode
my $file = <$fh>;
close $fh;

# Split in different lines
$file =~ s%>\s+<%>\n<%gi;
my @lines = split("\n", $file);

foreach (@lines){
	if (m%<beginTime>(\d+)</beginTime>%){print "$1;"};
	if (m%<endTime>(\d+)</endTime>%){print "$1;"};
	if (m%<firstBlock>(\d+)</firstBlock>%){print "$1;"};
    if (m%<lastBlock>(\d+)</lastBlock>%){print "$1;"};    
    if (m%</epoch>%){print "\n"}; 
}


