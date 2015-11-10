#!/usr/bin/perl

# German Gomez-Herrero, <german.gomezherrero@kasku.org>
# Parses EGI's event description files that come with an .mff file
#
# Usage:
#
# parse_signal_info.pl file.mff signalIdx
#
# 

use warnings;
use strict;
use File::Find;
use File::Spec;

my $mff = shift;
my $idx = shift;
open my $fh, "<", File::Spec->catfile($mff, 'info'.$idx.'.xml') or die "Could not open $File::Find::name : $!";

local $/; # enable localizing slurp mode
my $file = <$fh>;

if ($file =~ m%^.+<fileDataType>[^<]*<([^>]+)>.+$%){
    print "dataType;$1\n";
}

if ($file =~ m%^.+<sensorLayoutName>([^<]*)</sensorLayoutName>.+$%){
    print "sensorLayout;$1\n";
}

if ($file =~ m%^.+<pnsSetName>([^<]*)</pnsSetName>.+$%){
    print "pnsSetName;$1\n";
}







