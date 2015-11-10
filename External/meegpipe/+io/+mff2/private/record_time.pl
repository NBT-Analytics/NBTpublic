#!/usr/bin/perl

# German Gomez-Herrero, <german.gomezherrero@kasku.org>
# Parses EGI's record description information
#
# Usage:
#
# record_time.pl file.mff
#
# 

use warnings;
use strict;
use File::Spec;

open my $fh, "<", File::Spec->catfile(shift, 'info.xml') or die "$!";
local $/; # enable localizing slurp mode
my $file = <$fh>;
close $fh;

$file =~ s%^.+<recordTime>([^<]+)</recordTime>.+$%$1%;
print $file;



