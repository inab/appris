#!/usr/bin/perl -W

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib2";
use APPRIS::Registry;
use Data::Dumper;
use CGI;
use HTTP::Status qw(is_success status_message);
$|=1; # not use buffering

###################
# Global variable #
###################
use vars qw(
	$CONFIG_INI_FILE
	$ANALYSIS
);

$CONFIG_INI_FILE = "$FindBin::Bin/conf/config.ini";
$ANALYSIS = 'inertia';

#####################
# Method prototypes #
#####################
sub _get_inertia_report($);
sub print_http_response($;$);
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
	my ($cgi) = new CGI;
	
	# Check input parameters:
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
		if ( ($type ne 'id') and ($type ne 'name') );

	# Get result
	my ($result);	
	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);	

	if ( $type eq 'id' ) {
		my ($analysis) = $registry->fetch_analysis_by_stable_id($input, $ANALYSIS);
		$result = _get_inertia_report($analysis);
	}
	elsif ( $type eq 'name' ) {
		my ($analysis) = $registry->fetch_analysis_by_xref_entry($input, $ANALYSIS);
		$result = _get_inertia_report($analysis);
	}
	else {
		print_http_response(400);
	}
	
	# Everything was OK
	if ( defined $result and ($result ne '') ) {
		print_http_response(200, $result);
	}
	else {
		print_http_response(204);
	}
}

sub print_http_response($;$)
{
	my ($http_error_num,$content) = @_;
	
	my($http_response)=new CGI();
	my($status_line)=$http_error_num." ".status_message($http_error_num);
	if (is_success($http_error_num))
	{
		print $http_response->header(
				-status => $status_line,
				-type => 'text/plain'
		);
		print $content;
	}
	else
	{
		print $http_response->header(
				-status => $status_line,
				-type => 'text/html'
		);
		print $http_response->start_html($status_line);
		print $http_response->h1($status_line);
		print $http_response->end_html;
	}

	$http_error_num==200? exit 0: exit $http_error_num;
}

sub _get_inertia_report($)
{
	my ($analysis) = @_;
	my ($result);
	$result .= "### inertia 1.0 prediction results ##################################\n";
	$result .= "\n";
		
	if ( $analysis and $analysis->inertia ) {

		if ( $analysis->inertia->mafft_alignment and $analysis->inertia->mafft_alignment->result ) {
			$result .= "### Evolutionary rates of exons from MAF alignment ###\n";
			$result .= "# omega_average	omega_exon_id	start_exon	end_exon	strand_exon	difference_value	p_value	st_desviation	exon_annotation	transcript_list\n";
 			$result .= $analysis->inertia->mafft_alignment->result."\n";
		}

		if ( $analysis->inertia->prank_alignment and $analysis->inertia->prank_alignment->result ) {
			$result .= "### Evolutionary rates of exons from Prank alignment ###\n";
			$result .= "# omega_average	omega_exon_id	start_exon	end_exon	strand_exon	difference_value	p_value	st_desviation	exon_annotation	transcript_list\n";			
 			$result .= $analysis->inertia->prank_alignment->result."\n";
		}

		if ( $analysis->inertia->kalign_alignment and $analysis->inertia->kalign_alignment->result ) {
			$result .= "### Evolutionary rates of exons from Kalign alignment ###\n";
			$result .= "# omega_average	omega_exon_id	start_exon	end_exon	strand_exon	difference_value	p_value	st_desviation	exon_annotation	transcript_list\n";			
 			$result .= $analysis->inertia->kalign_alignment->result."\n";
		}
		
	}
	return $result;
}



main();


1;


__END__

=head1 NAME

search_identifiers

=head1 DESCRIPTION

CGI-BIN script that retrieves gene/trancript identifiers storing within database.
Identifiers are reported as XML Document.

=head1 VERSION

0.1

=head1 SYNOPSIS

search_identifiers query=<input query>

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
