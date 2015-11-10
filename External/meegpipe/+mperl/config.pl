###############################################################################
#
# Script:	config.pl
# Purpose:	Fix up Config.pm after a binary installation
#
# Copyright (c) 1999-2005 ActiveState Corp.  All rights reserved.
#
###############################################################################

# Modified by German Gomez-Herrero

use File::Basename qw(dirname);
use File::Copy;

my $prefix = shift;
my $libpth = $ENV{LIB};
my $user   = $ENV{USERNAME};
my $file   = $prefix . '\lib\Config.pm';
my $file2   = $prefix . '\lib\Config_heavy.pl';
my $oldfile = 'Config.pm~';
my $oldfile2 = 'Config_heavy.pl~';

$tmp = $ENV{'TEMP'} || $ENV{'tmp'};
if ($^O =~ /MSWin/) {
    $tmp ||= 'c:/temp';
}
else {
    $tmp ||= '/tmp';
}

# Remove the "command" value from the file association to prevent the MSI
# "Repair" feature from triggering once an included extension has been
# upgraded by PPM.
if ($^O =~ /MSWin/) {
    require Win32::Registry;
    $::HKEY_CLASSES_ROOT->Open('Perl\shell\Open\command', my $command);
    $command->DeleteValue('command') if $command;
}

my %replacements = (
	archlib			=> "'$prefix\\lib'",
	archlibexp		=> "'$prefix\\lib'",
	bin			=> "'$prefix\\bin'",
	binexp			=> "'$prefix\\bin'",
	cf_by			=> "'ActiveState'",
	installarchlib		=> "'$prefix\\lib'",
	installbin		=> "'$prefix\\bin'",
	installhtmldir		=> "'$prefix\\html'",
	installhtmlhelpdir 	=> "'$prefix\\htmlhelp'",
	installman1dir		=> "''",
	installman3dir		=> "''",
	installprefix		=> "'$prefix'",
	installprefixexp	=> "'$prefix'",
	installprivlib		=> "'$prefix\\lib'",
	installscript		=> "'$prefix\\bin'",
	installsitearch		=> "'$prefix\\site\\lib'",
	installsitebin		=> "'$prefix\\bin'",
	installsitelib		=> "'$prefix\\site\\lib'",
	libpth			=> q('") . join(q(" "), split(/;/, $libpth), $prefix . "\\lib\\CORE") . q("'),
	man1dir			=> "''",
	man1direxp		=> "''",
	man3dir			=> "''",
	man3direxp		=> "''",
	perlpath		=> "'$prefix\\bin\\perl.exe'",
	prefix			=> "'$prefix'",
	prefixexp		=> "'$prefix'",
	privlib			=> "'$prefix\\lib'",
	privlibexp		=> "'$prefix\\lib'",
	scriptdir		=> "'$prefix\\bin'",
	scriptdirexp		=> "'$prefix\\bin'",
	sitearch		=> "'$prefix\\site\\lib'",
	sitearchexp		=> "'$prefix\\site\\lib'",
	sitebin			=> "'$prefix\\site\\bin'",
	sitebinexp		=> "'$prefix\\site\\bin'",
	sitelib			=> "'$prefix\\site\\lib'",
	sitelibexp		=> "'$prefix\\site\\lib'",
	siteprefix		=> "'$prefix\\site'",
	siteprefixexp		=> "'$prefix\\site'",
);

# Modified by German Gomez-Herrero
my $pattern = '^\s*(' . join('|', keys %replacements) . ')\s*=>.*';

chmod(0644, $file)
    or die "Unable to chmod(0644, $file) : $!";

copy($file, $oldfile);

if(open(FILE, "+<$file")) {
    my @Config;
    while(<FILE>) {
# Modified by German Gomez-Herrero
	s/$pattern/$1=>$replacements{$1},/;
	push(@Config, $_); 
    }
    seek(FILE, 0, 0);
    truncate(FILE, 0);
    print FILE @Config;
    close(FILE);
    chmod(0444, $file)
	or warn "Unable to chmod(0444, $file) : $!";
}
else {
    print "Unable to open $file : $!\n\n";
    print "Press [Enter] to continue:\n";
    <STDIN>;
    exit 1;
}

# Modified by German Gomez-Herrero
my $pattern = '^(' . join('|', keys %replacements) . ')=.*';

chmod(0644, $file2)
    or die "Unable to chmod(0644, $file2) : $!";

copy($file2, $oldfile2);

if(open(FILE, "+<$file2")) {
    my @Config;
    while(<FILE>) {
# Modified by German Gomez-Herrero
	s/$pattern/$1=$replacements{$1}/;
	push(@Config, $_); 
    }
    seek(FILE, 0, 0);
    truncate(FILE, 0);
    print FILE @Config;
    close(FILE);
    chmod(0444, $file2)
	or warn "Unable to chmod(0444, $file2) : $!";
}
else {
    print "Unable to open $file2 : $!\n\n";
    print "Press [Enter] to continue:\n";
    <STDIN>;
    exit 1;
}

