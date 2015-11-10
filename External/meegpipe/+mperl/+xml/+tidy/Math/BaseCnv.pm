# 3159mLT - Math::BaseCnv.pm created by Pip Stuart <Pip@CPAN.Org> to CoNVert between arbitrary number Bases.  I'm totally addicted to bass!
package Math::BaseCnv;
require Exporter;
use strict;
use warnings;
use base qw(Exporter);
use Memoize; memoize('summ'); memoize('fact'); memoize('choo');
# only export cnv() for 'use Math::BaseCnv;' && all other stuff optionally
our @EXPORT      =             qw(cnv                                    )    ;
our @EXPORT_OK   =             qw(    dec hex b10 b64 b64sort dig diginit summ fact choo)  ;
our %EXPORT_TAGS = ( 'all' =>[ qw(cnv dec hex b10 b64 b64sort dig diginit summ fact choo) ],
                     'hex' =>[ qw(    dec hex                            ) ],
                     'b64' =>[ qw(cnv         b10 b64 b64sort            ) ],
                     'dig' =>[ qw(                            dig diginit) ],
                     'sfc' =>[ qw(                         summ fact choo) ] );
our $VERSION     = '1.4.75O6Pbr'; our $PTVR = $VERSION; $PTVR =~ s/^\d+\.\d+\.//; # Please see `perldoc Time::PT` for an explanation of $PTVR.
my $d2bs = ''; my %bs2d = (); my $nega = '';
my %digsets = (
  'usr' => [], # this will be assigned if a dig(\@newd) call is made
  'bin' => ['0', '1'],
  'oct' => ['0'..'7'],
  'dec' => ['0'..'9'],
  'hex' => ['0'..'9', 'a'..'f'],
  'HEX' => ['0'..'9', 'A'..'F'],
  'b62' => ['0'..'9', 'a'..'z', 'A'..'Z'],
  'm64' => ['A'..'Z', 'a'..'z', '0'..'9', '+', '/'], # 0-63 from MIME::Base64
  'b64' => ['0'..'9', 'A'..'Z', 'a'..'z', '.', '_'], # month:C:12 day:V:31
  'b85' => ['0'..'9', 'A'..'Z', 'a'..'z', '!', '#',  # RFC 1924 for IPv6 addresses, might need to return Math::BigInt objs
            '$', '%', '&', '(', ')', '*', '+', '-', ';', '<', '=', '>', '?', '@', '^', '_', '`', '{', '|', '}', '~'],
);
sub bs2init { %bs2d = (); for(my $i = 0; $i < @{ $digsets{$d2bs} }; $i++) { $bs2d{${ $digsets{$d2bs} }[$i]} = $i; } } # build hash digit chars => array indices
sub diginit { $d2bs = 'b64'; bs2init(); } # reset digit character list to initial Dflt
sub dig { # assign a new digit character list
  return( @{ $digsets{$d2bs} } ) unless(@_);
  if(ref $_[0]) { $d2bs = 'usr'; $digsets{$d2bs} = [ @{ shift() } ]; }
  else          { my $setn = shift(); return(-1) unless(exists $digsets{$setn}); $d2bs = $setn; }
  diginit() unless(@{ $digsets{$d2bs} });
  bs2init();
}
sub cnv__10 { # convert from some number base to decimal fast
  my $t = shift || '0'; my $s = shift || 64; my $n = 0;
  $nega = ''; $nega = '-' if($t =~ s/^-//);
  foreach(split(//, $t)) { return(-1) unless(exists $bs2d{$_}); }
  while(length($t)) { $n += $bs2d{substr($t,0,1,'')}; $n *= $s; } 
  return($nega . int($n / $s));
}
sub cnv10__ { # convert from decimal to some number base fast
  my $n = shift || 0; my $s = shift || 64; my $t = '';
  return(-1) if($s > @{ $digsets{$d2bs} });
  $nega = ''; $nega = '-' if($n =~ s/^-//);
  while($n) { $t = $digsets{$d2bs}->[($n % $s)] . $t; $n = int($n / $s); }
  if(length($t)) { $t = $nega . $t;           }
  else           { $t = $digsets{$d2bs}->[0]; }
  return($t);
}
sub dec     { return(cnv__10(uc(shift), 16)); }#shortcut for hexadecimal -> decimal
sub hex     { return(cnv10__(   shift,  16)); }#shortcut for decimal     -> hex
sub b10     { return(cnv__10(   shift,  64)); }#shortcut for base64      -> decimal
sub b64     { return(cnv10__(   shift,  64)); }#shortcut for decimal     -> base64
sub b64sort { return( map { b64($_) } sort { $a <=> $b } map { b10($_) } @_ ); }
sub cnv     { # CoNVert between any number base
  my $numb = shift; return(-1) unless(defined($numb) && length($numb));
  my $fbas = shift; my $tbas = shift; my $rslt = ''; my $temp = 0;
  return($digsets{$d2bs}->[0]) if($numb =~ /^-?0+$/); # lots of (negative?) zeros is just zero
  if(!defined($tbas)) { # makeup reasonable values for missing params
    if(!defined($fbas)) {                                                         $fbas =    10; $tbas = 16;
      if   ($numb =~ /^0x/i || ($numb =~ /[A-F]/i && $numb =~ /^[0-9A-F]+$/i )) { $fbas =    16; $tbas = 10; }
      elsif($numb =~                   /[G-Z._]/i && $numb =~ /^[0-9A-Z._]+$/i) { $fbas =    64; $tbas = 10; }
      elsif($numb =~ /\D/) { print "!*EROR*! Can't determine reasonable FromBase && ToBase from number:$numb!\n"; }
    } else                                                                      { $tbas = $fbas; $fbas = 10; }
  }
  $fbas = 16 if($fbas =~ /\D/); $tbas = 10 if($tbas =~ /\D/);
  if($fbas == 16) { $numb =~ s/^0x//i; $numb = uc($numb); }
  return(-1) if($fbas < 2 || $tbas < 2); # invalid base error
  $numb = cnv__10($numb, $fbas) if($numb =~ /\D/ || $fbas != 10);
  $numb = cnv10__($numb, $tbas) if(                 $tbas != 10);
  return($numb);
}
sub summ { # simple function to calculate summation down to 1
  my $summ = shift; return(0) unless(defined($summ) && $summ && ($summ > 0)); my $answ = $summ; while(--$summ) { $answ += $summ; } return($answ);
}
sub fact { # simple function to calculate factorials
  my $fact = shift; return(0) unless(defined($fact) && $fact && ($fact > 0)); my $answ = $fact; while(--$fact) { $answ *= $fact; } return($answ);
}
sub choo { # simple function to calculate n choose m  (i.e., (n! / (m! * (n - m)!)))
  my $ennn = shift; my $emmm = shift; return(0) unless(defined($ennn) && defined($emmm) && $ennn && $emmm && ($ennn != $emmm));
  ($ennn, $emmm) = ($emmm, $ennn) if($ennn < $emmm); my $diff = $ennn - $emmm; my $answ = fact($ennn); my $mfct = fact($emmm); my $dfct = fact($diff);
  $mfct *= $dfct; return(0) unless($mfct);
  $answ /= $mfct; return($answ);
}
diginit(); # initialize the Dflt digit set whenever BaseCnv is used

127;

=head1 NAME

Math::BaseCnv - fast functions to CoNVert between number Bases

=head1 VERSION

This documentation refers to version 1.4.75O6Pbr of Math::BaseCnv, which was released on Thu May 24 06:25:37:53 2007.

=head1 SYNOPSIS

  use Math::BaseCnv;

  # CoNVert     63 from base-10 (decimal) to base- 2 (binary )
  $binary_63  = cnv(     63, 10,  2 );
  # CoNVert 111111 from base- 2 (binary ) to base-16 (hex    )
  $hex_63     = cnv( 111111,  2, 16 );
  # CoNVert     3F from base-16 (hex    ) to base-10 (decimal)
  $decimal_63 = cnv(   '3F', 16, 10 );
  print "63 dec->bin $binary_63 bin->hex $hex_63 hex->dec $decimal_63\n";

=head1 DESCRIPTION

BaseCnv provides a few simple functions for converting between arbitrary number bases.  It is as fast as I currently know how to make it (of course
relying only on the lovely Perl).  If you would rather utilize an object syntax for number-base conversion, please see Ken Williams's
<Ken@Forum.Swarthmore.Edu> fine L<Math::BaseCalc> module.

=head1 PURPOSE

The reason I created BaseCnv was that I needed a simple way to convert quickly between the 3 number bases I use most (10, 16, && 64).  It turned out
that it was trivial to handle any arbitrary number base that is represented as characters.  High-bit ASCII has proven somewhat problemmatic but at least
BaseCnv can simply && realiably convert between any possible base between 2 && 64 (or 85).  I'm happy with it && employ b64() in places I probably
shouldn't now =).

=head1 USAGE

=head2 cnv($numb[,$from[,$tobs]])

CoNVert the number contained in $numb from its current number base ($from) into the result number base ($tobs).

B<When only $numb is provided as a parameter:>

If $numb only contains valid decimal (base 10) digits, it will be converted to hexadecimal (base 16).

If $numb only contains valid hexadecimal (base 16) digits or begins with '0x', it will be it will be converted to decimal (base 10).

B<When only $numb && $from are provided as parameters:>

cnv() assumes that $numb is already in decimal format && uses $from as the $tobs.

B<When all three parameters are provided:>

The normal (&& most clear) usage of cnv() is to provide all three parameters where $numb is converted from $from base to $tobs.

cnv() is the only function that is exported from a normal 'use Math::BaseCnv;' command.  The other functions below can be imported to local namespaces
explicitly or with the following tags:

  :all - every function described here
  :hex - only dec() && hex()
  :b64 - only b10() && b64() && b64sort() && cnv()
  :dig - only dig() && diginit()
  :sfc - only summ(), fact(), && choo()

=head2 b10($b64n)

A shortcut to convert the number given as a parameter ($b64n) from base 64 to decimal (base 10).

=head2 b64($b10n)

A shortcut to convert the number given as a parameter ($b10n) from decimal (base 10) to base 64.

=head2 b64sort(@b64s)

A way to sort b64 strings as though they were decimal numbers.

=head2 dec($b16n)

A shortcut to convert the number given as a parameter ($b16n) from hexadecimal (base 16) to decimal (base 10).

=head2 hex($b10n)

A shortcut to convert the number given as a parameter ($b10n) from decimal (base 10) to hexadecimal (base 16).

Please read the L<"NOTES"> regarding hex().

=head2 dig(\@newd)

Assign the new digit character list to be used in place of the default one.  dig() can also alternately accept a string name matching one of the
following predefined digit sets:

  'bin' => ['0', '1']
  'oct' => ['0'..'7']
  'dec' => ['0'..'9']
  'hex' => ['0'..'9', 'a'..'f']
  'HEX' => ['0'..'9', 'A'..'F']
  'b62' => ['0'..'9', 'a'..'z', 'A'..'Z']
  'm64' => ['A'..'Z', 'a'..'z', '0'..'9', '+', '/'] # MIME::Base64
  'b64' => ['0'..'9', 'A'..'Z', 'a'..'z', '.', '_'] 
  'b85' => ['0'..'9', 'A'..'Z', 'a'..'z', '!', '#', # RFC 1924 for
            '$', '%', '&', '(', ')', '*', '+', '-', #   IPv6 addrs
            ';', '<', '=', '>', '?', '@', '^', '_', #   like in
            '`', '{', '|', '}', '~'               ] # Math::Base85

If no \@newd list or digit set name is provided as a parameter, dig() returns the current character list.  It's fine to have many more characters
in your current digit set than will be used with your conversions (e.g., using dig('b64') works fine for any cnv() call with $from && $tobs params
less than or equal to 64).

An example of a \@newd parameter for a specified alternate digit set for base 9 conversions is:

  dig( [ qw( n a c h o z   y u m ) ] );

=head2 diginit()

Resets the used digit list to the initial default order of the predefined digit set: 'b64'.  This is simply a shortcut for calling dig('b64') for
reinitialization purposes.

=head2 summ($numb)

A simple function to calculate a memoized summation of $numb down to 1.

=head2 fact($numb)

A simple function to calculate a memoized factorial of $numb.

=head2 choo($ennn, $emmm)

A simple function to calculate a memoized function  of $ennn choose $emmm.

=head1 NOTES

The Perl builtin hex() function takes a hex string as a parameter && returns the decimal value (FromBase = 16, ToBase = 10) but this notation seems
counter-intuitive to me since a simple reading of the code suggests that a hex() function will turn your parameter into hexadecimal (i.e., It sounds
like Perl's hex() will hexify your parameter but it does not.) so I've decided (maybe foolishly) to invert the notation for my similar functions since
it makes more sense to me this way && will be easier to remember (I've had to lookup hex() in the Camel book many times already which was part of the
impetus for this module... as well as the gut reaction that sprintf() is not a proper natural inverse function for hex()).

This means that my b64() function takes a decimal number as a parameter && returns the base64 equivalent (FromBase = 10, ToBase = 64) && my b10()
function takes a base64 number (string) && returns the decimal value (FromBase = 64, ToBase = 10).  My hex() function overloads Perl's builtin version
with this opposite behavior so my dec() function behaves like Perl's normal hex() function.  I know it's confusing && maybe bad form of me to do this
but I like it so much better this way that I'd rather go against the grain.

Please think of my dec() && hex() functions as meaning decify && hexify.  Also the pronunciation of dec() is 'dess' (!'deck' which would be the inverse
of 'ink' which -- && ++ already do so well). After reading the informative Perl module etiquette guidelines, I now  appreciate the need to export as
little as is necessary by default. So to be responsible, I have limited BaseCnv exporting to only cnv() under normal circumstances.  Please
specify the other functions you'd like to import into your namespace or use the tags described above in the cnv() section like:

  'use Math::BaseCnv qw(:all !:hex);'

Error checking is minimal.

This module does not handle fractional number inputs because I like using the dot (.) character as a standard base64 digit since it makes for clean filenames.

summ(), fact(), && choo() are general Math function utilities which are unrelated to number-base conversion but I didn't feel like making another separate
module just for them so they snuck in here.

I hope you find Math::BaseCnv useful.  Please feel free to e-mail me any suggestions or coding tips or notes of appreciation ("app-ree-see-ay-shun").
Thank you.  TTFN.

=head1 2DO

=over 2

=item - better error checking

=item - handle fractional parts? umm but I like using '.' as a b64 char so ',' comma or some other separator?

=item -    What else does BaseCnv need?

=back

=head1 CHANGES

Revision history for Perl extension Math::BaseCnv:

=over 2

=item - 1.4.75O6Pbr  Thu May 24 06:25:37:53 2007

* added Test::Pod(::Coverage)? tests && PREREQ entries

* added b85 for IPv6, gen'd META.yml (w/ newline before EOF), up'd minor ver

=item - 1.2.68J9uJQ  Sat Aug 19 09:56:19:26 2006

* added b64sort() && put pod at bottom

=item - 1.2.59M7mRX  Thu Sep 22 07:48:27:33 2005

* testing Make as primary and BuildPL backup (needing rename for dot)

=item - 1.2.59IBlgw  Sun Sep 18 11:47:42:58 2005

* testing just using Module::Build instead of MakeMaker

* fixed test 12 which was failing on AMD64

* added Build.PL to pkg

=item - 1.2.54HK3pB  Sun Apr 17 20:03:51:11 2005

* removed 128 digit-set since some hi-bit chars cause probs on Win32

* made bin/cnv only executable to go in EXE_FILES

* made Math::BaseCalc a link in pod && updated License

=item - 1.2.45UC8fo  Sun May 30 12:08:41:50 2004

* tidied POD && upped minor version number since CPAN can't read PTVR

=item - 1.0.44E9ljP  Wed Apr 14 09:47:45:25 2004

* added test for div-by-zero error in choo()

* added summ()

=item - 1.0.446EIbS  Tue Apr  6 14:18:37:28 2004

* snuck in fact() && choo()

=item - 1.0.42REDir  Fri Feb 27 14:13:44:53 2004

* changed test.pl to hopefully pass MSWin32-x86-multi-thread

=item - 1.0.428LV46  Sun Feb  8 21:31:04:06 2004

* broke apart CHANGES to descend chronologically

* made dec() auto uppercase param since dec(a) was returning 36 instead of 10

=item - 1.0.41M4GMP  Thu Jan 22 04:16:22:25 2004

* put cnv in bin/ as EXE_FILES

=item - 1.0.418BEPc  Thu Jan  8 11:14:25:38 2004

* testing new e auto-gen MANIFEST(.SKIP)?

=item - 1.0.3CNH37s  Tue Dec 23 17:03:07:54 2003

* updated POD

=item - 1.0.3CG3dIx  Tue Dec 16 03:39:18:59 2003

* normalized base spelling

=item - 1.0.3CD1Vdd  Sat Dec 13 01:31:39:39 2003

* added ABSTRACT section to WriteMakeFile()

* changed synopsis example

* updated all POD indenting

=item - 1.0.3CCA5Mi  Fri Dec 12 10:05:22:44 2003

* removed indenting from POD NAME field

=item - 1.0.3CB7M43  Thu Dec 11 07:22:04:03 2003

* updated package to coincide with Time::Fields release

=item - 1.0.39B36Lv  Thu Sep 11 03:06:21:57 2003

* synchronized POD with README documentation using new e utility

* templatized package compilation

* fixed boundary bugs

=item - 1.0.37SLNGN  Mon Jul 28 21:23:16:23 2003

* first version (&& my first Perl module... yay!) put on CPAN

=item - 1.0.37JKj3w  Sat Jul 19 20:45:03:58 2003

* reworked interface from shell utility to package

=item - 1.0.3159mLT  Sun Jan  5 09:48:21:29 2003

* original version

=back

=head1 INSTALL

Please run:

  `perl -MCPAN -e "install Math::BaseCnv"`

or uncompress the package && run:

  `perl Makefile.PL;       make;       make test;       make install`
    or if you don't have  `make` but Module::Build is installed
  `perl    Build.PL; perl Build; perl Build test; perl Build install`

=head1 LICENSE

Most source code should be Free!  Code I have lawful authority over is && shall be!
Copyright: (c) 2003-2007, Pip Stuart.
Copyleft :  This software is licensed under the GNU General Public License (version 2).  Please consult the Free Software Foundation (HTTP://FSF.Org)
  for important information about your freedom.

=head1 AUTHOR

Pip Stuart <Pip@CPAN.Org>

=cut
