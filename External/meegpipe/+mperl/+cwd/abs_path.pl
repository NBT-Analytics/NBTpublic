#!/usr/bin/perl
# (c) German Gomez-Herrero, german.gomezherrero@kasku.org

# Description: Canonical pathname
# Documentation: pkg_mperl_cwd.txt

use warnings;
use Cwd 'abs_path';

print abs_path(shift);

