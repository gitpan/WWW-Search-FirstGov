# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use WWW::Search::FirstGov;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $test = 2;
my $engine = 'FirstGov';
my $search = new WWW::Search($engine);
print ref($search) ? '' : 'not ';
print "ok $test\n";

use WWW::Search::Test;

# This test returns no results (but we should not get an HTTP error):
$test++;
$search->native_query($WWW::Search::Test::bogus_query);
@results = $search->results();
$results = scalar(@results);
print (0 < $results) ? 'not ' : '';
print "ok $test\n";

# This query returns MANY pages of results:
$test++;
$query = 'commerce';
$search->native_query(WWW::Search::escape_query($query));
$results = $search->approximate_result_count();
if ($results == 0) {
  print STDERR " --- got $results results for $query, but expected more...\n";
  print 'not ';
}
print "ok $test\n";
