# FirstGov.pm
# by Dennis Sutch
#

package WWW::Search::FirstGov;


=head1 NAME

WWW::Search::FirstGov - class for searching http://www.firstgov.gov

=head1 SYNOPSIS

    use WWW::Search;
    my $search = new WWW::Search('FirstGov'); # cAsE matters
    my $query = WWW::Search::escape_query("uncle sam");
    $search->native_query($query);
    while (my $result = $search->next_result()) {
      print $result->url, "\n";
    }

=head1 DESCRIPTION

Class specialization of WWW::Search for searching F<http://www.firstgov.gov>.

FirstGov.gov can return up to 100 hits per page.

This class exports no public interface; all interaction should
be done through WWW::Search objects.

=head1 OPTIONS

The following search options can be activated by sending a hash as the
second argument to native_query().

=head2 Result Set Partitioning

=over 4

=item   { 'begin_at' => '100' }

Retrieve results starting at 100th match.

This option is not passed to FirstGov.gov.  Instead, this option is used to
set 'fr', 'act.next.x' and 'act.next.y' options to obtain results starting
the requested starting point.

=item   { 'fr' => '100' }

Retrieve results starting at the 100th match, when 'act.next.x' and
'act.next.y' options are set.  Otherwise results start at the 100th less
the value of the 'nr' option.

Note: Do not use this option.  Use the 'begin_at' option instead.

=item   { 'act.next.x' => '1', 'act.next.y' => '1' }

Retrieve next set of results, starting at the value of the 'fr' option plus
the value of the 'nr' option.

Note: Do not use this option.

=item   { 'act.prev.x' => '1', 'act.prev.y' => '1' }

Retrieve previous set of results, starting at the value of the 'fr' option
less the value of the 'nr' option.

Note: Do not use this option.

=item   { 'nr' => '40' }

Retrieve 40 results.

FirstGov.gov returns no more than 100 results at a time.  In addition, when
the 'nr' option is set to 100, FirstGov.gov treats the 'de' paramater as if it
is set to 'brief', returning results without descriptions.

From FirstGov.gov documentation:

The Number of Results parameter (nr) allows you or the user to set how many
search "hits" appear on each search results page.  If this parameter is not
used, nr is defaulted to 10.

=back

=head2 Query Terms

From FirstGov.gov documentation:

You may have noticed many parameters are suffixed by the number zero (0).
This number essentially groups a set of search parameters sharing the same
suffix number together to form a query statement.  It is possible to link
two or more such statements together.  You might have guessed that this is
accomplished by creating another set of search parameters, this time suffixed
by the number one (1) or higher.  Just be careful to keep track of parameters
and follow the same guidelines as outline above.  For example if you have an
mw0, have corresponding ms0, mt0, etc. parameters.  For each mw1, set its own
corresponding ms1, mt1, etc. parameters.  Be forewarned that the more
complicated the query, the longer it may take to process.

=over 4

=item   { 'mw0' => 'uncle sam' }

Return results that contain the words 'uncle' and 'sam'.

The native_query() method sets this option.

Note: Do not use the 'mw0' option, instead use the native_query() method and
the 'mw1', 'mw2', ... options.  

From FirstGov.gov documentation:

The Main Words parameter is represented by the input field named mw0.  This
is a text input field that allows a user to enter the word or words they
would like to search for.  

=item   { 'mt0' => 'all' }
=item   { 'mt0' => 'any' }
=item   { 'mt0' => 'phrase' }

From FirstGov.gov documentation:

The Main Type field (mt0) is used to specify how you want to search for the
words entered in the mw0 field.  You can search for documents containing all
the words provided, any of the words provided, or documents containing the
exact phrase in the order the words are entered.  This is done by setting the
mt0 field to "all", "any", or "phrase".  If this field is not provided, it is
defaulted to "all".

=item   { 'ms0' => 'should' }
=item   { 'ms0' => 'mustnot' }

From FirstGov.gov documentation:

Main Sign field (ms0) further specifies your search.  It can be used to specify
whether words should or must not be present in the document.  This is done by
setting the ms0 field to "should" or "mustnot".  If this field is not provided,
it is defaulted to "should".

=item   { 'in0' => 'anywhere' }
=item   { 'in0' => 'home' }
=item   { 'in0' => 'title' }

