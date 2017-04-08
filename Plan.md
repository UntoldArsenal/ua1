# A Suggestion on Plans

I started this with a program written in Perl.  I am not going to try
and convince people to use Perl.  If you want to use Perl, that is
fine.  If not, well I hope we can get whatever it is you translated
to, to be part of this.

I suspect that if you asked every "good" Perl programmer in the world
to write a program to do a specific task, and compared that to similar
requests in other languages; you would probably find a wider
distribution of solutions with Perl.  This doesn't mean Perl is
superior in any way.  It does mean that it can be more work for
someone to translate something from Perl to another language.

At some point, I think we want a database.  There are other football
(soccer) databases.  And, none really impress me.  There is
information missing that I want.  But to me the most important part,
is that there is no easy way to include referee reviews done by
UntoldArsenal in any of those databases.

I am not suggesting that the referee reviews that UntoldArsenal has
done, will be part of any database that we put up here (at github).
That is a decision for Walter, Tony and others to decide on.  All we
can do here, is make it possible to include many commentaries on a
game, in a database.  Or, that is how I read it.

## Databases - DBI and DBD

As near as I can tell, the first database interface which works in the
context I think is appropriate was in Perl.  It was called DBI, and it
has components that are part of a DBD namespace.  And I suspect if you
go looking at other languages like Python, Ruby and others; they will
tend to have all of this under a DBI namespace and probably have
specific dbase support under DBD namespaces.  Which should mean that
all work here, at least as far as databases goes, should just "work"
regardless of language.  They are all following the same ABI.

I think DBI nominally assumes we are storing data in a SQL database.
But, SQL is not really a standard.  I don't know if Perl DBI supports
non-SQL databases, I've never been inclined to look.  A few years ago,
there were a number of these that were popular.

### Develop on SQLite and Production on PostgreSQL?

While Mysql was probably what become the most popular (remember
LAMP?), I think the Open Source beacon on databases is probably
PostgreSQL.  If you are thinking of comparing Oracle, DB2, or other
commercial databases to something in Open Source, I think PostgreSQL
is what you will be comparing to.

So, I would think that in the sense of doing anything to the limit, we
should be happy if what we do works with PostgreSQL as the backend
database.  As far as development work goes, I kind of lean towards
SQLite(3).  It nominally follows the same syntax as PostgreSQL, but it
does not really enforce data typing at all.  If you want to stuff a
GIF into a boolean variable, it will probably let you do it.

If you want to store on other databases, that is wonderful.  I know
nothing about M$ (Micro$oft) databases (or anything else from them)
that is extensive, so I would not be of any help with problems related
to anything from M$.

## Library Support

Perl (via CPAN) has interfaces to zillions of things.  A lot of that
work is done in Perl, and you shouldn't expect that it would be
difficult to interface Perl to Perl.  But there is also a lot done in
SWIG and XS, which interfaces Perl to C or other.  Usually libraries.
But we can even use Inline (and daughters) to do little tiny things in
other languages with Perl.

If someone has interfaced a specific library to Perl (Python, Ruby,
...), it is likely true that same library has been interfaced to all
the other languages.  Which means it shouldn't be too difficult to
translate.  If we are lucky.  If the wind is blowing from the correct
direction.

### Statistics - Try to Use R

In terms of statistics, you might have a zillion options as to how to
calculate something.  I will suggest that if you have an option of
calculating something statistical via the R language, you should pick
that.  All the people that spend all day doing statistics, are
probably doing it in R (the Open Source version of S).  Or doing it in
S.  Or doing it in a proprietary thing that is supposed to be like S.
I don't have any experience in calling R from Perl, it is on my TODO
list.

### Statistics - No Support in R

Properly propagating error through calculations can be a bear of a
problem.  If there doesn't happen to be tools in R which can solve a
problem _AND_ supply estimates on precision, there might be another
way.

Perl has a module called Number::WithError.  With it, you can do all
the calculations one might ordinarily do (probably much slower).  But,
you can use it to propagate error (including different kinds of error)
through all the mathematical manipulations you are doing, so that you
can get an estimate of precision.

It may be that Python, Ruby, ... have similar modules.  I don't know.

The file calc2.pl sort of implements a command line RPN calculator
which grafts Number::WithError onto its usage.  As it stands, if
someone executes it it prints out 3 lines and quits.

## Matrix Inversion

Many people are surprised to learn that:

 (1.0 / 3.0) * 3.0 != 1.0

There are lots of numbers that cannot be represented in a finite
length floating point format.  And when these numbers turn up in the
middle of calculations, we lose the ability to test for equality.

One way to handle this, is to include bounds on a number, and then see
how the bounds change through calculations.

One place where this kind of problem really hits home, is when working
with matrices.  If the condition number of a matrix is large, it
becomes difficult to calculate an answer with precision.

People often look for fast solutions, and often one can find matrix
solutions that scale as N^2.  You are probably much better off using a
stable and slow method, such as Singular Value Decomposition (which
scales as N^3), that quickly calculating the wrong answer.

It is entirely possible you may need to use iterative methods to
improve a slow answer, making it even slower.

## Outliers

Outliers are data points which come from some different distribution
of data, than the one we are trying to find.  In many circumstances,
we seek to _prove_ that this point is not form the data we are looking
for, and hence we can ignore it.

Most of the tests for outliers that a person learns in unsophisticated
classes, can detect only a single outlier.  And you are not supposed
to apply this test iteratively.  If you ignore one data point
(presumably the worst case), you are not allowed to use that test
again.  Or even a similar test.

For much of history, that was the only game in town.  But, if you were
doing all the work with pencil and paper, presumably the survey was
conducted well enough that you only got a single outlier.  If you had
more than a single outlier, what you were then forced to do is to
switch to a more robust analysis method (which may mean you don't need
to ignore the outlier).  If you are trying to find the slope of a line
through the data, you might have to look for a median slope instead of
a mean slope.

If you take a data set upon which you are calculating a median slope,
and you start to change the value associated with a single data set,
it is possible that at one (or more) points, the value of the median
slope changes.  And it will do so in a discontinuous manner (it will
jump to a new value).  This is often not a desirable behavior.

Peirce's Criterion is a mechanism to recognize multiple outliers in a
set of data.  Within Peirce's Criterion is an assumption of Gaussian
distribution of points, which may not be acceptable.  There are other
tests now which can also be used to flag multiple outliers.  But, it
may be that switching to some computation intensive approach might be
better, in that you can use probability distributions actually present
in the data, instead of assuming some distribution.

