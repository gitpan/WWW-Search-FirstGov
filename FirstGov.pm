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

=item   { 'begin_at' => '100' }

Retrieve results starting at 100th match.

=item   { 'pl' => 'domain', 'domain' => 'osec.doc.gov+itd.doc.gov' }

The query is limited to searching the domains osec.doc.gov and itd.doc.gov.

=head1 SEE ALSO

To make new back-ends, see L<WWW::Search>,
or the specialized AltaVista searches described in options.

See http://www.fed-search.org/specialized.html to learn more about
specialized FirstGov searches.

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

1.02  2001-03-01 - Removed 'my' declarations for package variables.

1.01  2001-02-26 - Fixed problem with quoted sring on MSWin.
                   Removed 'our' declarations.

1.00  2001-02-23 - First publicly-released version.

=cut

#####################################################################
require 5.005_62;
use strict;

require Exporter;
@WWW::Search::FirstGov::EXPORT = qw();
@WWW::Search::FirstGov::EXPORT_OK = qw();
@WWW::Search::FirstGov::ISA = qw( WWW::Search Exporter );
$WWW::Search::FirstGov::VERSION = '1.02';

$WWW::Search::FirstGov::MAINTAINER = 'Dennis Sutch <dsutch@doc.gov>';

use Carp ();
use WWW::Search( 'generic_option' );
require WWW::SearchResult;

my $default_option = {
		'search_url' => 'http://www.firstgov.gov/fedsearch3/index.jsp',
		'fr' => 0,  # return results starting at match number 'fr' plus or minus 'nr', when act.next.x and .y (or act.prev.x and .y) are set [messy, messy, messy]
		'act.search' => 'Search',  # submit button
#		'mw0' => keywords (match words?)
		'mt0' => 'all',  # match: "all" = All Words | "any" = Any Words | "phrase" = The Exact Phrase | "name" = A Person's Name | "urls" = Embedded URLs
		'ms0' => 'must',  # "must" = Must | "should" = Should | "mustnot" = Must Not
		'adv' => '1111',  # (advanced search? ; not used during search?)
		'nr' => 20,  # number of results returned per page (max = 100)
		'de' => 'detailed',  # format of results (may be: "detailed" | "brief")
#		'mw1' => additional keywords
#		'mt1' => 'all'  # used with additional keywords
#		'ms1' => 'must'  # used with additional keywords
		'dop' => 'anytime',  # a date range for search: "within" (within the last period specified by 'dd' and 'du') | "range" (range as specified by 'dr', 'mo', 'dy' and 'yr' | "anytime"
#		'dd' =>  # number of 'du' periods
#		'du' =>  # "year" | "month" | "day"
#		'dr' =>  # "before" | "after"
#		'mo' =>  # "01" = January ... "12" = December
#		'dy' =>  # day: two digit number
#		'yr' =>  # year: a four digit number, currently 1994 ... 2001
		'pl' => 'anywhere',  # Restrict search to documents in specific locations: "geoRegion" (as specified by 'georegion') | "domain" (as specified by 'domain') | "anywhere"
#		'georegion' =>  # "northamerica" = North America | "europe" = Europe | "southeastasia" = Southeast Asia | "asia" = Asia | "southamerica" = South America | "downunder" = Australia/Oceania | "africa" = Africa | "mideast" = Middle East | "centralamerica" = Central America | "japan" = Japan
#		'domain' => a list of Internet domains, separated by commas and spaces (or just spaces), (or '+')
#		'imageToggle' =>  # Search for documents with specific media types: Image
#		'shockwaveToggle' =>  # Search for documents with specific media types: Shockwave
#		'javascriptToggle' =>  # Search for documents with specific media types: JavaScript
#		'audioToggle' =>  # Search for documents with specific media types: Audio
#		'acrobatToggle' =>  # Search for documents with specific media types: Acrobat
#		'javaToggle' =>  # Search for documents with specific media types: Java
#		'videoToggle' =>  # Search for documents with specific media types: Video
#		'activexToggle' =>  # Search for documents with specific media types: ActiveX
#		'vbscriptToggle' =>  # Search for documents with specific media types: VBScript
#		'extensionBoxToggle' =>  # Search for documents with extension as specified by 'extension'
#		'extension' =>  # for example: mpg, gif, txt
		};

