#!/usr/bin/perl
# (c) German Gomez-Herrero, german.gomezherrero@kasku.org

use File::Find;

my ($root, $regex, $ignorePath, $nodirs, $nofiles, $negated) = @ARGV;

undef $nodirs       if $nodirs      eq 'undef';
undef $nofiles      if $nofiles      eq 'undef';
undef $ignorePath   if $ignorePath  eq 'undef';
undef $negated      if $negated     eq 'undef';


if ($ignorePath){

  finddepth(
    sub{
        if ($nodirs) {
            return if (-d $_);
        }
        if ($nofiles) {           
            return unless (-d $_);            
        }
        
        if (m%$regex% && !$negated){
            print $File::Find::name,"\n";
        } elsif ($negated) {
            print $File::Find::name,"\n";
        }
    }, 
 $root); 

} else {

  finddepth(
    sub{
        if ($nodirs) {
            return if (-d $File::Find::name);
        } elsif ($nofiles) {
            return unless (-d $File::Find::name);
        }

        if (-f $File::Find::name && $File::Find::name =~ m%$regex%){
            print $File::Find::name,"\n";
        } elsif (!-f $File::Find::name && $File::Find::dir =~ m%$regex%){
            print $File::Find::dir,"\n";
        }
    }, 
    $root); 
}