From FirstGov.gov documentation:

The In parameter (in0) can be implemented to tell the search engine where
specifically to search.  Setting in0 to "anywhere" searches the complete web
page of all web pages in a particular database.  Setting in0 to "home"
searches only the home pages of websites in a particular database.  Setting
in0 to "title" searches only the Titles of web pages of a particular database.

=item   { 'in0' => 'title', 'dom0' => 'doc.gov' }

The query is limited to searching the doc.gov domain.

From the FirstGov.gov documentation:

Setting in0 to "domain" allows you to search only a certain domain or domains,
or domain/path combinations.  Use of this attribute also requires an
additional parameter, the Domain parameter (dom0).  The Domain parameter (dom0),
when used with in0="domain", allows searching of specific domains or
domain/path combinations as described above.  This is useful if you want
a "site search" for your website.  To do this, you could set in0 to domain
and then dom0 to yourdomain.com.  This would ensure that users are only
searching web pages within your domain.  In fact, you may specify as many
domain or domain/path combinations up to 20 that you would like to limit your
searches to.  You can use any combination of domains or domain/path elements
as long as they are separated by a comma or a space.

=item   { 'pl' => 'domain', 'domain' => 'osec.doc.gov+itd.doc.gov' }

The query is limited to searching the domains osec.doc.gov and itd.doc.gov.

These parameters are no longer used by FirstGov.gov.  FirstGov.gov currently
accepts these parameters, but converts them to 'in0' and 'dom0' parameters in
the forms of returned pages.

Note: It is suggested that these options not be used.  Use the 'in0' and
'dom0' options instead.

=back

=head2 Specifying Federal and/or State Government Databases

=over 4

=item   { 'db' => 'www' }

From FirstGov.gov documentation:

The Database field (db) allows you to specify if a search should query
Federal Government websites, State Government websites, or both.  This is done
by setting db to "www" for a Federal Search, setting db to "states" for a
State Search, or "www-fed-all" to search both.  If you are using the
Database field, and allowing the State Search option, it is highly recommended
you also provide a State Field.  If the db field is not provided, it is
defaulted to Federal.

=item   { 'st' => 'NY' }

From FirstGov.gov documentation:

The State field (st) allows you to search for government websites of a
specific state or territory.  If you are a state agency and want users
to only search your state's web pages, set this field to your state's
abbreviation from the list provided below.  (Be sure to have set the db
field to states!)  If a state is not selected it will default to search
All States (AS).  List of State and Territory Abbreviations for FirstGov
Searching:
AS - All States,
AL - Alabama,
AK - Alaska,
AZ - Arizona,
AR - Arkansas,
CA - California,
CO - Colorado,
CT - Connecticut,
DC - D.C.,
DE - Delaware,
FL - Florida,
GA - Georgia,
HI - Hawaii,
ID - Idaho,
IL - Illinois,
IN - Indiana,
IA - Iowa,
KS - Kansas,
KY - Kentucky,
LA - Louisiana,
ME - Maine,
MD - Maryland,
MA - Massachusetts,
MI - Michigan,
MN - Minnesota,
MS - Mississippi,
MO - Missouri,
MT - Montana,
NE - Nebraska,
NV - Nevada,
NH - New Hampshire,
NJ - New Jersey,
NM - New Mexico,
NY - New York,
NC - North Carolina,
ND - North Dakota,
OH - Ohio,
OK - Oklahoma,
OR - Oregon,
PA - Pennsylvania,
RI - Rhode Island,
SC - South Carolina,
SD - South Dakota,
TN - Tennessee,
TX - Texas,
UT - Utah,
VT - Vermont,
VA - Virginia,
WA - Washington,
WV - West Virginia,
WI - Wisconsin,
WY - Wyoming,
SA - American Samoa,
GU - Guam,
MP - Mariana Islands,
MH - Marshall Islands,
FM - Micronesia,
PR - Puerto Rico,
VI - Virgin Islands.

=back

=head2 Format of Returned Results

=over 4

=item   { 'de' => 'detailed' }

Request FirstGov.gov to return detailed results.

