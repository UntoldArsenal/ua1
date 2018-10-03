#!/usr/bin/perl
use warnings;
use strict;
use diagnostics;

# Simple program to calculate correlations between goals against,
# points and standing at end of season for Arsenal.  The data is
# from Tony's article at UntoldArsena https://untold-arsenal.com/archives/71544
# Untold@materialisations.com
# October, 2018  Gordon Haverland

my $dat = [
    ['1997-98',   0, 33, 78, 1],
    ['1998-99',   1, 17, 78, 2],
    ['1999-2000', 2, 43, 73, 2],
    ['2000-01',   3, 38, 70, 2],
    ['2001-02',   4, 36, 87, 1],
    ['2002-03',   5, 42, 78, 2],
    ['2003-04',   6, 26, 90, 1],
    ['2004-05',   7, 36, 83, 2],
    ['2005-06',   8, 31, 67, 4],
    ['2006-07',   9, 35, 68, 4],
    ['2007-08',  10, 31, 83, 3],
    ['2008-09',  11, 37, 72, 4],
    ['2009-10',  12, 41, 75, 3],
    ['2010-11',  13, 43, 68, 4],
    ['2011-12',  14, 49, 70, 3],
    ['2012-13',  15, 37, 73, 4],
    ['2013-14',  16, 41, 79, 4],
    ['2014-15',  17, 36, 75, 3],
    ['2015-16',  18, 36, 71, 2],
    ['2016-17',  19, 44, 75, 5],
    ['2017-18',  20, 51, 63, 6],
    ];

use Statistics::Basic qw(:all);

my @vector;
for( my $i = 1; $i < 5; $i++ ) {
    $vector[$i] = getVector( $dat, $i );
    printf( "%1d: %6.2f %3d %5.2f %5.2f\n",
	    $i, mean( $vector[$i] ), median( $vector[$i] ), variance( $vector[$i] ),  stddev( $vector[$i] ) );
}
print "\n";
my $corr = correlation( $vector[1], $vector[2] );
print "correlation of year and GAgainst is $corr\n";
$corr = correlation( $vector[1], $vector[3] );
print "correlation of year and points is $corr\n";
$corr = correlation( $vector[1], $vector[4] );
print "correlation of year and standing is $corr\n";

$corr = correlation( $vector[2], $vector[3] );
print "correlation of GAgainst and points is $corr\n";
$corr = correlation( $vector[2], $vector[4] );
print "correlation of GAgainst and standing is $corr\n";

$corr = correlation( $vector[3], $vector[4] );
print "correlation of points and standing is $corr\n";

print "done\n";

sub getVector {
    my $list  = shift;
    my $index = shift;

    my $rlist = [];
    foreach my $d (@$list) {
	push @$rlist, $d->[$index];
    }
    return vector( $rlist );
}
