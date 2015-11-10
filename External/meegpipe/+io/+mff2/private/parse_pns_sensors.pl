#!/usr/bin/perl

# German Gomez-Herrero, <german.gomezherrero@kasku.org>


use File::Spec;

my $mff = shift;

if (-e File::Spec->catfile($mff, 'pnsSet.xml')){
    $mff = File::Spec->catfile($mff, 'pnsSet.xml');
} else {
    exit;
}

open my $fh, "<", $mff or die "Could not open $mff : $!";
local $/; # enable localizing slurp mode
my $file = <$fh>;
close $fh;

# Sensor net name
if ($file =~ m%^.+<name>([^<]*)</name>\s*(<sensors>.+)$%){
    print "$1\n";
    $file = $2;
} else {
    print 'NO NAME';
}

# Split in different lines
$file =~ s%>\s+<%>\n<%gi;
my @lines = split("\n", $file);

foreach (@lines){
    next unless (m%^\s*<(n|u|p)%);
	if (m%<name>([^<]+)</name>%){print "$1;"};
	if (m%<unit>([^<]*)</unit>%){print "$1\n"};	
}


