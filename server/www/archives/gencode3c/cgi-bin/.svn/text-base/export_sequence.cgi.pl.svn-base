#!/usr/bin/perl -W
# _________________________________________________________________
# $Id$
# $Revision$
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________

use CGI qw(:standard);
use strict;
use warnings;
use FindBin;

#BEGIN
#{
#	use FindBin;
#	@INC = ( "$FindBin::Bin/lib2", @INC );	
#}
#use FindBin qw($Bin);

use lib "$FindBin::Bin/lib2";
use APPRIS::Registry;
use APPRIS::Exporter;

use Data::Dumper;

###################
# Global variable #
###################
use vars qw($CONFIG_INI_FILE);

$CONFIG_INI_FILE="$FindBin::Bin/conf/config.ini";

#####################
# Method prototypes #
#####################
sub print_content($);

#################
# Method bodies #
#################
# Main subroutine
sub main()
{
	# Get inputs
	my ($query_cgi) = new CGI;
	my ($id_list) = $query_cgi->param('id');
	print_content('') unless (defined $id_list and $id_list ne '');
	my ($type) = $query_cgi->param('type');
	print_content('') unless (defined $type and $type ne '');
	my ($format) = lc($query_cgi->param('format')); # Optional (by default, 'fasta')
	$format='fasta' unless (defined $format and $format ne '');
	
	# APPRIS database connection
	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);	
	
	# Get position features for each id
	my ($output_content) = '';
	my(@ids)=split(',',$id_list);
	foreach my $id (@ids) {
		my ($features);
		if ($id=~/^ENSG/) {
			my ($region) = $1;
			$features = $registry->fetch_basic_by_stable_id('gene',$id);
			print_content('') unless ($features);
		}
		elsif($id=~/^ENST/) {
			my ($region) = $1;
			$features = $registry->fetch_basic_by_stable_id('transcript',$id);
			print_content('') unless ($features);
		}
		else {
			print_content('');
		}
	
		# Export data
		if ($format eq 'fasta') {
			my ($exporter) = APPRIS::Exporter->new();
			$output_content .= $exporter->get_sequences($features,$type,$format);
		}
		else {
			print_content('');
		}
	}

	# Print output
	print_content($output_content);
}

# Print output as text/plain
sub print_content($)
{
	my ($content) = @_;
	
	print STDOUT "Content-type: text/plain\n\n";
	print STDOUT $content;
	
	exit 0;
}

main();


1;


__END__

=head1 NAME

export_sequence

=head1 DESCRIPTION

CGI-BIN script that exports sequences from gene or transcript 
identifier (Ensembl).

=head1 VERSION

0.1

=head1 SYNOPSIS

export_data

	id= <Gene|Transcript identifier> (ENSG00000099904, ENST00000382363)
	
	format= <Output format> ('fasta') By default, 'fasta'

	type= <Type of sequence. Nucleotide sequence of aminoacid sequence> ('na', 'aa')	

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
