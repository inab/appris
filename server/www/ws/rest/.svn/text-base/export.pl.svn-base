#!/usr/bin/perl -W

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Retrieve;
use HTTP qw(print_http_response);
use CGI;
use Data::Dumper;

# Add local APPRIS API
use APPRIS::Exporter;

$|=1; # not use buffering

###################
# Global variable #
###################
use vars qw(
	$CONFIG_INI_FILE
	$FORMAT
	$HEAD
	$SOURCES
	$ENCODING
);

$CONFIG_INI_FILE = "$FindBin::Bin/conf/config.ini";
$FORMAT = 'gtf';
$HEAD = 'no';
$SOURCES = 'all';
$ENCODING = 'text/plain';

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
	# "/position/chr22:20116979-20137016?format=gtf"
	# "/position/chr22:20116979-20137016?format=json"
	# "/position/chr22:20116979-20137016?&format=bed&head=no"
	# "/id/gene_id?method=appris&format=json"

	my ($cgi) = new CGI;	
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
		if ( ($type ne 'id') and ($type ne 'name') and ($type ne 'position') );

	my ($sources) = $cgi->param('source') || undef; # Optional (by default all of them)
	if (defined $sources and ($sources ne '')) {
		$sources = lc($sources);		
		if (($sources ne '') and ( 
			($sources =~ /appris/) or
			($sources =~ /firestar/) or
			($sources =~ /matador3d/) or
			($sources =~ /inertia_corsair/) or
			($sources =~ /spade/) or
			($sources =~ /corsair/) or
			($sources =~ /inertia/) or
			($sources =~ /crash/) or
			($sources =~ /thump/) or
			($sources =~ /cexonic/) or
			($sources =~ /proteo/) )
		) {
			$SOURCES = $sources;	
		}
		else {
			print_http_response(400);
		}
	}
		
	my ($format) = $cgi->param('format') || undef ; # Optional (by default, 'gtf')
	if (defined $format and ($format ne '')) {
		$format = lc($format);
		if (($format ne '') and ( ($format eq 'gtf') or ($format eq 'gff3') or ($format eq 'bed') or ($format eq 'json') ) ) {
			$FORMAT = $format;	
		}
		else {
			print_http_response(400);
		}
	}
	
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

	# Get features from input
	my ($features);
	my ($retrieve) = new Retrieve(
								-specie => $specie,
								-conf   => $CONFIG_INI_FILE
	);
	if ( defined $retrieve and $type eq 'id' ) {
		$features = $retrieve->get_report_by_stable_id($input);
	}
	elsif ( defined $retrieve and $type eq 'name' ) {
		$features = $retrieve->get_report_by_xref_entry($input);
	}
	elsif ( defined $retrieve and $type eq 'position' ) { 
		$features = $retrieve->get_report_by_position($input);		
	}
	else {
		print_http_response(400);
	}

	# Print data
	my ($result) = '';
	if ($features and $FORMAT eq 'bed') {
		my ($position); # get position param
		$position = $input if ( $type eq 'position' );		
		my ($exporter) = APPRIS::Exporter->new();
		$result .= $exporter->get_bed_annotations($features, $position, $HEAD, $SOURCES);
	}
	elsif ($features and $FORMAT eq 'gtf') {
		my ($exporter) = APPRIS::Exporter->new();
		$result .= $exporter->get_gtf_annotations($features, $SOURCES);
	}
	elsif ($features and $FORMAT eq 'gff3') {
		my ($exporter) = APPRIS::Exporter->new();
		$result .= $exporter->get_gff3_annotations($features, $SOURCES);        
    }
	elsif ($features and $FORMAT eq 'json') {
		my ($exporter) = APPRIS::Exporter->new();
		$result .= $exporter->get_json_annotations($features, $SOURCES);
		$ENCODING = 'application/json';        
    }	
	else {
		print_http_response(400);
	}
	
	# Everything was OK
	if ( defined $result and ($result ne '') ) {
		print_http_response(200, $result, $ENCODING);
	}
	else {
		print_http_response(404);
	}
}

main();


1;


__END__

=head1 NAME

export

=head1 DESCRIPTION

CGI-BIN script that exports sequences from gene or transcript identifier (Ensembl).

=head1 SYNOPSIS

export

	id= <Gene|Transcript identifier> (ENSG00000099904, ENST00000382363)
	
	type= <Type of sequence. Nucleotide sequence of aminoacid sequence> ('na', 'aa')
	
	format= <Output format> ('fasta') By default, 'fasta'	

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut