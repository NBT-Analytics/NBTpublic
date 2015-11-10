#!/usr/bin/perl
# (c) German Gomez-Herrero, german.gomezherrero@kasku.org

use strict;
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

my ($file, $section, $parameter) = (shift, shift, shift);

my (
    $nocase, 
    $allowcontinue, 
    $allowempty) = (shift,shift,shift);

my $cfg = Config::IniFiles->new( -file                 => $file,
                                 -allowempty           => $allowempty,
                                 -nocase               => $nocase, 
                                 -allowcontinue        => $allowcontinue
                               );


unless ($cfg){exit;}

my $value = $cfg->newval($section, $parameter, @ARGV);

if ($value){
  print '1';
  $cfg->RewriteConfig();
} else {
  print '0';
}

