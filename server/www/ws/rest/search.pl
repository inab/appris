#!/usr/bin/perl -W

use strict;
use warnings;
use FindBin;
use APPRIS::Registry;
use XML::LibXML;
use JSON;
use Data::Dumper;
use CGI;
use lib "$FindBin::Bin/lib";
use HTTP qw( print_http_response);
$|=1; # not use buffering

###################
# Global variable #
###################
use vars qw(
	$CONFIG_INI_FILE
	$FORMAT
);

$CONFIG_INI_FILE = "$FindBin::Bin/conf/config.ini";
$FORMAT = 'json';

#####################
# Method prototypes #
#####################
sub get_report($$);
sub get_xml_report($);
sub main();

#################
# Method bodies #
#################

# Main subroutine
sub main()
{
	# Get input parameters:
	# "/query/input_query"
	my ($cgi) = new CGI;	
	my ($url_path_info) = $cgi->path_info();
	my (@input_parameters) = split('/',$url_path_info);

	print_http_response(400)
		unless ( @input_parameters ); # defined path

	print_http_response(400)
		if ( scalar(@input_parameters) > 3 ); # only 2 parameters (+1 empty value)

	my ($q_type) = $input_parameters[1];
	my ($input_query) = $input_parameters[2];

	print_http_response(400)
		unless ( defined $q_type and defined $input_query );

	print_http_response(400)
		if ( ($q_type ne 'query') );
		
	my ($format) = $cgi->param('format') || undef; # Optional (by default, 'gtf')
	if (defined $format and ($format ne '')) {
		$format = lc($format);
		if (($format ne '') and ( ($format eq 'json') or ($format eq 'xml') ) ) {
			$FORMAT = $format;	
		}
		else {
			print_http_response(400);
		}
	}

	# Get all identifiers storing into input file
	if ( defined $input_query and $input_query ne '' ) {
		#$input_query = lc($input_query);
		
		my ($query_report) = get_query_report($input_query);
		print_http_response(400) unless ( defined $query_report );

		my ($report) = get_report($input_query,$query_report);
		print_http_response(400) unless ( defined $report );

		if ( $FORMAT eq 'xml' ) {
			my ($xml_doc) = get_xml_report($report);
			if ( defined $xml_doc ) {
				my ($xml_string) = $xml_doc->toString(1);
				print_http_response(200, $xml_string, 'text/xml');
			}
			else {
				print_http_response(400);
			}			
		}
		elsif ( $FORMAT eq 'json' ) {
			my ($json) = new JSON;
			my ($json_string) = $json->encode($report);
			print_http_response(200, $json_string, 'application/json');
		}
	}
	else {
		print_http_response(400);		
	}
}

