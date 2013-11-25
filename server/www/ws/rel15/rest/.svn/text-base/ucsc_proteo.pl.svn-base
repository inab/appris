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
	$UCSC_CGI
	$UCSC_URL
	$PROTEO_URL
	$FORMAT
	$HEAD
);

$UCSC_CGI=$ENV{'UCSC_CGI'};
$UCSC_URL=$ENV{'UCSC_URL'};
$PROTEO_URL=$ENV{'PROTEO_URL'};
$FORMAT = 'bedg';
$HEAD = 'no';

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
	# "/id/gene_id"
	# "/name/gene_name"
	# "/id/trans_id"
	# "/name/trans_name"
	# "/position/chr22:20116979-20137016"

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

	print_http_response(400)
		if ( ($type ne 'id') and ($type ne 'name') and ($type ne 'position') );

	my ($head) = $cgi->param('head') || undef;
	if (defined $head and ($head ne '')) {
		#$head = lc($head);
		$head =~ s/\s*//g;
		if ($head ne '' and ( ($head =~ /^yes/) or ($head =~ /^no/) or ($head =~ /^only/) ) ) {
			$HEAD = $head;	
		}
		else {
			print_http_response(400);
		}
	}

	my ($appris_export_data_url) = $PROTEO_URL.'/'.$type.'/'.$input.'?'.
																'format='.$FORMAT.'%26'.
																'head='.$HEAD;
	# Make a request to UCSC
	my ($request);
	eval{
		$request = HTTP::Request->new("GET", $UCSC_URL,HTTP::Headers->new(),
											'db=hg19'.'&'.
											'hgt.customText='.$appris_export_data_url
		);
	};
	
#use Data::Dumper;
#print_http_response(200, Dumper($request), 'text/plain');
	
	print_http_response(404) if($@);

	my ($ua) = LWP::UserAgent->new;
	my ($req) = $ua->request($request);
	if ( $req->is_error() ) {
		my ($status) = $req->status_line;
		print_http_response(404);
	}
	else {
		my ($http_response) = $req->content();
		if ( $http_response=~/warnList.innerHTML/ ) {
			print_http_response(404); # error
		}
		
		# Parse HTML response of UCSC
		my ($parser);
		eval {
			$parser = HTML::TreeBuilder->new_from_content($http_response);
		};
		print_http_response(404) if($@);

		# find UCSC url of images: side and hgt
		my ($img_table) = $parser->find_by_attribute('id','imgTbl');
		my ($row_data_ruler) = $img_table->find_by_attribute('id','td_data_ruler');
		my ($img_data_ruler) = $row_data_ruler->find_by_attribute('id','img_data_ruler');
		my ($img_data_ruler_src) = $img_data_ruler->attr('src');
		my ($img_data_ruler_url) = $UCSC_CGI.$img_data_ruler_src;
		
		my ($row_side_ruler) = $img_table->find_by_attribute('id','td_side_ruler');
		my ($img_side_ruler) = $row_side_ruler->find_by_attribute('id','img_side_ruler');
		my ($img_side_ruler_src) = $img_side_ruler->attr('src');
		my ($img_side_ruler_url) = $UCSC_CGI.$img_side_ruler_src;
		my ($trash) = '../trash/hgt[^\/]*\/';
		$img_side_ruler_src =~ s/$trash//;
		$img_data_ruler_src =~ s/$trash//;
		
		# Create JSON output
		if ( ($img_side_ruler_src ne '') and ($img_side_ruler_src ne '') ) {
			# BEGIN: IMPORTANT
			# Comment and uncoment these lines to change Genome Browser
			#my ($json) = qq{{"side" : "$img_side_ruler_src", "hgt" : "$img_side_ruler_src"}};
			my ($json) = qq{{"side" : "$img_side_ruler_src", "hgt" : "$img_data_ruler_src"}};		   	
			# END: IMPORTANT			
			print_http_response(200, $json, 'application/json');
		} else {
			my ($json) = qq{{"error" : "ucsc problems"}};
			print_http_response(404, $json, 'application/json');
		}
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
