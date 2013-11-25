# _________________________________________________________________
# $Id: DB.pm 1564 2011-06-05 18:17:44Z jmrodriguez $
# $Revision: 1564 $
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________
package DB;

use strict;
use warnings;
use Config::IniFiles;
use FindBin;
use MySQL;
use Constant;


###################
# Global variable #
###################
use vars qw($DB_HOST $DB_NAME $DB_PORT $DB_USER $DB_PASS);

# Init File
# TODO: You have to do something with config file
my $cfg = new Config::IniFiles(-file =>  "$FindBin::Bin/conf/config.ini"); 
$DB_HOST = $cfg->val( 'ENCODE_DB', 'host');
$DB_NAME = $cfg->val( 'ENCODE_DB', 'db' );
$DB_PORT = $cfg->val( 'ENCODE_DB', 'port');
$DB_USER = $cfg->val( 'ENCODE_DB', 'user');
$DB_PASS = $cfg->val( 'ENCODE_DB', 'pass');


#####################
# Method prototypes #
#####################
sub insert_chromosome_report($);
sub insert_transcript_sequence($);
sub insert_peptide_sequence($);
sub insert_cds_alignment($);
sub insert_extended_peptide_sequence($);
sub insert_signalp_annotations($);
sub insert_targetp_annotations($);
sub insert_firestar_annotations($);
sub insert_cexonic_annotations($);
sub insert_matador3d_annotations($);
sub insert_thump_annotations($);
sub insert_spade_annotations($);
sub insert_corsair_annotations($);
sub insert_inertia_annotations($);
sub insert_slr_annotations($$$$$);
sub insert_pi_annotation($$$);
sub insert_appris_annotations($);

sub update_xref_identify($);
sub update_cexonic_annotation($$);
sub update_omega_annotation($$);
sub update_appris_annotation($$);

sub get_chromosome_report($);
sub get_chromosome_report_region($);
sub get_chromosome_report_gene($);
sub get_alignment($$);
sub get_coordinate($);
sub get_exons($);
sub get_cds($);
sub get_signalp_annotations($);
sub get_signalp_annotations_gene($);
sub get_targetp_annotations($);
sub get_targetp_annotations_gene($);
sub get_firestar_annotations($);
sub get_firestar_annotations_gene($);
sub get_firestar_residues_annotations($);
sub get_spade_annotations($);
sub get_spade_annotations_gene($);
sub get_spade_residues_annotations($);
sub get_corsair_annotations($);
sub get_corsair_annotations_gene($);
sub get_cexonic_annotations($);
sub get_cexonic_annotations_gene($);
sub get_cexonic_residues_annotations($);
sub get_matador3d_annotations($);
sub get_matador3d_annotations_gene($);
sub get_matador3d_alignments_annotations($);
sub get_thump_annotations($);
sub get_thump_annotations_gene($);
sub get_inertia_annotations($);
sub get_inertia_residues_annotations($);
sub get_omega_annotations($$);
sub get_omega_residues_annotations($);
sub get_slr_report($);
sub get_pi_annotation($$);
sub get_appris_annotations($);


##################
# INSERT methods #
##################

sub insert_chromosome_report($)
{
	my($chromosome_features) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get the Identifiers for entity datasources
	my($vega_gene_datasource_id);
	my($vega_trans_datasource_id);
	my($vega_pep_datasource_id);	
	my($external_datasource_id);	
	my($ensembl_gene_datasource_id);
	my($ensembl_trans_datasource_id);
	my($ensembl_pep_datasource_id);
	my($uniprot_gene_datasource_id);
	my($ccds_trans_datasource_id);
	eval {	
		my($datasource_list)=$db->query_datasource(name => 'Vega_Gene_Id');
		$vega_gene_datasource_id=$datasource_list->[0]->{'datasource_id'};
		
		my($datasource_list2)=$db->query_datasource(name => 'Vega_Transcript_Id');
		$vega_trans_datasource_id=$datasource_list2->[0]->{'datasource_id'};
		
		my($datasource_list3)=$db->query_datasource(name => 'Vega_Peptide_Id');
		$vega_pep_datasource_id=$datasource_list3->[0]->{'datasource_id'};
		
		my($datasource_list4)=$db->query_datasource(name => 'External_Id');
		$external_datasource_id=$datasource_list4->[0]->{'datasource_id'};
		
		my($datasource_list5)=$db->query_datasource(name => 'Ensembl_Gene_Id');
		$ensembl_gene_datasource_id=$datasource_list5->[0]->{'datasource_id'};
		
		my($datasource_list6)=$db->query_datasource(name => 'Ensembl_Transcript_Id');
		$ensembl_trans_datasource_id=$datasource_list6->[0]->{'datasource_id'};
		
		my($datasource_list7)=$db->query_datasource(name => 'Ensembl_Peptide_Id');
		$ensembl_pep_datasource_id=$datasource_list7->[0]->{'datasource_id'};

		my($datasource_list8)=$db->query_datasource(name => 'UniProtKB_SwissProt');
		$uniprot_gene_datasource_id=$datasource_list8->[0]->{'datasource_id'};

		my($datasource_list9)=$db->query_datasource(name => 'CCDS');
		$ccds_trans_datasource_id=$datasource_list9->[0]->{'datasource_id'};		
	};
	return "1:",$@ if($@);
		
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		# Check if exits => ERROR
		eval {
			my($gene_list)=$db->query_entity(identifier => $gene_id);
			return "2:" if(defined $gene_list and scalar(@{$gene_list})>0);
		};
		return "3:",$@ if($@);

		# Get datasource id 
		my($gene_datasource_id);
		if($gene_id=~/^OTTHUMG/)
		{
			$gene_datasource_id=$vega_gene_datasource_id;
		}
		elsif($gene_id=~/^ENSG/)
		{
			$gene_datasource_id=$ensembl_gene_datasource_id;
		}		
		return "3:" unless(defined $gene_datasource_id);
		
		# Insert Gene Entity info
		my(%entity_parameters)=(
								datasource_id => $gene_datasource_id,
								identifier => $gene_id
		);
		if(exists $gene_features->{'source'} and defined $gene_features->{'source'})
		{
			$entity_parameters{'source'}=$gene_features->{'source'};
		}
		if(exists $gene_features->{'class'} and defined $gene_features->{'class'})
		{
			$entity_parameters{'class'}=$gene_features->{'class'};
		}
		if(exists $gene_features->{'status'} and defined $gene_features->{'status'})
		{
			$entity_parameters{'status'}=$gene_features->{'status'};
		}
		if(exists $gene_features->{'level'} and defined $gene_features->{'level'})
		{
			$entity_parameters{'level'}=$gene_features->{'level'};
		}

		my($gene_entity_id)=$db->insert_entity(%entity_parameters);
		return "4:" unless(defined $gene_entity_id);
		
		# Insert Gene Coordinate
		if(	defined $gene_entity_id and 
			exists $gene_features->{'chr'} and defined $gene_features->{'chr'} and
			exists $gene_features->{'start'} and defined $gene_features->{'start'} and
			exists $gene_features->{'end'} and defined $gene_features->{'end'} and
			exists $gene_features->{'strand'} and defined $gene_features->{'strand'}			
		)
		{
			my($xref_list)=$db->query_coordinate(
								entity_id => $gene_entity_id,
								chromosome => $gene_features->{'chr'},
								start => $gene_features->{'start'},
								end => $gene_features->{'end'},
								strand => $gene_features->{'strand'}								
			);
			unless(scalar(@{$xref_list})>0){ # insert if not exists
				$db->insert_coordinate(
								entity_id => $gene_entity_id,
								chromosome => $gene_features->{'chr'},
								start => $gene_features->{'start'},
								end => $gene_features->{'end'},
								strand => $gene_features->{'strand'}								
				);
			}			
		} else { return "5:"; }

		# Insert Havana Id
		if(defined $gene_entity_id and exists $gene_features->{'havana_gene'} and defined $gene_features->{'havana_gene'})
		{
			my(%xref_identify_parameters)=(
										entity_id => $gene_entity_id,
										identifier => $gene_features->{'havana_gene'},
										datasource_id => $vega_gene_datasource_id
			);
			eval {
				my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
				$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
			};
			return "6:",$@ if ($@);
		}

		# Insert External Id
		if(defined $gene_entity_id and exists $gene_features->{'external_id'} and defined $gene_features->{'external_id'})
		{
			my(%xref_identify_parameters)=(
										entity_id => $gene_entity_id,
										identifier => $gene_features->{'external_id'},
										datasource_id => $external_datasource_id # Destiny datasource
			);
			eval {
				my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
				$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
			};
			return "6:",$@ if ($@);
		}

		# Insert Ensembl Gene Id
		if(defined $gene_entity_id and exists $gene_features->{'ensembl_id'} and defined $gene_features->{'ensembl_id'})
		{
			my(%xref_identify_parameters)=(
										entity_id => $gene_entity_id,
										identifier => $gene_features->{'ensembl_id'},
										datasource_id => $ensembl_gene_datasource_id # Destiny datasource
			);
			eval {
				my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
				$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
			};
			return "6:",$@ if ($@);
		}

		# Insert UniProt Id (per gene)
		if(defined $gene_entity_id and exists $gene_features->{'uniprot_id'} and defined $gene_features->{'uniprot_id'})
		{
			my(%xref_identify_parameters)=(
										entity_id => $gene_entity_id,
										identifier => $gene_features->{'uniprot_id'},
										datasource_id => $uniprot_gene_datasource_id # Destiny datasource
			);
			eval {
				my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
				$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
			};
			return "6:",$@ if ($@);
		}

		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			# Check if exits => ERROR
			eval {
				my($transcript_list)=$db->query_entity(identifier => $transcript_id);
				return "7:" if(defined $transcript_list and scalar(@{$transcript_list})>0);
			};
			return "8:",$@ if($@);

			# Get datasource id (Transcript and Peptide)
			my($trans_datasource_id);
			my($pep_datasource_id);
			if($transcript_id=~/^OTTHUMT/)
			{
				$trans_datasource_id=$vega_trans_datasource_id;
				$pep_datasource_id=$vega_pep_datasource_id;
			}
			elsif($transcript_id=~/^ENST/)
			{
				$trans_datasource_id=$ensembl_trans_datasource_id;
				$pep_datasource_id=$ensembl_pep_datasource_id;
			}
			return "8:" unless(defined $trans_datasource_id);

			# Insert Transcript Entity info
			my(%entity_parameters)=(
								datasource_id => $trans_datasource_id,
								identifier => $transcript_id
			);
			if(exists $transcript_features->{'source'} and defined $transcript_features->{'source'})
			{
				$entity_parameters{'source'}=$transcript_features->{'source'};
			}
			if(exists $transcript_features->{'class'} and defined $transcript_features->{'class'})
			{
				$entity_parameters{'class'}=$transcript_features->{'class'};
			}
			if(exists $transcript_features->{'status'} and defined $transcript_features->{'status'})
			{
				$entity_parameters{'status'}=$transcript_features->{'status'};
			}
			if(exists $transcript_features->{'level'} and defined $transcript_features->{'level'})
			{
				$entity_parameters{'level'}=$transcript_features->{'level'};
			}
			
			my($transcript_entity_id)=$db->insert_entity(%entity_parameters);					
			return "9:" unless(defined $transcript_entity_id);
			
			# Insert relation Gene Id => Transcript Id
			if(defined $gene_entity_id and defined $transcript_id)
			{
				my(%xref_identify_parameters)=(
											entity_id => $gene_entity_id,
											identifier => $transcript_id,
											datasource_id => $trans_datasource_id # Destiny datasource (Havana or Source)
				);
				eval {
					my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
					$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
				};
				return "10:",$@ if ($@);				
			}		

			# Insert relation  Transcript Id => Gene Id
			if(defined $gene_entity_id and defined $transcript_id)
			{
				my(%xref_identify_parameters)=(
											entity_id => $transcript_entity_id,
											identifier => $gene_id,
											datasource_id => $gene_datasource_id # Destiny datasource (Havana or Source)
				);
				eval {
					my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
					$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
				};
				return "10:",$@ if ($@);				
			}
						
			# Insert Transcript Coordinate
			if(	defined $transcript_entity_id and
				exists $transcript_features->{'chr'} and defined $transcript_features->{'chr'} and
				exists $transcript_features->{'start'} and defined $transcript_features->{'start'} and
				exists $transcript_features->{'end'} and defined $transcript_features->{'end'} and
				exists $transcript_features->{'strand'} and defined $transcript_features->{'strand'}			
			)
			{
				my($xref_list)=$db->query_coordinate(
									entity_id => $transcript_entity_id,
									chromosome => $transcript_features->{'chr'},
									start => $transcript_features->{'start'},
									end => $transcript_features->{'end'},
									strand => $transcript_features->{'strand'}								
				);
				unless(scalar(@{$xref_list})>0){ # insert if not exists
					$db->insert_coordinate(
									entity_id => $transcript_entity_id,
									chromosome => $transcript_features->{'chr'},
									start => $transcript_features->{'start'},
									end => $transcript_features->{'end'},
									strand => $transcript_features->{'strand'}								
					);
				}			
			} else { return "11:"; }

			# Insert Havana Transcript Id
			if(defined $transcript_entity_id and exists $transcript_features->{'havana_transcript'} and defined $transcript_features->{'havana_transcript'})
			{
				my(%xref_identify_parameters)=(
											entity_id => $transcript_entity_id,
											identifier => $transcript_features->{'havana_transcript'},
											datasource_id => $vega_trans_datasource_id
				);
				eval {
					my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
					$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
				};
				return "12:",$@ if ($@);				
			}

			# Insert External Transcript Id
			if(defined $transcript_entity_id and exists $transcript_features->{'external_id'} and defined $transcript_features->{'external_id'})
			{
				my(%xref_identify_parameters)=(
											entity_id => $transcript_entity_id,
											identifier => $transcript_features->{'external_id'},
											datasource_id => $external_datasource_id # Destiny datasource
				);
				eval {
					my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
					$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
				};
				return "12:",$@ if ($@);				
			}

			# Insert Ensembl Transcript Id
			if(defined $transcript_entity_id and exists $transcript_features->{'ensembl_id'} and defined $transcript_features->{'ensembl_id'})
			{
				my(%xref_identify_parameters)=(
											entity_id => $transcript_entity_id,
											identifier => $transcript_features->{'ensembl_id'},
											datasource_id => $ensembl_trans_datasource_id # Destiny datasource
				);
				eval {
					my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
					$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
				};
				return "13:",$@ if ($@);				
			}

			# Insert Peptide Ids
			if(defined $transcript_entity_id and exists $transcript_features->{'peptide'} and defined $transcript_features->{'peptide'})
			{
				# Scan peptide
				while(my($peptide_id, $peptide_features)=each(%{$transcript_features->{'peptide'}}))
				{			
					# Insert peptide Id
					my(%xref_identify_parameters)=(
											entity_id => $transcript_entity_id,
											identifier => $peptide_id,
											datasource_id => $pep_datasource_id # Destiny datasource
					);
					eval {
						my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
						$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
					};
					return "14:",$@ if ($@);					
				}
			}

			# Insert CCDS Ids
			if(defined $transcript_entity_id and exists $transcript_features->{'ccds'} and defined $transcript_features->{'ccds'})
			{
				# Insert peptide Id
				my(%xref_identify_parameters)=(
										entity_id => $transcript_entity_id,
										identifier => $transcript_features->{'ccds'},
										datasource_id => $ccds_trans_datasource_id # Destiny datasource
				);
				eval {
					my($xref_list)=$db->query_xref_identify(%xref_identify_parameters); # Check if not exits
					$db->insert_xref_identify(%xref_identify_parameters) unless(scalar(@{$xref_list})>0);
				};
				return "14:",$@ if ($@);					
			}

			# Insert Exons
			if(defined $transcript_entity_id and exists $transcript_features->{'exons'} and defined $transcript_features->{'exons'})
			{
				my($exons)=$transcript_features->{'exons'};
				for(my $i=0; $i<scalar(@{$exons}); $i++)
				{
					my($exon_id)=$i+1;
					eval {
						my($xref_list)=$db->query_exon(
											entity_id => $transcript_entity_id,
											exon_id => $exon_id
						);
						unless(scalar(@{$xref_list})>0){ # insert if not exists
							$db->insert_exon(
											entity_id => $transcript_entity_id,
											exon_id => $exon_id,
											start => $exons->[$i]->{'start'},
											end => $exons->[$i]->{'end'},
											strand => $exons->[$i]->{'strand'}
							);
						}
					};
					return "16:",$@ if ($@);					
				}
			}

			# Insert CDS
			if(defined $transcript_entity_id and exists $transcript_features->{'cds'} and defined $transcript_features->{'cds'})
			{
				my($cds_list)=$transcript_features->{'cds'};
				for(my $i=0; $i<scalar(@{$cds_list}); $i++)
				{
					my($cds_id)=$i+1;
					eval {
						my($xref_list)=$db->query_cds(
											entity_id => $transcript_entity_id,
											cds_id => $cds_id
						);
						unless(scalar(@{$xref_list})>0){ # insert if not exists
							$db->insert_cds(
											entity_id => $transcript_entity_id,
											cds_id => $cds_id,
											start => $cds_list->[$i]->{'start'},
											end => $cds_list->[$i]->{'end'},
											strand => $cds_list->[$i]->{'strand'},
											phase => $cds_list->[$i]->{'phase'}
							);
						}
					};
					return "17:",$@ if ($@);					
				}
			}

			# Insert Codons: Start and end
			if(defined $transcript_entity_id and exists $transcript_features->{'codons'} and defined $transcript_features->{'codons'})
			{
				my($codon_list)=$transcript_features->{'codons'};
				foreach my $codon (@{$codon_list})
				{
					my($type_codon)=$codon->{'type'};
					eval {
						my($xref_list)=$db->query_codon(
											entity_id => $transcript_entity_id,
											type => $type_codon
						);
						unless(scalar(@{$xref_list})>0){ # insert if not exists
							$db->insert_codon(
											entity_id => $transcript_entity_id,
											type => $type_codon,
											start => $codon->{'start'},
											end => $codon->{'end'},
											strand => $codon->{'strand'},
											phase => $codon->{'phase'}
							);
						}
					};
					return "18:",$@ if ($@);					
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();
	
	return undef;
	
} # End insert_chromosome_report

sub insert_transcript_sequence($)
{
	my($chromosome_features) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Sequence type
	my($transcript_type_id);
	eval {
		my($type_list)=$db->query_type(name => 'transcript');
		$transcript_type_id=$type_list->[0]->{'type_id'};			
	};
	return $@ if ($@);

	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{			
			# Insert sequence
			if(exists $transcript_features->{'sequence'} and defined $transcript_features->{'sequence'})
			{
				# Get entity id
				my($transcript_entity_id);
				eval {
					my($transcript_list)=$db->query_entity(identifier => $transcript_id);
					return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);

					$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
				};
				return "2:",$@ if ($@);

				eval {
					my($sequence)=$transcript_features->{'sequence'};
					$sequence=~s/\s*//g;
					$db->insert_sequence(
										entity_id => $transcript_entity_id,
										type_id => $transcript_type_id,
										length => length($sequence),
										sequence => $sequence
					);
				};
				return "3:",$@ if ($@);				
			}
		}
	}	
	$db->commit(); # Do commit of everything
	$db->disconnect();
	
	return undef;
	
} # End insert_transcript_sequence

sub insert_peptide_sequence($)
{
	my($chromosome_features) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Sequence type
	my($peptide_type_id);
	eval {
		my($type_list)=$db->query_type(name => 'peptide');
		$peptide_type_id=$type_list->[0]->{'type_id'};			
	};
	return $@ if ($@);

	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{			
			# Insert sequence
			if(exists $transcript_features->{'peptide'} and defined $transcript_features->{'peptide'})
			{
				# Get entity id
				my($transcript_entity_id);
				eval {
					my($transcript_list)=$db->query_entity(identifier => $transcript_id);
					return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
					
					$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
				};
				return "2:",$@ if ($@);
				
				# Scan peptide
				if(defined $transcript_entity_id and exists $transcript_features->{'peptide'} and defined $transcript_features->{'peptide'})
				{
					while(my($peptide_id, $peptide_features)=each(%{$transcript_features->{'peptide'}}))
					{
						if(exists $peptide_features->{'sequence'} and defined $peptide_features->{'sequence'})
						{
							eval {
								my($sequence)=$peptide_features->{'sequence'};
								$sequence=~s/\s*//g;
								$db->insert_sequence(
													entity_id => $transcript_entity_id,
													type_id => $peptide_type_id,
													length => length($sequence),
													sequence => $sequence
								);
							};
							return "3:",$@ if ($@);							
						}
					}
				}
			}
		}
	}	
	$db->commit(); # Do commit of everything
	$db->disconnect();
	
	return undef;	
} # End insert_peptide_sequence

sub insert_extended_peptide_sequence($)
{
	my($chromosome_features) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Sequence type
	my($extended_type_id);
	eval {
		my($type_list)=$db->query_type(name => 'extended');
		$extended_type_id=$type_list->[0]->{'type_id'};			
	};
	return $@ if ($@);

	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{		
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{			
			# Insert Sequence
			if(exists $transcript_features->{'peptide'} and defined $transcript_features->{'peptide'})
			{
				# Get entity id
				my($transcript_entity_id);
				eval {
					my($transcript_list)=$db->query_entity(identifier => $transcript_id);
					return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
					
					$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
				};
				return "2:",$@ if ($@);
				
				# Scan peptide
				if(defined $transcript_entity_id and exists $transcript_features->{'peptide'} and defined $transcript_features->{'peptide'})
				{
					while(my($peptide_id, $peptide_features)=each(%{$transcript_features->{'peptide'}}))
					{
						if(exists $peptide_features->{'extended'} and defined $peptide_features->{'extended'})
						{
							eval {
								my($sequence)=$peptide_features->{'extended'};
								$sequence=~s/\s*//g;
								$db->insert_sequence(
													entity_id => $transcript_entity_id,
													type_id => $extended_type_id,
													length => length($sequence),
													sequence => $sequence
								);
							};
							return "3:",$@ if ($@);							
						}
					}
				}
			}
		}
	}	
	$db->commit(); # Do commit of everything
	$db->disconnect();
	
	return undef;
	
} # End insert_extended_peptide_sequence

