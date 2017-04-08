#!/usr/bin/perl
use warnings;
use strict;

use Number::WithError;

=pod

=head1 calc.pl

Three related chunks of code from RosettaCode, not completely
implemented as subroutines.  The object is to show how
C<Number::WithError> can help with calculations.

This program only calls rpnCalc() 3 times, with 3 different argument
strings.  If a decimal place is present in a number, this program
assumes the error in the number is one half of the smallest
significant figure present.  And then when myE (of rpnCalc) goes to
C<eval> the string, the presence of the Number::WithError module will
overload many Perl operators so that the error in the calculation is
correctly propagated,

The subroutine toNWE does not look for the presence of a (leading)
sign, which is a bug.

There is no error trapping here.

Much of this code is lifted from RosettaCode.  The code lifted, is
rudimentally wrapped in a subroutine call, and preceeding that
subroutine is a comment saying where it comes from.  In a couple of
incidences, I have moved code.

The content I have contributed here, is the C<toNWE()> subroutine, and
modifying the C<myE()> subroutine.  I made some changes to take
content from a string, instead of reading STDIN.  It is only such
minor contributions I claim as mine.

Copyright 2017 Gordon Haverland untold@materialisations.com

=cut

# There are some variables holding regex common to routines, or almost common
# first one is from rpn2infix, second is from rpnCalc
my  $WSb = '(?:^|\s+)';
#my $WSb = '(?:^|\s+)';
my  $WSa = '(?:\s+|$)';
#my $WSa = '(?:\s+|$)';
#my $num = '([+-/$]?(?:\.\d+|\d+(?:\.\d*)?))';
#my $num = '([+-/]?(?:\.\d+|\d+(?:\.\d*)?))';
my  $op = '([-+*/^])';
#my $op = '([-+*/^])';

# These two hashes have been moved to the preamble part from infix2rpn
my %prec = (
    '^' => 4,
    '*' => 3,
    '/' => 3,
    '+' => 2,
    '-' => 2,
    '(' => 1
    );
 
my %assoc = (
    '^' => 'right',
    '*' => 'left',
    '/' => 'left',
    '+' => 'left',
    '-' => 'left'
    );

rpnCalc( '5 4 *' );         #  20 
rpnCalc( '5. 4.0 *' );      #  2.00e+01 +/- 2.0e+00 
rpnCalc( '5.00 4.000 *' );  #  2.0000e+01 +/- 2.0e-02 

print "done\n";


# From RosettaCode.org
# https://rosettacode.org/wiki/Parsing/RPN_to_infix_conversion
sub rpn2infix {
    my $input = shift;
    my @stack;
my $num = '([+-/$]?(?:\.\d+|\d+(?:\.\d*)?))';

    my @elems;
    while( <> )  {
	my $n = -1;
	while( s/$WSb$num\s+$num\s+$op$WSa/' '.('$'.++$n).' '/e ) {
#	    @elems[$n] = '('.$1.$3.$2.')';
	    $elems[$n] = '('.$1.$3.$2.')';
	}
#	while( s!(\$)(\d+)!@elems[$2]!e ) {
	while( s!(\$)(\d+)!$elems[$2]!e ) {
	}
	print(substr($_,2,-2)."\n");
    }
    return \@stack;
}

# https://rosettacode.org/wiki/Parsing/Shunting-yard_algorithm#Perl
sub infix2rpn {
 
    sub shunting_yard {
	my @inp = split ' ', $_[0];
	my @ops;
	my @res;
 
	my $report = sub { printf "%25s    %-7s %10s %s\n", "@res", "@ops", $_[0], "@inp" };
	my $shift  = sub { $report->("shift @_");  push @ops, @_ };
	my $reduce = sub { $report->("reduce @_"); push @res, @_ };
 
	while (@inp) {
	    my $token = shift @inp;
	    if    ( $token =~ /\d/ ) { $reduce->($token) }
	    elsif ( $token eq '(' )  { $shift->($token) }
	    elsif ( $token eq ')' ) {
		while ( @ops and "(" ne ( my $x = pop @ops ) ) { $reduce->($x) }
	    } else {
		my $newprec = $prec{$token};
		while (@ops) {
		    my $oldprec = $prec{ $ops[-1] };
		    last if $newprec > $oldprec;
		    last if $newprec == $oldprec and $assoc{$token} eq 'right';
		    $reduce->( pop @ops );
		}
		$shift->($token);
	    }
	}
	$reduce->( pop @ops ) while @ops;
	@res;
    }
 
    local $, = " ";
    print shunting_yard '3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3';
 
}

# https://rosettacode.org/wiki/Parsing/RPN_calculator_algorithm#Perl
# RPN calculator
#
# Nigel Galloway April 2nd., 2012
#
sub rpnCalc {
    my $input = shift;
my $num = '([+-/]?(?:\.\d+|\d+(?:\.\d*)?))';
    
    sub toNWE {
	my $str = shift;
	my $n = $str;
	if( index( $str, '.' ) != -1 ) {  # Has a decimal point
	    my $e = "$str";
	    $e =~ tr/123456789/000000000/;
	    $e .= '5';
	    $n = Number::WithError->new( $n, $e );
	}
	return $n;
    }
    sub myE {
	my $str1 = $1;
	my $str2 = $2;
	my $op   = $3;
	my $n1 = toNWE( $str1 );
	my $n2 = toNWE( $str2 );
	my $str = '($n1)'.$op.'($n2)';
	$str =~ s/\^/**/;
	return eval( $str );
    }
#    while( <> ) {
	while( $input =~ s/$WSb$num\s+$num\s+$op$WSa/' '.myE().' '/e ) {}
#	print ($_, "\n");
	print($input, "\n");
#    }
 
}
