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

my $file = shift;

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

# Read all sections and all parameters
my @sections = $cfg->Sections();

foreach (@sections){
    my $section = $_;
    my @params = $cfg->Parameters($section);
    print "$section\n\n";
    foreach (@params){
        my $value = $cfg->val($section, $_);
        if ($value){ 
            print "$_\n$value\n\n";
        }
    }
    print "\n\n\n";
}





