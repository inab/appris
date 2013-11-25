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

use lib "$FindBin::Bin/lib2";
use APPRIS::Registry;
use APPRIS::Exporter;

use Data::Dumper;

###################
# Global variable #
###################
use vars qw($CONFIG_INI_FILE $CONSTANT_PARAMETERS);

$CONFIG_INI_FILE="$FindBin::Bin/conf/config.ini";

$CONSTANT_PARAMETERS={
	'identifier'				=> undef,
	'gene'						=> undef,
	'chr'						=> undef,
	'start'						=> undef,
	'end'						=> undef,
	'strand'					=> undef,
	'class'						=> undef,
	'status'					=> undef,
	'level'						=> undef,
	'external_name'				=> undef,
	'ccds_id'					=> undef,
	'length_na'					=> undef,
	'length_aa'					=> undef,
	'principal_isoform'			=> undef,
	'principal_isoform_source'	=> undef,
	'codons_not_found'			=> undef
};
		
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
	my ($param_list) = $query_cgi->param('param');
	print_content('') unless (defined $param_list and $param_list ne '');
	my($head)=$query_cgi->param('head'); # Optional ('yes','no','only'). By default, 'no'
	
	# Var outputs
	my ($output_content) = '';
		
	# Get the list of parameters and check them
	my ($params);
	my(@param_list2)=split(',',$param_list);

	foreach my $param (@param_list2) {
		if (exists $CONSTANT_PARAMETERS->{$param}) {
			push(@{$params},$param);
		} else {
			print_content('');
		}
	}
    
	# APPRIS database connection
	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);	
	
	# Print head    
    if (defined $head and $head eq 'yes') {
    	foreach my $param (@{$params}) {
    		$output_content .= $param ."\t";
    	}
    	$output_content =~ s/\t$/\n/;
    }
	
	# Get position features for each id
	my(@ids)=split(',',$id_list);
	foreach my $id (@ids) {
		my ($features);
		if ($id=~/^ENSG/) {
			my ($region) = $1;
			$features = $registry->fetch_by_stable_id('gene',$id);
			print_content('') unless ($features);
		}
		elsif($id=~/^ENST/) {
			my ($region) = $1;
			$features = $registry->fetch_by_stable_id('transcript',$id);
			print_content('') unless ($features);
		}
		else {
			print_content('');
		}
		
		# Export data
		if ($features and defined $params) {
			my ($exporter) = APPRIS::Exporter->new();
			$output_content .= $exporter->get_tab_annotations($features,$params);
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

export_appris

=head1 DESCRIPTION

CGI-BIN script that exports APPRIS annotations.

=head1 VERSION

0.1

=head1 PARAMETERS

	id= <List of Gene|Transcript identifiers> (ENSG00000099904, ENST00000382363)
	
	param= <List of features> ('identifier','class','status','level','external_name',
	'length_na','length_aa','principal_isoform','principal_isoform_source')

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
