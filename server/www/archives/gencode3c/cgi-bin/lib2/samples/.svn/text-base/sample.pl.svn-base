#!/usr/bin/perl -W

use strict;
use warnings;

use APPRIS::Registry;

sub main()
{
	# APPRIS Registry
	# The Registry system allows to tell your programs where to find the APPRIS databases and how to connect to them.
	# The following call will load all the local APPRIS database that was downloaded previously
	my($registry)=APPRIS::Registry->new();
	
	# By means of config file
	$registry->load_registry_from_ini
	(
		-file	=> "config.ini"
	);	
	
	# Retrieve a list reference of gene objects
	my ($chromosome) = $registry->fetch_by_region('M');	
	foreach my $gene (@{$chromosome}) {
		print "gene_id: ". $gene->stable_id ." source: ".$gene->source." external: ".$gene->external_name."\n";
	}

	# Another useful way to obtain information of a gene
	my ($gene) = $registry->fetch_by_gene_stable_id('ENSG00000135541');
	print("gene start:end:strand is "
		. join( ":", map { $gene->$_ } qw(start end strand) )
		. "\n" );

	# Retrieve a transcript object from given transcript id
	my ($transcript) = $registry->fetch_by_transc_stable_id('ENST00000367800');  

	# Retrieve a translate object from given transcript id
	my ($translation) = $registry->fetch_by_transl_stable_id('ENST00000367800');
	print "\nTranslate ENST00000367800:\n".
		"* stable_id: ".$translation->stable_id."\n* sequence:\n".$translation->sequence."\n";

}

main();


1;