sub get_query_report($$)
{
	my ($input_query) = @_;
	my ($query_report);
	
	# config ini
	my ($cfg) = new Config::IniFiles( -file => $CONFIG_INI_FILE );
	
	# with ensembl identifier we go directly
	my ($specie) = '';
	if ( lc($input_query) =~ /^ensg(\d){11,13}/ or
		 lc($input_query) =~ /^ensgr(\d){10,13}/ or
		 lc($input_query) =~ /^enst(\d){11,13}/ or
		 lc($input_query) =~ /^enstr(\d){10,13}/		 
	) {
		$specie = 'homo_sapiens';
	}
	elsif ( lc($input_query) =~ /^ensmusg(\d){11,13}/ or
			 lc($input_query) =~ /^ensmusgr(\d){10,13}/ or
			 lc($input_query) =~ /^ensmust(\d){11,13}/ or
			 lc($input_query) =~ /^ensmustr(\d){10,13}/		 
	) {
		$specie = 'mus_musculus';
	}
	elsif ( lc($input_query) =~ /^ensrnog(\d){11,13}/ or
			 lc($input_query) =~ /^ensrnogr(\d){10,13}/ or
			 lc($input_query) =~ /^ensrnot(\d){11,13}/ or
			 lc($input_query) =~ /^ensrnotr(\d){10,13}/		 
	) {
		$specie = 'rattus_norvegicus';
	}
	
	# check all species
	if ( $specie eq '' ) {
		my ($species) = [ split( ',', $cfg->val('APPRIS_DATABASES', 'species') ) ];
		
		foreach my $specie (@{$species}) {
			my ($specie_db) = uc($specie.'_db');
			my ($specie_name) = $cfg->val($specie_db, 'specie');
			my ($registry) = APPRIS::Registry->new();		
			$registry->load_registry_from_db(
									-dbhost	=> $cfg->val($specie_db, 'host'),
									-dbname	=> $cfg->val($specie_db, 'db'),
									-dbuser	=> $cfg->val($specie_db, 'user'),
									-dbpass	=> $cfg->val($specie_db, 'pass'),
									-dbport	=> $cfg->val($specie_db, 'port'),
			);	
			print_http_response(400) unless ( defined $registry );
		
			my ($e_query_report) = $registry->fetch_basic_by_xref_entry($input_query);
			if ( defined $e_query_report ) {
				foreach my $entity (@{$e_query_report}) {
					push(@{$query_report->{$specie_name}}, $entity);
				}
			}
		}		
	}
	else {
		my ($specie_db) = uc($specie.'_db');
		my ($specie_name) = $cfg->val($specie_db, 'specie');
		my ($registry) = APPRIS::Registry->new();
		$registry->load_registry_from_db(
								-dbhost	=> $cfg->val($specie_db, 'host'),
								-dbname	=> $cfg->val($specie_db, 'db'),
								-dbuser	=> $cfg->val($specie_db, 'user'),
								-dbpass	=> $cfg->val($specie_db, 'pass'),
								-dbport	=> $cfg->val($specie_db, 'port'),
		);	
		print_http_response(400) unless ( defined $registry );
	
		my ($e_query_report) = $registry->fetch_basic_by_xref_entry($input_query);
		if ( defined $e_query_report ) {
			foreach my $entity (@{$e_query_report}) {
				push(@{$query_report->{$specie_name}}, $entity);
			}
		}
	}
	
	return $query_report;
}

sub get_report($$)
{
	my ($input_query,$query_report) = @_;
	my ($report);
	$report->{'query'} = $input_query if ( defined $input_query );
	
	while ( my ($specie, $q_report) = each(%{$query_report}) )
	{
		foreach my $entity (@{$q_report})
		{
			if ( $entity and ref($entity) ) {
				my ($match) = {
					'specie'	=> $specie,
					'id'		=> $entity->stable_id,
					'version'	=> $entity->version,
					'label'		=> $entity->stable_id,
					'chr'		=> $entity->chromosome,
					'start'		=> $entity->start,
					'end'		=> $entity->end,
					'biotype'	=> $entity->biotype,
					'status'	=> $entity->status,
				};
				if ( $entity->isa("APPRIS::Gene") ) {
					$match->{'namespace'} = 'Ensembl_Gene_Id';	
				}
				elsif ( $entity->isa("APPRIS::Transcript") ) {
					$match->{'namespace'} = 'Ensembl_Transcript_Id';
				}
				if ( $entity->external_name ) {
					my ($dblink) = {
						'id'		=> $entity->external_name,
						'namespace'	=> 'External_Id'
					};
					push(@{$match->{'dblink'}}, $dblink);
				}
				if ( $entity->xref_identify ) {
					foreach my $xref_identify (@{$entity->xref_identify}) {
						my ($dblink) = {
							'id'		=> $xref_identify->id,
							'namespace'	=> $xref_identify->dbname
						};
						push(@{$match->{'dblink'}}, $dblink);
					}			
				}
				if ( ($entity->isa("APPRIS::Gene")) and $entity->transcripts ) {
					foreach my $transcript (@{$entity->transcripts}) {
						my ($dblink) = {
							'id'		=> $transcript->stable_id,
							'namespace'	=> 'Ensembl_Transcript_Id'
						};
						push(@{$match->{'dblink'}}, $dblink);
					}
				}
				push(@{$report->{'match'}}, $match);
			}
			else {
				return $report; # Empty return
			}
		}
	}
	return $report;
}