sub insert_cds_alignment($) 
{
	my ($chromosome_features) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Sequence type
	my($transcript_type_id);
	eval {
		my($type_list)=$db->query_type(name => 'cds');
		$transcript_type_id=$type_list->[0]->{'type_id'};			
	};
	return $@ if ($@);
	
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'alignments'} and defined $transcript_features->{'alignments'} and
				exists $transcript_features->{'alignments'}->{'cds'} and defined $transcript_features->{'alignments'}->{'cds'}
			)
			{
				my($transcript_alignment_content)=$transcript_features->{'alignments'}->{'cds'};
				my($num_species)=$transcript_features->{'alignments'}->{'num_species'};
				my($length)=$transcript_features->{'alignments'}->{'length'};
				
				# Get Transcript Entity info
				my($transcript_entity_id);
				eval {
					my($transcript_list)=$db->query_entity(identifier => $transcript_id);
					return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
					
					$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
				};
				return "2:",$@ if ($@);
				
				if(defined $transcript_entity_id)
				{
					# Check if the annotation already exists
					my($xref_list)=$db->query_alignment(
										entity_id => $transcript_entity_id,
										type_id => $transcript_type_id
					);
					return "3:",$@ if(defined $xref_list and scalar(@{$xref_list})>0);
					eval {
						$db->insert_alignment(
									entity_id => $transcript_entity_id,
									type_id => $transcript_type_id,
									length => $length,
									num_species => $num_species,
									alignment => $transcript_alignment_content
						);
					};
					return "4:",$@ if ($@);
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
		
} # End insert_cds_alignment

sub insert_signalp_annotations($)
{
	my ($chromosome_features) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		if(	exists $gene_features->{'methods'} and defined $gene_features->{'methods'} and
			exists $gene_features->{'methods'}->{$Constant::SIGNALP_METHOD} and defined $gene_features->{'methods'}->{$Constant::SIGNALP_METHOD}
		)
		{
			my($method_features)=$gene_features->{'methods'}->{$Constant::SIGNALP_METHOD};

			# Get Gene Entity info
			my($gene_entity_id);
			eval {
				my($gene_list)=$db->query_entity(identifier => $gene_id);
				return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
					
				$gene_entity_id=$gene_list->[0]->{'entity_id'};			
			};
			return "2:",$@ if ($@);
	
			if(defined $gene_entity_id)
			{
				eval {
					$db->insert_signalp(
							entity_id => $gene_entity_id,
							result => $method_features->{'result'}
					);
				};
				return "3:",$@ if ($@);
			}
		}
		
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
				exists $transcript_features->{'methods'}->{$Constant::SIGNALP_METHOD} and defined $transcript_features->{'methods'}->{$Constant::SIGNALP_METHOD}
			)
			{
				my($method_features)=$transcript_features->{'methods'}->{$Constant::SIGNALP_METHOD};
				if(	exists $method_features->{'Smean'} and defined $method_features->{'Smean'} and
					exists $method_features->{'Dscore'} and defined $method_features->{'Dscore'} and
					exists $method_features->{'Sprob'} and defined $method_features->{'Sprob'} and
					exists $method_features->{'Cmax'} and defined $method_features->{'Cmax'} and
					exists $method_features->{'score'} and defined $method_features->{'score'} and
					exists $method_features->{'start'} and defined $method_features->{'start'} and
					exists $method_features->{'end'} and defined $method_features->{'end'} and
					exists $method_features->{'trans_start'} and defined $method_features->{'trans_start'} and
					exists $method_features->{'trans_end'} and defined $method_features->{'trans_end'} and
					exists $method_features->{'trans_strand'} and defined $method_features->{'trans_strand'} and					
					exists $method_features->{'peptide_signal'} and defined $method_features->{'peptide_signal'}
				)
				{
					# Get Transcript Entity info
					my($transcript_entity_id);
					eval {
						my($transcript_list)=$db->query_entity(identifier => $transcript_id);
						return "4:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
						
						$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
					};
					return "5:",$@ if ($@);
					
					if(defined $transcript_entity_id)
					{
						# Check if the annotation already exists
						my($xref_list)=$db->query_signalp(
											entity_id=>$transcript_entity_id
						);
						return "6:",$@ if(defined $xref_list and scalar(@{$xref_list})>0);
						eval {
							$db->insert_signalp(
										entity_id => $transcript_entity_id,
										s_mean => $method_features->{'Smean'}->{'score'},
										s_prob => $method_features->{'Sprob'}->{'score'},
										d_score => $method_features->{'Dscore'}->{'score'},
										c_max => $method_features->{'Cmax'}->{'score'},
										score => $method_features->{'score'},
										start => $method_features->{'start'},
										end => $method_features->{'end'},
										trans_start => $method_features->{'trans_start'},
										trans_end => $method_features->{'trans_end'},
										trans_strand => $method_features->{'trans_strand'},
										peptide_signal => $method_features->{'peptide_signal'}
							);
						};
						return "7:",$@ if ($@);
					}
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
	
} # End insert_signalp_annotations

sub insert_targetp_annotations($)
{
	my ($chromosome_features) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		if(	exists $gene_features->{'methods'} and defined $gene_features->{'methods'} and
			exists $gene_features->{'methods'}->{$Constant::TARGETP_METHOD} and defined $gene_features->{'methods'}->{$Constant::TARGETP_METHOD}
		)
		{
			my($method_features)=$gene_features->{'methods'}->{$Constant::TARGETP_METHOD};

			# Get Gene Entity info
			my($gene_entity_id);
			eval {
				my($gene_list)=$db->query_entity(identifier => $gene_id);
				return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
					
				$gene_entity_id=$gene_list->[0]->{'entity_id'};			
			};
			return "2:",$@ if ($@);
	
			if(defined $gene_entity_id)
			{
				eval {
					$db->insert_targetp(
							entity_id => $gene_entity_id,
							result => $method_features->{'result'}
					);
				};
				return "3:",$@ if ($@);
			}
		}
		
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
				exists $transcript_features->{'methods'}->{$Constant::TARGETP_METHOD} and defined $transcript_features->{'methods'}->{$Constant::TARGETP_METHOD}
			)
			{
				my($method_features)=$transcript_features->{'methods'}->{$Constant::TARGETP_METHOD};
				if(	exists $method_features->{'reliability'} and defined $method_features->{'reliability'} and
					exists $method_features->{'localization'} and defined $method_features->{'localization'} and
					exists $method_features->{'score'} and defined $method_features->{'score'} and
					exists $method_features->{'start'} and defined $method_features->{'start'} and
					exists $method_features->{'end'} and defined $method_features->{'end'} and
					exists $method_features->{'trans_start'} and defined $method_features->{'trans_start'} and
					exists $method_features->{'trans_end'} and defined $method_features->{'trans_end'} and
					exists $method_features->{'trans_strand'} and defined $method_features->{'trans_strand'} and
					exists $method_features->{'mitochondrial_signal'} and defined $method_features->{'mitochondrial_signal'}
				)
				{
					# Get Transcript Entity info
					my($transcript_entity_id);
					eval {
						my($transcript_list)=$db->query_entity(identifier => $transcript_id);
						return "4:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
						
						$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
					};
					return "5:",$@ if ($@);
					
					if(defined $transcript_entity_id)
					{
						# Check if the annotation already exists
						my($xref_list)=$db->query_targetp(
											entity_id=>$transcript_entity_id
						);
						return "6:",$@ if(defined $xref_list and scalar(@{$xref_list})>0);
						eval {
							$db->insert_targetp(
										entity_id => $transcript_entity_id,
										reliability => $method_features->{'reliability'}->{'score'},
										localization => $method_features->{'localization'}->{'score'},
										score => $method_features->{'score'},
										start => $method_features->{'start'},
										end => $method_features->{'end'},
										trans_start => $method_features->{'trans_start'},
										trans_end => $method_features->{'trans_end'},
										trans_strand => $method_features->{'trans_strand'},
										mitochondrial_signal => $method_features->{'mitochondrial_signal'}
							);
						};
						return "7:",$@ if ($@);
					}				
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
	
} # End insert_targetp_annotations

sub insert_firestar_annotations($)
{
	my ($chromosome_features) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		if(	exists $gene_features->{'methods'} and defined $gene_features->{'methods'} and
			exists $gene_features->{'methods'}->{$Constant::FIRESTAR_METHOD} and defined $gene_features->{'methods'}->{$Constant::FIRESTAR_METHOD}
		)
		{
			my($method_features)=$gene_features->{'methods'}->{$Constant::FIRESTAR_METHOD};

			# Get Gene Entity info
			my($gene_entity_id);
			eval {
				my($gene_list)=$db->query_entity(identifier => $gene_id);
				return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
					
				$gene_entity_id=$gene_list->[0]->{'entity_id'};			
			};
			return "2:",$@ if ($@);
	
			if(defined $gene_entity_id)
			{
				eval {
					$db->insert_firestar(
							entity_id => $gene_entity_id,
							result => $method_features->{'result'}
					);
				};
				return "3:",$@ if ($@);
			}
		}
		
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
				exists $transcript_features->{'methods'}->{$Constant::FIRESTAR_METHOD} and defined $transcript_features->{'methods'}->{$Constant::FIRESTAR_METHOD}
			)
			{
				my($method_features)=$transcript_features->{'methods'}->{$Constant::FIRESTAR_METHOD};
				if(exists $method_features->{'functional_residue'} and defined $method_features->{'functional_residue'})
				{
					# Get Transcript Entity info
					my($transcript_entity_id);
					eval {
						my($transcript_list)=$db->query_entity(identifier => $transcript_id);
						return "4:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
						
						$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
					};
					return "5:",$@ if ($@);

					# Insert method info
					my($method_id);
					if(defined $transcript_entity_id)
					{
						# Check if the annotation already exists
						my($xref_list)=$db->query_firestar(
											entity_id => $transcript_entity_id
						);
						return "6:",$@ if(defined $xref_list and scalar(@{$xref_list})>0);
						eval {
							my($insert)={
										'entity_id' => $transcript_entity_id,								
										'functional_residue' => $method_features->{'functional_residue'},
							};
							if(exists $method_features->{'result'} and defined $method_features->{'result'})
							{
								$insert->{'result'}=$method_features->{'result'};
							}
							if(exists $method_features->{'num_residues'} and defined $method_features->{'num_residues'})
							{
								$insert->{'num_residues'}=$method_features->{'num_residues'};
							}
							else
							{
								$insert->{'num_residues'}=0;
							}
							$method_id=$db->insert_firestar(%{$insert});
						};
						return "7:",$@ if ($@);
					}
					
					# Insert residues features
					if(	defined $method_id and
						exists $method_features->{'residues'} and defined $method_features->{'residues'}					
					)
					{
						foreach my $residue_features (@{$method_features->{'residues'}})
						{
							if(	exists $residue_features->{'score'} and defined $residue_features->{'score'} and
								exists $residue_features->{'peptide_position'} and defined $residue_features->{'peptide_position'} and
								exists $residue_features->{'start'} and defined $residue_features->{'start'} and
								exists $residue_features->{'end'} and defined $residue_features->{'end'} and
								exists $residue_features->{'strand'} and defined $residue_features->{'strand'}
							){
								eval {
									my($method_residues_id)=$db->insert_firestar_residues(
																			firestar_id => $method_id,
																			score => $residue_features->{'score'},
																			peptide_position => $residue_features->{'peptide_position'},
																			start => $residue_features->{'start'},
																			end => $residue_features->{'end'},
																			strand => $residue_features->{'strand'}
									);
								};
								return "9:",$@ if ($@);
							}
						}					
					}
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
	
} # End insert_firestar_annotations

sub insert_cexonic_annotations($)
{
	my ($chromosome_features) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		if(	exists $gene_features->{'methods'} and defined $gene_features->{'methods'} and
			exists $gene_features->{'methods'}->{$Constant::CEXONIC_METHOD} and defined $gene_features->{'methods'}->{$Constant::CEXONIC_METHOD}
		)
		{
			my($method_features)=$gene_features->{'methods'}->{$Constant::CEXONIC_METHOD};

			# Get Gene Entity info
			my($gene_entity_id);
			eval {
				my($gene_list)=$db->query_entity(identifier => $gene_id);
				return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
					
				$gene_entity_id=$gene_list->[0]->{'entity_id'};			
			};
			return "2:",$@ if ($@);
	
			if(defined $gene_entity_id)
			{
				eval {
					$db->insert_cexonic(
							entity_id => $gene_entity_id,
							specie => $method_features->{'specie'},
							result => $method_features->{'result'},
							first_specie_alignment_image => $method_features->{'first_specie_alignment_image'},
							second_specie_alignment_image => $method_features->{'second_specie_alignment_image'}
					);
				};
				return "3:",$@ if ($@);
			}
		}
		
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
				exists $transcript_features->{'methods'}->{$Constant::CEXONIC_METHOD} and defined $transcript_features->{'methods'}->{$Constant::CEXONIC_METHOD}
			)
			{
				my($method_features)=$transcript_features->{'methods'}->{$Constant::CEXONIC_METHOD};
				if(	exists $method_features->{'result'} and defined $method_features->{'result'} and
					exists $method_features->{'num_introns'} and defined $method_features->{'num_introns'} and
					exists $method_features->{'first_specie_num_exons'} and defined $method_features->{'first_specie_num_exons'} and
					exists $method_features->{'second_specie_num_exons'} and defined $method_features->{'second_specie_num_exons'} and
					exists $method_features->{'conservation_exon'} and defined $method_features->{'conservation_exon'}
				)
				{
					# Get Transcript Entity info
					my($transcript_entity_id);
					eval {
						my($transcript_list)=$db->query_entity(identifier => $transcript_id);
						return "4:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
						
						$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
					};
					return "5:",$@ if ($@);
					
					# Insert method info
					my($method_id);
					if(defined $transcript_entity_id)
					{
						# Check if the annotation already exists
						my($xref_list)=$db->query_cexonic(
											entity_id=>$transcript_entity_id
						);
						return "6:",$@ if(defined $xref_list and scalar(@{$xref_list})>0);
						eval {
							$method_id=$db->insert_cexonic(
										entity_id => $transcript_entity_id,
										result => $method_features->{'result'},
										num_introns => $method_features->{'num_introns'},
										first_specie_num_exons => $method_features->{'first_specie_num_exons'},
										second_specie_num_exons => $method_features->{'second_specie_num_exons'},
										conservation_exon => $method_features->{'conservation_exon'}
							);
						};
						return "7:",$@ if ($@);
					}
					
					# Insert residues features
					if(	defined $method_id and
						exists $method_features->{'residues'} and defined $method_features->{'residues'}					
					)
					{
						foreach my $residue_features (@{$method_features->{'residues'}})
						{
							if(	exists $residue_features->{'start'} and defined $residue_features->{'start'} and
								exists $residue_features->{'end'} and defined $residue_features->{'end'} and
								exists $residue_features->{'strand'} and defined $residue_features->{'strand'}
							){
								eval {
									my($method_residues_id)=$db->insert_cexonic_residues(
																			cexonic_id => $method_id,
																			start => $residue_features->{'start'},
																			end => $residue_features->{'end'},
																			strand => $residue_features->{'strand'}
									);
								};
								return "9:",$@ if ($@);
							}
						}					
					}
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
		
} # End insert_cexonic_annotations

# BEGIN: Version from Iakes
#sub insert_matador3d_annotations($)
#{
#	my ($chromosome_features) = @_;
#
#	# Connection to DB
#	my $db = MySQL->new(
#				dbhost => $DB_HOST,
#				dbname => $DB_NAME,
#				dbport => $DB_PORT,
#				dbuser => $DB_USER,
#				dbpass => $DB_PASS,
#	);
#	# Scan genes
#	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
#	{
#		if(	exists $gene_features->{'methods'} and defined $gene_features->{'methods'} and
#			exists $gene_features->{'methods'}->{$Constant::MATADOR3D_METHOD} and defined $gene_features->{'methods'}->{$Constant::MATADOR3D_METHOD}
#		)
#		{
#			my($method_features)=$gene_features->{'methods'}->{$Constant::MATADOR3D_METHOD};
#
#			# Get Gene Entity info
#			my($gene_entity_id);
#			eval {
#				my($gene_list)=$db->query_entity(identifier => $gene_id);
#				return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
#					
#				$gene_entity_id=$gene_list->[0]->{'entity_id'};			
#			};
#			return "2:",$@ if ($@);
#	
#			if(defined $gene_entity_id)
#			{
#				eval {
#					$db->insert_matador3d(
#							entity_id => $gene_entity_id,
#							result => $method_features->{'result'}
#					);
#				};
#				return "3:",$@ if ($@);
#			}
#		}
#		
#		# Scan transcripts
#		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
#		{
#			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
#				exists $transcript_features->{'methods'}->{$Constant::MATADOR3D_METHOD} and defined $transcript_features->{'methods'}->{$Constant::MATADOR3D_METHOD}
#			)
#			{
#				my($method_features)=$transcript_features->{'methods'}->{$Constant::MATADOR3D_METHOD};
#				if(exists $method_features->{'conservation_structure'} and defined $method_features->{'conservation_structure'})
#				{
#					# Get Transcript Entity info
#					my($transcript_entity_id);
#					eval {
#						my($transcript_list)=$db->query_entity(identifier => $transcript_id);
#						return "4:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
#						
#						$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
#					};
#					return "5:",$@ if ($@);
#					
#					# Insert method info
#					my($method_id);
#					if(defined $transcript_entity_id)
#					{
#						# Check if the annotation already exists
#						my($xref_list)=$db->query_matador3d(
#											entity_id => $transcript_entity_id
#						);
#						return "6:",$@ if(defined $xref_list and scalar(@{$xref_list})>0);
#						eval {
#							my($insert)={
#										'entity_id' => $transcript_entity_id,								
#										'conservation_structure' => $method_features->{'conservation_structure'},
#							};
#							if(exists $method_features->{'result'} and defined $method_features->{'result'})
#							{
#								$insert->{'result'}=$method_features->{'result'};
#							}
#							$method_id=$db->insert_matador3d(%{$insert});
#						};
#						return "7:",$@ if ($@);
#					}
#					
#					# Insert residues features
#					if(	defined $method_id and
#						exists $method_features->{'residues'} and defined $method_features->{'residues'}					
#					)
#					{
#						foreach my $residue_features (values(%{$method_features->{'residues'}}))
#						{
#							if(	exists $residue_features->{'peptide_position'} and defined $residue_features->{'peptide_position'} and
#								exists $residue_features->{'start'} and defined $residue_features->{'start'} and
#								exists $residue_features->{'end'} and defined $residue_features->{'end'} and
#								exists $residue_features->{'strand'} and defined $residue_features->{'strand'}
#							){
#								my($method_residues_id);
#								eval {
#									$method_residues_id=$db->insert_matador3d_residues(
#																			matador3d_id => $method_id,
#																			peptide_position => $residue_features->{'peptide_position'},
#																			start => $residue_features->{'start'},
#																			end => $residue_features->{'end'},
#																			strand => $residue_features->{'strand'}
#									);
#								};
#								return "9:",$@ if ($@);
#
#								# Insert PDB features
#								if(defined $method_residues_id)
#								{
#									foreach my $pdb_features (@{$residue_features->{'pdb_list'}})
#									{
#										if(	exists $pdb_features->{'name'} and defined $pdb_features->{'name'} and
#											exists $pdb_features->{'evalue'} and defined $pdb_features->{'evalue'} and
#											exists $pdb_features->{'coverage'} and defined $pdb_features->{'coverage'} and
#											exists $pdb_features->{'identity'} and defined $pdb_features->{'identity'} and
#											exists $pdb_features->{'num_gaps'} and defined $pdb_features->{'num_gaps'}
#										){										
#											eval {
#												my($matador3d_pdbs_id)=$db->insert_matador3d_pdbs(
#																	matador3d_residues_id => $method_residues_id,
#																	name => $pdb_features->{'name'},
#																	evalue => $pdb_features->{'evalue'},
#																	coverage => $pdb_features->{'coverage'},
#																	identity => $pdb_features->{'identity'},
#																	num_gaps => $pdb_features->{'num_gaps'}
#												);
#											};
#											return "10:",$@ if ($@);
#										}
#									}									
#								}
#							}
#						}					
#					}
#				}
#			}
#		}
#	}
#	$db->commit(); # Do commit of everything
#	$db->disconnect();
#
#	return undef;
#	
#} # End insert_matador3d_annotations
# END: Version from Iakes

# BEGIN: New version of Matador3D
sub insert_matador3d_annotations($)
{
	my ($chromosome_features) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		if(	exists $gene_features->{'methods'} and defined $gene_features->{'methods'} and
			exists $gene_features->{'methods'}->{$Constant::MATADOR3D_METHOD} and defined $gene_features->{'methods'}->{$Constant::MATADOR3D_METHOD}
		)
		{
			my($method_features)=$gene_features->{'methods'}->{$Constant::MATADOR3D_METHOD};

			# Get Gene Entity info
			my($gene_entity_id);
			eval {
				my($gene_list)=$db->query_entity(identifier => $gene_id);
				return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
					
				$gene_entity_id=$gene_list->[0]->{'entity_id'};			
			};
			return "2:",$@ if ($@);
	
			if(defined $gene_entity_id)
			{
				eval {
					$db->insert_matador3d(
							entity_id => $gene_entity_id,
							result => $method_features->{'result'}
					);
				};
				return "3:",$@ if ($@);
			}
		}
		
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
				exists $transcript_features->{'methods'}->{$Constant::MATADOR3D_METHOD} and defined $transcript_features->{'methods'}->{$Constant::MATADOR3D_METHOD}
			)
			{
				my($method_features)=$transcript_features->{'methods'}->{$Constant::MATADOR3D_METHOD};
				if(	exists $method_features->{'score'} and defined $method_features->{'score'} and
					exists $method_features->{'conservation_structure'} and defined $method_features->{'conservation_structure'})
				{
					# Get Transcript Entity info
					my($transcript_entity_id);
					eval {
						my($transcript_list)=$db->query_entity(identifier => $transcript_id);
						return "4:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
						
						$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
					};
					return "5:",$@ if ($@);
					
					# Insert method info
					my($method_id);
					if(defined $transcript_entity_id)
					{
						# Check if the annotation already exists
						my($xref_list)=$db->query_matador3d(
											entity_id => $transcript_entity_id
						);
						return "6:",$@ if(defined $xref_list and scalar(@{$xref_list})>0);
						eval {
							my($insert)={
										'entity_id' => $transcript_entity_id,
										'score' => $method_features->{'score'},
										'conservation_structure' => $method_features->{'conservation_structure'},
							};
							if(exists $method_features->{'result'} and defined $method_features->{'result'})
							{
								$insert->{'result'}=$method_features->{'result'};
							}
							$method_id=$db->insert_matador3d(%{$insert});
						};
						return "7:",$@ if ($@);
					}
					
					# Insert alignment features
					if(	defined $method_id and
						exists $method_features->{'alignments'} and defined $method_features->{'alignments'}					
					)
					{
						foreach my $alignment_features (@{$method_features->{'alignments'}})
						{
							if(	exists $alignment_features->{'cds_id'} and defined $alignment_features->{'cds_id'} and
								exists $alignment_features->{'start'} and defined $alignment_features->{'start'} and
								exists $alignment_features->{'end'} and defined $alignment_features->{'end'} and
								exists $alignment_features->{'score'} and defined $alignment_features->{'score'} and
								exists $alignment_features->{'trans_start'} and defined $alignment_features->{'trans_start'} and
								exists $alignment_features->{'trans_end'} and defined $alignment_features->{'trans_end'} and
								exists $alignment_features->{'trans_strand'} and defined $alignment_features->{'trans_strand'}
							){
								my(%insert_matador3d_alignments)=(
													matador3d_id => $method_id,
													cds_id => $alignment_features->{'cds_id'},
													start => $alignment_features->{'start'},
													end => $alignment_features->{'end'},
													score => $alignment_features->{'score'},
													trans_start => $alignment_features->{'trans_start'},
													trans_end => $alignment_features->{'trans_end'},
													trans_strand => $alignment_features->{'trans_strand'}
								);
								if(exists $alignment_features->{'score'} and defined $alignment_features->{'score'}) {
									$insert_matador3d_alignments{'pdb_id'}=$alignment_features->{'pdb_id'};
								}
								my($method_alignment_id);
								eval {
									$method_alignment_id=$db->insert_matador3d_alignments(%insert_matador3d_alignments);
								};
								return "9:",$@ if ($@);
							}
						}					
					}
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
	
} # End insert_matador3d_annotations
# END: New version of Matador3D

sub insert_thump_annotations($)
{
	my ($chromosome_features) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		if(	exists $gene_features->{'methods'} and defined $gene_features->{'methods'} and
			exists $gene_features->{'methods'}->{$Constant::THUMP_METHOD} and defined $gene_features->{'methods'}->{$Constant::THUMP_METHOD}
		)
		{
			my($method_features)=$gene_features->{'methods'}->{$Constant::THUMP_METHOD};

			# Get Gene Entity info
			my($gene_entity_id);
			eval {
				my($gene_list)=$db->query_entity(identifier => $gene_id);
				return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
					
				$gene_entity_id=$gene_list->[0]->{'entity_id'};			
			};
			return "2:",$@ if ($@);
	
			if(defined $gene_entity_id)
			{
				eval {
					$db->insert_thump(
							entity_id => $gene_entity_id,
							result => $method_features->{'result'}
					);
				};
				return "3:",$@ if ($@);
			}
		}
		
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
				exists $transcript_features->{'methods'}->{$Constant::THUMP_METHOD} and defined $transcript_features->{'methods'}->{$Constant::THUMP_METHOD}
			)
			{
				my($method_features)=$transcript_features->{'methods'}->{$Constant::THUMP_METHOD};
				if(	exists $method_features->{'result'} and defined $method_features->{'result'} and
					exists $method_features->{'num_tmh'} and defined $method_features->{'num_tmh'} and
					exists $method_features->{'num_damaged_tmh'} and defined $method_features->{'num_damaged_tmh'} and
					exists $method_features->{'transmembrane_signal'} and defined $method_features->{'transmembrane_signal'}
				)
				{
					# Get Transcript Entity info
					my($transcript_entity_id);
					eval {
						my($transcript_list)=$db->query_entity(identifier => $transcript_id);
						return "4:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
						
						$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
					};
					return "5:",$@ if ($@);
					
					# Insert method info
					my($method_id);
					if(defined $transcript_entity_id)
					{
						# Check if the annotation already exists
						my($xref_list)=$db->query_thump(
											entity_id=>$transcript_entity_id
						);
						return "6:",$@ if(defined $xref_list and scalar(@{$xref_list})>0);
						eval {
							$method_id=$db->insert_thump(
										entity_id => $transcript_entity_id,
										result => $method_features->{result},
										num_tmh => $method_features->{num_tmh},
										num_damaged_tmh => $method_features->{num_damaged_tmh},
										transmembrane_signal => $method_features->{transmembrane_signal}
							);
						};
						return "7:",$@ if ($@);
					}
					
					# Insert helix features
					if(	defined $method_id and
						exists $method_features->{'tmhs'} and defined $method_features->{'tmhs'}					
					)
					{
						foreach my $helix_features (@{$method_features->{'tmhs'}})
						{
							if(	exists $helix_features->{'start'} and defined $helix_features->{'start'} and
								exists $helix_features->{'end'} and defined $helix_features->{'end'} and
								exists $helix_features->{'trans_start'} and defined $helix_features->{'trans_start'} and
								exists $helix_features->{'trans_end'} and defined $helix_features->{'trans_end'} and
								exists $helix_features->{'trans_strand'} and defined $helix_features->{'trans_strand'}
							){
								my($helix_damaged)=0;
								$helix_damaged=$helix_features->{'damaged'} if(exists $helix_features->{'damaged'} and defined $helix_features->{'damaged'});
								eval {
									my($method_residues_id)=$db->insert_thump_helixes(
																			thump_id => $method_id,
																			start => $helix_features->{'start'},
																			end => $helix_features->{'end'},
																			trans_start => $helix_features->{'trans_start'},
																			trans_end => $helix_features->{'trans_end'},
																			trans_strand => $helix_features->{'trans_strand'},
																			damaged => $helix_damaged
									);
								};
								return "9:",$@ if ($@);
							}
						}					
					}
					
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
	
} # End insert_thump_annotations

sub insert_spade_annotations($)
{
	my ($chromosome_features) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		if(	exists $gene_features->{'methods'} and defined $gene_features->{'methods'} and
			exists $gene_features->{'methods'}->{$Constant::SPADE_METHOD} and defined $gene_features->{'methods'}->{$Constant::SPADE_METHOD}
		)
		{
			my($method_features)=$gene_features->{'methods'}->{$Constant::SPADE_METHOD};

			# Get Gene Entity info
			my($gene_entity_id);
			eval {
				my($gene_list)=$db->query_entity(identifier => $gene_id);
				return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
					
				$gene_entity_id=$gene_list->[0]->{'entity_id'};			
			};
			return "2:",$@ if ($@);
	
			if(defined $gene_entity_id)
			{
				eval {
					$db->insert_spade(
							entity_id => $gene_entity_id,
							result => $method_features->{'result'}
					);
				};
				return "3:",$@ if ($@);
			}
		}
		
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
				exists $transcript_features->{'methods'}->{$Constant::SPADE_METHOD} and defined $transcript_features->{'methods'}->{$Constant::SPADE_METHOD}
			)
			{
				my($method_features)=$transcript_features->{'methods'}->{$Constant::SPADE_METHOD};
				if(	exists $method_features->{'result'} and defined $method_features->{'result'} and
					exists $method_features->{'num_domains'} and defined $method_features->{'num_domains'} and
					exists $method_features->{'num_possibly_damaged_domains'} and defined $method_features->{'num_possibly_damaged_domains'} and
					exists $method_features->{'num_damaged_domains'} and defined $method_features->{'num_damaged_domains'} and
					exists $method_features->{'num_wrong_domains'} and defined $method_features->{'num_wrong_domains'} and
					exists $method_features->{'domain_signal'} and defined $method_features->{'domain_signal'}
				)
				{
					# Get Transcript Entity info
					my($transcript_entity_id);
					eval {
						my($transcript_list)=$db->query_entity(identifier => $transcript_id);
						return "4:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
						
						$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
					};
					return "5:",$@ if ($@);
					
					# Insert method info
					my($method_id);
					if(defined $transcript_entity_id)
					{
						# Check if the annotation already exists
						my($xref_list)=$db->query_spade(
											entity_id=>$transcript_entity_id
						);
						return "6:",$@ if(defined $xref_list and scalar(@{$xref_list})>0);
						eval {
							$method_id=$db->insert_spade(
										entity_id => $transcript_entity_id,
										result => $method_features->{'result'},
										num_domains => $method_features->{'num_domains'},
										num_possibly_damaged_domains => $method_features->{'num_possibly_damaged_domains'},
										num_damaged_domains => $method_features->{'num_damaged_domains'},
										num_wrong_domains => $method_features->{'num_wrong_domains'},
										domain_signal => $method_features->{'domain_signal'}
							);
						};
						return "7:",$@ if ($@);
					}
					
					# Insert features
					if(	defined $method_id and
						exists $method_features->{'domains'} and defined $method_features->{'domains'}					
					)
					{
						foreach my $alignment_features (@{$method_features->{'domains'}})
						{
							if(	exists $alignment_features->{'alignment_start'} and defined $alignment_features->{'alignment_start'} and
								exists $alignment_features->{'alignment_end'} and defined $alignment_features->{'alignment_start'} and
								exists $alignment_features->{'envelope_start'} and defined $alignment_features->{'envelope_start'} and
								exists $alignment_features->{'envelope_end'} and defined $alignment_features->{'envelope_end'} and
								exists $alignment_features->{'hmm_start'} and defined $alignment_features->{'hmm_start'} and
								exists $alignment_features->{'hmm_end'} and defined $alignment_features->{'hmm_end'} and
								exists $alignment_features->{'hmm_length'} and defined $alignment_features->{'hmm_length'} and
								exists $alignment_features->{'hmm_acc'} and defined $alignment_features->{'hmm_acc'} and
								exists $alignment_features->{'hmm_name'} and defined $alignment_features->{'hmm_name'} and
								exists $alignment_features->{'hmm_type'} and defined $alignment_features->{'hmm_type'} and
								exists $alignment_features->{'bit_score'} and defined $alignment_features->{'bit_score'} and
								exists $alignment_features->{'e_value'} and defined $alignment_features->{'e_value'} and
								exists $alignment_features->{'significance'} and defined $alignment_features->{'significance'} and
								exists $alignment_features->{'clan'} and defined $alignment_features->{'clan'} and
								exists $alignment_features->{'trans_start'} and defined $alignment_features->{'trans_start'} and
								exists $alignment_features->{'trans_end'} and defined $alignment_features->{'trans_end'} and
								exists $alignment_features->{'trans_strand'} and defined $alignment_features->{'trans_strand'} and
								exists $alignment_features->{'score'} and defined $alignment_features->{'score'} and
								exists $alignment_features->{'type_domain'} and defined $alignment_features->{'type_domain'}
							){
								my($predicted_active_site_residues)='NULL';
								$predicted_active_site_residues=$alignment_features->{'predicted_active_site_residues'} if(exists $alignment_features->{'predicted_active_site_residues'} and defined $alignment_features->{'predicted_active_site_residues'});
								my($external_id)='NULL';
								$external_id=$alignment_features->{'external_id'} if(exists $alignment_features->{'external_id'} and defined $alignment_features->{'external_id'});
								eval {
									my($method_residues_id)=$db->insert_spade_alignments(
																			spade_id => $method_id,
																			alignment_start => $alignment_features->{'alignment_start'},
																			alignment_end => $alignment_features->{'alignment_end'},
																			envelope_start => $alignment_features->{'envelope_start'},
																			envelope_end => $alignment_features->{'envelope_end'},
																			hmm_start => $alignment_features->{'hmm_start'},
																			hmm_end => $alignment_features->{'hmm_end'},
																			hmm_length => $alignment_features->{'hmm_length'},
																			hmm_acc => $alignment_features->{'hmm_acc'},
																			hmm_name => $alignment_features->{'hmm_name'},
																			hmm_type => $alignment_features->{'hmm_type'},
																			bit_score => $alignment_features->{'bit_score'},
																			evalue => $alignment_features->{'e_value'},
																			significance => $alignment_features->{'significance'},
																			clan => $alignment_features->{'clan'},
																			predicted_active_site_residues => $predicted_active_site_residues,
																			trans_start => $alignment_features->{'trans_start'},
																			trans_end => $alignment_features->{'trans_end'},
																			trans_strand => $alignment_features->{'trans_strand'},
																			score => $alignment_features->{'score'},
																			type_domain => $alignment_features->{'type_domain'},
																			external_id => $external_id																		
									);
								};
								return "9:",$@ if ($@);
							}
						}					
					}
					
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
	
} # End insert_spade_annotations

sub insert_corsair_annotations($)
{
	my ($chromosome_features) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		if(	exists $gene_features->{'methods'} and defined $gene_features->{'methods'} and
			exists $gene_features->{'methods'}->{$Constant::CORSAIR_METHOD} and defined $gene_features->{'methods'}->{$Constant::CORSAIR_METHOD}
		)
		{
			my($method_features)=$gene_features->{'methods'}->{$Constant::CORSAIR_METHOD};

			# Get Gene Entity info
			my($gene_entity_id);
			eval {
				my($gene_list)=$db->query_entity(identifier => $gene_id);
				return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
					
				$gene_entity_id=$gene_list->[0]->{'entity_id'};			
			};
			return "2:",$@ if ($@);
	
			if(defined $gene_entity_id)
			{
				eval {
					$db->insert_corsair(
							entity_id => $gene_entity_id,
							result => $method_features->{'result'}
					);
				};
				return "3:",$@ if ($@);
			}
		}
		
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
				exists $transcript_features->{'methods'}->{$Constant::CORSAIR_METHOD} and defined $transcript_features->{'methods'}->{$Constant::CORSAIR_METHOD}
			)
			{
				my($method_features)=$transcript_features->{'methods'}->{$Constant::CORSAIR_METHOD};
				if(	exists $method_features->{'score'} and defined $method_features->{'score'} and
					exists $method_features->{'vertebrate_signal'} and defined $method_features->{'vertebrate_signal'}
				)
				{
					# Get Transcript Entity info
					my($transcript_entity_id);
					eval {
						my($transcript_list)=$db->query_entity(identifier => $transcript_id);
						return "4:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
						
						$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
					};
					return "5:",$@ if ($@);
					
					# Insert method info
					my($method_id);
					if(defined $transcript_entity_id)
					{
						# Check if the annotation already exists
						my($xref_list)=$db->query_corsair(
											entity_id=>$transcript_entity_id
						);
						return "6:",$@ if(defined $xref_list and scalar(@{$xref_list})>0);
						eval {
							$method_id=$db->insert_corsair(
										entity_id => $transcript_entity_id,
										score => $method_features->{score},
										vertebrate_signal => $method_features->{vertebrate_signal}
							);
						};
						return "7:",$@ if ($@);
					}
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
	
} # End insert_corsair_annotations

sub insert_inertia_annotations($)
{
	my ($chromosome_features) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		# Get Omega Average and Omega St desviation (per gene)
		my($omega_average);
		my($omega_st_desviation);
		
		if(	exists $gene_features->{'methods'} and defined $gene_features->{'methods'} and
			exists $gene_features->{'methods'}->{$Constant::INERTIA_METHOD}->{$Constant::OMEGA_METHOD} and defined $gene_features->{'methods'}->{$Constant::INERTIA_METHOD}->{$Constant::OMEGA_METHOD} and
			exists $gene_features->{'methods'}->{$Constant::INERTIA_METHOD}->{$Constant::OMEGA_METHOD}->{'reports'} and defined $gene_features->{'methods'}->{$Constant::INERTIA_METHOD}->{$Constant::OMEGA_METHOD}->{'reports'}
		)
		{
			my($aux_method_features)=$gene_features->{'methods'}->{$Constant::INERTIA_METHOD}->{$Constant::OMEGA_METHOD}->{'reports'};

			# Scan method types
			while(my($method_type, $method_features)=each(%{$aux_method_features}))
			{
				if(exists $method_features->{'result'} and defined $method_features->{'result'})
				{

					$omega_average->{$method_type}=$method_features->{'omega_average'};
					$omega_st_desviation->{$method_type}=$method_features->{'omega_st_desviation'};					
				}
			}		
		}
		
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
				exists $transcript_features->{'methods'}->{$Constant::INERTIA_METHOD}->{'unusual_evolution'} and defined $transcript_features->{'methods'}->{$Constant::INERTIA_METHOD}->{'unusual_evolution'}
			)
			{
				my($transcript_annotation)=$transcript_features->{'methods'}->{$Constant::INERTIA_METHOD}->{'unusual_evolution'};
				
				# Get Transcript Entity info
				my($transcript_entity_id);
				eval {
					my($transcript_list)=$db->query_entity(identifier => $transcript_id);
					return "4:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
					
					$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
				};
				return "5:",$@ if ($@);
				
				# Insert Global info
				my($global_id);
				if(defined $transcript_entity_id)
				{
					eval {
						$global_id=$db->insert_inertia(
									entity_id => $transcript_entity_id,
									unusual_evolution => $transcript_annotation
						);
					};
					return "7:",$@ if ($@);
				}

				# Insert residues features
				if(	defined $global_id and
					exists $transcript_features->{'methods'}->{$Constant::INERTIA_METHOD}->{'residues'} and 
					defined $transcript_features->{'methods'}->{$Constant::INERTIA_METHOD}->{'residues'}					
				)
				{
					my($transcript_residues)=$transcript_features->{'methods'}->{$Constant::INERTIA_METHOD}->{'residues'};
					foreach my $residue_features (@{$transcript_residues})
					{
						if(	exists $residue_features->{'inertia_exon_id'} and defined $residue_features->{'inertia_exon_id'} and
							exists $residue_features->{'start'} and defined $residue_features->{'start'} and
							exists $residue_features->{'end'} and defined $residue_features->{'end'} and
							exists $residue_features->{'strand'} and defined $residue_features->{'strand'} and
							exists $residue_features->{'unusual_evolution'} and defined $residue_features->{'unusual_evolution'}
						){
							eval {
								my($method_residues_id)=$db->insert_inertia_residues(
																		inertia_id => $global_id,
																		inertia_exon_id => $residue_features->{'inertia_exon_id'},
																		start => $residue_features->{'start'},
																		end => $residue_features->{'end'},
																		strand => $residue_features->{'strand'},
																		unusual_evolution => $residue_features->{'unusual_evolution'}
								);
							};
							return "9:",$@ if ($@);
						}
					}					
				}
							
				# Insert reports
				my($transcript_report)=$transcript_features->{'methods'}->{$Constant::INERTIA_METHOD};
				if(exists $transcript_report->{$Constant::OMEGA_METHOD}->{'reports'} and defined $transcript_report->{$Constant::OMEGA_METHOD}->{'reports'})
				{
					my($aux_method_features2)=$transcript_report->{$Constant::OMEGA_METHOD}->{'reports'};
					
					# Scan method types
					while(my($method_type, $method_features2)=each(%{$aux_method_features2}))
					{
						if(	exists $method_features2->{'result'} and defined $method_features2->{'result'} and
							exists $method_features2->{'unusual_evolution'} and defined $method_features2->{'unusual_evolution'}
						)
						{
							# Get SLR type
							my($slr_type_id);
							eval {
								my($type_list)=$db->query_slr_type(name => $method_type);
								$slr_type_id=$type_list->[0]->{'slr_type_id'};			
							};
							return "8:",$@ if ($@);
							
							# Insert method info
							my($method_id);
							if(defined $global_id)
							{
								eval {
									$method_id=$db->insert_omega(
												inertia_id => $global_id,
												slr_type_id => $slr_type_id,
												omega_average => $omega_average->{$method_type},
												omega_st_desviation => $omega_st_desviation->{$method_type},
												result => $method_features2->{'result'},
												unusual_evolution => $method_features2->{'unusual_evolution'}
									);
								};
								return "8:",$@ if ($@);
							}

							# Insert residues features
							if(	defined $method_id and
								exists $method_features2->{'residues'} and defined $method_features2->{'residues'}					
							)
							{
								foreach my $residue_features2 (@{$method_features2->{'residues'}})
								{
									if(	exists $residue_features2->{'omega_exon_id'} and defined $residue_features2->{'omega_exon_id'} and
										exists $residue_features2->{'start'} and defined $residue_features2->{'start'} and
										exists $residue_features2->{'end'} and defined $residue_features2->{'end'} and
										exists $residue_features2->{'omega_mean'} and defined $residue_features2->{'omega_mean'} and
										exists $residue_features2->{'st_deviation'} and defined $residue_features2->{'st_deviation'} and
										exists $residue_features2->{'p_value'} and defined $residue_features2->{'p_value'} and
										exists $residue_features2->{'difference_value'} and defined $residue_features2->{'difference_value'} and
										exists $residue_features2->{'unusual_evolution'} and defined $residue_features2->{'unusual_evolution'}
									){
										eval {
											my($method_residues_id)=$db->insert_omega_residues(
																					omega_id => $method_id,
																					omega_exon_id => $residue_features2->{'omega_exon_id'},
																					start => $residue_features2->{'start'},
																					end => $residue_features2->{'end'},
																					omega_mean => $residue_features2->{'omega_mean'},
																					st_deviation => $residue_features2->{'st_deviation'},
																					p_value => $residue_features2->{'p_value'},
																					difference_value => $residue_features2->{'difference_value'},
																					unusual_evolution => $residue_features2->{'unusual_evolution'}
											);
										};
										return "9:",$@ if ($@);
									}
								}					
							}
						}
					}
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
	
} # End insert_inertia_annotations

sub insert_slr_annotations($$$$$)
{
	my ($transcript_id, $type, $report, $alignment, $tree) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get SLR type
	my($slr_type_id);
	eval {
		my($type_list)=$db->query_slr_type(name => $type);
		$slr_type_id=$type_list->[0]->{'slr_type_id'};			
	};
	return $@ if ($@);

	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);

	# Insert SLR reult, and both alignment and tree
	if(defined $transcript_entity_id)
	{
		# Get main id
		my($global_id);
		my($xref_list)=$db->query_omega(
							entity_id => $transcript_entity_id,
							slr_type_id => $slr_type_id
		);
		return "3:",$@ unless(defined $xref_list and scalar(@{$xref_list})>0);
		$global_id=$xref_list->[0]->{'omega_id'};			

		if(defined $global_id)
		{
			# Insert SLR result
			my($method_id);
			eval {
				$method_id=$db->insert_slr(
									omega_id => $global_id,
									result => $report
				);
			};
			return "4:",$@ if ($@);

			# Insert Alignment and tree that have been used by SLR
			if(defined $method_id)
			{
				eval {
					$db->insert_slr_alignments(
									slr_id => $method_id,
									alignment => $alignment,
									tree => $tree
					);
				};
				return "5:",$@ if ($@);
			}
		}
	}

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
	
} # End insert_slr_annotations

sub insert_pi_annotation($$$)
{
	my($transcript_id,$label,$value) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);

	# Check if the annotation already exists
	my($xref_list);
	eval {
		$xref_list=$db->query_appris(entity_id=>$transcript_entity_id);
	};
	return "3:",$@ if ($@);

	if(defined $xref_list and scalar(@{$xref_list})>0)
	{
		eval {
			$db->update_appris(
									entity_id => $transcript_entity_id,
									$label => $value
			);
		};
		return "4:",$@ if ($@);

	}else{
		eval {
			$db->insert_appris(
									entity_id => $transcript_entity_id,
									$label => $value
			);
		};
		return "5:",$@ if ($@);
	}
	
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;

} # End insert_pi_annotation

sub insert_appris_annotations($)
{
	my ($chromosome_features) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(	exists $transcript_features->{'methods'} and defined $transcript_features->{'methods'} and
				exists $transcript_features->{'methods'}->{$Constant::PI_METHOD} and defined $transcript_features->{'methods'}->{$Constant::PI_METHOD}
			)
			{
				my($method_features)=$transcript_features->{'methods'}->{$Constant::PI_METHOD};
				if(exists $method_features->{'annotation'} and defined $method_features->{'annotation'})
				{
					# Insert PI annotation
					my($annotation)=$method_features->{'annotation'};
					my($key)=$Constant::PI_LABEL;
					my($insert_pi_error)=insert_pi_annotation($transcript_id,$Constant::PI_LABEL,$annotation);
					return "0:",$insert_pi_error if (defined $insert_pi_error);					
				}
				if(exists $method_features->{'source'} and defined $method_features->{'source'})
				{
					# Insert Source of annotation
					my($annotation)=$method_features->{'source'};
					my($insert_pi_error)=insert_pi_annotation($transcript_id,'source',$annotation);
					return "0:",$insert_pi_error if (defined $insert_pi_error);					
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
	
} # End insert_appris_annotations

##################
# UPDATE methods #
##################
# Update CExonic annotation
sub update_cexonic_annotation($$)
{
	my ($vega_transcript_id,$value) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $vega_transcript_id);
		return "ERROR" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return $@ if ($@);

	if(defined $transcript_entity_id)
	{
		$db->update_cexonic(
							entity_id => $transcript_entity_id,
							value => $value
		);
	}

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
}

# Update Omega annotation
sub update_omega_annotation($$)
{
	my ($vega_transcript_id,$value) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $vega_transcript_id);
		return "ERROR" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return $@ if ($@);

	if(defined $transcript_entity_id)
	{
		$db->update_omega(
							entity_id => $transcript_entity_id,
							value => $value
		);
	}

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
}

# Update APPRIS annotation
sub update_appris_annotation($$)
{
	my ($vega_transcript_id,$value) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $vega_transcript_id);
		return "ERROR" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return $@ if ($@);

	if(defined $transcript_entity_id)
	{
		my (%parameters) = ();
		while (my($key,$val)=each(%{$value})) {
			$parameters{$key} = $val;
		}
		if ( %parameters ) {
			$parameters{entity_id} = $transcript_entity_id;
			$db->update_appris(%parameters);
		}		
	}

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return undef;
}

sub update_xref_identify($)
{
	my($chromosome_features) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get the Identifiers for entity datasources
	my($vega_gene_datasource_id);
	my($vega_trans_datasource_id);
	my($vega_pep_datasource_id);	
	my($external_datasource_id);	
	my($ensembl_gene_datasource_id);
	my($ensembl_trans_datasource_id);
	my($ensembl_pep_datasource_id);
	my($uniprot_gene_datasource_id);
	eval {	
		my($datasource_list)=$db->query_datasource(name => 'Vega_Gene_Id');
		$vega_gene_datasource_id=$datasource_list->[0]->{'datasource_id'};
		
		my($datasource_list2)=$db->query_datasource(name => 'Vega_Transcript_Id');
		$vega_trans_datasource_id=$datasource_list2->[0]->{'datasource_id'};
		
		my($datasource_list3)=$db->query_datasource(name => 'Vega_Peptide_Id');
		$vega_pep_datasource_id=$datasource_list3->[0]->{'datasource_id'};
		
		my($datasource_list4)=$db->query_datasource(name => 'External_Id');
		$external_datasource_id=$datasource_list4->[0]->{'datasource_id'};
		
		my($datasource_list5)=$db->query_datasource(name => 'Ensembl_Gene_Id');
		$ensembl_gene_datasource_id=$datasource_list5->[0]->{'datasource_id'};
		
		my($datasource_list6)=$db->query_datasource(name => 'Ensembl_Transcript_Id');
		$ensembl_trans_datasource_id=$datasource_list6->[0]->{'datasource_id'};
		
		my($datasource_list7)=$db->query_datasource(name => 'Ensembl_Peptide_Id');
		$ensembl_pep_datasource_id=$datasource_list7->[0]->{'datasource_id'};

		my($datasource_list8)=$db->query_datasource(name => 'UniProtKB_SwissProt');
		$uniprot_gene_datasource_id=$datasource_list8->[0]->{'datasource_id'};
	};
	return "1:",$@ if($@);
		
	# Scan genes
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		# Get entity id
		my($gene_entity_id);
		eval {
			my($gene_list)=$db->query_entity(identifier => $gene_id);
			return "2:" unless(defined $gene_list and scalar(@{$gene_list})>0);
			$gene_entity_id=$gene_list->[0]->{'entity_id'}; # We get the first one
		};
		return "3:",$@ if($@);

		# Get datasource id (Gene)
		my($gene_datasource_id);
		if(exists $gene_features->{'source'} and defined $gene_features->{'source'})
		{
			if($gene_features->{'source'} eq $Constant::HAVANA_SOURCE)
			{
				$gene_datasource_id=$vega_gene_datasource_id;
			}
			elsif($gene_features->{'source'} eq $Constant::ENSEMBL_SOURCE)
			{
				$gene_datasource_id=$ensembl_gene_datasource_id;
			}
		}
		return "3:" unless(defined $gene_datasource_id);	
		
		# Update External Id
		if(defined $gene_entity_id and exists $gene_features->{'external_id'} and defined $gene_features->{'external_id'})
		{
			my(%xref_identify_parameters)=(
									entity_id => $gene_entity_id,
									identifier => $gene_features->{'external_id'},
									datasource_id => $external_datasource_id, # Destiny datasource
			);
			eval {
				# Check if exits
				my($xref_list)=$db->query_xref_identify(
														entity_id => $gene_entity_id,
														datasource_id => $external_datasource_id
				); 
				if(scalar(@{$xref_list})==0)
				{
					$db->insert_xref_identify(%xref_identify_parameters);					
				}
				else
				{
					$db->update_xref_identify(%xref_identify_parameters);
				}
			};
			return "4:",$@ if ($@);
		}

		# Update Ensembl Gene Id
		if(defined $gene_entity_id and exists $gene_features->{'ensembl_id'} and defined $gene_features->{'ensembl_id'})
		{
			my(%xref_identify_parameters)=(
										entity_id => $gene_entity_id,
										identifier => $gene_features->{'ensembl_id'},
										datasource_id => $ensembl_gene_datasource_id # Destiny datasource
			);
			eval {
				# Check if exits
				my($xref_list)=$db->query_xref_identify(
														entity_id => $gene_entity_id,
														datasource_id => $ensembl_gene_datasource_id
				); 
				if(scalar(@{$xref_list})==0)
				{
					$db->insert_xref_identify(%xref_identify_parameters);					
				}
				else
				{
					$db->update_xref_identify(%xref_identify_parameters);
				}
			};
			return "5:",$@ if ($@);			
		}

		# Update UniProt Id (per gene)
		if(defined $gene_entity_id and exists $gene_features->{'uniprot_id'} and defined $gene_features->{'uniprot_id'})
		{
			my(%xref_identify_parameters)=(
										entity_id => $gene_entity_id,
										identifier => $gene_features->{'uniprot_id'},
										datasource_id => $uniprot_gene_datasource_id # Destiny datasource
			);
			eval {
				# Check if exits
				my($xref_list)=$db->query_xref_identify(
														entity_id => $gene_entity_id,
														datasource_id => $uniprot_gene_datasource_id
				); 
				if(scalar(@{$xref_list})==0)
				{
					$db->insert_xref_identify(%xref_identify_parameters);					
				}
				else
				{
					$db->update_xref_identify(%xref_identify_parameters);
				}
			};
			return "6:",$@ if ($@);
		}

		# Scan transcripts
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			# Get datasource id (Transcript and Peptide)
			my($trans_datasource_id);
			my($pep_datasource_id);
			if(exists $transcript_features->{'source'} and defined $transcript_features->{'source'})
			{
				if($transcript_features->{'source'} eq $Constant::HAVANA_SOURCE)
				{
					$trans_datasource_id=$vega_trans_datasource_id;
					$pep_datasource_id=$vega_pep_datasource_id;
				}
				elsif($transcript_features->{'source'} eq $Constant::ENSEMBL_SOURCE)
				{
					$trans_datasource_id=$ensembl_trans_datasource_id;
					$pep_datasource_id=$ensembl_pep_datasource_id;
				}
			}
			return "8:" unless(defined $trans_datasource_id);

			# Check if exits
			my($transcript_entity_id);
			eval {
				my($transcript_list)=$db->query_entity(identifier => $transcript_id);
				return "7:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
				$transcript_entity_id=$transcript_list->[0]->{'entity_id'}; # We get the first one
				
			};
			return "8:",$@ if($@);

			# Insert relation Gene Id => Transcript Id
			if(defined $gene_entity_id and defined $transcript_id)
			{
			
				# If it is HAVANA source that means there is havana transcript xref identifier
print STDERR "GENE($gene_entity_id): $gene_id TRANS: $trans_datasource_id \n";			
				if($transcript_features->{'source'} eq $Constant::HAVANA_SOURCE)
				{
print STDERR "HAVANA_TRANSCRIPT:".$transcript_features->{'havana_transcript'}."\n";					
					if(exists $transcript_features->{'havana_transcript'} and defined $transcript_features->{'havana_transcript'})
					{
						my(%xref_identify_parameters)=(
													entity_id => $gene_entity_id,
													identifier => $transcript_features->{'havana_transcript'},
													datasource_id => $trans_datasource_id # Destiny datasource (Havana or Source)
						);
print STDERR "IDENTIFY:".Dumper(%xref_identify_parameters).": ";
						eval {
							# Check if exits
							my($xref_list)=$db->query_xref_identify(
																	entity_id => $gene_entity_id,
																	datasource_id => $trans_datasource_id
							); 
							if(scalar(@{$xref_list})==0)
							{
print STDERR "INSERT\n";								
								$db->insert_xref_identify(%xref_identify_parameters);					
							}
							else
							{
print STDERR "UPDATE\n";
								$db->update_xref_identify(%xref_identify_parameters);
							}
						};
						return "9:",$@ if ($@);
	
					} 
				}
				elsif($transcript_features->{'source'} eq $Constant::ENSEMBL_SOURCE)
				{
					my(%xref_identify_parameters)=(
												entity_id => $gene_entity_id,
												identifier => $transcript_id,
												datasource_id => $trans_datasource_id # Destiny datasource (Havana or Source)
					);
					eval {
						# Check if exits
						my($xref_list)=$db->query_xref_identify(
																entity_id => $gene_entity_id,
																datasource_id => $trans_datasource_id
						); 
						if(scalar(@{$xref_list})==0)
						{
							$db->insert_xref_identify(%xref_identify_parameters);					
						}
						else
						{
							$db->update_xref_identify(%xref_identify_parameters);
						}
					};
					return "9:",$@ if ($@);
				}
			}
			
			# Insert relation  Transcript Id => Gene Id
			if(defined $gene_entity_id and defined $transcript_id)
			{
				my(%xref_identify_parameters)=(
											entity_id => $transcript_entity_id,
											identifier => $gene_id,
											datasource_id => $gene_datasource_id # Destiny datasource (Havana or Source)
				);
				eval {
					# Check if exits
					my($xref_list)=$db->query_xref_identify(
															entity_id => $transcript_entity_id,
															datasource_id => $gene_datasource_id
					); 
					if(scalar(@{$xref_list})==0)
					{
						$db->insert_xref_identify(%xref_identify_parameters);					
					}
					else
					{
						$db->update_xref_identify(%xref_identify_parameters);
					}
				};
				return "9:",$@ if ($@);
			}
			
			# Update External Transcript Id
			if(defined $transcript_entity_id and exists $transcript_features->{'external_id'} and defined $transcript_features->{'external_id'})
			{
				my(%xref_identify_parameters)=(
											entity_id => $transcript_entity_id,
											identifier => $transcript_features->{'external_id'},
											datasource_id => $external_datasource_id # Destiny datasource
				);
				eval {
					# Check if exits
					my($xref_list)=$db->query_xref_identify(
															entity_id => $transcript_entity_id,
															datasource_id => $external_datasource_id
					); 
					if(scalar(@{$xref_list})==0)
					{
						$db->insert_xref_identify(%xref_identify_parameters);					
					}
					else
					{
						$db->update_xref_identify(%xref_identify_parameters);
					}
				};
				return "9:",$@ if ($@);
			}

			# Update Ensembl Transcript Id
			if(defined $transcript_entity_id and exists $transcript_features->{'ensembl_id'} and defined $transcript_features->{'ensembl_id'})
			{
				my(%xref_identify_parameters)=(
											entity_id => $transcript_entity_id,
											identifier => $transcript_features->{'ensembl_id'},
											datasource_id => $ensembl_trans_datasource_id # Destiny datasource
				);
				eval {
					# Check if exits
					my($xref_list)=$db->query_xref_identify(
															entity_id => $transcript_entity_id,
															datasource_id => $ensembl_trans_datasource_id
					); 
					if(scalar(@{$xref_list})==0)
					{
						$db->insert_xref_identify(%xref_identify_parameters);					
					}
					else
					{
						$db->update_xref_identify(%xref_identify_parameters);
					}
				};
				return "10:",$@ if ($@);
			}

			# Update Peptide Ids
			if(defined $transcript_entity_id and exists $transcript_features->{'peptide'} and defined $transcript_features->{'peptide'})
			{
				# Scan peptide
				while(my($peptide_id, $peptide_features)=each(%{$transcript_features->{'peptide'}}))
				{
					# Update peptide Id
					my(%xref_identify_parameters)=(
											entity_id => $transcript_entity_id,
											identifier => $peptide_id,
											datasource_id => $pep_datasource_id # Destiny datasource
					);
					eval {
						# Check if exits
						my($xref_list)=$db->query_xref_identify(
																entity_id => $transcript_entity_id,
																datasource_id => $pep_datasource_id
						); 
						if(scalar(@{$xref_list})==0)
						{
							$db->insert_xref_identify(%xref_identify_parameters);					
						}
						else
						{
							$db->update_xref_identify(%xref_identify_parameters);
						}
					};
					return "11:",$@ if ($@);
				}
			}
		}
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();
	
	return undef;
}


##################
# SELECT methods #
##################
# Get features from chromosome
sub get_chromosome_report($)
{
	my ($chromosome) = @_;
	my($report);
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Entity identifiers
	my($vega_gene_datasource_id);
	my($vega_trans_datasource_id);
	my($vega_pep_datasource_id);
	my($external_datasource_id);
	my($ensembl_gene_datasource_id);
	my($ensembl_trans_datasource_id);
	my($ensembl_pep_datasource_id);
	my($ccds_datasource_id);
	eval {
		my($datasource_list)=$db->query_datasource(name => 'Vega_Gene_Id');
		$vega_gene_datasource_id=$datasource_list->[0]->{'datasource_id'};
		my($datasource_list2)=$db->query_datasource(name => 'Vega_Transcript_Id');
		$vega_trans_datasource_id=$datasource_list2->[0]->{'datasource_id'};			
		my($datasource_list3)=$db->query_datasource(name => 'Vega_Peptide_Id');
		$vega_pep_datasource_id=$datasource_list3->[0]->{'datasource_id'};			
		my($datasource_list4)=$db->query_datasource(name => 'External_Id');
		$external_datasource_id=$datasource_list4->[0]->{'datasource_id'};
		my($datasource_list5)=$db->query_datasource(name => 'Ensembl_Gene_Id');
		$ensembl_gene_datasource_id=$datasource_list5->[0]->{'datasource_id'};		
		my($datasource_list6)=$db->query_datasource(name => 'Ensembl_Transcript_Id');
		$ensembl_trans_datasource_id=$datasource_list6->[0]->{'datasource_id'};
		my($datasource_list7)=$db->query_datasource(name => 'Ensembl_Peptide_Id');
		$ensembl_pep_datasource_id=$datasource_list7->[0]->{'datasource_id'};
		my($datasource_list8)=$db->query_datasource(name => 'CCDS');
		$ccds_datasource_id=$datasource_list8->[0]->{'datasource_id'};				
	};
	return "1:",$@ if($@);

	# Get Sequence type
	my($transcript_type_id);
	my($peptide_type_id);
	my($extended_type_id);
	eval {
		my($type_list)=$db->query_type(name => 'transcript');
		$transcript_type_id=$type_list->[0]->{'type_id'};			
		my($type_list2)=$db->query_type(name => 'peptide');
		$peptide_type_id=$type_list2->[0]->{'type_id'};			
		my($type_list3)=$db->query_type(name => 'extended');
		$extended_type_id=$type_list3->[0]->{'type_id'};

	};
	return "2:",$@ if ($@);

	# Get gene list from chromosome
	my($gene_list);
	eval {	
		$gene_list=$db->query_entity_coordinate2(
										datasource_id => [$vega_gene_datasource_id,$ensembl_gene_datasource_id],
										chromosome => $chromosome
		);
	};		
	return "3:",$@ if($@);
	return "4:" unless(defined $gene_list and scalar(@{$gene_list})>0);

	# Scan every gene
	foreach my $gene (@{$gene_list})
	{
		if(	exists $gene->{'entity_id'} and defined $gene->{'entity_id'} and
			exists $gene->{'identifier'} and defined $gene->{'identifier'} and
			exists $gene->{'source'} and defined $gene->{'source'} and
			exists $gene->{'class'} and defined $gene->{'class'} and
			exists $gene->{'status'} and defined $gene->{'status'} and
			exists $gene->{'level'} and defined $gene->{'level'} and
			exists $gene->{'chromosome'} and defined $gene->{'chromosome'} and		
			exists $gene->{'start'} and defined $gene->{'start'} and		
			exists $gene->{'end'} and defined $gene->{'end'} and		
			exists $gene->{'strand'} and defined $gene->{'strand'}
		)
		{
			# Get main information
			my($gene_id)=$gene->{'identifier'};
			my($gene_entity_id)=$gene->{'entity_id'};
			my($gene_report)={
						'source' => $gene->{'source'},
						'class' => $gene->{'class'},
						'status' => $gene->{'status'},
						'level' => $gene->{'level'},
						'chr' => $gene->{'chromosome'},
						'start' => $gene->{'start'},
						'end' => $gene->{'end'},
						'strand' => $gene->{'strand'}
			};
			$report->{$gene_id}=$gene_report;

			# Get Entity identifier
			# Ensembl gene id
			my($xref_external_list);
			my($ensembl_gene_id);
			eval {
				$xref_external_list=$db->query_xref_identify(
										entity_id => $gene_entity_id,
										datasource_id => $ensembl_gene_datasource_id,
				);
				return "5:" unless(defined $xref_external_list and scalar(@{$xref_external_list})>0);
				$ensembl_gene_id=$xref_external_list->[0]->{'identifier'};
			};
			return "6:", $@ if ($@);
			$report->{$gene_id}->{'ensembl_id'}=$ensembl_gene_id if (defined $ensembl_gene_id);
			
			# Get transcript list from given gene identifier
			my($xref_transcript_list);
			eval {
				$xref_transcript_list=$db->query_xref_identify2(
										entity_id => $gene_entity_id,
										datasource_id => [$vega_trans_datasource_id,$ensembl_trans_datasource_id],
				);
				return "7:" unless(defined $xref_transcript_list and scalar(@{$xref_transcript_list})>0);			
			};
			return "8:", $@ if ($@);

			foreach my $xref_transcript (@{$xref_transcript_list})
			{
				# Get transcript coordinates from given identifier
				my($transcript_list);
				eval {
					$transcript_list=$db->query_entity_coordinate(identifier => $xref_transcript->{'identifier'});
					return "9:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);			
					
				};
				return "10:",$@ if($@);

				my($transcript)=$transcript_list->[0]; # We get the first one
				if(	exists $transcript->{'entity_id'} and defined $transcript->{'entity_id'} and
					exists $transcript->{'identifier'} and defined $transcript->{'identifier'} and
					exists $transcript->{'source'} and defined $transcript->{'source'} and
					exists $transcript->{'class'} and defined $transcript->{'class'} and
					exists $transcript->{'status'} and defined $transcript->{'status'} and
					exists $transcript->{'level'} and defined $transcript->{'level'} and
					exists $transcript->{'chromosome'} and defined $transcript->{'chromosome'} and		
					exists $transcript->{'start'} and defined $transcript->{'start'} and		
					exists $transcript->{'end'} and defined $transcript->{'end'} and		
					exists $transcript->{'strand'} and defined $transcript->{'strand'} 
				)
				{
					# Get main information
					my($transcript_id)=$transcript->{'identifier'};
					my($transcript_entity_id)=$transcript->{'entity_id'};
					my($transcript_report)={
								'source' => $transcript->{'source'},
								'status' => $transcript->{'status'},								
								'class' => $transcript->{'class'},
								'level' => $transcript->{'level'},
								'chr' => $transcript->{'chromosome'},
								'start' => $transcript->{'start'},
								'end' => $transcript->{'end'},
								'strand' => $transcript->{'strand'}
					};
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}=$transcript_report;

					# Get Start and End codon
					my($codon_list);
					eval {
						$codon_list=$db->query_codon(entity_id => $transcript_entity_id);

					};
					return "11:",$@ if($@);
					foreach my $codon (@{$codon_list}){
						my($codon_report);
						$codon_report->{'type'}=$codon->{'type'} if(defined $codon->{'type'});
						$codon_report->{'strand'}=$codon->{'strand'} if(defined $codon->{'strand'});
						$codon_report->{'start'}=$codon->{'start'} if(defined $codon->{'start'});
						$codon_report->{'end'}=$codon->{'end'} if(defined $codon->{'end'});
						$codon_report->{'phase'}=$codon->{'phase'} if(defined $codon->{'phase'});
						
						push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'codons'}}, $codon_report) if (defined $codon_report);

						# Get Codons that are not found (Start and End)
						my($codon_report2);
						$codon_report2->{'start'}=1 if($codon->{'type'} eq 'start');
						$codon_report2->{'stop'}=1 if($codon->{'type'} eq 'stop');

						if(exists $codon_report2->{'start'} and !(exists $codon_report2->{'stop'}))
						{
							$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_end'}=0;	
						}
						if(exists $codon_report2->{'stop'} and !(exists $codon_report2->{'start'}))
						{
							$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_start'}=0;	
						}
					}


					# Get Entity identifier
					
					# External id (Class name)
					my($xref_external_list2);
					my($external_id);
					eval {
						$xref_external_list2=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $external_datasource_id,
						);
						return "13:" unless(defined $xref_external_list2 and scalar(@{$xref_external_list2})>0);
						$external_id=$xref_external_list2->[0]->{'identifier'};
					};
					return "14:", $@ if ($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'external_id'}=$external_id if (defined $external_id);

					# Ensembl id
					my($xref_external_list3);
					my($ensembl_transcript_id);
					eval {
						$xref_external_list3=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $ensembl_trans_datasource_id,
						);
						return "15:" unless(defined $xref_external_list3 and scalar(@{$xref_external_list3})>0);
						$ensembl_transcript_id=$xref_external_list3->[0]->{'identifier'};
					};
					return "16:", $@ if ($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'ensembl_id'}=$ensembl_transcript_id if (defined $ensembl_transcript_id);

					# Get Exon list
					my($exon_list);
					eval {
						$exon_list=$db->query_exon(entity_id => $transcript_entity_id); 
					};
					return "17:",$@ if($@);
					foreach my $exon (@{$exon_list}){
						my($exon_report);
						$exon_report->{'exon_id'}=$exon->{'exon_id'} if(defined $exon->{'exon_id'});
						$exon_report->{'identifier'}=$exon->{'identifier'} if(defined $exon->{'identifier'});
						$exon_report->{'strand'}=$exon->{'strand'} if(defined $exon->{'strand'});
						$exon_report->{'start'}=$exon->{'start'} if(defined $exon->{'start'});
						$exon_report->{'end'}=$exon->{'end'} if(defined $exon->{'end'});						
						
						push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'exons'}}, $exon_report) if (defined $exon_report);
					}

					# Get CDS list
					my($cds_list);
					eval {
						$cds_list=$db->query_cds(entity_id => $transcript_entity_id); 
					};
					return "18:",$@ if($@);
					foreach my $cds (@{$cds_list}){
						my($cds_report);
						$cds_report->{'cds_id'}=$cds->{'cds_id'} if(defined $cds->{'cds_id'});
						$cds_report->{'strand'}=$cds->{'strand'} if(defined $cds->{'strand'});
						$cds_report->{'start'}=$cds->{'start'} if(defined $cds->{'start'});
						$cds_report->{'end'}=$cds->{'end'} if(defined $cds->{'end'});
						$cds_report->{'phase'}=$cds->{'phase'} if(defined $cds->{'phase'});
						
						push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds'}}, $cds_report) if (defined $cds_report);
					}

					# Get transcript sequence
					my($transcript_sequence);
					eval {
						my($sequence_list)=$db->query_sequence(entity_id => $transcript_entity_id, type_id => $transcript_type_id);
						return "19:" unless(defined $sequence_list and scalar(@{$sequence_list})>0);
						$transcript_sequence=$sequence_list->[0]->{'sequence'}; # We get the first one					
					};
					return "20:",$@ if($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'sequence'}=$transcript_sequence if (defined $transcript_sequence);

					# Get peptide sequence from given transcript identifier
					my($peptide_id)=$transcript_id; # By default transcript id					
					my($xref_peptide_list);
					eval {
						$xref_peptide_list=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $vega_pep_datasource_id,
						);			
					};
					unless($@)
					{
						if(defined $xref_peptide_list and scalar(@{$xref_peptide_list})>0)
						{
							$peptide_id=$xref_peptide_list->[0]->{'identifier'};
						}
					}
					# Get peptide sequence
					my($peptide_sequence);
					eval {
						my($sequence_list)=$db->query_sequence(entity_id => $transcript->{'entity_id'}, type_id => $peptide_type_id);
						return "21:" unless(defined $sequence_list and scalar(@{$sequence_list})>0);
						$peptide_sequence=$sequence_list->[0]->{'sequence'}; # We get the first one
					};
					return "22:",$@ if($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'sequence'}=$peptide_sequence if (defined $peptide_sequence);

					# Get extended sequence
					my($extended_sequence);
					eval {
						my($sequence_list)=$db->query_sequence(entity_id => $transcript->{'entity_id'}, type_id => $extended_type_id);
						return "23:" unless(defined $sequence_list and scalar(@{$sequence_list})>0);
						$extended_sequence=$sequence_list->[0]->{'sequence'}; # We get the first one
					};
					return "24:",$@ if($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'extended'}=$extended_sequence if (defined $extended_sequence);

					# Get peptide Ensembl id
					my($xref_external_list4);
					my($ensembl_peptide_id);
					eval {
						$xref_external_list4=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $ensembl_pep_datasource_id,
						);
						return "25:" unless(defined $xref_external_list4 and scalar(@{$xref_external_list4})>0);
						$ensembl_peptide_id=$xref_external_list4->[0]->{'identifier'};
					};
					return "26:", $@ if ($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'ensembl_id'}=$ensembl_peptide_id if (defined $ensembl_peptide_id);

					# CCDS id
					my($xref_external_list5);
					my($ccds_transcript_id);
					eval {
						$xref_external_list5=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $ccds_datasource_id,
						);
						return "27:" unless(defined $xref_external_list5 and scalar(@{$xref_external_list5})>0);
						$ccds_transcript_id=$xref_external_list5->[0]->{'identifier'};
					};
					return "28:", $@ if ($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'ccds_id'}=$ccds_transcript_id if (defined $ccds_transcript_id);
					
				}		
			}			
		}		
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $report;
	
} # End get_chromosome_report

# Get features from region
sub get_chromosome_report_region($)
{
	my ($region) = @_;
	my($report);
	
	my($chromosome);
	my($input_start);
	my($input_end);
	if($region=~/^chr([^\:]*):([^\-]*)-([^\$]*)$/)
	{
		$chromosome=$1;
		$input_start=$2;
		$input_end=$3;
	}
	return "0:" unless(defined $chromosome and defined $input_start and defined $input_end);

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Entity identifiers
	my($vega_gene_datasource_id);
	my($vega_trans_datasource_id);
	my($vega_pep_datasource_id);
	my($external_datasource_id);
	my($ensembl_gene_datasource_id);
	my($ensembl_trans_datasource_id);
	my($ensembl_pep_datasource_id);
	eval {
		my($datasource_list)=$db->query_datasource(name => 'Vega_Gene_Id');
		$vega_gene_datasource_id=$datasource_list->[0]->{'datasource_id'};
		my($datasource_list2)=$db->query_datasource(name => 'Vega_Transcript_Id');
		$vega_trans_datasource_id=$datasource_list2->[0]->{'datasource_id'};			
		my($datasource_list3)=$db->query_datasource(name => 'Vega_Peptide_Id');
		$vega_pep_datasource_id=$datasource_list3->[0]->{'datasource_id'};			
		my($datasource_list4)=$db->query_datasource(name => 'External_Id');
		$external_datasource_id=$datasource_list4->[0]->{'datasource_id'};
		my($datasource_list5)=$db->query_datasource(name => 'Ensembl_Gene_Id');
		$ensembl_gene_datasource_id=$datasource_list5->[0]->{'datasource_id'};		
		my($datasource_list6)=$db->query_datasource(name => 'Ensembl_Transcript_Id');
		$ensembl_trans_datasource_id=$datasource_list6->[0]->{'datasource_id'};
		my($datasource_list7)=$db->query_datasource(name => 'Ensembl_Peptide_Id');
		$ensembl_pep_datasource_id=$datasource_list7->[0]->{'datasource_id'};
				
	};
	return "1:",$@ if($@);

	# Get Sequence type
	my($transcript_type_id);
	my($peptide_type_id);
	my($extended_type_id);
	eval {
		my($type_list)=$db->query_type(name => 'transcript');
		$transcript_type_id=$type_list->[0]->{'type_id'};			
		my($type_list2)=$db->query_type(name => 'peptide');
		$peptide_type_id=$type_list2->[0]->{'type_id'};			
		my($type_list3)=$db->query_type(name => 'extended');
		$extended_type_id=$type_list3->[0]->{'type_id'};

	};
	return "2:",$@ if ($@);

	# Get Entity list
	my($entity_list);
	eval {	
		$entity_list=$db->query_entity_coordinate3(
										chromosome => $chromosome,
										start => $input_start,
										end => $input_end
		);
	};			
	return "3:",$@ if($@);
	return "4:" unless(defined $entity_list and scalar(@{$entity_list})>0);

	# Get gene list
	my($gene_list);
	foreach my $entity (@{$entity_list})
	{
		if(	($entity->{'datasource_id'} eq $vega_gene_datasource_id) or 
			($entity->{'datasource_id'} eq $ensembl_gene_datasource_id)
		){
			push(@{$gene_list},$entity);
		}
		elsif(	($entity->{'datasource_id'} eq $vega_trans_datasource_id) or 
			($entity->{'datasource_id'} eq $ensembl_trans_datasource_id)
		){
			# Get Gene from transcript
			my($xref_external_list)=$db->query_xref_identify(
												entity_id => $entity->{'entity_id'},
												datasource_id => $ensembl_gene_datasource_id,
			);
			return "5:" unless(defined $xref_external_list and scalar(@{$xref_external_list})>0);
			my($gene_id)=$xref_external_list->[0]->{'identifier'};
			
			my($gene_entity_list)=$db->query_entity_coordinate(identifier => $gene_id);
			return "6:" unless(defined $gene_entity_list and scalar(@{$gene_entity_list})>0);
			my($gene_entity)=$gene_entity_list->[0];
			push(@{$gene_list},$gene_entity);
		}	
	}

	# Scan every gene
	foreach my $gene (@{$gene_list})
	{
		if(	exists $gene->{'entity_id'} and defined $gene->{'entity_id'} and
			exists $gene->{'identifier'} and defined $gene->{'identifier'} and
			exists $gene->{'source'} and defined $gene->{'source'} and
			exists $gene->{'class'} and defined $gene->{'class'} and
			exists $gene->{'status'} and defined $gene->{'status'} and
			exists $gene->{'level'} and defined $gene->{'level'} and
			exists $gene->{'chromosome'} and defined $gene->{'chromosome'} and		
			exists $gene->{'start'} and defined $gene->{'start'} and		
			exists $gene->{'end'} and defined $gene->{'end'} and		
			exists $gene->{'strand'} and defined $gene->{'strand'}
		)
		{
			# Get main information
			my($gene_id)=$gene->{'identifier'};
			my($gene_entity_id)=$gene->{'entity_id'};
			my($gene_report)={
						'source' => $gene->{'source'},
						'class' => $gene->{'class'},
						'status' => $gene->{'status'},
						'level' => $gene->{'level'},
						'chr' => $gene->{'chromosome'},
						'start' => $gene->{'start'},
						'end' => $gene->{'end'},
						'strand' => $gene->{'strand'}
			};
			$report->{$gene_id}=$gene_report;

			# Get Entity identifier
			# Ensembl gene id
			my($xref_external_list);
			my($ensembl_gene_id);
			eval {
				$xref_external_list=$db->query_xref_identify(
										entity_id => $gene_entity_id,
										datasource_id => $ensembl_gene_datasource_id,
				);
				return "5:" unless(defined $xref_external_list and scalar(@{$xref_external_list})>0);
				$ensembl_gene_id=$xref_external_list->[0]->{'identifier'};
			};
			return "6:", $@ if ($@);
			$report->{$gene_id}->{'ensembl_id'}=$ensembl_gene_id if (defined $ensembl_gene_id);
			
			# Get transcript list from given gene identifier
			my($xref_transcript_list);
			eval {
				$xref_transcript_list=$db->query_xref_identify2(
										entity_id => $gene_entity_id,
										datasource_id => [$vega_trans_datasource_id,$ensembl_trans_datasource_id],
				);
				return "7:" unless(defined $xref_transcript_list and scalar(@{$xref_transcript_list})>0);			
			};
			return "8:", $@ if ($@);

			foreach my $xref_transcript (@{$xref_transcript_list})
			{
				# Get transcript coordinates from given identifier
				my($transcript_list);
				eval {
					$transcript_list=$db->query_entity_coordinate(identifier => $xref_transcript->{'identifier'});
					return "9:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);			
					
				};
				return "10:",$@ if($@);

				my($transcript)=$transcript_list->[0]; # We get the first one
				if(	exists $transcript->{'entity_id'} and defined $transcript->{'entity_id'} and
					exists $transcript->{'identifier'} and defined $transcript->{'identifier'} and
					exists $transcript->{'source'} and defined $transcript->{'source'} and
					exists $transcript->{'class'} and defined $transcript->{'class'} and
					exists $transcript->{'status'} and defined $transcript->{'status'} and
					exists $transcript->{'level'} and defined $transcript->{'level'} and
					exists $transcript->{'chromosome'} and defined $transcript->{'chromosome'} and		
					exists $transcript->{'start'} and defined $transcript->{'start'} and		
					exists $transcript->{'end'} and defined $transcript->{'end'} and		
					exists $transcript->{'strand'} and defined $transcript->{'strand'} 
				)
				{
					# If the transcript is not inside of genomic coordinates 
					next unless($transcript->{'start'} >= $input_start and $transcript->{'end'} <= $input_end);
					
					# Get main information
					my($transcript_id)=$transcript->{'identifier'};
					my($transcript_entity_id)=$transcript->{'entity_id'};
					my($transcript_report)={
								'source' => $transcript->{'source'},
								'status' => $transcript->{'status'},								
								'class' => $transcript->{'class'},
								'level' => $transcript->{'level'},
								'chr' => $transcript->{'chromosome'},
								'start' => $transcript->{'start'},
								'end' => $transcript->{'end'},
								'strand' => $transcript->{'strand'}
					};
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}=$transcript_report;

					# Get Start and End codon
					my($codon_list);
					eval {
						$codon_list=$db->query_codon(entity_id => $transcript_entity_id);

					};
					return "11:",$@ if($@);
					foreach my $codon (@{$codon_list}){
						my($codon_report);
						$codon_report->{'type'}=$codon->{'type'} if(defined $codon->{'type'});
						$codon_report->{'strand'}=$codon->{'strand'} if(defined $codon->{'strand'});
						$codon_report->{'start'}=$codon->{'start'} if(defined $codon->{'start'});
						$codon_report->{'end'}=$codon->{'end'} if(defined $codon->{'end'});
						$codon_report->{'phase'}=$codon->{'phase'} if(defined $codon->{'phase'});
						
						push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'codons'}}, $codon_report) if (defined $codon_report);

						# Get Codons that are not found (Start and End)
						my($codon_report2);
						$codon_report2->{'start'}=1 if($codon->{'type'} eq 'start');
						$codon_report2->{'stop'}=1 if($codon->{'type'} eq 'stop');

						if(exists $codon_report2->{'start'} and !(exists $codon_report2->{'stop'}))
						{
							$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_end'}=0;	
						}
						if(exists $codon_report2->{'stop'} and !(exists $codon_report2->{'start'}))
						{
							$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_start'}=0;	
						}
					}


					# Get Entity identifier
					
					# External id (Class name)
					my($xref_external_list2);
					my($external_id);
					eval {
						$xref_external_list2=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $external_datasource_id,
						);
						return "13:" unless(defined $xref_external_list2 and scalar(@{$xref_external_list2})>0);
						$external_id=$xref_external_list2->[0]->{'identifier'};
					};
					return "14:", $@ if ($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'external_id'}=$external_id if (defined $external_id);

					# Ensembl id
					my($xref_external_list3);
					my($ensembl_transcript_id);
					eval {
						$xref_external_list3=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $ensembl_trans_datasource_id,
						);
						return "15:" unless(defined $xref_external_list3 and scalar(@{$xref_external_list3})>0);
						$ensembl_transcript_id=$xref_external_list3->[0]->{'identifier'};
					};
					return "16:", $@ if ($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'ensembl_id'}=$ensembl_transcript_id if (defined $ensembl_transcript_id);

					# Get Exon list
					my($exon_list);
					eval {
						$exon_list=$db->query_exon(entity_id => $transcript_entity_id); 
					};
					return "17:",$@ if($@);
					foreach my $exon (@{$exon_list}){
						my($exon_report);
						$exon_report->{'exon_id'}=$exon->{'exon_id'} if(defined $exon->{'exon_id'});
						$exon_report->{'identifier'}=$exon->{'identifier'} if(defined $exon->{'identifier'});						
						$exon_report->{'strand'}=$exon->{'strand'} if(defined $exon->{'strand'});
						$exon_report->{'start'}=$exon->{'start'} if(defined $exon->{'start'});
						$exon_report->{'end'}=$exon->{'end'} if(defined $exon->{'end'});						
						
						push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'exons'}}, $exon_report) if (defined $exon_report);
					}

					# Get CDS list
					my($cds_list);
					eval {
						$cds_list=$db->query_cds(entity_id => $transcript_entity_id); 
					};
					return "18:",$@ if($@);
					foreach my $cds (@{$cds_list}){
						my($cds_report);
						$cds_report->{'cds_id'}=$cds->{'cds_id'} if(defined $cds->{'cds_id'});
						$cds_report->{'strand'}=$cds->{'strand'} if(defined $cds->{'strand'});
						$cds_report->{'start'}=$cds->{'start'} if(defined $cds->{'start'});
						$cds_report->{'end'}=$cds->{'end'} if(defined $cds->{'end'});
						$cds_report->{'phase'}=$cds->{'phase'} if(defined $cds->{'phase'});
						
						push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds'}}, $cds_report) if (defined $cds_report);
					}

					# Get transcript sequence
					my($transcript_sequence);
					eval {
						my($sequence_list)=$db->query_sequence(entity_id => $transcript_entity_id, type_id => $transcript_type_id);
						return "19:" unless(defined $sequence_list and scalar(@{$sequence_list})>0);
						$transcript_sequence=$sequence_list->[0]->{'sequence'}; # We get the first one					
					};
					return "20:",$@ if($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'sequence'}=$transcript_sequence if (defined $transcript_sequence);

					# Get peptide sequence from given transcript identifier
					my($peptide_id)=$transcript_id; # By default transcript id					
					my($xref_peptide_list);
					eval {
						$xref_peptide_list=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $vega_pep_datasource_id,
						);			
					};
					unless($@)
					{
						if(defined $xref_peptide_list and scalar(@{$xref_peptide_list})>0)
						{
							$peptide_id=$xref_peptide_list->[0]->{'identifier'};
						}
					}
					# Get peptide sequence
					my($peptide_sequence);
					eval {
						my($sequence_list)=$db->query_sequence(entity_id => $transcript->{'entity_id'}, type_id => $peptide_type_id);
						return "21:" unless(defined $sequence_list and scalar(@{$sequence_list})>0);
						$peptide_sequence=$sequence_list->[0]->{'sequence'}; # We get the first one
					};
					return "22:",$@ if($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'sequence'}=$peptide_sequence if (defined $peptide_sequence);

					# Get extended sequence
					my($extended_sequence);
					eval {
						my($sequence_list)=$db->query_sequence(entity_id => $transcript->{'entity_id'}, type_id => $extended_type_id);
						return "23:" unless(defined $sequence_list and scalar(@{$sequence_list})>0);
						$extended_sequence=$sequence_list->[0]->{'sequence'}; # We get the first one
					};
					return "24:",$@ if($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'extended'}=$extended_sequence if (defined $extended_sequence);

					# Get peptide Ensembl id
					my($xref_external_list4);
					my($ensembl_peptide_id);
					eval {
						$xref_external_list4=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $ensembl_pep_datasource_id,
						);
						return "25:" unless(defined $xref_external_list4 and scalar(@{$xref_external_list4})>0);
						$ensembl_peptide_id=$xref_external_list4->[0]->{'identifier'};
					};
					return "26:", $@ if ($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'ensembl_id'}=$ensembl_peptide_id if (defined $ensembl_peptide_id);
					
				}		
			}			
		}		
	}
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $report;
}

sub get_chromosome_report_gene($)
{
	my ($gene_id) = @_;
	my($report);

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Entity identifiers
	my($vega_gene_datasource_id);
	my($vega_trans_datasource_id);
	my($vega_pep_datasource_id);
	my($external_datasource_id);
	my($ensembl_gene_datasource_id);
	my($ensembl_trans_datasource_id);
	my($ensembl_pep_datasource_id);
	eval {
		my($datasource_list)=$db->query_datasource(name => 'Vega_Gene_Id');
		$vega_gene_datasource_id=$datasource_list->[0]->{'datasource_id'};
		my($datasource_list2)=$db->query_datasource(name => 'Vega_Transcript_Id');
		$vega_trans_datasource_id=$datasource_list2->[0]->{'datasource_id'};			
		my($datasource_list3)=$db->query_datasource(name => 'Vega_Peptide_Id');
		$vega_pep_datasource_id=$datasource_list3->[0]->{'datasource_id'};			
		my($datasource_list4)=$db->query_datasource(name => 'External_Id');
		$external_datasource_id=$datasource_list4->[0]->{'datasource_id'};
		my($datasource_list5)=$db->query_datasource(name => 'Ensembl_Gene_Id');
		$ensembl_gene_datasource_id=$datasource_list5->[0]->{'datasource_id'};		
		my($datasource_list6)=$db->query_datasource(name => 'Ensembl_Transcript_Id');
		$ensembl_trans_datasource_id=$datasource_list6->[0]->{'datasource_id'};
		my($datasource_list7)=$db->query_datasource(name => 'Ensembl_Peptide_Id');
		$ensembl_pep_datasource_id=$datasource_list7->[0]->{'datasource_id'};
				
	};
	return "1:",$@ if($@);

	# Get Sequence type
	my($transcript_type_id);
	my($peptide_type_id);
	my($extended_type_id);
	eval {
		my($type_list)=$db->query_type(name => 'transcript');
		$transcript_type_id=$type_list->[0]->{'type_id'};			
		my($type_list2)=$db->query_type(name => 'peptide');
		$peptide_type_id=$type_list2->[0]->{'type_id'};			
		my($type_list3)=$db->query_type(name => 'extended');
		$extended_type_id=$type_list3->[0]->{'type_id'};

	};
	return "2:",$@ if ($@);


		# Get Gene Entity info
		my($gene_entity);
		eval {
			my($gene_list)=$db->query_entity(identifier => $gene_id);
			unless(defined $gene_list and scalar(@{$gene_list})>0)
			{
				my($xref_gene_list)=$db->query_xref_identify(identifier => $gene_id);
				return "3:" unless(defined $xref_gene_list and scalar(@{$xref_gene_list})>0);

				my($xref_gene_list2)=$db->query_entity(entity_id => $xref_gene_list->[0]->{'entity_id'});
				return "4:" unless(defined $xref_gene_list2 and scalar(@{$xref_gene_list2})>0);
							
				$gene_entity=$xref_gene_list2->[0];
				
			}
			else
			{
				$gene_entity=$gene_list->[0];
			}
		};
		return "3:",$@ if ($@);
		
		my($coordinate_list);
		eval {
			$coordinate_list=$db->query_coordinate(entity_id => $gene_entity->{'entity_id'});
		};
		return "4:",$@ if($@);
		my($coordinate)=$coordinate_list->[0]; # We get the first one

		my($gene)={
			'entity_id' => $gene_entity->{'entity_id'},
			'identifier' => $gene_entity->{'identifier'},
			'source' => $gene_entity->{'source'},
			'class' => $gene_entity->{'class'},
			'status' => $gene_entity->{'status'},
			'level' => $gene_entity->{'level'},
			'chromosome' => $coordinate->{'chromosome'},
			'start' => $coordinate->{'start'},
			'end' => $coordinate->{'end'},
			'strand' => $coordinate->{'strand'}
		};
						
		if(	exists $gene->{'entity_id'} and defined $gene->{'entity_id'} and
			exists $gene->{'identifier'} and defined $gene->{'identifier'} and
			exists $gene->{'source'} and defined $gene->{'source'} and
			exists $gene->{'class'} and defined $gene->{'class'} and
			exists $gene->{'status'} and defined $gene->{'status'} and
			exists $gene->{'level'} and defined $gene->{'level'} and
			exists $gene->{'chromosome'} and defined $gene->{'chromosome'} and		
			exists $gene->{'start'} and defined $gene->{'start'} and		
			exists $gene->{'end'} and defined $gene->{'end'} and		
			exists $gene->{'strand'} and defined $gene->{'strand'}
		)
		{


			# Get main information
			my($gene_id)=$gene->{'identifier'};
			my($gene_entity_id)=$gene->{'entity_id'};
			my($gene_report)={
						'source' => $gene->{'source'},
						'class' => $gene->{'class'},
						'status' => $gene->{'status'},
						'level' => $gene->{'level'},
						'chr' => $gene->{'chromosome'},
						'start' => $gene->{'start'},
						'end' => $gene->{'end'},
						'strand' => $gene->{'strand'}
			};
			$report->{$gene_id}=$gene_report;

			# Get Entity identifier
			# Ensembl gene id
			my($xref_external_list);
			my($ensembl_gene_id);
			eval {
				$xref_external_list=$db->query_xref_identify(
										entity_id => $gene_entity_id,
										datasource_id => $ensembl_gene_datasource_id,
				);
				return "5:" unless(defined $xref_external_list and scalar(@{$xref_external_list})>0);
				$ensembl_gene_id=$xref_external_list->[0]->{'identifier'};
			};
			return "6:", $@ if ($@);
			$report->{$gene_id}->{'ensembl_id'}=$ensembl_gene_id if (defined $ensembl_gene_id);
			
			# Get transcript list from given gene identifier
			my($xref_transcript_list);
			eval {
				$xref_transcript_list=$db->query_xref_identify2(
										entity_id => $gene_entity_id,
										datasource_id => [$vega_trans_datasource_id,$ensembl_trans_datasource_id],
				);
				return "7:" unless(defined $xref_transcript_list and scalar(@{$xref_transcript_list})>0);			
			};
			return "8:", $@ if ($@);

			foreach my $xref_transcript (@{$xref_transcript_list})
			{
				# Get transcript coordinates from given identifier
				my($transcript_list);
				eval {
					$transcript_list=$db->query_entity_coordinate(identifier => $xref_transcript->{'identifier'});
					return "9:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);			
					
				};
				return "10:",$@ if($@);

				my($transcript)=$transcript_list->[0]; # We get the first one
				if(	exists $transcript->{'entity_id'} and defined $transcript->{'entity_id'} and
					exists $transcript->{'identifier'} and defined $transcript->{'identifier'} and
					exists $transcript->{'source'} and defined $transcript->{'source'} and
					exists $transcript->{'class'} and defined $transcript->{'class'} and
					exists $transcript->{'status'} and defined $transcript->{'status'} and
					exists $transcript->{'level'} and defined $transcript->{'level'} and
					exists $transcript->{'chromosome'} and defined $transcript->{'chromosome'} and		
					exists $transcript->{'start'} and defined $transcript->{'start'} and		
					exists $transcript->{'end'} and defined $transcript->{'end'} and		
					exists $transcript->{'strand'} and defined $transcript->{'strand'} 
				)
				{
					# Get main information
					my($transcript_id)=$transcript->{'identifier'};
					my($transcript_entity_id)=$transcript->{'entity_id'};
					my($transcript_report)={
								'source' => $transcript->{'source'},
								'status' => $transcript->{'status'},								
								'class' => $transcript->{'class'},
								'level' => $transcript->{'level'},
								'chr' => $transcript->{'chromosome'},
								'start' => $transcript->{'start'},
								'end' => $transcript->{'end'},
								'strand' => $transcript->{'strand'}
					};
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}=$transcript_report;

					# Get Start and End codon
					my($codon_list);
					eval {
						$codon_list=$db->query_codon(entity_id => $transcript_entity_id);

					};
					return "11:",$@ if($@);
					foreach my $codon (@{$codon_list}){
						my($codon_report);
						$codon_report->{'type'}=$codon->{'type'} if(defined $codon->{'type'});
						$codon_report->{'strand'}=$codon->{'strand'} if(defined $codon->{'strand'});
						$codon_report->{'start'}=$codon->{'start'} if(defined $codon->{'start'});
						$codon_report->{'end'}=$codon->{'end'} if(defined $codon->{'end'});
						$codon_report->{'phase'}=$codon->{'phase'} if(defined $codon->{'phase'});
						
						push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'codons'}}, $codon_report) if (defined $codon_report);

						# Get Codons that are not found (Start and End)
						my($codon_report2);
						$codon_report2->{'start'}=1 if($codon->{'type'} eq 'start');
						$codon_report2->{'stop'}=1 if($codon->{'type'} eq 'stop');

						if(exists $codon_report2->{'start'} and !(exists $codon_report2->{'stop'}))
						{
							$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_end'}=0;	
						}
						if(exists $codon_report2->{'stop'} and !(exists $codon_report2->{'start'}))
						{
							$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_start'}=0;	
						}
					}


					# Get Entity identifier
					
					# External id (Class name)
					my($xref_external_list2);
					my($external_id);
					eval {
						$xref_external_list2=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $external_datasource_id,
						);
						return "13:" unless(defined $xref_external_list2 and scalar(@{$xref_external_list2})>0);
						$external_id=$xref_external_list2->[0]->{'identifier'};
					};
					return "14:", $@ if ($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'external_id'}=$external_id if (defined $external_id);

					# Ensembl id
					my($xref_external_list3);
					my($ensembl_transcript_id);
					eval {
						$xref_external_list3=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $ensembl_trans_datasource_id,
						);
						return "15:" unless(defined $xref_external_list3 and scalar(@{$xref_external_list3})>0);
						$ensembl_transcript_id=$xref_external_list3->[0]->{'identifier'};
					};
					return "16:", $@ if ($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'ensembl_id'}=$ensembl_transcript_id if (defined $ensembl_transcript_id);

					# Get Exon list
					my($exon_list);
					eval {
						$exon_list=$db->query_exon(entity_id => $transcript_entity_id); 
					};
					return "17:",$@ if($@);
					foreach my $exon (@{$exon_list}){
						my($exon_report);
						$exon_report->{'exon_id'}=$exon->{'exon_id'} if(defined $exon->{'exon_id'});
						$exon_report->{'identifier'}=$exon->{'identifier'} if(defined $exon->{'identifier'});						
						$exon_report->{'strand'}=$exon->{'strand'} if(defined $exon->{'strand'});
						$exon_report->{'start'}=$exon->{'start'} if(defined $exon->{'start'});
						$exon_report->{'end'}=$exon->{'end'} if(defined $exon->{'end'});						
						
						push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'exons'}}, $exon_report) if (defined $exon_report);
					}

					# Get CDS list
					my($cds_list);
					eval {
						$cds_list=$db->query_cds(entity_id => $transcript_entity_id); 
					};
					return "18:",$@ if($@);
					foreach my $cds (@{$cds_list}){
						my($cds_report);
						$cds_report->{'cds_id'}=$cds->{'cds_id'} if(defined $cds->{'cds_id'});
						$cds_report->{'strand'}=$cds->{'strand'} if(defined $cds->{'strand'});
						$cds_report->{'start'}=$cds->{'start'} if(defined $cds->{'start'});
						$cds_report->{'end'}=$cds->{'end'} if(defined $cds->{'end'});
						$cds_report->{'phase'}=$cds->{'phase'} if(defined $cds->{'phase'});
						
						push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds'}}, $cds_report) if (defined $cds_report);
					}

					# Get transcript sequence
					my($transcript_sequence);
					eval {
						my($sequence_list)=$db->query_sequence(entity_id => $transcript_entity_id, type_id => $transcript_type_id);
						return "19:" unless(defined $sequence_list and scalar(@{$sequence_list})>0);
						$transcript_sequence=$sequence_list->[0]->{'sequence'}; # We get the first one					
					};
					return "20:",$@ if($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'sequence'}=$transcript_sequence if (defined $transcript_sequence);

					# Get peptide sequence from given transcript identifier
					my($peptide_id)=$transcript_id; # By default transcript id					
					my($xref_peptide_list);
					eval {
						$xref_peptide_list=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $vega_pep_datasource_id,
						);			
					};
					unless($@)
					{
						if(defined $xref_peptide_list and scalar(@{$xref_peptide_list})>0)
						{
							$peptide_id=$xref_peptide_list->[0]->{'identifier'};
						}
					}
					# Get peptide sequence
					my($peptide_sequence);
					eval {
						my($sequence_list)=$db->query_sequence(entity_id => $transcript->{'entity_id'}, type_id => $peptide_type_id);
						return "21:" unless(defined $sequence_list and scalar(@{$sequence_list})>0);
						$peptide_sequence=$sequence_list->[0]->{'sequence'}; # We get the first one
					};
					return "22:",$@ if($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'sequence'}=$peptide_sequence if (defined $peptide_sequence);

					# Get extended sequence
					my($extended_sequence);
					eval {
						my($sequence_list)=$db->query_sequence(entity_id => $transcript->{'entity_id'}, type_id => $extended_type_id);
						return "23:" unless(defined $sequence_list and scalar(@{$sequence_list})>0);
						$extended_sequence=$sequence_list->[0]->{'sequence'}; # We get the first one
					};
					return "24:",$@ if($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'extended'}=$extended_sequence if (defined $extended_sequence);

					# Get peptide Ensembl id
					my($xref_external_list4);
					my($ensembl_peptide_id);
					eval {
						$xref_external_list4=$db->query_xref_identify(
												entity_id => $transcript_entity_id,
												datasource_id => $ensembl_pep_datasource_id,
						);
						return "25:" unless(defined $xref_external_list4 and scalar(@{$xref_external_list4})>0);
						$ensembl_peptide_id=$xref_external_list4->[0]->{'identifier'};
					};
					return "26:", $@ if ($@);
					$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'ensembl_id'}=$ensembl_peptide_id if (defined $ensembl_peptide_id);
					
				}		
			}			
		}
		else
		{
			return "27:"; 
		}

	
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $report;
	
} # End get_chromosome_report_gene

sub get_chromosome_report_trans($)
{

	my ($transcript_id) = @_;
	my($report);
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Entity identifiers
	my($vega_gene_datasource_id);
	my($vega_trans_datasource_id);
	my($vega_pep_datasource_id);
	my($external_datasource_id);
	my($ensembl_gene_datasource_id);
	my($ensembl_trans_datasource_id);
	my($ensembl_pep_datasource_id);
	eval {
		my($datasource_list)=$db->query_datasource(name => 'Vega_Gene_Id');
		$vega_gene_datasource_id=$datasource_list->[0]->{'datasource_id'};
		my($datasource_list2)=$db->query_datasource(name => 'Vega_Transcript_Id');
		$vega_trans_datasource_id=$datasource_list2->[0]->{'datasource_id'};			
		my($datasource_list3)=$db->query_datasource(name => 'Vega_Peptide_Id');
		$vega_pep_datasource_id=$datasource_list3->[0]->{'datasource_id'};			
		my($datasource_list4)=$db->query_datasource(name => 'External_Id');
		$external_datasource_id=$datasource_list4->[0]->{'datasource_id'};
		my($datasource_list5)=$db->query_datasource(name => 'Ensembl_Gene_Id');
		$ensembl_gene_datasource_id=$datasource_list5->[0]->{'datasource_id'};		
		my($datasource_list6)=$db->query_datasource(name => 'Ensembl_Transcript_Id');
		$ensembl_trans_datasource_id=$datasource_list6->[0]->{'datasource_id'};
		my($datasource_list7)=$db->query_datasource(name => 'Ensembl_Peptide_Id');
		$ensembl_pep_datasource_id=$datasource_list7->[0]->{'datasource_id'};
				
	};
	return "1:",$@ if($@);

	# Get Transcript info
	my($trans_entity);
	eval {
		my($trans_list)=$db->query_entity(identifier => $transcript_id);
		unless(defined $trans_list and scalar(@{$trans_list})>0)
		{
			my($xref_trans_list)=$db->query_xref_identify(identifier => $transcript_id);
				return "3:" unless(defined $xref_trans_list and scalar(@{$xref_trans_list})>0);

				my($xref_trans_list2)=$db->query_entity(entity_id => $xref_trans_list->[0]->{'entity_id'});
				return "4:" unless(defined $xref_trans_list2 and scalar(@{$xref_trans_list2})>0);
							
				$trans_entity=$xref_trans_list2->[0];
				
			}
			else
			{
				$trans_entity=$trans_list->[0];
			}
		};
		return "3:",$@ if ($@);

	# Get Gene id		
	my($gene_id);
	eval {
		my($xref_transcript_list)=$db->query_xref_identify(
												entity_id => $trans_entity->{'entity_id'},
												datasource_id => $ensembl_gene_datasource_id,
		);
		return "2:" unless(defined $xref_transcript_list and scalar(@{$xref_transcript_list})>0);

		$gene_id=$xref_transcript_list->[0]->{'identifier'};
		return "3: " unless(defined $gene_id);

	};
	return "4:",$@ if ($@);

	# Get Gene report	
	$report=get_chromosome_report_gene($gene_id);

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $report;
	
} # get_chromosome_report_trans

sub get_alignment($$)
{
	my ($transcript_id,$type_align) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Sequence type
	my($transcript_type_id);
	eval {
		my($type_list)=$db->query_type(name => $type_align);
		$transcript_type_id=$type_list->[0]->{'type_id'};			
	};
	return $@ if ($@);

	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);

	# Get alignments
	my($alignment_list);
	eval {
		$alignment_list=$db->query_alignment(
									entity_id => $transcript_entity_id,
									type_id => $transcript_type_id
		);
	};
	return "3:",$@ if($@);
	my($alignment)=$alignment_list->[0]; # We get the first one

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $alignment;
	
} # End get_alignment

sub get_coordinate($)
{
	my ($identifier_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Entity info
	my($entity_id);
	eval {
		my($entity_list)=$db->query_entity(identifier => $identifier_id);
		return "1:" unless(defined $entity_list and scalar(@{$entity_list})>0);
		
		$entity_id=$entity_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);

	# Get coordinate
	my($coordinate_list);
	eval {
		$coordinate_list=$db->query_coordinate(entity_id => $entity_id);
	};
	return "3:",$@ if($@);
	my($annotation)=$coordinate_list->[0]; # We get the first one

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $annotation;

} # End get_coordinate

sub get_exons($)
{
	my ($identifier_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Entity info
	my($entity_id);
	eval {
		my($entity_list)=$db->query_entity(identifier => $identifier_id);
		return "1:" unless(defined $entity_list and scalar(@{$entity_list})>0);
		
		$entity_id=$entity_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_exon(entity_id => $entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);			
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $list;
		
} # End get_exons

sub get_cds($)
{
	my ($identifier_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Entity info
	my($entity_id);
	eval {
		my($entity_list)=$db->query_entity(identifier => $identifier_id);
		return "1:" unless(defined $entity_list and scalar(@{$entity_list})>0);
		
		$entity_id=$entity_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_cds(entity_id => $entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);			
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $list;
		
} # End get_cds

sub get_signalp_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_signalp(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;
		
} # End get_signalp_annotations

sub get_signalp_annotations_gene($)
{
	my ($gene_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Gene Entity info
	my($gene_entity_id);
	eval {
		my($gene_list)=$db->query_entity(identifier => $gene_id);
		return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
		
		$gene_entity_id=$gene_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_signalp(entity_id => $gene_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;

} # End get_signalp_annotations_gene

sub get_targetp_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_targetp(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;
		
} # End get_targetp_annotations

sub get_targetp_annotations_gene($)
{
	my ($gene_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Gene Entity info
	my($gene_entity_id);
	eval {
		my($gene_list)=$db->query_entity(identifier => $gene_id);
		return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
		
		$gene_entity_id=$gene_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_targetp(entity_id => $gene_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;

} # End get_targetp_annotations_gene

sub get_firestar_annotations($)
{
	my ($transcript_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_firestar(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;

} # End get_firestar_annotations

sub get_firestar_annotations_gene($)
{
	my ($gene_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Gene Entity info
	my($gene_entity_id);
	eval {
		my($gene_list)=$db->query_entity(identifier => $gene_id);
		return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
		
		$gene_entity_id=$gene_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_firestar(entity_id => $gene_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;

} # End get_firestar_annotations_gene

sub get_firestar_residues_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_firestar_residues(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $list;
	
} # End get_firestar_residues_annotations

sub get_spade_annotations($)
{
	my ($transcript_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_spade(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;

} # End get_spade_annotations

sub get_spade_annotations_gene($)
{
	my ($gene_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Gene Entity info
	my($gene_entity_id);
	eval {
		my($gene_list)=$db->query_entity(identifier => $gene_id);
		return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
		
		$gene_entity_id=$gene_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_spade(entity_id => $gene_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;

} # End get_spade_annotations_gene

sub get_spade_alignments_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_spade_alignments(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $list;
	
} # End get_spade_alignments_annotations

sub get_corsair_annotations($)
{
	my ($transcript_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_corsair(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;

} # End get_corsair_annotations

sub get_corsair_annotations_gene($)
{
	my ($gene_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Gene Entity info
	my($gene_entity_id);
	eval {
		my($gene_list)=$db->query_entity(identifier => $gene_id);
		return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
		
		$gene_entity_id=$gene_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_corsair(entity_id => $gene_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;

} # End get_corsair_annotations_gene

sub get_cexonic_annotations($)
{
	my ($transcript_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_cexonic(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;

} # End get_cexonic_annotations

sub get_cexonic_residues_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_cexonic_residues(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $list;
	
} # End get_firestar_residues_annotations

sub get_cexonic_annotations_gene($)
{
	my ($gene_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Gene Entity info
	my($gene_entity_id);
	eval {
		my($gene_list)=$db->query_entity(identifier => $gene_id);
		return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
		
		$gene_entity_id=$gene_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_cexonic(entity_id => $gene_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);
	my($method_annotation)=$list->[0];# We get the first one

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;
	
} # End get_cexonic_annotations_gene

sub get_matador3d_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_matador3d(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);	
	my($method_annotation)=$list->[0]; # We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;
		
} # End get_matador3d_annotations

sub get_matador3d_annotations_gene($)
{
	my ($gene_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Gene Entity info
	my($gene_entity_id);
	eval {
		my($gene_list)=$db->query_entity(identifier => $gene_id);
		return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
		
		$gene_entity_id=$gene_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_matador3d(entity_id => $gene_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;
		
} # End get_matador3d_annotations

sub get_matador3d_alignments_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {
		$list=$db->query_matador3d_alignments(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $list;
		
} # End get_matador3d_alignments_annotations

sub get_thump_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_thump(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;
		
} # End get_thump_annotations

sub get_thump_annotations_gene($)
{
	my ($gene_id) = @_;
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Gene Entity info
	my($gene_entity_id);
	eval {
		my($gene_list)=$db->query_entity(identifier => $gene_id);
		return "1:" unless(defined $gene_list and scalar(@{$gene_list})>0);
		
		$gene_entity_id=$gene_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_thump(entity_id => $gene_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;

} # End get_thump_annotations_gene

sub get_thump_helixes_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_thump_helixes(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);

	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $list;

} # End get_thump_helixes_annotations

sub get_inertia_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_inertia(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);
	my($method_annotation)=$list->[0];# We get the first one
			
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;
	
} # End get_inertia_annotations

sub get_inertia_residues_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_inertia_residues(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);
			
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $list;
	
} # End get_inertia_residues_annotations

sub get_omega_annotations($$)
{
	my ($transcript_id,$type) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get type
	my($type_id);
	eval {
		my($type_list)=$db->query_slr_type(name => $type);
		$type_id=$type_list->[0]->{'slr_type_id'};			
	};
	return $@ if ($@);

	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_omega(
								entity_id => $transcript_entity_id,
								slr_type_id => $type_id
		);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);
	my($method_annotation)=$list->[0];# We get the first one
	
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;
	
} # End get_omega_annotations

sub get_omega_residues_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_omega_residues(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);
			
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $list;
	
} # End get_omega_residues_annotations

sub get_slr_report($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_slr(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $list;
		
} # End get_slr_report

sub get_pi_annotation($$)
{
	my($transcript_id,$label) = @_;
	my($annotation);
	
	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);

	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);

	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_appris(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);
	my($method_annotation)=$list->[0];# We get the first one
	$annotation=$method_annotation->{$label};
	
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $annotation;

} # End get_pi_annotation

sub get_appris_annotations($)
{
	my ($transcript_id) = @_;

	# Connection to DB
	my $db = MySQL->new(
				dbhost => $DB_HOST,
				dbname => $DB_NAME,
				dbport => $DB_PORT,
				dbuser => $DB_USER,
				dbpass => $DB_PASS,
	);
	
	# Get Transcript Entity info
	my($transcript_entity_id);
	eval {
		my($transcript_list)=$db->query_entity(identifier => $transcript_id);
		return "1:" unless(defined $transcript_list and scalar(@{$transcript_list})>0);
		
		$transcript_entity_id=$transcript_list->[0]->{'entity_id'};			
	};
	return "2:",$@ if ($@);
	
	# Check if the annotation already exists
	my($list);
	eval {	
		$list=$db->query_appris(entity_id => $transcript_entity_id);
		return "3:" unless(defined $list and scalar(@{$list})>0);
	};
	return "4:",$@ if ($@);		
	my($method_annotation)=$list->[0];# We get the first one
		
	$db->commit(); # Do commit of everything
	$db->disconnect();

	return $method_annotation;	
}


1;