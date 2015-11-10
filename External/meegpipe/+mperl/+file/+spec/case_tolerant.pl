#!/usr/bin/perl
# (c) German Gomez-Herrero, german.gomezherrero@kasku.org

# Description:  Indicates whether file names are or not case sensitive
# Documentation: pkg_filespec.txt

use warnings;

# Make our Spec.pm visible
my $libLocation;
BEGIN {
    use Cwd 'abs_path';
    use File::Spec;
    my $name = abs_path($0);
    $name=~m/^.+\//; 
    $libLocation = abs_path(File::Spec->catdir($&, '../../lib'));
}

use lib $libLocation;

use File::Spec;

my $res = File::Spec->case_tolerant();

if ($res){
    print 'true';
} else { 
    print 'false';
}

