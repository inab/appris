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
	$CONFIG_INI_FILE
	$FORMAT
);

$CONFIG_INI_FILE = "$FindBin::Bin/conf/config.ini";
$FORMAT = 'fasta';

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
	# "/id/trans_id"
	# "/id/gene_id1,gene_id2,...,gene_idN"
	# "/id/trans_id1,trans_id2,...,trans_idN"	
	my ($cgi) = new CGI;	
	my ($url_path_info) = $cgi->path_info();
	my (@input_parameters) = split('/',$url_path_info);

	print_http_response(400)
		unless ( @input_parameters ); # defined path

	print_http_response(400)
		if ( scalar(@input_parameters) > 4 ); # only 2 parameters (+1 empty value)

	my ($q_type) = $input_parameters[1];
	my ($specie) = $input_parameters[2];
	my ($id_list) = $input_parameters[3];

	print_http_response(400)
		unless ( defined $specie and defined $q_type and defined $id_list );

	print_http_response(400)
		if ( ($q_type ne 'id') );
		
	my ($type) = lc($cgi->param('type'));
	print_http_response(400) unless (defined $type and $type ne '');

	my ($format) = $cgi->param('format') || undef; # Optional (by default, 'fasta')
	if (defined $format and ($format ne '')) {
		$format = lc($format);
		if ( ($format ne '') and ($format eq 'fasta') ) {
			$FORMAT = $format;	
		}
		else {
			print_http_response(400);
		}
	}

	# Get result
	my ($retrieve) = new Retrieve(
								-specie => $specie,
								-conf   => $CONFIG_INI_FILE
	);	
	my ($result) = $retrieve->get_sequence_result($id_list, $type, $FORMAT);
	
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

sequence

=head1 DESCRIPTION

CGI-BIN script that exports sequences from gene or transcript identifier (Ensembl).

=head1 SYNOPSIS

export_data

	id= <Gene|Transcript identifier> (ENSG00000099904, ENST00000382363)
	
	type= <Type of sequence. Nucleotide sequence of aminoacid sequence> ('na', 'aa')
	
	format= <Output format> ('fasta') By default, 'fasta'	

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut