#!/usr/bin/perl -W

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Retrieve;
use HTTP qw( print_http_response);
use CGI;
use Data::Dumper;
$|=1; # not use buffering

###################
# Global variable #
###################
use vars qw(
	$ANALYSIS
	$CONFIG_INI_FILE
);

$ANALYSIS = 'firestar';
$CONFIG_INI_FILE = "$FindBin::Bin/conf/config.ini";

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
	# "/firestar/gene?id=gene_id"
	# "/firestar/gene?name=gene_name"	
	# "/firestar/transcript?id=trans_id"
	# "/firestar/transcript?name=trans_name"	
	my ($cgi) = new CGI;
	
	# Check input parameters:
	my ($url_path_info) = $cgi->path_info();
	my (@input_parameters) = split('/',$url_path_info);
	print_http_response(400)
		unless ( @input_parameters ); # defined path
	print_http_response(400)
		if ( scalar(@input_parameters) > 4 ); # only 2 parameters (+1 empty value)
	my ($type) = $input_parameters[1];
	my ($specie) = $input_parameters[2];
	my ($input) = $input_parameters[3];
	print_http_response(400)
		unless ( defined $type and defined $specie and defined $input );
	print_http_response(400)
		if ( ($type ne 'id') and ($type ne 'name') );

	# Get result
	my ($retrieve) = new Retrieve(
								-specie => $specie,
								-conf   => $CONFIG_INI_FILE
	);
	my ($result) = $retrieve->get_method_result($type, $input, $ANALYSIS);
		
	# Everything was OK
	if ( defined $result and ($result ne '') ) {
		print_http_response(200, $result);
	}
	else {
		print_http_response(404);
	}
}

main();


1;


__END__

=head1 NAME

firestar

=head1 DESCRIPTION

RESTful web services that retrieves the output of method from a given input

=head2 Required arguments:

	- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
	- name (string), is a query input that could be:
		- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
		- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
		- CCDS identifier (e.g. CCDS4929).

=head1 EXAMPLE

		http://appris.bioinfo.cnio.es/ws/rest/firestar/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rest/firestar/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rest/firestar/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rest/firestar/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rest/firestar/name/CCDS4929
		
=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
