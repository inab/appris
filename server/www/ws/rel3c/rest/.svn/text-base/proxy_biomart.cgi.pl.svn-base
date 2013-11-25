#!/usr/bin/perl -W
# _________________________________________________________________
# $Id: proxy_biomart.cgi.pl 715 2010-03-29 16:35:41Z jmrodriguez $
# $Revision: 715 $
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________

use CGI qw(:standard);
use strict;
use warnings 'all';
use LWP::UserAgent;

use Data::Dumper;

###################
# Global variable #
###################
use vars qw($BIOMART_URL);
$BIOMART_URL="http://appris.bioinfo.cnio.es/biomart/martservice";


#####################
# Method prototypes #
#####################

#################
# Method bodies #
#################
sub print_content($$)
{
	my($report,$exit_flag)=@_;
	
	print STDOUT "Content-type: text/plain\n\n";
	print STDOUT $report;
	exit 0 if($exit_flag eq 'exit');
}

# Main subroutine
sub main()
{
	my($query_cgi)=new CGI;
	my($input_query)=$query_cgi->param('query'); # XML Query
	
	eval{
		my $request = HTTP::Request->new("POST",$BIOMART_URL,HTTP::Headers->new(),'query='.$input_query."\n");
		my $ua = LWP::UserAgent->new;
		my $response;
		my($req)=$ua->request($request);
		if ($req->is_error())
		{
			my $status = $req->status_line;
			print STDOUT "Content-type: text/plain\n\n";		
			print STDOUT $status."\n";
	
		}
		else
		{
			my($http_response)=$req->content();
			print STDOUT "Content-type: text/plain\n\n";		
			print STDOUT $http_response."\n";
		}
		exit 0;		
	};
	if($@) {
		
	}
}

main();


1;


__END__

=head1 NAME



=head1 DESCRIPTION

CGI-BIN script that retrieves report from given gene calling BioMart database.

=head1 VERSION

0.1

=head1 SYNOPSIS


=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
