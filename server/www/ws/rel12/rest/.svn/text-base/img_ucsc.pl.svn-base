#!/usr/bin/perl -W

use strict;
use warnings;

use HTTP::Request;
use HTTP::Headers; 
use LWP::UserAgent;
use HTML::TreeBuilder;
use JSON;
use CGI;
use HTTP qw( print_http_response);
use Data::Dumper;
$|=1; # not use buffering

###################
# Global variable #
###################
use vars qw(
	$UCSC_URL
);

$UCSC_URL=$ENV{'UCSC_TRASH'};

#####################
# Method prototypes #
#####################
sub main();

#################
# Method bodies #
#################
# Main subroutine
sub main()
{
	# Get input parameters:
	# "/bg/blueLines800-118-12.png"
	# "/side/side_genome_2c4f_2664d0.png"
	# "/hgt/hgt_genome_2c4f_2664d0.png"

	my ($cgi) = new CGI;
	my ($url_path_info) = $cgi->path_info();
	my (@input_parameters) = split('/',$url_path_info);

	print_http_response(400)
		unless ( @input_parameters ); # defined path

	print_http_response(400)
		if ( scalar(@input_parameters) > 3 ); # only 2 parameters (+1 empty value)

	my ($type) = $input_parameters[1];
	my ($input) = $input_parameters[2];

	print_http_response(400)
		unless ( defined $type and defined $input );

	my ($hgt) = lc( $cgi->param('hgt') );
	print_http_response(400) if (defined $hgt and ($hgt ne ''));

	my ($bg) = lc( $cgi->param('bg') );
	print_http_response(400) if (defined $bg and ($bg ne ''));

	my ($ua) = LWP::UserAgent->new;
	$ua->agent("MyApp/0.1");
	my ($request) = HTTP::Request->new(GET => $UCSC_URL.'/'.$url_path_info);
	my ($req) = $ua->request($request);
	if ( $req->is_error() ) {
		my ($status) = $req->status_line;
		print_http_response(404);
	}
	else {
        print_http_response(200, $req->content(), 'text/plain');
	}
}

main();


1;


__END__

=head1 NAME

ucsc

=head1 DESCRIPTION

CGI-BIN script that retrieves url of images of UCSC genome browser

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
