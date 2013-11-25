#!/usr/bin/perl -W

use strict;
use warnings;

use Retrieve qw( get_residues_result );
use HTTP qw( print_http_response);
use CGI;
use Data::Dumper;
$|=1; # not use buffering

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
	# "/id/trans_id"
	# "/id/trans_id1,trans_id2,...,trans_idN"
	my ($cgi) = new CGI;	
	my ($url_path_info) = $cgi->path_info();
	my (@input_parameters) = split('/',$url_path_info);

	print_http_response(400)
		unless ( @input_parameters ); # defined path

	print_http_response(400)
		if ( scalar(@input_parameters) > 3 ); # only 2 parameters (+1 empty value)

	my ($q_type) = $input_parameters[1];
	my ($id_list) = $input_parameters[2];

	print_http_response(400)
		unless ( defined $q_type and defined $id_list );

	print_http_response(400)
		if ( ($q_type ne 'id') );
	
	# Get result
	my ($result) = get_residues_result($id_list);
	
	# Everything was OK
	if ( defined $result and ($result ne '') ) {
		print_http_response(200, $result);
	}
	else {
		print_http_response(204);
	}
}

main();


1;


__END__

=head1 NAME

residues

=head1 DESCRIPTION

CGI-BIN script that exports residues matches by methods from gene or transcript identifier (Ensembl).

=head1 SYNOPSIS

export_data

	id= <Gene|Transcript identifier> (ENSG00000099904, ENST00000382363)
	
=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
