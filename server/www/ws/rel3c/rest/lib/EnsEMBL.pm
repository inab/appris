# _________________________________________________________________
# $Id: EnsEMBL.pm 1147 2010-08-20 11:15:03Z jmrodriguez $
# $Revision: 1147 $
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________
package EnsEMBL;

use strict;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::DBSQL::DBAdaptor;

use Data::Dumper;

#####################
# Method prototypes #
#####################
sub get_id(\$);
sub get_ccds_id($);

sub get_id(\$)
{
	my ($ref_chromosome_report) = @_;

	# Ensembl connection details
	my($registry)='Bio::EnsEMBL::Registry';
	eval {
		$registry->load_registry_from_db(
				-host => 'jabba.cnio.es',
				-user => 'ensembl'
#			    -host => 'ensembldb.ensembl.org',
#			    -user => 'anonymous'
		);
	};
	return "1:",$@ if $@;
	

	while(my ($gene_id, $gene_features)=each(%{$$ref_chromosome_report}))
	{
		my($gene);
		if($gene_id=~/^OTTHUMG/)
		{
			my($gene_adaptor)=$registry->get_adaptor('human','vega','gene');
			my($gene_aux)=@{$gene_adaptor->fetch_all_by_external_name($gene_id)}; # ListRef
			$gene=$gene_aux; # We get the first one
		}
		elsif($gene_id=~/^ENSG/)
		{
			my($gene_adaptor)=$registry->get_adaptor('human','core','gene');
			$gene=$gene_adaptor->fetch_by_stable_id($gene_id);
		}

		# Be careful: Sometimes we have information for a transcript where there is not transcript report
	 	if(defined $gene and defined $gene->stable_id())
	 	{
	 		# Get the UniProt ID from description when Gene Id is Ensembl
	 		if(defined $gene->description())
	 		{	 			
	 			my($description)=$gene->description();
	 			if($description=~/\[Source:UniProtKB\/Swiss-Prot;Acc:([^\]]*)\]/)
	 			{
	 				my($uniprot_id)=$1;
	 				$$ref_chromosome_report->{$gene_id}->{'uniprot_id'}=$uniprot_id if(defined $uniprot_id);	
	 			}
	 		}
			my(@db_entries)=@{$gene->get_all_DBEntries};
			foreach my $dbe (@db_entries)
			{
				if(defined $dbe->dbname() and defined $dbe->display_id())
				{
					if(($dbe->dbname() eq 'Ens_Hs_gene') and defined $dbe->display_id())
					{
						$$ref_chromosome_report->{$gene_id}->{'ensembl_id'}=$dbe->display_id();
					}
					if(($dbe->dbname() eq 'Uniprot/SWISSPROT') and defined $dbe->display_id())
					{
						$$ref_chromosome_report->{$gene_id}->{'uniprot_id'}=$dbe->display_id();
					}
				}
			}
	 	}
	 		
		while(my ($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))		
		{
			my($transcript);
			if($transcript_id=~/^OTTHUMT/)
			{
				my($transcript_adaptor)=$registry->get_adaptor('human','vega','transcript');
				my($transcript_aux)=@{$transcript_adaptor->fetch_all_by_external_name($transcript_id)}; # ListRef
				$transcript=$transcript_aux; # We get the first one
			}
			elsif($transcript_id=~/^ENST/)
			{
				my($transcript_adaptor)=$registry->get_adaptor('human','core','transcript');
				$transcript=$transcript_adaptor->fetch_by_stable_id($transcript_id);
			}

			# Be careful: Sometimes we have information for a transcript where there is not transcript report
	 		if(defined $transcript and defined $transcript->stable_id())
	 		{
	 			# Get VEGA Peptide Id (By default transcript id)
	 			my($vega_peptide_id)=$transcript_id;
				if(defined $transcript->translation() and defined $transcript->translation()->stable_id())
				{
					my($vega_translation)=$transcript->translation();
					$vega_peptide_id=$vega_translation->stable_id() if(defined $vega_translation->stable_id());
					$$ref_chromosome_report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$vega_peptide_id}=();
				}
				
				# Get CCDS
				my(@dblinks)=@{$transcript->get_all_DBLinks};				
				foreach my $dbe (@dblinks)
				{
					if(($dbe->dbname() eq 'CCDS') and defined $dbe->primary_id())
					{
						$$ref_chromosome_report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'ccds'}=$dbe->primary_id();						
					}
				}
	 		}
		}
	}
	return undef;
		
} # End get_id

sub get_ccds_id($)
{
	my ($transcript_id) = @_;
	
	my($ccdsIDs);
	
	# Ensembl connection details
	my($registry)='Bio::EnsEMBL::Registry';
	eval {
		$registry->load_registry_from_db(
				-host => 'jabba.cnio.es',
				-user => 'ensembl'
#			    -host => 'ensembldb.ensembl.org',
#			    -user => 'anonymous'
		);
	};
	return "1:",$@ if $@;
	
	my($transcript_adaptor)=$registry->get_adaptor('human','core','transcript');
	my($transcript)=$transcript_adaptor->fetch_by_stable_id($transcript_id);
	if($transcript) {
		my(@dblinks)=@{$transcript->get_all_DBLinks};
		
		foreach my $entry (@dblinks) {
			if ($entry->dbname eq 'CCDS') {
				push(@{$ccdsIDs}, $entry->primary_id());
			}
		}		
	}
	return $ccdsIDs;
} # End get_ccds_id
1;