sub get_xml_report($)
{
	my ($query_report) = @_;

	my ($xml_doc) = XML::LibXML::Document->new('1.0','UTF-8');
	my ($e_query) = $xml_doc->createElement('query');
	$e_query->setNamespace("http://appris.bioinfo.cnio.es", "appris", 0);
	$xml_doc->setDocumentElement($e_query);
	my ($a_query) = $xml_doc->createAttribute('query', $query_report->{'query'});
	$e_query->setAttributeNode($a_query);

	foreach my $match (@{$query_report->{'match'}})
	{
		my ($e_match) = $xml_doc->createElement('match');
		my ($a_match) = $xml_doc->createAttribute('label', $match->{'label'});
		my ($a_match2) = $xml_doc->createAttribute('namespace', $match->{'namespace'});
		my ($a_match3) = $xml_doc->createAttribute('chr', $match->{'chr'});
		my ($a_match4) = $xml_doc->createAttribute('start', $match->{'start'});
		my ($a_match5) = $xml_doc->createAttribute('end', $match->{'end'});
		my ($a_match6) = $xml_doc->createAttribute('specie', $match->{'specie'});
		$e_match->setAttributeNode($a_match);
		$e_match->setAttributeNode($a_match2);
		$e_match->setAttributeNode($a_match3);
		$e_match->setAttributeNode($a_match4);
		$e_match->setAttributeNode($a_match5);
		$e_match->setAttributeNode($a_match6);

		my ($e_class) = $xml_doc->createElement('biotype');
		my ($e_class_txt) = $xml_doc->createCDATASection($match->{'biotype'});
		$e_class->appendChild($e_class_txt);
		$e_match->appendChild($e_class);

		my ($e_status) = $xml_doc->createElement('status');
		my ($e_status_txt) = $xml_doc->createCDATASection($match->{'status'});
		$e_status->appendChild($e_status_txt);		
		$e_match->appendChild($e_status);
		
		foreach my $dblink (@{$match->{'dblink'}}) {
			my ($e_dblink) = $xml_doc->createElement('dblink');
			my ($a_dblink) = $xml_doc->createAttribute('namespace', $dblink->{'namespace'});
			my ($a_dblink2) = $xml_doc->createAttribute('id', $dblink->{'id'});
			$e_dblink->setAttributeNode($a_dblink);
			$e_dblink->setAttributeNode($a_dblink2);
			$e_match->appendChild($e_dblink);
		}
		$e_query->appendChild($e_match);
	}

	return $xml_doc;
}


main();


1;

#
#/* 
# * Output formats
# * =============
#
# XML format:
#
#<?xml version="1.0" encoding="UTF-8"?>
#<query xmlns:appris="http://appris.bioinfo.cnio.es" query="ENSG00000099899">
#  <match label="ENSG00000099899" namespace="Ensembl_Gene_Id" chr="22" start="20099389" end="20104915" specie="homo_sapiens">
#    <class><![CDATA[protein_coding]]></class>
#    <status><![CDATA[KNOWN]]></status>
#    <dblink namespace="External_Id" id="TRMT2A"/>
#    <dblink namespace="Vega_Gene_Id" id="OTTHUMG00000150454"/>
#    <dblink namespace="UniProtKB_SwissProt" id="Q8IZ69"/>
#    <dblink namespace="Ensembl_Transcript_Id" id="ENST00000487668"/>
#    <dblink namespace="Ensembl_Transcript_Id" id="ENST00000444845"/>
#  </match>
#</query>
#
# JSON format:
#
#{
#    "match": [
#        {
#            "namespace":"Ensembl_Gene_Id",
#            "specie":"homo_sapiens",
#            "status":"KNOWN",
#            "chr":"22",
#            "dblink": [
#                    {
#                        "namespace":"External_Id",
#                        "id":"SCO2"
#                    },{
#                        "namespace":"Havana_Gene_Id",
#                        "id":"OTTHUMG00000150251.1"
#                    },{
#                        "namespace":"Ensembl_Transcript_Id",
#                        "id":"ENST00000535425"
#                    }
#            ],
#            "biotype":"protein_coding",
#            "end":"50964868",
#            "label":"ENSG00000130489",
#            "start":"50961997"
#        }
#    ],
#    "query":"ENSG00000130489"
#}

__END__

=head1 NAME

search

=head1 DESCRIPTION

CGI-BIN script that retrieves gene/trancript identifiers storing within database.
Identifiers are reported as XML Document.

=head1 SYNOPSIS

search query=<input query>

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
