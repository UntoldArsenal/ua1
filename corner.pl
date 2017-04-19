#!/usr/bin/perl -w
use strict;
use diagnostics;

=pod

=head1 corner.pl - a program to explore trend change discovery

This is not a finished product.  This is a quick hack to produce some
data, an edit, produce some more data, and so on.

C<Statistics::OLS> is used to perform a straight line fit (regression)
of data to a line, C<Statistics::Distributions> is used to caclulate a
critical value of a T distribution and C<Math::Random> is used to
generate random Gaussian deviates.  Of course, whenever you may
generate lots of radnom deviates, it is better to replace the built-in
Perl random number generator, with the Mersenne Twister from
C<Math::Random>.

We set up an "old trend line" for 0 and negative X values, with a
slope of -1 and an intercept of zero (ideally), to which we add a
little Guassian noise (zero mean, small deviation).  I looked at three
use cases:

=over 4

=item 1 New trend has a slope of +1, which is a 90 degree change in
direction.

=item 2 New trend has a slope of 0, which is a 45 degree change in
direction.

=item 3 New trend has a slope of -0.5, which is a 22.5 degree change
in direction.

=back

We build our "old trend line" data, and then call C<Statistics::OLS>
to find the best fit (least squares) parameters for the data (which
will have a slope of about -1 and an intercept of about 0).

With the old trend defined, we need to calculate some data so that we
can determine if a new point is consistent with the old trend line.  I
am manually adding the new point (at X=1 or X=2), not using a
subroutine.

We then add new points (one at a time) to the old data set, and at
every step we recalculate a straight line fit to all the data.

 Process Trending with Piecewise Linear Smoothing
 Mah, R.S.H. and Tamhane, A.C. and Tung, S.H. and Patel, A.N.
 McCormick School of Engineering and Applied Sciences, Nowthwestern Univ
 Evanston, IL
 Computers Chem Eng V19N2, p129-137, 1995

Equation 3 on page 133 is the generic equation used to detect if a new
point is conistent or inconsistent with the old trend.

Nothing worthy of copyright here.  Sorry, I am mistaken.  Even if the
code is utilitarian and someone wants to cut and paste it, what
Copyright seeks prevent, is someone just taking this code and
presenting it as theirs.  Which includes the name of the program.  So, ...

Copyright 2017, Gordon Haverland <untold@materialisations.com>

=cut

use Statistics::OLS;
use Statistics::Distributions;
use Math::Random::MT::Auto qw(rand);
use Math::Random; # qw(random_normal);

my @data;
my $X = -4;
my $Y = 4 + random_normal( 1, 0, 0.2 );
my( @xlist, @ylist );
for( my $i = 0; $i < 4; $i++ ) {
    push @xlist, $X;
    push @ylist, $Y;
    $X += 1;
    $Y  = -1 * $X + random_normal( 1, 0, 0.2 );
}
push @xlist, $X;
push @ylist, $Y;
my $ls1 = Statistics::OLS->new();
$ls1->setData( \@xlist, \@ylist );
$ls1->regress();
my( $intercept, $slope ) = $ls1->coefficients();
my $r2 = $ls1->rsq();
print "$slope * X + $intercept\tR^2 = $r2\n";
my @predictedY = $ls1->predicted();
my @residuals  = $ls1->residuals();  # actual - predicted
my $nu = 3;
my $Tcrit = Statistics::Distributions::tdistr($nu, 0.05);  # 95th ?

my $sumYsq =  0;
my $AveX   = -2;# (-4, -3, -2, -1, 0) => -2
my $sumXsq =  0;
for( my $i = 0; $i <= $#xlist; $i++ ) {
    # Y_predicted = -X for this instance
    $sumYsq += (-1 * $xlist[$i] - $ylist[$i])**2;
    $sumXsq += ($xlist[$i] - $AveX)**2;
}
my $MSE = $sumYsq / scalar( @ylist );
my $yDiv = $Tcrit * sqrt( $MSE ) * sqrt(
    1 + (1 / scalar( @ylist )) * (1 - $AveX)**2 / $sumXsq
    );

for( my $i = 0; $i < 4; $i++ ) {
    $X += 1;
    $Y  = -0.5 * $X + random_normal( 1, 0, 0.2 );
    push @xlist, $X;
    push @ylist, $Y;

    my $ls2 = Statistics::OLS->new();
    $ls2->setData( \@xlist, \@ylist );
    $ls2->regress();
    ( $intercept, $slope ) = $ls2->coefficients();
    $r2 = $ls2->rsq();
    print "$slope * X + $intercept\tR^2 = $r2\n";
}


print "done\n";

__END__

  DB<1> p join ' ', @xlist
-4 -3 -2 -1 0
  DB<2> p join ' ', @ylist
4.04100 2.90887 1.909098 1.069 -0.01547
-0.995247615372912 * X + -0.00792284750513481	R^2 = 0.997828641491185
  DB<3> p $X 1    p $Y 0.817868363943318
-0.735099211541289 * X + 0.685806229379195	R^2 = 0.85523531857969
  DB<5> p $X 2    p $Y 2.02576715536951
-0.434010709854908 * X + 1.38834606664742	R^2 = 0.474922493496957
  DB<7> p $X 3    p $Y 3.04647007133689
-0.187331032000391 * X + 1.88170542235645	R^2 = 0.118704216424586
  DB<9> p  $X 4   p $Y 4.01298791439585
0.00470940933567278 * X + 2.20177282458322	R^2 = 8.26161896056257e-05
  DB<11> 


Slope 0
-0.97723027407033 * X + 0.0618937566373365	R^2 = 0.994104465627031
-0.859288836787847 * X + 0.376404256057291	R^2 = 0.971343951207652
-0.720296386247447 * X + 0.700719973984891	R^2 = 0.918863872438741
-0.595278441475825 * X + 0.950755863528136	R^2 = 0.851496610702225
-0.490148281802952 * X + 1.12597279631626	R^2 = 0.776752244877576


Slope -0.5
-1.00756229455015 * X + -0.0440611444355941	R^2 = 0.996045990057905
-0.91282389626234 * X + 0.208574584331891	R^2 = 0.983162595738439
-0.851365876613282 * X + 0.351976630179692	R^2 = 0.979441733495741
-0.798558794456686 * X + 0.457590794492884	R^2 = 0.975942166552371
-0.737349138235937 * X + 0.559606888194134	R^2 = 0.964953999315905


Slope -0.5, double the noise
-1.03805041647429 * X + -0.163474637254242	R^2 = 0.990806277807543
-0.923235568262571 * X + 0.142698291310353	R^2 = 0.973402634978713
-0.835426685037831 * X + 0.347585685501412	R^2 = 0.962215245171304
-0.776854712101173 * X + 0.464729631374729	R^2 = 0.960020313025032
-0.765263224846425 * X + 0.484048776799309	R^2 = 0.970330794777467