This option may be set to either 'detailed' or 'brief'.  Detailed results
contain result numbers, URLs, page titles, and descriptions.  Brief results
contain result numbers, URLs, and page titles.

When the 'nr' option is set to '100', FirstGov.gov treats the 'de' paramater
as if it is set to 'brief', returning results without descriptions.

Note: It is suggested that this option not be used (since this class was
developed using detailed results.

From FirstGov.gov documentation:

The Results Format parameter (de) allows you or the user to specify how
results will be displayed.  Results can be returned with a title and brief
summary of the content, or just listing the title of the web page.  Use:
Simply set the de parameter to "brief" or "detailed".  If this parameter is
not used, de is defaulted to "detailed".

=item   { 'rn' => '2' }

Request FirstGov.gov to return pages using affiliate #2's page format.

This option is used by FirstGov.gov to return result  pages customized
with headers and footers for the affiliate as identified by the 'rn' option.

When not set, FirstGov.gov currently sets the 'rn' parameter to '2'.

Note: It is suggested that this option not be used (since this class was
developed using results returned with the 'rn' option not set).

From FirstGov.gov documentation:

The Referrer Name (rn) field is used to uniquely identify your affiliate.
Each Affiliate, upon registration, is assigned a referrer ID that corresponds
to it.

=back

=head1 SEE ALSO

To make new back-ends, see L<WWW::Search>,
or the specialized AltaVista searches described in options.

=head1 HOW DOES IT WORK?

C<native_setup_search> is called before we do anything.
It initializes our private variables (which all begin with underscores)
and sets up a URL to the first results page in C<{_next_url}>.

C<native_retrieve_some> is called (from C<WWW::Search::retrieve_some>)
whenever more hits are needed.  It calls the LWP library
to fetch the page specified by C<{_next_url}>.
It parses this page, appending any search hits it finds to
C<{cache}>.  If it finds a ``next'' button in the text,
it sets C<{_next_url}> to point to the page for the next
set of results, otherwise it sets it to undef to indicate we're done.

=head1 AUTHOR

C<WWW::Search::FirstGov> is written and maintained
by Dennis Sutch - <dsutch@doc.gov>.

=head1 LEGALESE

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=head1 BUGS

None reported.

=head1 VERSION HISTORY

1.11  2002-03-13 - Upated to reflect changed FirstGov search engine parameters.
                   approximate_result_count() now returns 1 more than the result count when FirstGov's result count is "more than X relevant results". 
                   Changed test case 4 (in test.pl) to finish sooner.

1.10  2002-03-05 - Updated to handle new FirstGov search engine format and to use HTML::TreeBuilder.
                   Fixed problem that caused one too many searches against FirstGov.gov.
                   Documented additional options, including adding notes from FirstGov.gov documentation.

1.04  2001-07-16 - Fixed parsing problem.

1.03  2001-03-01 - Removed 'require 5.005_62;'.

1.02  2001-03-01 - Removed 'my' declarations for package variables.

1.01  2001-02-26 - Fixed problem with quoted sring on MSWin.
                   Removed 'our' declarations.

1.00  2001-02-23 - First publicly-released version.

=cut

#####################################################################
use strict;

require Exporter;
@WWW::Search::FirstGov::EXPORT = qw();
@WWW::Search::FirstGov::EXPORT_OK = qw();
@WWW::Search::FirstGov::ISA = qw( WWW::Search Exporter );
$WWW::Search::FirstGov::VERSION = '1.11';

$WWW::Search::FirstGov::MAINTAINER = 'Dennis Sutch <dsutch@doc.gov>';

use Carp ();
use WWW::Search( 'generic_option' );
require WWW::SearchResult;

my $default_option = {
		'search_url' => 'http://www.firstgov.gov/fgsearch/index.jsp',
		'rn' => '2',
#		'mw0' => 'search words',
#		'Submit' => 'Go',
		'fr' => 0,  # return results starting at match number 'fr' plus or minus 'nr', when act.next.x and .y (or act.prev.x and .y) are set
		'nr' => 20,  # number of results returned per page (max = 100)
		'mt0' => 'all',  # match: "all" = All Words | "any" = Any Words | "phrase" = The Exact Phrase | "name" = A Person's Name | "urls" = Embedded URLs
		'ms0' => 'should',  # "should" = Should | "mustnot" = Must Not
		'db' => 'www',
#		'st' => 'AS',
#		'parsed' => 'true'
#		'de' => 'detailed',  # format of results (may be: "detailed" | "brief") Important: FirstGov.gov treats 'de' as 'brief' whenever 'nr' is set to 100
		'srcfrm' => 'query',  # seems to be required (added by FirstGov.gov's redirect)
		'parsed' => 'true',  # seems to be required (added by FirstGov.gov's redirect)
		};

sub native_setup_search {
	my($self, $native_query, $native_options_ref) = @_;
	$self->{'_debug'} = $native_options_ref->{'search_debug'};
	$self->{'_debug'} = 2 if ($native_options_ref->{'search_parse_debug'});
	$self->{'_debug'} = 0 if (!defined($self->{'_debug'}));

	print STDERR " + WWW::Search::FirstGov::native_setup_search()\n" if ($self->{'_debug'});

	$self->{'agent_name'} = ref($self) . '/' . $WWW::Search::FirstGov::VERSION;
	$self->user_agent('non-robot');
	$self->{'_next_to_retrieve'} = 0;

	$self->{'_num_hits'} = 0;

	if (! defined($self->{'_options'})) {
		foreach (keys %$default_option) {
			$self->{'_options'}{$_} = $default_option->{$_};
		}
		$self->{'_options'}{'mw0'} = $native_query;
	}
	if (defined($native_options_ref)) {
		foreach (keys %$native_options_ref) {
			$self->{'_options'}{$_} = $native_options_ref->{$_} if ($_ ne 'begin_at');
		}
	}
	# if user has set 'begin_at' option, then handle other options to get desired result
	if (exists($native_options_ref->{'begin_at'}) && defined($native_options_ref->{'begin_at'})) {
		my $begin_at = $native_options_ref->{'begin_at'} || 1;
		$begin_at = 1 if ($begin_at < 1);
		$self->{'_options'}{'fr'} = $begin_at - 1 - $self->{'_options'}{'nr'};
		$self->{'_options'}{'act.next.x'} = 1;
		$self->{'_options'}{'act.next.y'} = 1;
	}
	my $options = '';
	foreach (sort keys %{$self->{'_options'}}) {
		next if (generic_option($_));
		$options .= '&' if ($options);
		$options .= $_ . '=' . $self->{'_options'}{$_};
	}
	$self->{'_next_url'} = $self->{'_options'}{'search_url'} . '?' . $options;
}

sub parse_tree {
	my($self, $tree) = @_;

	print STDERR " + WWW::Search::FirstGov::parse_tree()\n" if ($self->{'_debug'});

	print STDERR " + result HTML page tree:\n" if ($self->{'_debug'} > 1);
	$tree->dump( *STDERR ) if ($self->{'_debug'} > 1);

	return undef if (! defined($self->{'_prev_url'}));  # fast exit if already done

	# approximate_result_count
	my $result_count = undef;
	my @td = $tree->look_down('_tag', 'td');
	while (! defined($result_count) && (my $td = shift(@td))) {
		my $text = $td->as_text();
		if ($text =~ m{Your\s+(.*\s)?search\s+(for.*\s.*\s)?returned\s+(\d+)\s+results\.}is) {
			$result_count = $3;
		} elsif ($text =~ m{Your\s+(.*\s)?search\s+(for.*\s)?returned\s+more\s+than\s+(\d+)\s+(relevant\s+)results\.}is) {
			$result_count = $3 + 1;
		} elsif ($text =~ m{Your\s+(.*\s)?search\s+(for.*\s.*\s)?did\s+not\s+return\s+any\s+documents\.}is) {
			$result_count = 0;
		}
	}
	if (defined($result_count)) {
		$self->approximate_result_count($result_count);
	}
	print STDERR " + approximate_result_count is " . $result_count . "\n" if ($self->{'_debug'});

	# SearchResults
	my $hits_found = 0;
	my $results_table_comment = $tree->look_down('_tag', '~comment', sub { $_[0]->attr('text') =~ m{Begin\s+Results\s+Table}si });
	return undef if (! defined($results_table_comment));  # exit if no results table comment
	my $results_table = $results_table_comment->right();  # locate table containing results
	return undef if (! defined($results_table));  # exit if no results table
	my @results_tds = $results_table->look_down('_tag', 'td');  # get array of all TDs within the table of results
	my %result = ();  # hash to contain one result
	foreach my $result_td (@results_tds) {
		next if ($result_td->as_text() =~ m{^(\s|\xA0)*$}s);  # ignore any white space (or &nbsp;) TDs
		print STDERR " + result_td: " . $result_td->as_text() . "\n" if ($self->{'_debug'} > 1);
		if (! exists($result{'count'})) {  # count TD occurs first
			if ($result_td->as_text() =~ m{^\s*(\d+)\.?\s*$}s) {  # digit(s) with optional period
				$result{'count'} = $1;
			}  # else ignore this TD
		} elsif (! exists($result{'url'})) {  # url/title (anchor) TD occurs second
			if (my $result_a = $result_td->look_down('_tag', 'a')) {  # if TD contains A
				$result{'url'} = $result_a->attr('href');
				if ($result{'url'} =~ m{url=([^&]+)}i) {
					$result{'url'} = $1;
				}
				$result{'title'} = $result_a->as_text();
			}  # else ignore this TD
		} else {  # description TD occurs third
			my $hit = WWW::SearchResult->new();
			$hit->add_url($result{'url'});
			$hit->title($result{'title'});
			$hit->description(&WWW::Search::strip_tags($result_td->as_text()));
			push(@{$self->{cache}}, $hit);
			$self->{'_num_hits'} += 1;
			$hits_found += 1;
			%result = ();
		} # the URL TD occurs fourth and is ignored when looking for count TD
	}

	# _next_url
	my $input_fr = undef;
	my $form = $tree->look_down('_tag', 'form', sub {
			defined($input_fr = $_[0]->look_down('_tag', 'input', sub { $_[0]->attr('name') eq 'fr' })) &&
			defined($_[0]->look_down('_tag', 'input', sub { $_[0]->attr('name') eq 'nr' }))
			});
	if (defined($form->look_down('_tag', 'input', sub { lc($_[0]->attr('type')) eq 'image' && lc($_[0]->attr('name')) eq 'act.next' }))) {
		$self->{'_next_url'} = $self->{'_prev_url'};
		if ($self->{'_next_url'} =~ s|([?&]fr=)(-?\d+)(&.+)?$||) {
			my $tail = $3 || '';
			$self->{'_next_url'} .= $1 . $input_fr->attr('value') . $tail;
		} else {
			$self->{'_next_url'} .= '&fr=' . $input_fr->attr('value');
		}
		if ($self->{'_next_url'} !~ m|act\.next\.x|) {
			$self->{'_next_url'} .= '&act.next.x=1&act.next.y=1';
		}
		print STDERR " + _next_url: " . $self->{'_next_url'} . "\n" if ($self->{'_debug'});
	}

	print STDERR " + hits_found: " . $hits_found . "\n" if ($self->{'_debug'});
	return $hits_found;
}

# native_retrieve_some is copied from WWW::Search and modified to set store_comments(1) for HTML::TreeBuilder object 
# required because FirstGov
sub native_retrieve_some
  {
  my ($self) = @_;
  printf STDERR (" +   %s::native_retrieve_some()\n", __PACKAGE__) if $self->{_debug};
  # fast exit if already done
  return undef if (!defined($self->{_next_url}));
  # If this is not the first page of results, sleep so as to not overload the server:
  $self->user_agent_delay if 1 < $self->{'_next_to_retrieve'};
  # Get one page of results:
  print STDERR " +   sending request (", $self->{'_next_url'}, ")\n" if $self->{_debug};
  my $response = $self->http_request('GET', $self->{'_next_url'});
  $self->{_prev_url} = $self->{_next_url};
  $self->{'_next_url'} = undef;
  $self->{response} = $response;
  if (! $response->is_success)
    {
    return undef;
    } # if
  # Parse the output:
  ### beginning of modified section ###
  my $tree = HTML::TreeBuilder->new();
  $tree->store_comments(1);
  $tree->parse($self->preprocess_results_page($response->content));
  $tree->eof();
  ### end of modified section ###
  return $self->parse_tree($tree);
  } # native_retrieve_some

1;

