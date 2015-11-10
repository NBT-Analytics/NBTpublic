#!/usr/bin/perl

# German Gomez-Herrero, <german.gomezherrero@kasku.org>


use File::Spec;

my $mff = shift;

if (-e File::Spec->catfile($mff, 'info1.xml')){
    $mff = File::Spec->catfile($mff, 'info1.xml');
} else {
    exit;
}

open my $fh, "<", $mff or die "Could not open $mff : $!";
local $/; # enable localizing slurp mode
my $file = <$fh>;
close $fh;

# GCAL
my $gcal;
my $ical;
if ($file =~ m%^.+<type>GCAL</type>\s*<channels>\s*(.+)\s*</channels>\s*</calibration>\s*<calibration>(.+)$%){   
    $gcal = $1;  
    $ical = $2;
    $ical =~ s%^.+<type>ICAL</type>\s*<channels>\s*(.+)\s*</channels>.+$%$1%;
} elsif ($file =~ m%^.+<type>GCAL</type>\s*<channels>\s*(.+)\s*</channels>\s*</calibration>%){
    $gcal = $1;
} else {    
    exit;
}


my @cals = ($gcal, $ical);

foreach (@cals){  
    next unless $_;
    s%>\s+<%>\n<%gi;
    my @lines = split("\n", $_);
    foreach (@lines){        
        if (m%<ch n="(\d+)">([^<]+)</ch>%){print "$1 $2\n"};        
    }
    print "\n\n";
}