sub native_setup_search {
	my($self, $native_query, $native_options_ref) = @_;
	$self->{'_debug'} = $native_options_ref->{'search_debug'};
	$self->{'_debug'} = 2 if ($native_options_ref->{'search_parse_debug'});
	$self->{'_debug'} = 0 if (!defined($self->{'_debug'}));
	$self->{'agent_e_mail'} = 'dsutch@doc.gov';
	$self->user_agent('user');
	$self->{'_num_hits'} = 0;
	if (!defined($self->{'_options'})) {
		foreach (keys %$default_option) {
			$self->{'_options'}{$_} = $default_option->{$_};
		}
		$self->{'_options'}{'mw0'} = $native_query;
	}
	if (defined($native_options_ref)) {
		foreach (keys %$native_options_ref) {
			$self->{'_options'}{$_} = $native_options_ref->{$_} if ($_ ne 'begin_hit_number');
		}
	}
	if (exists($self->{'_options'}{'begin_at'}) && defined($self->{'_options'}{'begin_at'})) {
		my $begin_at = $self->{'_options'}{'begin_at'} || 1;
		$begin_at = 1 if ($begin_at < 1);
		$self->{'_options'}{'fr'} = $begin_at - 1 - $self->{'_options'}{'nr'};
		$self->{'_options'}{'act.next.x'} = 1;
		$self->{'_options'}{'act.next.y'} = 1;
	}
	my $options = '';
	foreach (sort keys %{$self->{'_options'}}) {
		printf STDERR "**FirstGov::native_setup_search() option: $_ is " . $self->{'_options'}{$_} . "\n" if ($self->{'_debug'} >= 2);
		next if (generic_option($_));
		$options .= '&' if ($options);
		$options .= $_ . '=' . $self->{'_options'}{$_};
	}
#print STDERR "_next_url: " . $self->{'_options'}{'search_url'} . '?' . $options . "\n";
	$self->{'_next_url'} = $self->{'_options'}{'search_url'} . '?' . $options;
}

sub native_retrieve_some {
	my ($self) = @_;
	print STDERR "**FirstGov::native_retrieve_some()\n" if $self->{'_debug'};
	return undef if (!defined($self->{'_next_url'})); 	# fast exit if already done
	$self->user_agent_delay if ($self->{'_next_to_retrieve'} > 1); 	# if this is not the first page of results, sleep so as to not overload the server
	print STDERR "**Requesting (" . $self->{'_next_url'} . ")\n" if ($self->{'_debug'});
	my $response = $self->http_request('GET', $self->{'_next_url'});
	$self->{response} = $response;
	return undef if (!$response->is_success);
	my $current_url = $self->{'_next_url'};
	$self->{'_next_url'} = undef;
	print STDERR "**Found Some\n" if ($self->{'_debug'});
	my ($HEADER, $FR, $MATCHES, $URL, $SCORE, $DESCRIPTION) = qw(HEADER MATCHES URL SCORE DESCRIPTION);
	my $state = $HEADER;
	my $hits_found = 0;
	my $has_next_url = 0;
	my $next_fr = undef;
	my $hit = ();
	foreach ($self->split_lines($response->content())) {
		next if (m/^\s*$/);  # short circuit for blank lines
		print STDERR " * $state ===$_=== " if ($self->{'_debug'} >= 2);
		if ($state eq $HEADER && m|<input type="hidden" name="fr"(.*)|i) {
			my $value = $1;
			if ($value =~ m|value="(\d*)">|) {
				$next_fr = $1;
			} else {
				$state = $FR;
			}
		} elsif ($state eq $FR && m|value="(\d*)">|i) {
			$next_fr = $1;
			$state = $HEADER;
		} elsif ($state eq $HEADER && m|<td><b>Returned:</b> (\d+) matches|i) {
			$self->approximate_result_count($1);
			$state = $MATCHES;
		} elsif ($state eq $MATCHES && m|name="act.next" border="0" VALUE="Next" WIDTH="17" HEIGHT="19">|i) {
			$has_next_url = 1;
		} elsif ($state eq $MATCHES && m|<TD nowrap><a href="([^"]+)">(.*)</A></TD></TR>\s*$|i) {
			print STDERR "**Found a URL and title\n" if ($self->{'_debug'} >= 2);
			my ($url,$title) = ($1,$2);
			if (defined($hit)) {
				push(@{$self->{'cache'}}, $hit);
			}
			$hit = new WWW::SearchResult;
			$hit->add_url($url);
			$hits_found += 1;
			$title =~ s/&amp;/&/g;
			$hit->title($title);
			$state = $URL;
		} elsif ($state eq $URL && m|<TR><TD align="center" colspan="2"><FONT size="-1">(\d+)% </FONT></TD>|i) {
			print STDERR "**Found score\n" if ($self->{'_debug'} >= 2);
			$hit->score($1);
			$state = $SCORE;
		} elsif ($state eq $SCORE && m|<TR><TD colspan="3">(.*)</TD></TR>|i) {
			print STDERR "**Found description\n" if ($self->{'_debug'} >= 2);
			$hit->description($1);
			$state = $DESCRIPTION;
		} elsif ($state eq $DESCRIPTION && m|<TR><TD colspan="2"></TD><TD nowrap><FONT size="-1" color="#888888">(\d+) bytes, (\d+/\d+/\d+)</FONT></TD></TR>|i) {
			print STDERR "**Found size\n" if ($self->{'_debug'} >= 2);
			$hit->size($1);
			$hit->change_date($2);
			push(@{$self->{'cache'}}, $hit);
			$hit = ();
			$state = $MATCHES;
		}
	}
	if ($has_next_url && defined($next_fr)) {
		$self->{'_next_url'} = $current_url;
		if ($self->{'_next_url'} =~ s|([?&]fr=)(\d+)(&.+)?$||) {
			$self->{'_next_url'} .= $1 . $next_fr . $3;
		} else {
			$self->{'_next_url'} .= '&fr=' . $next_fr;
		}
		if ($self->{'_next_url'} !~ m|act\.next.x|) {
			$self->{'_next_url'} .= '&act.next.x=1&act.next.y=1';
		}
	}
	return $hits_found;
}

1;

