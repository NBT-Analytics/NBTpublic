#!/usr/bin/perl
# (c) German Gomez-Herrero, german.gomezherrero@kasku.org


use warnings;
use Cwd 'abs_path';

# Make our Tidy.pm visible
my $libLocation;
BEGIN {
    my $name = abs_path($0);
    $name=~m/^.+\//; 
    $libLocation=$&;
}
use lib $libLocation;
use XML::Tidy;

my ($file, $indentChar) = (shift, shift);

my $tidyObj = XML::Tidy->new('filename' => $file);                             
        
unless ($tidyObj){exit;}

$tidyObj->tidy($indentChar);
$tidyObj->write();

