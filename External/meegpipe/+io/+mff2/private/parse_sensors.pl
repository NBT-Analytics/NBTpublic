#!/usr/bin/perl

# German Gomez-Herrero, <german.gomezherrero@kasku.org>
# Parses EGI's event description files that come with an .mff file
#
# Usage:
#
# parse_sensors.pl file.mff
#
# 

use File::Spec;

my $mff = shift;

if (-e File::Spec->catfile($mff, 'coordinates.xml')){
    $mff = File::Spec->catfile($mff, 'coordinates.xml');
} else {
    $mff = File::Spec->catfile($mff, 'sensorLayout.xml');
}

open my $fh, "<", $mff or die "Could not open $mff : $!";
local $/; # enable localizing slurp mode
my $file = <$fh>;
close $fh;

# Sensor net name
if ($file =~ m%^.+<name>(.+?)</name>\s*<sensors>.+$%){
    print "$1\n";
} else {
    print 'NO NAME';
}

# Split in different lines
$file =~ s%>\s+<%>\n<%gi;
my @lines = split("\n", $file);

foreach (@lines){
	if (m%<number>([^<]+)</number>%){print "$1;"};
	if (m%<type>([^<]+)</type>%){print "$1;"};
	if (m%<x>([^<]+)</x>%){print "$1;"};
    if (m%<y>([^<]+)</y>%){print "$1;"};
    if (m%<z>([^<]+)</z>%){print "$1\n"};
}


