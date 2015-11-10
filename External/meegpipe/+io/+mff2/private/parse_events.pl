#!/usr/bin/perl

# German Gomez-Herrero, <german.gomezherrero@kasku.org>
# Parses EGI's event description files that come with an .mff file
#
# Usage:
#
# parse_events.pl file.mff
#
# 


use File::Find;
use File::Spec;

find(\&parse, shift);

sub parse {

unless (m%^Events.+\.xml$%){return;}

open my $fh, "<", $_ or die "Could not open $File::Find::name : $!";

local $/; # enable localizing slurp mode
my $file = <$fh>;

close $fh;

# Split in different lines
$file =~ s%>\s+<%>\n<%gi;

my @lines = split("\n", $file);

foreach (@lines){
    next unless (m%^\s*<(l|b|d|c|k|e|/)%);

    # Only read useful pieces of info
    # next unless (m%^\s*<[lbdcke\/]%);
	if (m%<beginTime>(.+?)</beginTime>%){
        print "$1\n";
    } elsif (m%<duration>(.+?)</duration>%){
        print "$1\n";
    } elsif (m%<code>(.+?)</code>%){
        print "$1\n";
    } elsif (m%<keyCode>(.+?)</keyCode>%){
        print "$1\n";
    } elsif (m%</event>$%){
        print chr(13);
    } elsif (m%<data.+>(.+?)</data>%){
        print "$1\n";
    }
}

}
