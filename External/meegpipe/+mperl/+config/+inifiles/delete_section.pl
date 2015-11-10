#!/usr/bin/perl
# (c) German Gomez-Herrero, german.gomezherrero@kasku.org

use warnings;
use Cwd 'abs_path';
use File::Spec;

# Make our IniFiles.pm visible
my $libLocation;
BEGIN {
    my $name = abs_path($0);
    $name=~m/^.+\//; 
    $libLocation=File::Spec->catdir($&, '../../lib');
}
use lib $libLocation;
use Config::IniFiles;

my ($file, $section) = (shift, shift);

my (
    $nocase, 
    $allowcontinue, 
    $allowempty) = (shift,shift,shift);


$cfg = Config::IniFiles->new( -file                 => $file,                                                     
                              -nocase               => $nocase, 
                              -allowcontinue        => $allowcontinue, 
                              -allowempty           => $allowempty,
                               );

unless ($cfg){exit;}

$cfg->DeleteSection($section);
$cfg->RewriteConfig();
print '1';
