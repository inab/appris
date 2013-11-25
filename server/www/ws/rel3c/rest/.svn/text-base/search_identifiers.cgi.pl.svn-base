#!/usr/bin/perl -W
# _________________________________________________________________
# $Id: search_identifiers.cgi.pl 1424 2011-04-01 18:26:36Z jmrodriguez $
# $Revision: 1424 $
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________

use CGI qw(:standard);
use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/lib2";
use APPRIS::Registry;
use XML::LibXML;

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
sub get_xml_report($$);
sub get_identifier_report($);

#################
# Method bodies #
#################

# Main subroutine
sub main()
{
	my ($query_cgi) = new CGI;
	my ($input_query) = $query_cgi->param('queryId'); # test: ENSG00000109670

	# Get all identifiers storing into input file
	if (defined $input_query and $input_query ne '')
	{
		# APPRIS Registry
		# The Registry system allows to tell your programs where to find the APPRIS databases and how to connect to them.
		my ($registry) = APPRIS::Registry->new();
		$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);	
	
		my ($query_report) = $registry->fetch_basic_by_xref_entry($input_query);
		
		my ($xml_doc) = get_xml_report($input_query,$query_report);
		print_content($xml_doc);		
	}
	else
	{
		print_content(undef);		
	}
}

# Create XML Document for identifiers       
#Output:
#
#<?xml version="1.0" encoding="UTF-8"?>
#<query id="OTTHUMG0000009043" namespace="Vega_Gene_Id">
#  <match label="OTTHUMG00000090439" id="OTTHUMG00000090439" namespace="Vega_Gene_Id" chr='21' start='46300858' end='46301909' /> 
#  <match label="OTTHUMG00000090438" id="OTTHUMG00000090438" namespace="Vega_Gene_Id" chr='21' start='46337606' end='46341872' /> 
#</query>
# or
#<query id="OTTHUMT0000020687" namespace="Vega_Transcript_Id">
#  <match label="OTTHUMT00000206878" id="OTTHUMT00000206877" namespace="Vega_Transcript_Id" chr='21' start='46300858' end='46301909' /> 
#  <match label="OTTHUMT00000206877" id="OTTHUMT00000206877" namespace="Vega_Transcript_Id" chr='21' start='46300858' end='46301909' /> 
#</query>
# or
#<?xml version="1.0" encoding="UTF-8"?>
#<query id="AP001479.4-006" namespace="Vega_External_Id">
#  <match label="AP001479.4-006" id="OTTHUMT00000206882" namespace="Vega_Transcript_Id" chr='21' start='46245273' end='46247491' />
#</query>
sub get_xml_report($$)
{
	my ($input_query,$query_report) = @_;

	my ($xml_doc) = XML::LibXML::Document->new('1.0','UTF-8');
	my ($e_query) = $xml_doc->createElement('query');
	$e_query->setNamespace("http://appris.bioinfo.cnio.es", "appris", 0);
	$xml_doc->setDocumentElement($e_query);

	foreach my $entity (@{$query_report})
	{
		my ($a_query) = $xml_doc->createAttribute('id', $input_query);
		$e_query->setAttributeNode($a_query);

		my ($namespace);
		if ($entity and ref($entity))
		{
			if ($entity->isa("APPRIS::Gene"))
			{
				$namespace = 'Ensembl_Gene_Id';	
			}
			elsif ($entity->isa("APPRIS::Transcript"))
			{
				$namespace = 'Ensembl_Transcript_Id';
			}
		}
		else
		{
			return $xml_doc; # Empty return
		}
		
		my ($e_match) = $xml_doc->createElement('match');
		my ($a_match) = $xml_doc->createAttribute('label', $entity->stable_id);
		my ($a_match2) = $xml_doc->createAttribute('namespace', $namespace);
		my ($a_match3) = $xml_doc->createAttribute('chr', $entity->chromosome);
		my ($a_match4) = $xml_doc->createAttribute('start', $entity->start);
		my ($a_match5) = $xml_doc->createAttribute('end', $entity->end);
		$e_match->setAttributeNode($a_match);
		$e_match->setAttributeNode($a_match2);
		$e_match->setAttributeNode($a_match3);
		$e_match->setAttributeNode($a_match4);
		$e_match->setAttributeNode($a_match5);

		my ($e_class) = $xml_doc->createElement('class');
		my ($e_class_txt) = $xml_doc->createCDATASection($entity->biotype);
		$e_class->appendChild($e_class_txt);
		$e_match->appendChild($e_class);

		my ($e_status) = $xml_doc->createElement('status');
		my ($e_status_txt) = $xml_doc->createCDATASection($entity->status);
		$e_status->appendChild($e_status_txt);		
		$e_match->appendChild($e_status);

		if ($entity->external_name) {
			my ($e_dblink) = $xml_doc->createElement('dblink');
			my ($a_dblink) = $xml_doc->createAttribute('namespace', 'External_Id');
			my ($a_dblink2) = $xml_doc->createAttribute('id', $entity->external_name);
			$e_dblink->setAttributeNode($a_dblink);
			$e_dblink->setAttributeNode($a_dblink2);
			$e_match->appendChild($e_dblink);			
		}
		if ($entity->xref_identify) {
			foreach my $xref_identify (@{$entity->xref_identify}) {
				my ($e_dblink) = $xml_doc->createElement('dblink');
				my ($a_dblink) = $xml_doc->createAttribute('namespace', $xref_identify->dbname);
				my ($a_dblink2) = $xml_doc->createAttribute('id', $xref_identify->id);
				$e_dblink->setAttributeNode($a_dblink);
				$e_dblink->setAttributeNode($a_dblink2);
				$e_match->appendChild($e_dblink);			
			}			
		}
		if (($entity->isa("APPRIS::Gene")) and $entity->transcripts) {
			foreach my $transcript (@{$entity->transcripts}) {
				my ($e_dblink) = $xml_doc->createElement('dblink');
				my ($a_dblink) = $xml_doc->createAttribute('namespace', 'Ensembl_Transcript_Id');
				my ($a_dblink2) = $xml_doc->createAttribute('id', $transcript->stable_id);
				$e_dblink->setAttributeNode($a_dblink);
				$e_dblink->setAttributeNode($a_dblink2);
				$e_match->appendChild($e_dblink);			
			}			
		}
		$e_query->appendChild($e_match);
	}

	return $xml_doc;
}

# Print output as text/xml
sub print_content($)
{
	my ($xml_doc) = @_;
	
	my ($xml_report) = "Content-type: text/xml\n\n";
	if ( defined $xml_doc )
	{
		$xml_report .= $xml_doc->toString(1);
	}
	else
	{
		my ($xml_doc) = XML::LibXML::Document->new('1.0','UTF-8');
		my ($e_query) = $xml_doc->createElement('query');
		$xml_doc->setDocumentElement($e_query);
			
		my ($a_query) = $xml_doc->createAttribute('id', '');
		$e_query->setAttributeNodeNS($a_query);
		
		$xml_report .= $xml_doc->toString();
	}
	print STDOUT $xml_report;	
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
