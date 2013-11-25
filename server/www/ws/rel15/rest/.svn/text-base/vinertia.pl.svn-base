#!/usr/bin/perl -W

use strict;
use warnings;

use Retrieve qw( get_vmethod_result );
use HTTP qw( print_http_response);
use CGI;
use Data::Dumper;
$|=1; # not use buffering

###################
# Global variable #
###################
use vars qw(
	$ANALYSIS
);

$ANALYSIS = 'inertia';

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
	my ($result) = get_vmethod_result($type, $input, $ANALYSIS);
	
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

inertia

=head1 DESCRIPTION

RESTful web services that retrieves the output of method from a given input

=head2 Required arguments:

	- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
	- name (string), is a query input that could be:
		- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
		- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
		- CCDS identifier (e.g. CCDS4929).

=head1 EXAMPLE

		http://appris.bioinfo.cnio.es/ws/rest/inertia/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rest/inertia/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rest/inertia/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rest/inertia/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rest/inertia/name/CCDS4929
		
=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
