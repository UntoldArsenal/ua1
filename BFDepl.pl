#!/usr/bin/perl -w
use strict;
use diagnostics;

=pod

=head1 BFDepl.pl

This program is a very simple model of a football league (some would
call it soccer), in particular a 20 team league.  This league has each
team play every other team twice, home and away.  This model
calculates the score of both teams in a particular game as random
deviates drawn from a Poisson distribution, where the "average rate"
used for the Poisson comes from the C<$league> structure below.

As is good form in Perl, the program has warnings (perl -w) turned on,
and has strict turned on (use strict).  Out of habit, I usually have
diagnostics turned on (use diagnostics).

There are two CPAN modules called: C<Math::Random::MT::Auto> and
C<Math::Random>.  From the first module, we are bringing in the
C<rand> function, which overloads the standard Perl 'rand' function.
We don't want a Monte Carlo simulation to deplete the entropy the OS
kernel needs to function on the Internet, so we use a Mersenne Twister
instead of /dev/random.  The second module is bringing in the Poisson
generator.

The C<finish> element of league was never used.

As written, this program assumes you are running this inside a
debugger, and that you stop (set a breakpoint) at the last executable
line of the program (line 225).

=cut

use Math::Random::MT::Auto qw(rand);
use Math::Random qw(random_poisson);

my $league = {
    '0' => {
	ave => 2.6,
	finish => [],
    },
    '1' => {
	ave => 2.55,
	finish => [],
    },
    '2' => {
	ave => 2.45,
	finish => [],
    },
    '3' => {
	ave => 2.4,
	finish => [],
    },
    '4' => {
	ave => 1.075,
	finish => [],
    },
    '5' => {
	ave => 1.065,
	finish => [],
    },
    '6' => {
	ave => 1.055,
	finish => [],
    },
    '7' => {
	ave => 1.045,
	finish => [],
    },
    '8' => {
	ave => 1.035,
	finish => [],
    },
    '9' => {
	ave => 1.025,
	finish => [],
    },
    '10' => {
	ave => 1.015,
	finish => [],
    },
    '11' => {
	ave => 1.005,
	finish => [],
    },
    '12' => {
	ave => 0.995,
	finish => [],
    },
    '13' => {
	ave => 0.985,
	finish => [],
    },
    '14' => {
	ave => 0.975,
	finish => [],
    },
    '15' => {
	ave => 0.965,
	finish => [],
    },
    '16' => {
	ave => 0.955,
	finish => [],
    },
    '17' => {
	ave => 0.945,
	finish => [],
    },
    '18' => {
	ave => 0.935,
	finish => [],
    },
    '19' => {
	ave => 0.925,
	finish => [],
    },
};
my @teams = sort {$a <=> $b} keys( %$league );

my $count1234Rest = {};
my $not1234 = 0;

# Run for 1000 seasons
for( my $trial = 0; $trial < 1000; $trial++ ) {
    my $season = [];
    my $team = {};
    my( $min, $max );
    # Loop over all the games in the league
    foreach my $t1 (@teams) {
	foreach my $t2 (@teams) {
	    next if $t2 eq $t1;
	    my $hscore = random_poisson( 1, $league->{$t1}{ave} );
	    my $ascore = random_poisson( 1, $league->{$t2}{ave} );
	    my $hpoints = 1;
	    my $apoints = 1;
	    if( $hscore != $ascore ) {
		if( $hscore > $ascore ) {
		    $hpoints = 3;
		    $apoints = 0;
		} else {
		    $hpoints = 0;
		    $apoints = 3;
		}
	    }
	    my $h = {
		home => $t1,
		away => $t2,
		hscore => $hscore,
		ascore => $ascore,
		hpoints => $hpoints,
		apoints => $apoints,
	    };
	    #my $title = "$home:$away";
	    push @$season, $h;
	    $team->{$t1} = {
		points => 0,
		home => [],
		away => [],
	    } unless exists $team->{$t1};
	    push @{$team->{$t1}{home}}, $h;
	    $team->{$t1}{points} += $hpoints;

	    $team->{$t2} = {
		points => 0,
		home => [],
		away => [],
	    } unless exists $team->{$t2};
	    push @{$team->{$t2}{away}}, $h;
	    $team->{$t2}{points} += $apoints;
	}
    }

    # Now we process the league results.  This starts by sorting the
    # keys of the hash based on how many points that team (the key)
    # obtained.
#    print "We can process season/team here\n";
    my @sx = sort {$team->{$b}{points} <=> $team->{$a}{points}} keys( %$team );
#    if( ($sx[0] eq '0' && $sx[1] eq '1') ||
#	($sx[0] eq '1' && $sx[1] eq '0')    ) {
    if( $sx[0] < 4 && $sx[1] < 4 &&
	$sx[2] < 4 && $sx[3] < 4    ) {
	my $tdiff = $team->{$sx[3]}{points} - $team->{$sx[4]}{points};
	$count1234Rest->{$tdiff}++;
    } else {
	$not1234++;
    }
    $min = $team->{$sx[0]}{points};
    $max = $team->{$sx[0]}{points};
    $min = $min < $team->{$sx[1]}{points} ? $min : $team->{$sx[1]}{points};
    $max = $max > $team->{$sx[1]}{points} ? $max : $team->{$sx[1]}{points};
    #$min = $min < $team->{$sx[2]}{points} ? $min : $team->{$sx[2]}{points};
    #$max = $max > $team->{$sx[2]}{points} ? $max : $team->{$sx[2]}{points};
    #$min = $min < $team->{$sx[3]}{points} ? $min : $team->{$sx[3]}{points};
    #$max = $max > $team->{$sx[3]}{points} ? $max : $team->{$sx[3]}{points};
    printf("%d T%1d %03d ", $max-$min, 0, $team->{'0'}{points} );
    printf("T%1d %03d * ",             1, $team->{'1'}{points} );
#    print "Team 0 points $team->{'0'}{points} *";
    printf("T%02d %03d ", $sx[0], $team->{$sx[0]}{points} );
    printf("T%02d %03d ", $sx[1], $team->{$sx[1]}{points} );
    printf("T%02d %03d ", $sx[2], $team->{$sx[2]}{points} );
    printf("T%02d %03d * ", $sx[3], $team->{$sx[3]}{points} );
#    print " T$sx[0] $team->{$sx[0]}{points} ";
#    print " T$sx[1] $team->{$sx[1]}{points} ";
#    print " T$sx[2] $team->{$sx[2]}{points} ";
#    print " T$sx[3] $team->{$sx[3]}{points} * ";
    printf("T%02d %03d ", $sx[-3], $team->{$sx[-3]}{points} );
    printf("T%02d %03d ", $sx[-2], $team->{$sx[-2]}{points} );
    printf("T%02d %03d\n", $sx[-1], $team->{$sx[-1]}{points} );
#    print " T$sx[-3] $team->{$sx[-3]}{points} ";
#    print " T$sx[-2] $team->{$sx[-2]}{points} ";
#    print " T$sx[-1] $team->{$sx[-1]}{points}\n";

}

# For me running this in emacs, I copy the first line to the command
# buffer and execute it (another sorting operation), and then I copy
# the second line to the command buffer and execute it (prints things
# out).

# @z = sort {$count12Rest->{$a} <=> $count12Rest->{$b}} keys(%$count12Rest)
# foreach my $iz (@z) { print "$iz\t$count12Rest->{$iz}\n"; }
print "done\n";
