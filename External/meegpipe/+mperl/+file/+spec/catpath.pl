#!/usr/bin/perl
# (c) German Gomez-Herrero, german.gomezherrero@kasku.org

# Description: Takes volume, directory and file portions and returns a path
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

my ($volume, $dir, $file) = (shift, shift, shift);

my $path = File::Spec->catpath($volume, $dir, $file);

print $path;
