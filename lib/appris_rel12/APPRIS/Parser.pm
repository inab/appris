=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

Parser - Module to handle results of methods of APPRIS pipeline.

=head1 SYNOPSIS

  use APPRIS::Parser
    qw(
       parse_firestar
     );

  or to get all methods just

  use APPRIS::Parser;

  eval { parse_firestar($result) };
  if ($@) {
    print "Caught exception:\n$@";
  }

=head1 DESCRIPTION

Module to handle results of methods of APPRIS pipeline.

=head1 METHODS

=cut

package APPRIS::Parser;

use strict;
use warnings;
use Data::Dumper;
use Bio::SeqIO;

use APPRIS::Gene;
use APPRIS::Transcript;
use APPRIS::Translation;
use APPRIS::Exon;
use APPRIS::CDS;
use APPRIS::Codon;
use APPRIS::XrefEntry;
use APPRIS::Analysis;
use APPRIS::Analysis::Region;
use APPRIS::Analysis::Firestar;
use APPRIS::Analysis::Matador3D;
use APPRIS::Analysis::SPADE;
use APPRIS::Analysis::INERTIA;
use APPRIS::Analysis::CRASH;
use APPRIS::Analysis::THUMP;
use APPRIS::Analysis::CExonic;
use APPRIS::Analysis::CORSAIR;
use APPRIS::Analysis::APPRIS;
use APPRIS::Utils::ProCDS qw(sort_cds get_coords_from_residue);
use APPRIS::Utils::EnsEMBL qw(get_xref_identifiers get_exons);
use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);
use APPRIS::Utils::Constant qw(
	$HAVANA_SOURCE
	$ENSEMBL_SOURCE

	$OK_LABEL
	$NO_LABEL
	$UNKNOWN_LABEL

	$FIRESTAR_ACCEPT_LABEL
	$FIRESTAR_REJECT_LABEL
);

use Exporter;

use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(
	parse_gencode
	parse_firestar
	parse_matador3d
	parse_spade
	parse_inertia
	parse_corsair
	parse_cexonic
	parse_crash
	parse_thump
	parse_appris
	parse_appris_methods
);

sub parse_gencode($;$;$;$);
sub _get_id_version($);
sub _parse_gencode_data($);
sub _parse_gencode_sequence($);
sub _fetch_transc_objects($$$;$;$);
sub _fetch_transl_objects($$$;$);
sub parse_firestar($$);
sub parse_matador3d($$);
sub parse_spade($$);
sub parse_inertia($$;$;$;$);
sub _parse_inertia_file($$\$);
sub _parse_omega_file($$\$);
sub parse_corsair($$);
sub parse_cexonic($$);
sub parse_crash($$);
sub parse_thump($$);
sub parse_appris($$$);
sub parse_appris_methods($$$$$$$$$;$;$;$);

=head2 parse_gencode

  Arg [1]    : string $data_file
               File of gencode data as GTF format
  Arg [2]    : string $transc_file (optional)
               File of gencode transcript sequence as Fasta format
  Arg [3]    : string $transl_file (optional)
               File of gencode translation sequence as Fasta format
  Example    : use APPRIS::Parser qw(parse_gencode);
               parse_gencode($data_file, $transc_file, $transl_file);
  Description: Parse data of gencode.
  Returntype : Listref of APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_gencode($;$;$;$)
{
	my ($data_file, $transc_file, $transl_file, $registry) = @_;
	my ($entity_list, $raw_data_list);
	my ($data_cont);
	my ($transc_cont);
	my ($transl_cont);
	my ($index_genes);
	my ($index) = 0;	
		
	# Parse data/sequences
	$data_cont = _parse_gencode_data($data_file);
	$transc_cont = _parse_gencode_sequence($transc_file) if (defined $transc_file);
	$transl_cont = _parse_gencode_sequence($transl_file) if (defined $transl_file);

	# Scan genes
	while ( my ($gene_id, $gene_features) = each(%{$data_cont}) )
	{
		my ($xref_identities);
		my ($transcripts, $index_transcripts) = _fetch_transc_objects($registry, $gene_id, $gene_features->{'transcripts'}, $transc_cont, $transl_cont);
		
		# Create gene object
		my ($gene) = APPRIS::Gene->new
		(
			-stable_id	=> $gene_id,
			-chr		=> $gene_features->{'chr'},
			-start		=> $gene_features->{'start'},
			-end		=> $gene_features->{'end'},
			-strand		=> $gene_features->{'strand'},
			-biotype	=> $gene_features->{'biotype'},
			-status		=> $gene_features->{'status'},
			-source		=> $gene_features->{'source'},
			-level		=> $gene_features->{'level'},
			-version	=> $gene_features->{'version'}
		);

		# Xref identifiers
		if ( exists $gene_features->{'external_id'} and defined $gene_features->{'external_id'} ) {
			push(@{$xref_identities},
					APPRIS::XrefEntry->new
					(
						-id				=> $gene_features->{'external_id'},
						-dbname			=> 'External_Id'
					)
			);
		}
		if ( exists $gene_features->{'havana_gene'} and defined $gene_features->{'havana_gene'} ) {
			push(@{$xref_identities},
					APPRIS::XrefEntry->new
					(
						-id				=> $gene_features->{'havana_gene'},
						-dbname			=> 'Havana_Gene_Id'
					)
			);
		}				
		# From Ensembl: 
		my ($gene_xref) = get_xref_identifiers($registry, $gene_id);
		if ( exists $gene_xref->{'description'} and defined $gene_xref->{'description'}) { # add description
			$gene->description($gene_xref->{'description'});
		}		
		
		$gene->xref_identify($xref_identities) if (defined $xref_identities);
		$gene->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
		push(@{$entity_list},$gene) if (defined $gene);
		
		# Get raw data
		if ( exists $gene_features->{'raw'} and ($gene_features->{'raw'} ne '') ) {
			$raw_data_list->{$gene_id} =  $gene_features->{'raw'};					
		}
		
		# Get index genes
		$index_genes->{$gene_id} = $index; $index++; # Index the list of transcripts
	}
		
	return ($entity_list, $index_genes, $raw_data_list);
}

=head2 parse_firestar

  Arg [1]    : APPRIS::Gene $gene 
               APPRIS::Gene object
  Arg [2]    : string $result
               Parse firestar result
  Example    : use APPRIS::Parser qw(parse_firestar);
               parse_firestar($result);
  Description: Parse output of firestar.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_firestar($$)
{
	my ($gene, $result) = @_;

	my ($stable_id) = $gene->stable_id;
	my ($transcript_result) = '';
	my ($init_trans_result) = 0;
	my ($cutoffs);
	my ($transcripts);
	my ($index_transcripts);
	my ($index) = 0;	
	
	my (@results) = split( '\n', $result);
	foreach my $line (@results)
	{
		if ( $line eq '######') {
			# Init trans result
			$transcript_result = '';
			$init_trans_result = 1;
		}
		if ( $init_trans_result ) {
			$transcript_result .= $line."\n";		
		}

		#>>>OTTHUMT00000171822      29      46,47,48,49,67,68,69,70,98,99,100,101,166,170,171,394,411,412,413,448,452,480,481,492,495,497,498,499,504
		if ( $line=~/^>>>([^\t]+)\t+([^\t]+)\t+([^\$]+)$/ )
		{
			my ($id) = $1;
			my (@residue_list) = split(',', $3);

			# Get the peptide position and scores
			my ($residue_list_report);
			foreach my $residue_position (@residue_list)
			{
				if ( defined $residue_position and $residue_position ne '' )
				{
					#349     GLLCGGSAGSTVA   PLP[0.71,6,99.5]|Cat_Site_Atl[1.00,4,XXX]
					if ( $transcript_result =~ /$residue_position\t+([^\t]*)\t+([^\n]*)[^\>]*>>>$id/ )
					{
						my ($domain) = $1;
						my ($ligands) = $2; $ligands =~ s/^\s*//; $ligands =~ s/\s*$//; $ligands =~ s/\s+/\|/g; #$ligands = join('|',split(/\s+/,$ligands));
						push(@{$residue_list_report},{
								'residue'	=> $residue_position,
								'domain'	=> $domain,
								'ligands'	=> $ligands,
						});
					}
				}			
			}

			if(defined $residue_list_report and scalar(@{$residue_list_report})>0)
			{
				$cutoffs->{$id}->{'residues'} = $residue_list_report;
			}
			
			# Save result for each transcript
			$cutoffs->{$id}->{'result'} = $transcript_result;
			
			# Init trans result
			$transcript_result = ''; 
		}
		#C>>     OTTHUMT00000171822      3      46,47,48
		if ( $line=~/^C>>\t+([^\t]+)\t+([^\t]+)\t+([^\$]+)$/ )
		{
			my ($id) = $1;
			my (@residue_list) = split(',', $3);

			# Get the peptide position and scores
			foreach my $residue_position (@residue_list)
			{
				if ( defined $residue_position and $residue_position ne '' )
				{
					#349     GLLCGGSAGSTVA   PLP[0.71,6,99.5]|Cat_Site_Atl[1.00,4,XXX]					
					if ( $transcript_result =~ /$residue_position\t+([^\t]*)\t+([^\n]*)[^\>]*>>\t+$id/ )
					{
						my ($domain) = $1;
						my ($ligands) = $2; $ligands =~ s/^\s*//; $ligands =~ s/\s*$//; $ligands =~ s/\s+/\|/g; #$ligands = join('|',split(/\s+/,$ligands));
						push(@{$cutoffs->{$id}->{'residues'}},{
								'residue'	=> $residue_position,
								'domain'	=> $domain,
								'ligands'	=> $ligands,				
						});		
					}
				}
			}
			
			# Sort residues
			if ( exists $cutoffs->{$id}->{'residues'} and defined $cutoffs->{$id}->{'residues'} and
				 (scalar(@{$cutoffs->{$id}->{'residues'}}) > 0) )
			{
				my (@res_list) = @{$cutoffs->{$id}->{'residues'}};
				my (@sort_res_list) = sort { $a->{'residue'} <=> $b->{'residue'} } @res_list;
				$cutoffs->{$id}->{'residues'} = \@sort_res_list;				
			}

			# Save result for each transcript
			my ($trans_result) = '';
			$trans_result = $cutoffs->{$id}->{'result'} if ( exists $cutoffs->{$id}->{'result'} and defined $cutoffs->{$id}->{'result'} );
			$cutoffs->{$id}->{'result'} = $trans_result . $transcript_result;
			
			# Init result variable for the next
			$transcript_result = '';
		}
		
		#ACCEPT: ID\tTOTAL_SCORE\tTOTAL_MOTIFS\tNUM_SCORE_6\tNUM_SCORE_5\tNUM_SCORE_4\tNUM_SCORE_3\n		
		if ( $line =~ /^ACCEPT:\s*([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\n]+)\n*/ )
		{
			my ($id) = $1;
			my ($total_score) = $2;
			my ($total_residues) = $3;
			my ($num_residues_6) = $4;
			my ($num_residues_5) = $5;
			my ($num_residues_4) = $6;
			my ($num_residues_3) = $7;

			if ( defined $id and ($id ne '') )
			{
				unless ( defined $total_residues and $total_residues ne '' )
					{ $total_residues = 0; }
					
				$cutoffs->{$id}->{'num_residues'} = $total_residues;
				$cutoffs->{$id}->{'functional_residue'} = $APPRIS::Utils::Constant::FIRESTAR_ACCEPT_LABEL;

				# Save result for each transcript
				my ($trans_result) = '';
				if ( exists $cutoffs->{$id}->{'result'} and defined $cutoffs->{$id}->{'result'} ) {
					$trans_result .= $cutoffs->{$id}->{'result'};
					$trans_result .= "----------------------------------------------------------------------\n";					
				}				
				$cutoffs->{$id}->{'result'} = $trans_result . $line;
			}
		}
		#REJECT: ID\tTOTAL_SCORE\tTOTAL_MOTIFS\tNUM_SCORE_6\tNUM_SCORE_5\tNUM_SCORE_4\tNUM_SCORE_3\n
		if ( $line =~ /^REJECT:\s*([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\n]+)\n*/ )
		{
			my ($id) = $1;
			my ($total_score) = $2;
			my ($total_residues) = $3;
			my ($num_residues_6) = $4;
			my ($num_residues_5) = $5;
			my ($num_residues_4) = $6;
			my ($num_residues_3) = $7;

			if ( defined $id and ($id ne '') )
			{
				unless ( defined $total_residues and $total_residues ne '' )
					{ $total_residues = 0; }
					
				$cutoffs->{$id}->{'num_residues'} = $total_residues;
				$cutoffs->{$id}->{'functional_residue'} = $APPRIS::Utils::Constant::FIRESTAR_REJECT_LABEL;
				
				# Save result for each transcript
				my ($trans_result) = '';
				if ( exists $cutoffs->{$id}->{'result'} and defined $cutoffs->{$id}->{'result'} ) {
					$trans_result .= $cutoffs->{$id}->{'result'};
					$trans_result .= "----------------------------------------------------------------------\n";					
				}				
				$cutoffs->{$id}->{'result'} = $trans_result . $line;				
			}
		}
	}
	$cutoffs->{'result'} = $result;	

	# Create APPRIS object
	foreach my $transcript (@{$gene->transcripts}) {			
		my ($transcript_id) = $transcript->stable_id;
		my ($analysis);
		
		# create method object
		if ( exists $cutoffs->{$transcript_id} and exists $cutoffs->{$transcript_id}->{'functional_residue'} ) {
			my ($report) = $cutoffs->{$transcript_id};
			my ($regions);			
			if ( $transcript->translate and $transcript->translate->cds ) {				
				if ( exists $report->{'residues'} ) {
					foreach my $re (@{$report->{'residues'}}) {
						my ($pro_coord) = get_coords_from_residue($transcript, $re->{'residue'});
						my ($region) = APPRIS::Analysis::FirestarRegion->new (
										-residue	=> $re->{'residue'},
										-domain		=> $re->{'domain'},
										-ligands	=> $re->{'ligands'},
										-start		=> $pro_coord->start,
										-end		=> $pro_coord->end,
										-strand		=> $pro_coord->strand,
						);
						push(@{$regions}, $region);
					}
				}
			}
			
			# create Analysis object (for trans)			
			my ($method) = APPRIS::Analysis::Firestar->new (
							-result					=> $report->{'result'},
							-score					=> $report->{'score'},
							-functional_residue		=> $report->{'functional_residue'},
							-num_residues			=> $report->{'num_residues'},
			);
			$method->residues($regions) if (defined $regions); 
			$analysis = APPRIS::Analysis->new();
			if (defined $method) {
				$analysis->firestar($method);
				$analysis->number($analysis->number+1);
			}			
		}
				
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $transcript_id,
		);
		$transcript->analysis($analysis) if (defined $analysis);
		push(@{$transcripts}, $transcript);
		$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts
	}

	# create Analysis object (for gene)
	my ($method2) = APPRIS::Analysis::Firestar->new( -result => $cutoffs->{'result'} );	
	my ($analysis2) = APPRIS::Analysis->new();
	if (defined $method2) {
		$analysis2->firestar($method2);
		$analysis2->number($analysis2->number+1);
	}
	
	# create Gene object
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
	$entity->analysis($analysis2) if (defined $analysis2);	

	return $entity;
}

=head2 parse_matador3d

  Arg [1]    : APPRIS::Gene $gene 
               APPRIS::Gene object
  Arg [2]    : string $result
               Parse matador3d result
  Example    : use APPRIS::Parser qw(parse_matador3d);
               parse_matador3d($result);
  Description: Parse output of matador3d.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_matador3d($$)
{
	my ($gene, $result) = @_;

	my ($stable_id) = $gene->stable_id;
	my ($cutoffs);
	my ($transcripts);
	my ($index_transcripts);
	my ($index) = 0;

	my (@results) = split('>',$result);	
	foreach my $transcript_result (@results)
	{
        #>ENST00000381318        UNKNOWN
        if ( $transcript_result =~ /^([^\t]+)\t+($APPRIS::Utils::Constant::OK_LABEL|$APPRIS::Utils::Constant::NO_LABEL|$APPRIS::Utils::Constant::UNKNOWN_LABEL)\n+/ )        
		{
			my ($transcript_id) = $1;
			my ($conservation_structure) = $2;

			$cutoffs->{$transcript_id}->{'conservation_structure'} = $conservation_structure;
		}
        elsif ( $transcript_result =~ /^([^\t]+)\t+([^\n]+)\n+/ )
		{
			#>ENST00000308249        3.65
			#- 196:262[3]    1.33
	        #	196:242[190:240] 0.33[0.33*1*1]	 1Q33_A[35.9]

			my ($transcript_id) = $1;
			my ($structure_score) = $2;
			$cutoffs->{$transcript_id}->{'score'} = $structure_score;

			my ($alignment_list_report);			
			my (@trans_alignments) = split('- ', $transcript_result);

			for (my $i = 1; $i < scalar(@trans_alignments); $i++) { # jump the first line (ENST00000308249        3.65)
				if ( $trans_alignments[$i] =~ /^(\d+)\:(\d+)\[(\d+)\]\t+([^\n]*)\n*([^\$]*)$/ )
				{				
					my ($cds_start) = $1;
					my ($cds_end) = $2;
					my ($cds_order) = $3;
					my ($cds_score) = $4;
					my ($trans_mini_alignments) = $5;

					if(defined $cds_start and defined $cds_end and defined $cds_order and defined $cds_score and defined $trans_mini_alignments)
					{
						my ($alignment_report) = {
							'cds_id'	=> $cds_order,
							'start'		=> $cds_start,
							'end'		=> $cds_end,
							'score'		=> $cds_score,
							'type'		=> 'exon',
						};
						push(@{$alignment_list_report}, $alignment_report);
						
						# get mini-alignments
						while ( $trans_mini_alignments =~ /^\s+([^\n]*)\n*/mg ) # per line
						{
							if ( $1 =~ /^(\d+)\:(\d+)\[(\d+)\:(\d+)\]\t+([^\[]+)\[([^\]]+)\]\t+([^\$]*)$/ ) { #	196:242[190:240] 0.33[0.33*1*1]	 1Q33_A[35.9]
								my ($mini_cds_start) = $1;
								my ($mini_cds_end) = $2;
								my ($align_start) = $3;
								my ($align_end) = $4;								
								my ($mini_cds_score) = $5;
								my ($mini_cds_info) = $6;
								my ($mini_pdb_list) = $7;
								my ($mini_alignment_report) = {
									'alignment_start'		=> $align_start,
									'alignment_end'		=> $align_end,									
									'cds_id'	=> $cds_order,
									'start'		=> $mini_cds_start,
									'end'		=> $mini_cds_end,
									'score'		=> $mini_cds_score,
									'info'		=> $mini_cds_info,
									'type'		=> 'mini-exon',								
								};
								my ($mini_pdb_ident);
								my ($mini_pdb);
								my ($mini_ident);
								my ($mini_ext_id);

								if ( $mini_pdb_list =~ /^([^\t]+)\t+([^\$]+)$/ ) {
									$mini_pdb_ident = $1;
									$mini_ext_id = $2;
								}
								else {
									$mini_pdb_ident = $mini_pdb_list;
								}
								if ( defined $mini_pdb_ident and ($mini_pdb_ident =~ /^([^\[]+)\[([^\]]+)\]$/) ) {
									$mini_pdb = $1;
									$mini_ident = $2;	
								}									
								$mini_alignment_report->{'pdb_id'} = $mini_pdb if (defined $mini_pdb);
								$mini_alignment_report->{'identity'} = $mini_ident if (defined $mini_ident);
								$mini_alignment_report->{'external_id'} = $mini_ext_id if (defined $mini_ext_id);								
								push(@{$alignment_list_report}, $mini_alignment_report);							
							}
						}						
					}
				}
			}
			if ( defined $alignment_list_report and (scalar(@{$alignment_list_report}) > 0) )
			{
				$cutoffs->{$transcript_id}->{'alignments'} = $alignment_list_report;
			}
			$transcript_result =~ s/\n*#[^#]+#\n+#[^#]+#\n+#[^#]+#//mg;
			$cutoffs->{$transcript_id}->{'result'}='>'.$transcript_result;			
		}
	}
	$cutoffs->{'result'} = $result;
	
	# Create APPRIS object
	foreach my $transcript (@{$gene->transcripts}) {			
		my ($transcript_id) = $transcript->stable_id;
		my ($analysis);
		
		# create method object
		if ( exists $cutoffs->{$transcript_id} and exists $cutoffs->{$transcript_id}->{'conservation_structure'} ) {
			my ($report) = $cutoffs->{$transcript_id};
			my ($regions);			
			if ( $transcript->translate and $transcript->translate->cds ) {
				my ($translate) = $transcript->translate;
				
				if ( exists $report->{'alignments'} ) {
					my ($strand) = $transcript->strand;
					foreach my $residue (@{$report->{'alignments'}}) {
						my ($pro_coord_start) = get_coords_from_residue($transcript, $residue->{'start'});
						my ($pro_coord_end) = get_coords_from_residue($transcript, $residue->{'end'});
						$residue->{'trans_strand'} = $strand;
						if ( $strand eq '-' ) {
							$residue->{'trans_end'} = $pro_coord_start->{'start'};                                                
							$residue->{'trans_start'} = $pro_coord_end->{'end'};                                              
						}
						else {
							$residue->{'trans_start'} = $pro_coord_start->{'start'};                                                
							$residue->{'trans_end'} = $pro_coord_end->{'end'};                                              
						}
						my ($region) = APPRIS::Analysis::Matador3DRegion->new (
										-cds_id		=> $residue->{'cds_id'},
										-pstart		=> $residue->{'start'},
										-pend		=> $residue->{'end'},
										-score		=> $residue->{'score'},
										-start		=> $residue->{'trans_start'},
										-end		=> $residue->{'trans_end'},
										-strand		=> $residue->{'trans_strand'},										
						);
						$region->type($residue->{'type'}) if (exists $residue->{'type'} and defined $residue->{'type'});
						$region->alignment_start($residue->{'alignment_start'}) if (exists $residue->{'alignment_start'} and defined $residue->{'alignment_start'});
						$region->alignment_end($residue->{'alignment_end'}) if (exists $residue->{'alignment_end'} and defined $residue->{'alignment_end'});
						$region->pdb_id($residue->{'pdb_id'}) if (exists $residue->{'pdb_id'} and defined $residue->{'pdb_id'});
						$region->identity($residue->{'identity'}) if (exists $residue->{'identity'} and defined $residue->{'identity'});
						$region->external_id($residue->{'external_id'}) if (exists $residue->{'external_id'} and defined $residue->{'external_id'});
						push(@{$regions}, $region);						
					}
				}
			}
			
			# create Analysis object (for trans)			
			my ($method) = APPRIS::Analysis::Matador3D->new (
							-result					=> $report->{'result'},
							-score					=> $report->{'score'},
							-conservation_structure	=> $report->{'conservation_structure'},
			);
			if (defined $regions and (scalar(@{$regions}) > 0) ) {
				$method->alignments($regions);
				$method->num_alignments(scalar(@{$regions}));
			}			
			$analysis = APPRIS::Analysis->new();
			if (defined $method) {
				$analysis->matador3d($method);
				$analysis->number($analysis->number+1);
			}			
		}
				
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $transcript_id,
		);
		$transcript->analysis($analysis) if (defined $analysis);
		push(@{$transcripts}, $transcript);
		$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts
	}

	# create Analysis object (for gene)
	my ($method2) = APPRIS::Analysis::Matador3D->new( -result => $cutoffs->{'result'} );	
	my ($analysis2) = APPRIS::Analysis->new();
	if (defined $method2) {
		$analysis2->matador3d($method2);
		$analysis2->number($analysis2->number+1);
	}
	
	# create Gene object
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
	$entity->analysis($analysis2) if (defined $analysis2);	

	return $entity;
}

=head2 parse_spade

  Arg [1]    : APPRIS::Gene $gene 
               APPRIS::Gene object
  Arg [2]    : string $result
               Parse spade result
  Example    : use APPRIS::Parser qw(parse_spade);
               parse_spade($result);
  Description: Parse output of spade.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_spade($$)
{
	my ($gene, $result) = @_;

	my ($stable_id) = $gene->stable_id;
	my ($cutoffs);
	my ($transcripts);
	my ($index_transcripts);
	my ($index) = 0;

	my (@results) = split('>',$result);	
	foreach my $transcript_result (@results)
	{
        #>ENST00000381318        UNKNOWN
        if ( $transcript_result =~ /^([^\t]+)\t+($APPRIS::Utils::Constant::OK_LABEL|$APPRIS::Utils::Constant::NO_LABEL|$APPRIS::Utils::Constant::UNKNOWN_LABEL)\n+/ )        
		{
			my ($transcript_id) = $1;
			my ($domain_signal) = $2;

			$cutoffs->{$transcript_id}->{'domain_signal'} = $domain_signal;
		}
        elsif ( $transcript_result=~/^([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\n]+)\n+/ )
		{

			#>ENST00000356093        4       1     	1		0
			#domain  0       214     290     214     290     PF09379.3       FERM_N  Domain  1       80      80      73.6    7.6e-21 1       CL0072
			#domain_damaged  .       292     401     292     401     PF00373.11      FERM_M  Domain  1       117     117     74.0    8.3e-21 1       No_clan
			#domain_possibly_damaged 7       407     490     405     494     PF09380.3       FERM_C  Domain  3       85      90      81.2    3.7e-23 1       CL0266
			#domain_wrong 7       407     490     405     494     PF09380.3       FERM_C  Domain  3       85      90      81.2    3.7e-23 1       CL0266
			my ($transcript_id) = $1;
			my ($num_domains) = $2;
			my ($num_possibly_damaged_domains) = $3;
			my ($num_damaged_domains) = $4;
			my ($num_wrong_domains) = $5;

			$cutoffs->{$transcript_id}->{'num_domains'} = $num_domains;
			$cutoffs->{$transcript_id}->{'num_possibly_damaged_domains'} = $num_possibly_damaged_domains;
			$cutoffs->{$transcript_id}->{'num_damaged_domains'} = $num_damaged_domains;
			$cutoffs->{$transcript_id}->{'num_wrong_domains'} = $num_wrong_domains;
	
			# <type_domain> <domain score>
			# <alignment start> <alignment end> <envelope start> <envelope end>
			# <hmm acc> <hmm name> <type> <hmm start> <hmm end> <hmm length> <bit score> <E-value>
			# <significance> <clan> <predicted_active_site_residues> -optional values-
			# <external id, if applied> -optional values-			
			my ($alignment_list);
			while ( $transcript_result =~ /([domain|domain_possibly_damaged|domain_damaged|domain_wrong][^\n]*)\n*/mg )
			{
				my ($value_line) = $1;
				my (@value_list) = split(/\t+/,$value_line);
				if ( scalar(@value_list) > 12 )
				{
					my ($alignment_report);
					
					my ($type_domain) = $value_list[0];
					my ($domain_score) = $value_list[1];					
					my ($alignment_start) = $value_list[2];
					my ($alignment_end) = $value_list[3];
					my ($envelope_start) = $value_list[4];
					my ($envelope_end) = $value_list[5];
					my ($hmm_acc) = $value_list[6];
					my ($hmm_name) = $value_list[7];
					my ($hmm_type) = $value_list[8];
					my ($hmm_start) = $value_list[9];
					my ($hmm_end) = $value_list[10];
					my ($hmm_length) = $value_list[11];
					my ($bit_score) = $value_list[12];
					my ($e_value) = $value_list[13];
					
					# required values
					$alignment_report->{'type_domain'} = $type_domain;
					$alignment_report->{'score'} = $domain_score;
					$alignment_report->{'alignment_start'} = $alignment_start;
					$alignment_report->{'alignment_end'} = $alignment_end;
					$alignment_report->{'envelope_start'} = $envelope_start;
					$alignment_report->{'envelope_end'} = $envelope_end;
					$alignment_report->{'hmm_acc'} = $hmm_acc;
					$alignment_report->{'hmm_name'} = $hmm_name;
					$alignment_report->{'hmm_type'} = $hmm_type;
					$alignment_report->{'hmm_start'} = $hmm_start;
					$alignment_report->{'hmm_end'} = $hmm_end;
					$alignment_report->{'hmm_length'} = $hmm_length;
					$alignment_report->{'bit_score'} = $bit_score;
					$alignment_report->{'e_value'} = $e_value;
					
					# optional values taking into account the value of external_id
					if(defined $value_list[14] and !($value_list[14] =~ /\[[^\]]*\]/)) {
						$alignment_report->{'significance'} = $value_list[14];
					}
					elsif(defined $value_list[14] and ($value_list[14] =~ /\[[^\]]*\]/)) {
						$alignment_report->{'external_id'} = $value_list[14];
					}

					if(defined $value_list[15] and !($value_list[15] =~ /\[[^\]]*\]/)) {
						$alignment_report->{'clan'} = $value_list[15];
					}
					elsif(defined $value_list[15] and ($value_list[15] =~ /\[[^\]]*\]/)) {
						$alignment_report->{'external_id'} = $value_list[15];
					}
									
					if(defined $value_list[16] and !($value_list[16] =~ /\[[^\]]*\]/)) {
						$alignment_report->{'predicted_active_site_residues'} = $value_list[16];
					}
					elsif(defined $value_list[16] and ($value_list[16] =~ /\[[^\]]*\]/)) {
						$alignment_report->{'external_id'} = $value_list[16];
					}

					if(defined $value_list[17] and ($value_list[17] =~ /\[[^\]]*\]/))
						{ $alignment_report->{'external_id'} = $value_list[17]; }

					push(@{$alignment_list}, $alignment_report);					
				}
			}
			if ( defined $alignment_list and (scalar(@{$alignment_list}) > 0) )
			{
				$cutoffs->{$transcript_id}->{'domains'} = $alignment_list;
			}
			$transcript_result =~ s/\n*#[^#]+#\n+#[^#]+#\n+#[^#]+#//mg;
			$cutoffs->{$transcript_id}->{'result'} = '>'.$transcript_result;			
		}
        elsif ( $transcript_result =~ /^([^\s]+)(\s+[^\n]*\n+#HMM[^\n]*\n+#MATCH[^\n]*\n+#PP[^\n]*\n+#SEQ[^\n]*\n+)/ )
		{
			#>ENST00000270190     10    144     10    145 PF04118.7   Dopey_N           Family     1   136   309    199.8   3.3e-59   1 No_clan  
			##HMM       kdskqkkyasevekaLksFetlqEWADyisfLskLlkalqkkqeklsyvpskllvskrLaqcLnpsLPsGVHqkaLevYelIfekigketLskdlalylsGlfpllsyasisvkplllellekyllpLekalrpll
			##MATCH     +d++++ y+s +ekaL++Fe+++EWAD+is+L+kL+kalq ++ ++s +p++ll+skrLaqcL+p+LPsGVH kaLe+Ye+If+++g+++L+kdl+ly+ Glfpll++a++sv+p+ll+l+eky+lpL+k l+p l
			##PP        5899************************************.*****************************************************************************************999977
			##SEQ       NDYRYRSYSSVIEKALRNFESSSEWADLISSLGKLNKALQ-SNLRYSLLPRRLLISKRLAQCLHPALPSGVHLKALETYEIIFKIVGTKWLAKDLFLYSCGLFPLLAHAAVSVRPVLLTLYEKYFLPLQKLLLPSL

			my ($transcript_id) = $1;
			$transcript_result =~ s/\n*#[^#]+#\n+#[^#]+#\n+#[^#]+#//mg;						
			$cutoffs->{$transcript_id}->{'result'} .= '>'.$transcript_result;
		}	
	}
	$cutoffs->{'result'} = $result;

	# Create APPRIS object
	foreach my $transcript (@{$gene->transcripts}) {			
		my ($transcript_id) = $transcript->stable_id;
		my ($analysis);
		
		# create method object
		if ( exists $cutoffs->{$transcript_id} and exists $cutoffs->{$transcript_id}->{'domain_signal'} ) {
			my ($report) = $cutoffs->{$transcript_id};
			my ($regions);
			if ( $transcript->translate and $transcript->translate->cds ) {				
				if ( exists $report->{'domains'} ) {
					my ($strand) = $transcript->strand;
					foreach my $residue (@{$report->{'domains'}}) {
						my ($pro_coord_start) = get_coords_from_residue($transcript, $residue->{'alignment_start'});
						my ($pro_coord_end) = get_coords_from_residue($transcript, $residue->{'alignment_end'});
						$residue->{'trans_strand'} = $strand;
						if ( $strand eq '-' ) {
							$residue->{'trans_end'} = $pro_coord_start->{'start'};                                                
							$residue->{'trans_start'} = $pro_coord_end->{'end'};                                              
						}
						else {
							$residue->{'trans_start'} = $pro_coord_start->{'start'};                                                
							$residue->{'trans_end'} = $pro_coord_end->{'end'};                                              
						}

						my ($region) = APPRIS::Analysis::SPADERegion->new (
										-start								=> $residue->{'trans_start'},
										-end								=> $residue->{'trans_end'},
										-strand								=> $residue->{'trans_strand'},						
										-score								=> $residue->{'score'},						
										-type_domain						=> $residue->{'type_domain'},						
										-alignment_start					=> $residue->{'alignment_start'},					
										-alignment_end						=> $residue->{'alignment_end'},
										-envelope_start						=> $residue->{'envelope_start'},					
										-envelope_end						=> $residue->{'envelope_end'},
										-hmm_start							=> $residue->{'hmm_start'},					
										-hmm_end							=> $residue->{'hmm_end'},
										-hmm_length							=> $residue->{'hmm_length'},					
										-hmm_acc							=> $residue->{'hmm_acc'},
										-hmm_name							=> $residue->{'hmm_name'},					
										-hmm_type							=> $residue->{'hmm_type'},
										-bit_score							=> $residue->{'bit_score'},
										-evalue								=> $residue->{'e_value'}
						);
						$region->significance($residue->{'significance'}) if (exists $residue->{'significance'} and defined $residue->{'significance'});
						$region->clan($residue->{'clan'}) if (exists $residue->{'clan'} and defined $residue->{'clan'});
						$region->predicted_active_site_residues($residue->{'predicted_active_site_residues'}) if (exists $residue->{'predicted_active_site_residues'} and defined $residue->{'predicted_active_site_residues'});
						$region->external_id($residue->{'external_id'}) if (exists $residue->{'external_id'} and defined $residue->{'external_id'});
						
						push(@{$regions}, $region);
					}
				}
			}
			
			# create Analysis object (for trans)			
			my ($method) = APPRIS::Analysis::SPADE->new (
							-result							=> $report->{'result'},
							-domain_signal					=> $report->{'domain_signal'},
							-num_domains					=> $report->{'num_domains'},
							-num_possibly_damaged_domains	=> $report->{'num_possibly_damaged_domains'},
							-num_damaged_domains			=> $report->{'num_damaged_domains'},
							-num_wrong_domains				=> $report->{'num_wrong_domains'}
			);
			$method->regions($regions) if (defined $regions and (scalar(@{$regions}) > 0) );
			
			$analysis = APPRIS::Analysis->new();
			if (defined $method) {
				$analysis->spade($method);
				$analysis->number($analysis->number+1);
			}			
		}
				
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $transcript_id,
		);
		$transcript->analysis($analysis) if (defined $analysis);
		push(@{$transcripts}, $transcript);
		$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts
	}

	# create Analysis object (for gene)
	my ($method2) = APPRIS::Analysis::SPADE->new( -result => $cutoffs->{'result'} );	
	my ($analysis2) = APPRIS::Analysis->new();
	if (defined $method2) {
		$analysis2->spade($method2);
		$analysis2->number($analysis2->number+1);
	}
	
	# create Gene object
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
	$entity->analysis($analysis2) if (defined $analysis2);	

	return $entity;
}

=head2 parse_inertia

  Arg [1]    : String $id 
               The stable ID of the gene to retrieve
  Arg [2]    : string $inertia
               INERTIA result
  Arg [3]    : string $mafft
               MAFFT Omega result
  Arg [4]    : string $prank
               Prank Omega result
  Arg [5]    : string $kalign
               Kalign Omega result
  Example    : use APPRIS::Parser qw(parse_inertia);
               parse_inertia($id, $mafft, $prank, $kalign);
  Description: Parse the output of inertia.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_inertia($$;$;$;$)
{
	my ($gene, $inertia_i, $mafft_i, $prank_i, $kalign_i) = @_;
	
	my ($stable_id) = $gene->stable_id;	
	my ($transcripts);
	my ($cutoffs);
	my ($index_transcripts);
	my ($index) = 0;	
	
	_parse_inertia_file('inertia', $inertia_i, $cutoffs) if (defined $inertia_i);
	_parse_omega_file('mafft', $mafft_i, $cutoffs) if (defined $mafft_i);
	_parse_omega_file('prank', $prank_i, $cutoffs) if (defined $prank_i);
	_parse_omega_file('kalign', $kalign_i, $cutoffs) if (defined $kalign_i);

	# Create APPRIS objects
	foreach my $transcript (@{$gene->transcripts}) {
		my ($transcript_id) = $transcript->stable_id;
		my ($analysis);

		# create method object
		if ( exists $cutoffs->{$transcript_id} and exists $cutoffs->{$transcript_id}->{'inertia'} ) {
			my ($report) = $cutoffs->{$transcript_id};
			my ($report2) = $report->{'inertia'};
			my ($method);
			
			# create inertia object
			my ($regions);			
			foreach my $residue (@{$report2->{'residues'}})
			{
				push(@{$regions},
					APPRIS::Analysis::INERTIARegion->new
					(
						-start				=> $residue->{'start'},
						-end				=> $residue->{'end'},
						-strand				=> $residue->{'strand'},
						-unusual_evolution	=> $residue->{'unusual_evolution'}
					)
				);
			}
			if ( exists $report2->{'unusual_evolution'} and defined $report2->{'unusual_evolution'} ) {
				$method = APPRIS::Analysis::INERTIA->new
				(
					-unusual_evolution		=> $report2->{'unusual_evolution'}
				);
				$method->regions($regions) if (defined $regions);				
			}
			# create omega objects
			while ( my ($type, $report2) = each(%{$report}) )
			{
				if ( ($type eq 'mafft') or ($type eq 'prank') or ($type eq 'kalign') )
				{					
					my ($omega);
					my ($regions);
					
					foreach my $residue (@{$report2->{'residues'}})
					{
						push(@{$regions},
							APPRIS::Analysis::OmegaRegion->new
							(
								-start				=> $residue->{'start'},
								-end				=> $residue->{'end'},
								-omega_mean			=> $residue->{'omega_mean'},
								-st_deviation		=> $residue->{'st_deviation'},
								-p_value			=> $residue->{'p_value'},
								-difference_value	=> $residue->{'difference_value'},
								-unusual_evolution	=> $residue->{'unusual_evolution'}
							)
						);			
					}
					$omega = APPRIS::Analysis::Omega->new
					(
						-average			=> $report2->{'omega_average'},
						-st_desviation		=> $report2->{'omega_st_desviation'},
						-result				=> $report2->{'result'},
						-unusual_evolution	=> $report2->{'unusual_evolution'}
					);
					$omega->regions($regions) if (defined $regions);
					
					$method->mafft_alignment($omega) if ($method and $omega and ($type eq 'mafft') );
					$method->prank_alignment($omega) if ($method and $omega and ($type eq 'prank') );
					$method->kalign_alignment($omega) if ($method and $omega and ($type eq 'kalign') );
				}			
			}
			
			# create Analysis object (for trans)
			$analysis = APPRIS::Analysis->new();			
			if (defined $method) {				
				$analysis->inertia($method);
				$analysis->number($analysis->number+1);
			}
		}
					
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new ( -stable_id	=> $transcript_id );
		$transcript->analysis($analysis) if (defined $analysis);
		if ( defined $transcript ) {
			push(@{$transcripts}, $transcript);
			$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts
		}
	}
	
	# create Analysis object (for gene)
	my ($analysis2) = APPRIS::Analysis->new();
	if ( defined $inertia_i and ($inertia_i ne '') ) {
		my ($method2) = APPRIS::Analysis::INERTIA->new( -result => $inertia_i );	
		if (defined $method2) {
			if ( defined $mafft_i and ($mafft_i ne '') ) {	
				my ($method3) = APPRIS::Analysis::Omega->new( -result => $mafft_i );	
				if (defined $method3) {
					$method2->mafft_alignment($method3);
				}
			}		
			if ( defined $prank_i and ($prank_i ne '') ) {	
				my ($method4) = APPRIS::Analysis::Omega->new( -result => $prank_i );	
				if (defined $method4) {
					$method2->prank_alignment($method4);
				}
			}		
			if ( defined $kalign_i and ($kalign_i ne '') ) {	
				my ($method5) = APPRIS::Analysis::Omega->new( -result => $kalign_i );	
				if (defined $method5) {
					$method2->kalign_alignment($method5);
				}
			}
			$analysis2->inertia($method2);
			$analysis2->number($analysis2->number+1);
		}
	}
	
	# create Gene object
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
	$entity->analysis($analysis2) if (defined $analysis2);	

	return $entity;
}

=head2 parse_corsair

  Arg [1]    : APPRIS::Gene $gene 
               APPRIS::Gene object
  Arg [2]    : string $result
               Parse corsair result
  Example    : use APPRIS::Parser qw(parse_corsair);
               parse_corsair($result);
  Description: Parse output of corsair.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_corsair($$)
{
	my ($gene, $result) = @_;

	my ($stable_id) = $gene->stable_id;
	my ($cutoffs);
	my ($transcripts);
	my ($index_transcripts);
	my ($index) = 0;

	my (@results) = split('>',$result);	
	foreach my $transcript_result (@results)
	{
        #>ENST00000381318        UNKNOWN
        if ( $transcript_result =~ /^([^\t]+)\t+($APPRIS::Utils::Constant::OK_LABEL|$APPRIS::Utils::Constant::NO_LABEL|$APPRIS::Utils::Constant::UNKNOWN_LABEL)\n+/ )        
		{
			my ($transcript_id) = $1;
			my ($vertebrate_signal) = $2;

			$cutoffs->{$transcript_id}->{'vertebrate_signal'} = $vertebrate_signal;
		}
        elsif ( $transcript_result =~ /^([^\t]+)\t+([^\n]+)\n+/ )
		{
			#>ENST00000300481        1
			#Pan troglodytes 98.7586206896552        1       1       
			#Bos taurus      77.8231292517007        0       1       It has different N-terminal

			my ($transcript_id) = $1;
			my ($score) = $2;
			$cutoffs->{$transcript_id}->{'score'} = $score;
			$transcript_result =~ s/\n*#[^#]+#\n+#[^#]+#\n+#[^#]+#//mg;
			$cutoffs->{$transcript_id}->{'result'}='>'.$transcript_result;			
		}
	}
	$cutoffs->{'result'} = $result;

	# Create APPRIS object
	foreach my $transcript (@{$gene->transcripts}) {			
		my ($transcript_id) = $transcript->stable_id;
		my ($analysis);
		
		# create method object
		if ( exists $cutoffs->{$transcript_id} and exists $cutoffs->{$transcript_id}->{'vertebrate_signal'} ) {
			my ($report) = $cutoffs->{$transcript_id};

			# create Analysis object (for trans)			
			my ($method) = APPRIS::Analysis::CORSAIR->new (
							-result							=> $report->{'result'},
							-vertebrate_signal				=> $report->{'vertebrate_signal'},
							-score							=> $report->{'score'}
			);			
			$analysis = APPRIS::Analysis->new();
			if (defined $method) {
				$analysis->corsair($method);
				$analysis->number($analysis->number+1);
			}			
		}
				
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $transcript_id,
		);
		$transcript->analysis($analysis) if (defined $analysis);
		push(@{$transcripts}, $transcript);
		$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts
	}

	# create Analysis object (for gene)
	my ($method2) = APPRIS::Analysis::CORSAIR->new( -result => $cutoffs->{'result'} );	
	my ($analysis2) = APPRIS::Analysis->new();
	if (defined $method2) {
		$analysis2->corsair($method2);
		$analysis2->number($analysis2->number+1);
	}
	
	# create Gene object
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
	$entity->analysis($analysis2) if (defined $analysis2);	

	return $entity;
}

=head2 parse_cexonic

  Arg [1]    : APPRIS::Gene $gene 
               APPRIS::Gene object
  Arg [2]    : string $result
               Parse cexonic result
  Example    : use APPRIS::Parser qw(parse_cexonic);
               parse_cexonic($result);
  Description: Parse output of cexonic.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_cexonic($$)
{
	my ($gene, $text_result) = @_;

	my ($stable_id) = $gene->stable_id;
	my ($cutoffs);
	my ($transcripts);
	my ($index_transcripts);
	my ($index) = 0;

	my ($specie);
	#my ($text_result) = $result->{'result'};

	# Parser all alignments!!
	my (@transcript) = split(/\n+\>([^\n]+)\n/, $text_result);
	my ($cexonic_trans_aligments);
	foreach my $alignment (@transcript)
	{
		next if ( ($alignment =~ /^\/\*[^\$]*$/) or ($alignment =~ /^\s\*\w*$/) ); # jump comment line
		
		if ( defined $alignment ) {
			my ($id);
			my ($num_exons_1);
			my ($num_exons_2);
			my ($num_introns);
	    	my ($residues_exonic);
	    	
			# Get the transcript identifier and CExonic identifiers from the next pattern:
			# 1:OTTHUMT00000157419 2:OTTHUMG00000074130_mouse_musculus_2
			if ( $alignment =~ /^1\:([^\s]+)\s+2\:([^\n+]+)\n*/ ) {
				$id = $1;
				my ($cexonic_trans_id) = $2;
				$cexonic_trans_id =~ /^([^\_]+)\_([^\_]+)\_([^\_]+)\_[0-9]/;
				$specie = $2.'_'.$3;
			}
			# Get the CExonic scores from the next pattern:
			# #       1       2       2       2       1
			if ( $alignment =~ /\#\#\t+\d+\t+\d+\t+(\d+)\t+(\d+)\t+(\d+)/g ) {
				$num_exons_1 = $1;
				$num_exons_2 = $2;
				$num_introns = $3;
			}
			# Get CExonic Residues for the first article name from the next pattern:
	    	# intron:1      22      35493850        35501663        -
			while ( $alignment =~ /#\s+intron:([^\:]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t(\W)/g ) {
				my ($num_intron) = $1;
				my ($chr_residue) = $2;
				my ($start_residue) = $3;
				my ($end_residue) = $4;
				my ($strand_residue) = $5;
				if ( defined $start_residue and defined $end_residue and defined $strand_residue ) {
					my ($residues_report);
					$residues_report->{'start'} = $start_residue;
					$residues_report->{'end'} = $end_residue;
					$residues_report->{'strand'} = $strand_residue;
					push(@{$residues_exonic},$residues_report);
				}
			}
			if ( defined $id and defined $alignment and defined $num_exons_1 and defined $num_exons_2 and defined $num_introns ) {
				$alignment =~ s/\n*#[^#]+#\n+#[^#]+#\n+#[^#]+#//mg;
				$cutoffs->{$id}->{'result'} = $alignment;
				$cutoffs->{$id}->{'first_specie_num_exons'} = $num_exons_1;
				$cutoffs->{$id}->{'second_specie_num_exons'} = $num_exons_2;
				$cutoffs->{$id}->{'residues'} = $residues_exonic if ( defined $residues_exonic );
				if ( defined $residues_exonic and (scalar(@{$residues_exonic}) > 0) ) {
					$cutoffs->{$id}->{'num_introns'} = scalar(@{$residues_exonic});
				} else {
					$cutoffs->{$id}->{'num_introns'} = 0;
				}
			}
			# Get the appris annotations from the next pattern:
	        #ENST00000381318        UNKNOWN
	        if ( $alignment =~ /([^\t]+)\t+($APPRIS::Utils::Constant::OK_LABEL|$APPRIS::Utils::Constant::NO_LABEL|$APPRIS::Utils::Constant::UNKNOWN_LABEL)/ ) {	        	
				my ($transcript_id) = $1;
				my ($conservation_exon) = $2;
				$transcript_id =~ s/^>//mg;
				$cutoffs->{$transcript_id}->{'conservation_exon'} = $conservation_exon;
			}			
		}
	}
	if ( defined $specie and defined $text_result ) {
		$cutoffs->{'result'} = $text_result;
		#$cutoffs->{'specie'} = $specie; # DEPRECATED!!!
	}

	# Create APPRIS object
	foreach my $transcript (@{$gene->transcripts}) {			
		my ($transcript_id) = $transcript->stable_id;
		my ($analysis);
		
		# create method object
		if ( exists $cutoffs->{$transcript_id} and exists $cutoffs->{$transcript_id}->{'conservation_exon'} ) {
			my ($report) = $cutoffs->{$transcript_id};
			my ($regions);
			if ( $transcript->translate and $transcript->translate->cds ) {				
				if ( exists $report->{'residues'} ) {
					foreach my $residue (@{$report->{'residues'}}) {						
						my ($region) = APPRIS::Analysis::CExonicRegion->new (
										-start								=> $residue->{'start'},
										-end								=> $residue->{'end'},
										-strand								=> $residue->{'strand'},						
						);						
						push(@{$regions}, $region);
					}
				}
			}

			# create Analysis object (for trans)			
			my ($method) = APPRIS::Analysis::CExonic->new (
							-result							=> $report->{'result'},
							-conservation_exon				=> $report->{'conservation_exon'},
							-num_introns					=> $report->{'num_introns'},
							-first_specie_num_exons			=> $report->{'first_specie_num_exons'},
							-second_specie_num_exons		=> $report->{'second_specie_num_exons'}
			);
			$method->regions($regions) if (defined $regions and (scalar(@{$regions}) > 0) );
			
			$analysis = APPRIS::Analysis->new();
			if (defined $method) {
				$analysis->cexonic($method);
				$analysis->number($analysis->number+1);
			}			
		}
				
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $transcript_id,
		);
		$transcript->analysis($analysis) if (defined $analysis);
		push(@{$transcripts}, $transcript);
		$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts
	}

	# create Analysis object (for gene)
	my ($method2) = APPRIS::Analysis::CExonic->new( -result => $cutoffs->{'result'} );	
	my ($analysis2) = APPRIS::Analysis->new();
	if (defined $method2) {
		$analysis2->cexonic($method2);
		$analysis2->number($analysis2->number+1);
	}
	
	# create Gene object
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
	$entity->analysis($analysis2) if (defined $analysis2);	

	return $entity;
}

=head2 parse_crash

  Arg [1]    : APPRIS::Gene $gene 
               APPRIS::Gene object
  Arg [2]    : string $result
               Parse crash result
  Example    : use APPRIS::Parser qw(parse_crash);
               parse_crash($result);
  Description: Parse output of crash.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_crash($$)
{
	my ($gene, $result) = @_;

	my ($stable_id) = $gene->stable_id;
	my ($cutoffs);
	my ($transcripts);
	my ($index_transcripts);
	my ($index) = 0;

	my (@results) = split('>',$result);	
	foreach my $transcript_result (@results)
	{
        #id      start   end     s_mean  d_score c_max   s_prob  sp_score        peptide_signal  localization    reliability     tp_score        mitochondrial_signal
		#>ENST00000479548        1       20      0.902   0.832   0.963   0.709   2       YES     S       2       -3      NO
        if ( $transcript_result =~ /^([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+($APPRIS::Utils::Constant::OK_LABEL|$APPRIS::Utils::Constant::NO_LABEL|$APPRIS::Utils::Constant::UNKNOWN_LABEL)\t+([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+($APPRIS::Utils::Constant::OK_LABEL|$APPRIS::Utils::Constant::NO_LABEL|$APPRIS::Utils::Constant::UNKNOWN_LABEL)\n+/ )        
		{
			my ($transcript_id) = $1;
			my ($pstart) = $2;
			my ($pend) = $3;
			my ($s_mean) = $4;
			my ($d_score) = $5;
			my ($c_max) = $6;
			my ($s_prob) = $7;
			my ($sp_score) = $8;
			my ($peptide_signal) = $9;
			my ($localization) = $10;
			my ($reliability) = $11;
			my ($tp_score) = $12;
			my ($mitochondrial_signal) = $13;

			$cutoffs->{$transcript_id}->{'result'} = '>'.$transcript_result;
			$cutoffs->{$transcript_id}->{'sp_score'} = $sp_score;
			$cutoffs->{$transcript_id}->{'tp_score'} = $tp_score;
			$cutoffs->{$transcript_id}->{'peptide_signal'} = $peptide_signal;
			$cutoffs->{$transcript_id}->{'mitochondrial_signal'} = $mitochondrial_signal;
			$cutoffs->{$transcript_id}->{'pstart'} = $pstart;
			$cutoffs->{$transcript_id}->{'pend'} = $pend;
			$cutoffs->{$transcript_id}->{'s_mean'} = $s_mean;
			$cutoffs->{$transcript_id}->{'s_prob'} = $s_prob;
			$cutoffs->{$transcript_id}->{'d_score'} = $d_score;
			$cutoffs->{$transcript_id}->{'c_max'} = $c_max;
			$cutoffs->{$transcript_id}->{'reliability'} = $reliability;
			$cutoffs->{$transcript_id}->{'localization'} = $localization;
		}
	}
	$cutoffs->{'result'} = $result;

	# Create APPRIS object
	foreach my $transcript (@{$gene->transcripts}) {			
		my ($transcript_id) = $transcript->stable_id;
		my ($analysis);
		
		# create method object
		if ( exists $cutoffs->{$transcript_id} and exists $cutoffs->{$transcript_id}->{'peptide_signal'} and exists $cutoffs->{$transcript_id}->{'mitochondrial_signal'} ) {
			my ($report) = $cutoffs->{$transcript_id};
			my ($regions);
			if ( $transcript->translate and $transcript->translate->cds ) {		
				if ( exists $report->{'pstart'} and exists $report->{'pend'} and 
						($report->{'pstart'} ne '-') and ($report->{'pend'} ne '-') ) {
					my ($strand) = $transcript->strand;
					my ($pro_coord_start) = get_coords_from_residue($transcript, $report->{'pstart'});
					my ($pro_coord_end) = get_coords_from_residue($transcript, $report->{'pend'});
					$report->{'trans_strand'} = $strand;
					if ( $strand eq '-' ) {
						$report->{'trans_end'} = $pro_coord_start->{'start'};                                                
						$report->{'trans_start'} = $pro_coord_end->{'end'};                                              
					}
					else {
						$report->{'trans_start'} = $pro_coord_start->{'start'};                                                
						$report->{'trans_end'} = $pro_coord_end->{'end'};                                              
					}
						
					push(@{$regions},
							APPRIS::Analysis::CRASHRegion->new (
									-start						=> $report->{'trans_start'},
									-end						=> $report->{'trans_end'},
									-strand						=> $report->{'trans_strand'},
									-pstart						=> $report->{'pstart'},						
									-pend						=> $report->{'pend'},						
									-s_mean						=> $report->{'s_mean'},					
									-s_prob						=> $report->{'s_prob'},
									-d_score					=> $report->{'d_score'},					
									-c_max						=> $report->{'c_max'},
									-reliability				=> $report->{'reliability'},					
									-localization				=> $report->{'localization'},
							)
					);
				}
			}
			
			# create Analysis object (for trans)			
			my ($method) = APPRIS::Analysis::CRASH->new (
							-result						=> $report->{'result'},
							-sp_score					=> $report->{'sp_score'},
							-tp_score					=> $report->{'tp_score'},
							-peptide_signal				=> $report->{'peptide_signal'},
							-mitochondrial_signal		=> $report->{'mitochondrial_signal'}
			);
			$method->regions($regions) if (defined $regions and (scalar(@{$regions}) > 0) );
			
			$analysis = APPRIS::Analysis->new();
			if (defined $method) {
				$analysis->crash($method);
				$analysis->number($analysis->number+1);
			}			
		}
				
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $transcript_id,
		);
		$transcript->analysis($analysis) if (defined $analysis);
		push(@{$transcripts}, $transcript);
		$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts
	}

	# create Analysis object (for gene)
	my ($method2) = APPRIS::Analysis::CRASH->new( -result => $cutoffs->{'result'} );	
	my ($analysis2) = APPRIS::Analysis->new();
	if (defined $method2) {
		$analysis2->crash($method2);
		$analysis2->number($analysis2->number+1);
	}
	
	# create Gene object
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
	$entity->analysis($analysis2) if (defined $analysis2);	

	return $entity;
}

=head2 parse_thump

  Arg [1]    : APPRIS::Gene $gene 
               APPRIS::Gene object
  Arg [2]    : string $result
               Parse thump result
  Example    : use APPRIS::Parser qw(parse_thump);
               parse_thump($result);
  Description: Parse output of thump.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_thump($$)
{
	my ($gene, $result) = @_;

	my ($stable_id) = $gene->stable_id;
	my ($cutoffs);
	my ($transcripts);
	my ($index_transcripts);
	my ($index) = 0;
	
	my (@results) = split('>',$result);	
	foreach my $transcript_result (@results)
	{
        #>ENST00000381318        UNKNOWN
        if ( $transcript_result =~ /^([^\t]+)\t+($APPRIS::Utils::Constant::OK_LABEL|$APPRIS::Utils::Constant::NO_LABEL|$APPRIS::Utils::Constant::UNKNOWN_LABEL)\n+/ )        
		{
			my ($transcript_id) = $1;
			my ($transmembrane_signal) = $2;

			$cutoffs->{$transcript_id}->{'transmembrane_signal'} = $transmembrane_signal;
		}
		#>ENST00000300482    length 1503 a.a.
		#helix number 1 start: 798       end: 818
		#helix number 2 start: 829       end: 841        damaged
		#helix number 3 start: 868       end: 886
		#helix number 4 start: 895       end: 908        damaged
		#helix number 5 start: 935       end: 955
		#helix number 6 start: 1024      end: 1041		
        elsif ( $transcript_result =~ /^([^\t]+)\t+length\s+([^\s]+)\s+a\.a\.\n+/ )
		{
			# get the helix coordinates
			my ($transcript_id) = $1;
			my ($transmembrane_list);
			$cutoffs->{$transcript_id}->{'num_tmh'} = 0;
			$cutoffs->{$transcript_id}->{'num_damaged_tmh'} = 0;
			while ($transcript_result =~ /^helix number \d+ start:\s+(\d+)\s+end:\s+(\d+)(\s*damaged|)$/mg ) {
				my ($start) = $1;
				my ($end) = $2;
				my ($damaged) = $3;
				if ( defined $start and defined $end ) {
					my ($helix_report) = {
						'start'	=> $start,
						'end'	=> $end
					};
					$cutoffs->{$transcript_id}->{'num_tmh'}++;
					if ( $damaged =~ /damaged/ ) {
						$helix_report->{'damaged'} = 1;
						$cutoffs->{$transcript_id}->{'num_damaged_tmh'}++;
					}
					push(@{$transmembrane_list}, $helix_report);					
				}
			}
			$cutoffs->{$transcript_id}->{'tmhs'} = $transmembrane_list if (defined $transmembrane_list); 

			# save result for each transcript
			$transcript_result =~ s/\n*#[^#]+#\n+#[^#]+#\n+#[^#]+#//mg;
			$cutoffs->{$transcript_id}->{'result'}='>'.$transcript_result;				
		}
	}
	$cutoffs->{'result'} = $result;
		
	# Create APPRIS object
	foreach my $transcript (@{$gene->transcripts}) {
		my ($transcript_id) = $transcript->stable_id;
		my ($analysis);
		
		# create method object
		if ( exists $cutoffs->{$transcript_id} and exists $cutoffs->{$transcript_id}->{'transmembrane_signal'} ) {
			my ($report) = $cutoffs->{$transcript_id};
			my ($regions);
			if ( $transcript->translate and $transcript->translate->cds ) {				
				if ( exists $report->{'tmhs'} ) {
					my ($strand) = $transcript->strand;
					foreach my $residue (@{$report->{'tmhs'}}) {
						my ($pro_coord_start) = get_coords_from_residue($transcript, $residue->{'start'});
						my ($pro_coord_end) = get_coords_from_residue($transcript, $residue->{'end'});
						$residue->{'trans_strand'} = $strand;
						if ( $strand eq '-' ) {
							$residue->{'trans_end'} = $pro_coord_start->{'start'};                                                
							$residue->{'trans_start'} = $pro_coord_end->{'end'};                                              
						}
						else {
							$residue->{'trans_start'} = $pro_coord_start->{'start'};                                                
							$residue->{'trans_end'} = $pro_coord_end->{'end'};                                              
						}
		
						my ($region) = APPRIS::Analysis::THUMPRegion->new (
										-start								=> $residue->{'trans_start'},
										-end								=> $residue->{'trans_end'},
										-strand								=> $residue->{'trans_strand'},						
										-pstart								=> $residue->{'start'},					
										-pend								=> $residue->{'end'},
										-damaged							=> $residue->{'damaged'}										
						);
												
						push(@{$regions}, $region);
					}
				}
				# create Analysis object (for trans) Note: we only create an analysis object when trans has got translation 			
				my ($method) = APPRIS::Analysis::THUMP->new (
								-result							=> $report->{'result'},
								-transmembrane_signal			=> $report->{'transmembrane_signal'},
								-num_tmh						=> $report->{'num_tmh'},
								-num_damaged_tmh				=> $report->{'num_damaged_tmh'}
				);
				$method->regions($regions) if (defined $regions and (scalar(@{$regions}) > 0) );
				
				$analysis = APPRIS::Analysis->new();
				if (defined $method) {
					$analysis->thump($method);
					$analysis->number($analysis->number+1);
				}
			}
		}
				
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $transcript_id,
		);
		$transcript->analysis($analysis) if (defined $analysis);
		push(@{$transcripts}, $transcript);
		$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts
	}

	# create Analysis object (for gene)
	my ($method2) = APPRIS::Analysis::THUMP->new( -result => $cutoffs->{'result'} );	
	my ($analysis2) = APPRIS::Analysis->new();
	if (defined $method2) {
		$analysis2->thump($method2);
		$analysis2->number($analysis2->number+1);
	}
	
	# create Gene object
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
	$entity->analysis($analysis2) if (defined $analysis2);	

	return $entity;
}

=head2 parse_appris_methods

  Arg [1]    : APPRIS::Gene $gene 
               APPRIS::Gene object
  Arg [2]    : string $result
               Parse firestar result
  Arg [3]    : string $result
               Parse matador3d result
  Arg [4]    : string $result
               Parse spade result
  Arg [5]    : string $result
               Parse inertia result
  Arg [6]    : string $result
               Parse corsair result
  Arg [7]    : string $result
               Parse cexonic result
  Arg [8]    : string $result
               Parse crash result
  Arg [9]    : string $result
               Parse thump result
  Arg [10]    : string $result
               Parse inertia_maf result
  Arg [11]    : string $result
               Parse inertia_prank result
  Arg [12]    : string $result
               Parse inertia_kalign result               
  Example    : use APPRIS::Parser qw(parse_appris_methods);
               parse_appris_methods([$results]);
  Description: Parse output of methods of appris.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_appris_methods($$$$$$$$$;$;$;$)
{
	my ($gene, $firestar_result, $matador3d_result, $spade_result, $inertia_result, $corsair_result, $cexonic_result, $crash_result, $thump_result, $inertia_maf_result, $inertia_prank_result, $inertia_kalign_result) = @_;	
	
	my ($stable_id) = $gene->stable_id;
	my ($transcripts);
	my ($index_transcripts);
	my ($index) = 0;
	
	my ($firestar);
	my ($matador3d);
	my ($corsair);
	my ($spade);
	my ($inertia);
	my ($cexonic);
	my ($thump);
	my ($crash);
	
	# get the reports for every method
	if ( defined $firestar_result ) {
		$firestar = parse_firestar($gene, $firestar_result);
	}
	if ( defined $matador3d_result ) {
		$matador3d = parse_matador3d($gene, $matador3d_result);
	}
	if ( defined $corsair_result ) {
		$corsair = parse_corsair($gene, $corsair_result);
	}	
	if ( defined $spade_result ) {
		$spade = parse_spade($gene, $spade_result);
	}
	if ( defined $inertia_result ) {
		$inertia = parse_inertia($gene, $inertia_result, $inertia_maf_result, $inertia_prank_result, $inertia_kalign_result);
	}
	if ( defined $cexonic_result ) {
		$cexonic = parse_cexonic($gene, $cexonic_result);
	}
	if ( defined $thump_result ) {
		$thump = parse_thump($gene, $thump_result);
	}	
	if ( defined $crash_result ) {
		$crash = parse_crash($gene, $crash_result);
	}

	# get the results for each transcript
	foreach my $transcript (@{$gene->transcripts}) {			
		my ($transcript_id) = $transcript->stable_id;
		my ($index) = $gene->{'_index_transcripts'}->{$transcript_id};
		my ($analysis) = APPRIS::Analysis->new();		

		# get firestar
		if ( $firestar and $firestar->transcripts->[$index] and $firestar->transcripts->[$index]->analysis ) {
			my ($result) = $firestar->transcripts->[$index];
			if ( $result->analysis->firestar ) {
				my ($method) = $result->analysis->firestar;
				if (defined $method) {
					$analysis->firestar($method);
					$analysis->number($analysis->number+1);
				}
			}			
		}			
		# get matador3d
		if ( $matador3d and $matador3d->transcripts->[$index] and $matador3d->transcripts->[$index]->analysis ) {
			my ($result) = $matador3d->transcripts->[$index];
			if ( $result->analysis->matador3d ) {
				my ($method) = $result->analysis->matador3d;
				if (defined $method) {
					$analysis->matador3d($method);
					$analysis->number($analysis->number+1);
				}
			}			
		}
		# get corsair
		if ( $corsair and $corsair->transcripts->[$index] and $corsair->transcripts->[$index]->analysis ) {
			my ($result) = $corsair->transcripts->[$index];
			if ( $result->analysis->corsair ) {
				my ($method) = $result->analysis->corsair;
				if (defined $method) {
					$analysis->corsair($method);
					$analysis->number($analysis->number+1);
				}
			}			
		}		
		# get spade
		if ( $spade and $spade->transcripts->[$index] and $spade->transcripts->[$index]->analysis ) {
			my ($result) = $spade->transcripts->[$index];
			if ( $result->analysis->spade ) {
				my ($method) = $result->analysis->spade;
				if (defined $method) {
					$analysis->spade($method);
					$analysis->number($analysis->number+1);
				}
			}			
		}
		# get inertia
		if ( $inertia and $inertia->transcripts->[$index] and $inertia->transcripts->[$index]->analysis ) {
			my ($result) = $inertia->transcripts->[$index];
			if ( $result->analysis->inertia ) {
				my ($method) = $result->analysis->inertia;
				if (defined $method) {
					$analysis->inertia($method);
					$analysis->number($analysis->number+1);
				}
			}			
		}
		# get cexonic
		if ( $cexonic and $cexonic->transcripts->[$index] and $cexonic->transcripts->[$index]->analysis ) {
			my ($result) = $cexonic->transcripts->[$index];
			if ( $result->analysis->cexonic ) {
				my ($method) = $result->analysis->cexonic;
				if (defined $method) {
					$analysis->cexonic($method);
					$analysis->number($analysis->number+1);
				}
			}			
		}
		# get thump
		if ( $thump and $thump->transcripts->[$index] and $thump->transcripts->[$index]->analysis ) {
			my ($result) = $thump->transcripts->[$index];
			if ( $result->analysis->thump ) {
				my ($method) = $result->analysis->thump;
				if (defined $method) {
					$analysis->thump($method);
					$analysis->number($analysis->number+1);
				}
			}			
		}		
		# get crash
		if ( $crash and $crash->transcripts->[$index] and $crash->transcripts->[$index]->analysis ) {
			my ($result) = $crash->transcripts->[$index];
			if ( $result->analysis->crash ) {
				my ($method) = $result->analysis->crash;
				if (defined $method) {
					$analysis->crash($method);
					$analysis->number($analysis->number+1);
				}
			}			
		}
						
		# create object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $transcript_id,
		);
		$transcript->analysis($analysis) if (defined $analysis);
		push(@{$transcripts}, $transcript);
		$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts		
	}
	
	# get the results for gene
	my ($analysis2) = APPRIS::Analysis->new();
	
	# get firestar
	if ( $firestar and $firestar->analysis and $firestar->analysis->firestar ) {
		my ($method2) = $firestar->analysis->firestar;
		if (defined $method2) {
			$analysis2->firestar($method2);
			$analysis2->number($analysis2->number+1);
		}			
	}
	# get matador3d
	if ( $matador3d and $matador3d->analysis and $matador3d->analysis->matador3d ) {
		my ($method2) = $matador3d->analysis->matador3d;
		if (defined $method2) {
			$analysis2->matador3d($method2);
			$analysis2->number($analysis2->number+1);
		}
	}
	# get corsair
	if ( $corsair and $corsair->analysis and $corsair->analysis->corsair ) {
		my ($method2) = $corsair->analysis->corsair;
		if (defined $method2) {
			$analysis2->corsair($method2);
			$analysis2->number($analysis2->number+1);
		}
	}	
	# get spade
	if ( $spade and $spade->analysis and $spade->analysis->spade ) {
		my ($method2) = $spade->analysis->spade;
		if (defined $method2) {
			$analysis2->spade($method2);
			$analysis2->number($analysis2->number+1);
		}
	}
	# get inertia
	if ( $inertia and $inertia->analysis and $inertia->analysis->inertia ) {
		my ($method2) = $inertia->analysis->inertia;
		if (defined $method2) {
			$analysis2->inertia($method2);
			$analysis2->number($analysis2->number+1);
		}
	}
	# get cexonic
	if ( $cexonic and $cexonic->analysis and $cexonic->analysis->cexonic ) {
		my ($method2) = $cexonic->analysis->cexonic;
		if (defined $method2) {
			$analysis2->cexonic($method2);
			$analysis2->number($analysis2->number+1);
		}
	}	
	# get thump
	if ( $thump and $thump->analysis and $thump->analysis->thump ) {
		my ($method2) = $thump->analysis->thump;
		if (defined $method2) {
			$analysis2->thump($method2);
			$analysis2->number($analysis2->number+1);
		}
	}
	# get crash
	if ( $crash and $crash->analysis and $crash->analysis->crash ) {
		my ($method2) = $crash->analysis->crash;
		if (defined $method2) {
			$analysis2->crash($method2);
			$analysis2->number($analysis2->number+1);
		}
	}
	
	# create object
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
	$entity->analysis($analysis2) if (defined $analysis2);	
	
	return $entity;	
}

=head2 parse_appris

  Arg [1]    : APPRIS::Gene $gene 
               APPRIS::Gene object
  Arg [2]    : string $result
               Parse appris result
  Arg [3]    : string $result2
               Parse appris result in detail
  Example    : use APPRIS::Parser qw(parse_appris);
               parse_appris($result,$result2);
  Description: Parse output of appris.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_appris($$$)
{
	my ($gene, $result, $result2) = @_;

	my ($stable_id) = $gene->stable_id;
	my ($cutoffs);
	my ($transcripts);
	my ($index_transcripts);
	my ($index) = 0;
	
	# Parse reliability result
	my (@results) = split("\n", $result);
	foreach my $transcript_result (@results)
	{
		next if ($transcript_result =~ /^#/); # skip the first line

		my (@rst) = split("\t", $transcript_result);

        # gene_id	transcript_id	translation	status	biotype	no_codons ccds_id (7)
        # fun_res_rscore
        # con_struct_rscore
        # vert_signal_rscore
        # dom_signal_rscore
        # u_evol_rscore
        # exon_signal_rscore
        # tmh_signal_rscore
        # pep_mit_rscore
        # score
        # prin_isoform_signal
        # reliability
      
		if ( scalar(@rst) == 18 ) {			
			my ($gene_id) = $rst[0];
			my ($transcript_id) = $rst[1];
			my ($translation) = $rst[2];
			my ($status) = $rst[3];
			my ($biotype) = $rst[4];
			my ($no_codons) = $rst[5];
			my ($ccds_id) = $rst[6];

			my ($fun_res_rscore) = $rst[7];			
			my ($con_struct_rscore) = $rst[8];
			my ($vert_con_rscore) = $rst[9];
			my ($dom_rscore) = $rst[10];
			my ($u_evol_rscore) = $rst[11];
			my ($exon_con_rscore) = $rst[12];
			my ($tmh_rscore) = $rst[13];
			my ($pep_mit_rscore) = $rst[14];
			my ($prin_isoform_rscore) = $rst[15];		
			my ($prin_isoform_signal) = $rst[16];
			my ($reliability) = $rst[17];

			$cutoffs->{$transcript_id}->{'functional_residues_rscore'} = $fun_res_rscore;
			$cutoffs->{$transcript_id}->{'homologous_structure_rscore'} = $con_struct_rscore;
			$cutoffs->{$transcript_id}->{'vertebrate_conservation_rscore'} = $vert_con_rscore;
			$cutoffs->{$transcript_id}->{'domain_rscore'} = $dom_rscore;			
			$cutoffs->{$transcript_id}->{'unusual_evolution_rscore'} = $u_evol_rscore;
			$cutoffs->{$transcript_id}->{'exon_conservation_rscore'} = $exon_con_rscore;
			$cutoffs->{$transcript_id}->{'transmembrane_helices_rscore'} = $tmh_rscore;
			$cutoffs->{$transcript_id}->{'peptide_mitochondrial_rscore'} = $pep_mit_rscore;
			$cutoffs->{$transcript_id}->{'principal_isoform_rscore'} = $prin_isoform_rscore;
			$cutoffs->{$transcript_id}->{'principal_isoform_signal'} = $prin_isoform_signal;
			$cutoffs->{$transcript_id}->{'reliability'} = $reliability;

			$cutoffs->{$transcript_id}->{'result'} = $transcript_result;			
		}
	}	
	$result =~ s/^#[^\n]*\n+//g; # delete the comment line to be homogenous
	$cutoffs->{'result'} = $result;

	# Parse result in detail
	my (@results2) = split("\n", $result2);
	foreach my $transcript_result2 (@results2)
	{
		next if ($transcript_result2 =~ /^#/); # skip the first line

		my (@rst2) = split("\t", $transcript_result2);

        # gene_id	transcript_id	translation	status	biotype	no_codons ccds_id (7)
        # fun_res[score]
        # con_struct[score]
        # vert_signal[score]
        # dom_signal[score]
        # u_evol[score]
        # exon_signal[score]
        # tmh_signal[score]
        # pep_signal[score]
        # mit_signal[score]
        # prin_isoform[score]
        
        if ( scalar(@rst2) == 17 ) {
			my ($gene_id) = $rst2[0];
			my ($transcript_id) = $rst2[1];
			my ($translation) = $rst2[2];
			my ($status) = $rst2[3];
			my ($biotype) = $rst2[4];
			my ($no_codons) = $rst2[5];
			my ($ccds_id) = $rst2[6];

			my ($fun_res_annot) = $rst2[7];			
			my ($con_struct_annot) = $rst2[8];
			my ($vert_con_annot) = $rst2[9];
			my ($dom_annot) = $rst2[10];
			my ($u_evol_annot) = $rst2[11];
			my ($exon_con_annot) = $rst2[12];
			my ($tmh_annot) = $rst2[13];
			my ($pep_annot) = $rst2[14];
			my ($mit_annot) = $rst2[15];
			my ($prin_isoform_annot) = $rst2[16];
			
			my ($fun_res_signal,$fun_res_score);
			if ( $fun_res_annot =~ /([^\[]*)\[([^\]]*)\]/ ) {
				($fun_res_signal,$fun_res_score) = ($1,$2);
			}
			my ($con_struct_signal,$con_struct_score);
			if ( $con_struct_annot =~ /([^\[]*)\[([^\]]*)\]/ ) {
				($con_struct_signal,$con_struct_score) = ($1,$2);
			}
			my ($vert_con_signal,$vert_con_score);
			if ( $vert_con_annot =~ /([^\[]*)\[([^\]]*)\]/ ) {
				($vert_con_signal,$vert_con_score) = ($1,$2);
			}
			my ($dom_signal,$dom_score);
			if ( $dom_annot =~ /([^\[]*)\[([^\]]*)\]/ ) {
				($dom_signal,$dom_score) = ($1,$2);
			}
			my ($u_evol_signal,$u_evol_score);
			if ( $u_evol_annot =~ /([^\[]*)\[([^\]]*)\]/ ) {
				($u_evol_signal,$u_evol_score) = ($1,$2);
			}
			my ($exon_con_signal,$exon_con_score);
			if ( $exon_con_annot =~ /([^\[]*)\[([^\]]*)\]/ ) {
				($exon_con_signal,$exon_con_score) = ($1,$2);
			}
			my ($tmh_signal,$tmh_score);
			if ( $tmh_annot =~ /([^\[]*)\[([^\]]*)\]/ ) {
				($tmh_signal,$tmh_score) = ($1,$2);
			}
			my ($pep_signal,$pep_score);
			if ( $pep_annot =~ /([^\[]*)\[([^\]]*)\]/ ) {
				($pep_signal,$pep_score) = ($1,$2);
			}
			my ($mit_signal,$mit_score);
			if ( $mit_annot =~ /([^\[]*)\[([^\]]*)\]/ ) {
				($mit_signal,$mit_score) = ($1,$2);
			}
			$cutoffs->{$transcript_id}->{'functional_residues_signal'} = $fun_res_signal;
			$cutoffs->{$transcript_id}->{'homologous_structure_signal'} = $con_struct_signal;
			$cutoffs->{$transcript_id}->{'vertebrate_conservation_signal'} = $vert_con_signal;
			$cutoffs->{$transcript_id}->{'domain_signal'} = $dom_signal;			
			$cutoffs->{$transcript_id}->{'unusual_evolution_signal'} = $u_evol_signal;
			$cutoffs->{$transcript_id}->{'exon_conservation_signal'} = $exon_con_signal;
			$cutoffs->{$transcript_id}->{'transmembrane_helices_signal'} = $tmh_signal;
			$cutoffs->{$transcript_id}->{'peptide_signal'} = $pep_signal;
			$cutoffs->{$transcript_id}->{'mitochondrial_signal'} = $mit_signal;
			
			$cutoffs->{$transcript_id}->{'functional_residues_score'} = $fun_res_score;
			$cutoffs->{$transcript_id}->{'homologous_structure_score'} = $con_struct_score;
			$cutoffs->{$transcript_id}->{'vertebrate_conservation_score'} = $vert_con_score;
			$cutoffs->{$transcript_id}->{'domain_score'} = $dom_score;			
			$cutoffs->{$transcript_id}->{'unusual_evolution_score'} = $u_evol_score;
			$cutoffs->{$transcript_id}->{'exon_conservation_score'} = $exon_con_score;
			$cutoffs->{$transcript_id}->{'transmembrane_helices_score'} = $tmh_score;
			$cutoffs->{$transcript_id}->{'peptide_score'} = $pep_score;
			$cutoffs->{$transcript_id}->{'mitochondrial_score'} = $mit_score;
			
			# join transcript results
			if ( exists $cutoffs->{$transcript_id}->{'result'} and 
				defined $cutoffs->{$transcript_id}->{'result'} and 
				$cutoffs->{$transcript_id}->{'result'} ne '') {
					$cutoffs->{$transcript_id}->{'result'} .= "\n#------------------\n";
					$cutoffs->{$transcript_id}->{'result'} .= $transcript_result2;
			}
        }
	}
	$result2 =~ s/^#[^\n]*\n+//g; # delete the comment line to be homogenous
	# join results
	if ( exists $cutoffs->{'result'} and defined $result2 and $result2 ne '') {
		$cutoffs->{'result'} .= "\n#------------------\n";
		$cutoffs->{'result'} .= $result2;
	}
	
	# Create APPRIS object
	foreach my $transcript (@{$gene->transcripts}) {			
		my ($transcript_id) = $transcript->stable_id;
		my ($analysis);
		
		# create method object
		if ( exists $cutoffs->{$transcript_id} ) {
			my ($report) = $cutoffs->{$transcript_id};
						
			# create Analysis object (for trans)			
			my ($method) = APPRIS::Analysis::APPRIS->new (
							-result								=> $report->{'result'},
							-functional_residues_signal			=> $report->{'functional_residues_signal'},
							-homologous_structure_signal		=> $report->{'homologous_structure_signal'},
							-vertebrate_conservation_signal		=> $report->{'vertebrate_conservation_signal'},
							-domain_signal						=> $report->{'domain_signal'},
							-unusual_evolution_signal			=> $report->{'unusual_evolution_signal'},
							-exon_conservation_signal			=> $report->{'exon_conservation_signal'},
							-transmembrane_helices_signal		=> $report->{'transmembrane_helices_signal'},
							-peptide_signal						=> $report->{'peptide_signal'},
							-mitochondrial_signal				=> $report->{'mitochondrial_signal'},
							-principal_isoform_signal			=> $report->{'principal_isoform_signal'},

							-functional_residues_rscore			=> $report->{'functional_residues_rscore'},						
							-homologous_structure_rscore		=> $report->{'homologous_structure_rscore'},
							-vertebrate_conservation_rscore		=> $report->{'vertebrate_conservation_rscore'},
							-domain_rscore						=> $report->{'domain_rscore'},						
							-unusual_evolution_rscore			=> $report->{'unusual_evolution_rscore'},						
							-exon_conservation_rscore			=> $report->{'exon_conservation_rscore'},		
							-transmembrane_helices_rscore		=> $report->{'transmembrane_helices_rscore'},						
							-peptide_mitochondrial_rscore		=> $report->{'peptide_mitochondrial_rscore'},
							-principal_isoform_rscore			=> $report->{'principal_isoform_rscore'},
							-reliability						=> $report->{'reliability'},
							
							-functional_residues_score			=> $report->{'functional_residues_score'},
							-homologous_structure_score			=> $report->{'homologous_structure_score'},
							-vertebrate_conservation_score		=> $report->{'vertebrate_conservation_score'},
							-domain_score						=> $report->{'domain_score'},
							-unusual_evolution_score			=> $report->{'unusual_evolution_score'},
							-exon_conservation_score			=> $report->{'exon_conservation_score'},
							-transmembrane_helices_score		=> $report->{'transmembrane_helices_score'},
							-peptide_score						=> $report->{'peptide_score'},
							-mitochondrial_score				=> $report->{'mitochondrial_score'},
			);
			$analysis = APPRIS::Analysis->new();
			if (defined $method) {
				$analysis->appris($method);
				$analysis->number($analysis->number+1);
			}			
		}
				
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $transcript_id,
		);
		$transcript->analysis($analysis) if (defined $analysis);
		push(@{$transcripts}, $transcript);
		$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts
	}

	# create Analysis object (for gene)
	my ($method2) = APPRIS::Analysis::APPRIS->new( -result => $cutoffs->{'result'} );	
	my ($analysis2) = APPRIS::Analysis->new();
	if (defined $method2) {
		$analysis2->appris($method2);
		$analysis2->number($analysis2->number+1);
	}
	
	# create Gene object
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts, $index_transcripts) if (defined $transcripts and defined $index_transcripts);
	$entity->analysis($analysis2) if (defined $analysis2);	

	return $entity;
}


# *********************** #
# *** PRIVATE METHODS *** #
# *********************** #

# Get the id and the version from Ensembl identifiers
sub _get_id_version($)
{
	my ($i_id) = @_;
	my ($id, $version) = (undef,undef);
	
	if ( $i_id =~ /^([^\.]*)\.(\d*)$/ ) {
		#($id, $version) = ($1, $2); # gencode7-gencode12 version
		($id, $version) = ($i_id, $2); # gencode15 version
	}
	return ($id, $version);
		
} # End _get_id_version

# Parse GFT file of gencode
sub _parse_gencode_data($)
{
	my ($file) = @_;
	my ($data);	
	return $data unless (-e $file and (-s $file > 0) );
	
	open (GENCONDE_FILE, $file) or throw('Can not open file');
	while ( my $line = <GENCONDE_FILE> )
	{
		#ignore header
		next if ( $line =~ /^##/ );

		my ($chr,$source,$type,$start,$end,$score,$strand,$phase,$attributes) = split("\t", $line);
		next unless(defined $chr and 
					defined $source and
					defined $type and
					defined $start and
					defined $end and
					defined $score and
					defined $strand and
					defined $phase and 
					defined $attributes);

		#store nine columns in hash
		my ($fields) = {
				chr        => $chr,
				source     => $source,
				type       => $type,
				start      => $start,
				end        => $end,
				score      => $score,
				strand     => $strand,
				phase      => $phase,
				attributes => $attributes,
		};
		if(defined $chr and $chr=~/chr(\w*)/)
		{
			$chr = $1 if(defined $1);
		}
		
		#store ids and additional information in second hash
		my ($attribs);
		my (@add_attributes) = split(";", $attributes);				
		for ( my $i=0; $i<scalar @add_attributes; $i++ )
		{
			$add_attributes[$i] =~ /^(.+)\s(.+)$/;
			my ($c_type) = $1;
			my ($c_value) = $2;
			if(	defined $c_type and !($c_type=~/^\s*$/) and
				defined $c_value and !($c_value=~/^\s*$/))
			{
				$c_type =~ s/^\s//;
				$c_value =~ s/"//g;
				if(!exists($attribs->{$c_type}))
				{
					$attribs->{$c_type} = $c_value;
				}
			}
		}

		# Always we have Gene Id
		if(	exists $attribs->{'gene_id'} 		and defined $attribs->{'gene_id'} and
			exists $attribs->{'transcript_id'}	and defined $attribs->{'transcript_id'} )
		{
			my ($gene_id, $gene_version) = _get_id_version($attribs->{'gene_id'});
			my ($transcript_id, $trans_version) = _get_id_version($attribs->{'transcript_id'});

			if (defined $gene_id and defined $transcript_id and ($type eq 'gene') ) # Gene Information
			{
				$data->{$gene_id}->{'chr'} = $chr if(defined $chr);			
				$data->{$gene_id}->{'start'} = $start if(defined $start);
				$data->{$gene_id}->{'end'} = $end if(defined $end);
				$data->{$gene_id}->{'strand'} = $strand if(defined $strand);

				if ( defined $source and
					($source eq $APPRIS::Utils::Constant::HAVANA_SOURCE or $source eq $APPRIS::Utils::Constant::ENSEMBL_SOURCE) )
				{
					$data->{$gene_id}->{'source'} = $source; 					
				}
				if(exists $attribs->{'gene_status'} and defined $attribs->{'gene_status'})
				{
					$data->{$gene_id}->{'status'} = $attribs->{'gene_status'};	
				}			
				if(exists $attribs->{'gene_type'} and defined $attribs->{'gene_type'})
				{
					$data->{$gene_id}->{'biotype'} = $attribs->{'gene_type'};	
				}
				if(exists $attribs->{'gene_name'} and defined $attribs->{'gene_name'})
				{
					$data->{$gene_id}->{'external_id'} = $attribs->{'gene_name'};	
				}
				if(exists $attribs->{'havana_gene'} and defined $attribs->{'havana_gene'})
				{
					$data->{$gene_id}->{'havana_gene'} = $attribs->{'havana_gene'};	
				}
				if(exists $attribs->{'level'} and defined $attribs->{'level'})
				{
					$data->{$gene_id}->{'level'} = $attribs->{'level'};	
				}
				if (defined $gene_version)
				{
					$data->{$gene_id}->{'version'} = $gene_version;
				}
			}
			elsif (defined $gene_id and defined $transcript_id and ($type eq 'transcript') ) # Transcript Information
			{
				my ($transcript);
				$transcript->{'chr'} = $chr if(defined $chr);
				$transcript->{'start'} = $start if(defined $start);
				$transcript->{'end'} = $end if(defined $end);
				$transcript->{'strand'} = $strand if(defined $strand);					

				if ( defined $source and
					($source eq $APPRIS::Utils::Constant::HAVANA_SOURCE or $source eq $APPRIS::Utils::Constant::ENSEMBL_SOURCE) )
				{
					$transcript->{'source'} = $source;
				}
				if(exists $attribs->{'transcript_status'} and defined $attribs->{'transcript_status'})
				{
					$transcript->{'status'} = $attribs->{'transcript_status'};	
				}			
				if(exists $attribs->{'transcript_type'} and defined $attribs->{'transcript_type'})
				{
					$transcript->{'biotype'} = $attribs->{'transcript_type'};	
				}
				if(exists $attribs->{'transcript_name'} and defined $attribs->{'transcript_name'})
				{
					$transcript->{'external_id'} = $attribs->{'transcript_name'};	
				}
				if(exists $attribs->{'havana_transcript'} and defined $attribs->{'havana_transcript'})
				{
					$transcript->{'havana_transcript'} = $attribs->{'havana_transcript'};	
				}
				if(exists $attribs->{'level'} and defined $attribs->{'level'})
				{
					$transcript->{'level'} = $attribs->{'level'};	
				}
				if (defined $trans_version)
				{
					$transcript->{'version'} = $trans_version;
				}
				if(exists $attribs->{'ccdsid'} and defined $attribs->{'ccdsid'})
				{
					$transcript->{'ccdsid'} = $attribs->{'ccdsid'};	
				}
					
				$data->{$gene_id}->{'transcripts'}->{$transcript_id} = $transcript if(defined $transcript);
			}
			elsif (defined $gene_id and defined $transcript_id and ($type eq 'exon') ) # Exon Information
			{
				my ($exon);
				$exon->{'start'} = $start if(defined $start);
				$exon->{'end'} = $end if(defined $end);
				$exon->{'strand'} = $strand if(defined $strand);
						
				push(@{$data->{$gene_id}->{'transcripts'}->{$transcript_id}->{'exons'}},$exon);
			}			
			elsif (defined $gene_id and defined $transcript_id and ($type eq 'CDS') ) # CDS Information
			{
				my ($cds);
				$cds->{'start'} = $start if(defined $start);
				$cds->{'end'} = $end if(defined $end);
				$cds->{'strand'} = $strand if(defined $strand);
				$cds->{'phase'} = $phase if(defined $phase);
				
				push(@{$data->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds'}},$cds);
			}
			elsif (defined $gene_id and defined $transcript_id and ($type eq 'start_codon') ) # Codon Information
			{
				my ($codon);
				$codon->{'type'}='start';
				$codon->{'start'} = $start if(defined $start);
				$codon->{'end'} = $end if(defined $end);
				$codon->{'strand'} = $strand if(defined $strand);
				$codon->{'phase'} = $phase if(defined $phase);
				
				push(@{$data->{$gene_id}->{'transcripts'}->{$transcript_id}->{'codons'}},$codon) if(defined $codon);
			}
			elsif (defined $gene_id and defined $transcript_id and ($type eq 'stop_codon') ) # Codon Information
			{
				my ($codon);
				$codon->{'type'}='stop';
				$codon->{'start'} = $start if(defined $start);
				$codon->{'end'} = $end if(defined $end);
				$codon->{'strand'} = $strand if(defined $strand);
				$codon->{'phase'} = $phase if(defined $phase);
				
				push(@{$data->{$gene_id}->{'transcripts'}->{$transcript_id}->{'codons'}},$codon) if(defined $codon);
			}
			$data->{$gene_id}->{'raw'} .= $line; # Save Raw Data
		}
		else
		{
			throw('Wrong entity');
		}
	}
	close(GENCONDE_FILE);
	
	return $data;
	
} # End _parse_gencode_data

sub _parse_gencode_sequence($)
{
	my ($file) = @_;
	my ($data);

	if (-e $file and (-s $file > 0) ) {
		my ($in) = Bio::SeqIO->new(
							-file => $file,
							-format => 'Fasta'
		);
		while ( my $seq = $in->next_seq() )
		{
			if ( $seq->id=~/([^|]*)/ )
			{
				my ($sequence_id) = $1;
				#$sequence_id =~ s/\.\d*$//; # delete suffix (gencode7-gencode12)
				if(exists $data->{$sequence_id}) {
					throw("Duplicated sequence: $sequence_id");
				}
				else {
					my ($sequence) = $seq->seq; # control short sequences
					my ($seq_len) = length($sequence);
					if ( $seq_len > 2 ) {
						$data->{$sequence_id} = $seq->seq;						
					}
					else {
						warning("Short sequence: $sequence_id");
					}
				}
			}
		}		
	}
	return $data;
	
} # End _parse_gencode_sequence

# Create APPRIS::Transcript object from gencode data (GTF)
sub _fetch_transc_objects($$$;$;$)
{
	my ($registry, $gene_id, $gene_features, $transc_seq, $transl_seq) = @_;
	my ($transcripts);
	my ($index_transcripts);
	my ($index) = 0;	
	
	# Scan transcripts
	while (my ($transcript_id, $transcript_features) = each(%{$gene_features}) )
	{
		my ($xref_identities);
		my ($sequence);
		my ($exons);

		# Create transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $transcript_id,
			-chr		=> $transcript_features->{'chr'},
			-start		=> $transcript_features->{'start'},
			-end		=> $transcript_features->{'end'},
			-strand		=> $transcript_features->{'strand'},
			-biotype	=> $transcript_features->{'biotype'},
			-status		=> $transcript_features->{'status'},
			-source		=> $transcript_features->{'source'},
			-level		=> $transcript_features->{'level'},
			-version	=> $transcript_features->{'version'}
		);
			
		# Xref identifiers
		if ( defined $gene_id ) {
			push(@{$xref_identities},
					APPRIS::XrefEntry->new
					(
						-id				=> $gene_id,
						-dbname			=> 'Ensembl_Gene_Id'
					)
			);
		}
		if ( exists $transcript_features->{'external_id'} and defined $transcript_features->{'external_id'} ) {
			$transcript->external_name($transcript_features->{'external_id'}); 
			push(@{$xref_identities},
					APPRIS::XrefEntry->new
					(
						-id				=> $transcript_features->{'external_id'},
						-dbname			=> 'External_Id'
					)
			);
		}
		if ( exists $transcript_features->{'havana_transcript'} and defined $transcript_features->{'havana_transcript'} ) {
			push(@{$xref_identities},
					APPRIS::XrefEntry->new
					(
						-id				=> $transcript_features->{'havana_transcript'},
						-dbname			=> 'Havana_Transcript_Id'
					)
			);
		}
		if ( exists $transcript_features->{'ccdsid'} and defined $transcript_features->{'ccdsid'} ) {
			push(@{$xref_identities},
					APPRIS::XrefEntry->new
					(
						-id				=> $transcript_features->{'ccdsid'},
						-dbname			=> 'CCDS'
					)
			);
		}				

		# Add description From Ensembl 
		my ($trans_xref) = get_xref_identifiers($registry, $transcript_id);
		if ( exists $trans_xref->{'description'} and defined $trans_xref->{'description'}) {
			$transcript->description($trans_xref->{'description'});
		}			
		
		# Get transcript sequence
		if ( defined $transc_seq and
			 exists $transc_seq->{$transcript_id} and defined $transc_seq->{$transcript_id} ) {
				$sequence = $transc_seq->{$transcript_id};
		}
			
		# Get exon ids from ensembl
		if ( exists $transcript_features->{'exons'} and scalar(@{$transcript_features->{'exons'}} > 0) )
		{
			my ($aux_exons);
			my ($ensembl_exon_list) = get_exons($registry, $transcript_id);
			foreach my $exon (@{$transcript_features->{'exons'}})
			{
				my ($exon_id);
				foreach my $e_exon (@{$ensembl_exon_list}) { # get id from ensembl
					if ( ($exon->{'start'} == $e_exon->{'start'}) and ($exon->{'end'} == $e_exon->{'end'}) ) {
						$exon_id = $e_exon->{'id'};
					}
				}
				push(@{$aux_exons},
					APPRIS::Exon->new
					(
						-stable_id	=> $exon_id,
						-start		=> $exon->{'start'},
						-end		=> $exon->{'end'},
						-strand		=> $exon->{'strand'},
					)
				);
			}
			$exons = sort_cds($aux_exons, $transcript_features->{'strand'}); # sort exons
		}

		# Add translation
		my ($translate) = _fetch_transl_objects($registry, $transcript_id, $transcript_features, $transl_seq);
		
		
		$transcript->xref_identify($xref_identities) if (defined $xref_identities);
		$transcript->sequence($sequence) if (defined $sequence);
		$transcript->exons($exons) if (defined $exons);
		$transcript->translate($translate) if (defined $translate);
			
		push(@{$transcripts}, $transcript) if (defined $transcript);
		$index_transcripts->{$transcript_id} = $index; $index++; # Index the list of transcripts		
	}
	return ($transcripts,$index_transcripts);
	
} # End _fetch_transc_objects

# Create APPRIS::Translation object from gencode data
sub _fetch_transl_objects($$$;$)
{
	my ($registry, $transcript_id, $transcript_features, $transl_seq) = @_;
	my ($translate);
	my ($sequence);
	my ($cds);
	my ($codons);	

	# Get translate sequence
	if ( defined $transl_seq and
		 exists $transl_seq->{$transcript_id} and defined $transl_seq->{$transcript_id} ) {
			$sequence = $transl_seq->{$transcript_id};
	}

	# Get cds
	if ( exists $transcript_features->{'cds'} and scalar(@{$transcript_features->{'cds'}} > 0) )
	{
		my ($aux_cds);
		foreach my $cds (@{$transcript_features->{'cds'}})
		{
			push(@{$aux_cds},
				APPRIS::CDS->new
				(
					-start		=> $cds->{'start'},
					-end		=> $cds->{'end'},
					-strand		=> $cds->{'strand'},
					-phase		=> $cds->{'phase'},
				)
			);
		}
		$cds = sort_cds($aux_cds, $transcript_features->{'strand'}); # sort exons
	}	

	# Get codons
	if ( exists $transcript_features->{'codons'} and scalar(@{$transcript_features->{'codons'}} > 0) )
	{
		foreach my $codon (@{$transcript_features->{'codons'}})
		{
			push(@{$codons},
				APPRIS::Codon->new
				(
					-type		=> $codon->{'type'},
					-start		=> $codon->{'start'},
					-end		=> $codon->{'end'},
					-strand		=> $codon->{'strand'},
					-phase		=> $codon->{'phase'},
				)
			);
		}
	}
	
	if ( defined $sequence ) {
		
		# Create object
		$translate = APPRIS::Translation->new
		(
			-stable_id	=> $transcript_id,
		);		
	
		# From Ensembl:
		my ($trans_xref) = get_xref_identifiers($registry, $transcript_id);
		if ( exists $trans_xref->{'description'} and defined $trans_xref->{'description'}) { # add description
			$translate->description($trans_xref->{'description'});
		}
		if ( exists $trans_xref->{'peptide_id'} and defined $trans_xref->{'peptide_id'}) { # add description
			$translate->stable_id($trans_xref->{'peptide_id'});
		}
			
		$translate->sequence($sequence);
		$translate->cds($cds) if (defined $cds);
		$translate->codons($codons) if (defined $codons);
		$translate->cds_sequence($translate);	
	}
	
	return $translate;
	
} # End _fetch_transl_objects

# Parser result file of INERTIA method
sub _parse_inertia_file($$\$)
{
	my ($type, $result, $ref_cutoffs) = @_;

	my ($transcript_id);	
	my (@results) = split( '\n', $result);
	
	foreach my $line (@results)
	{
		next if( $line =~ /^#/ ); # Skip comment line
		$line.="\n"; # Due we are spliting by '\n'
		
		if ( $line =~ /^>([^\t]+)\t+([^\n]+)\n+$/ )
		{
			$transcript_id = $1;
			my ($unusual_evolution) = $2;

			${$ref_cutoffs}->{$transcript_id}->{$type}->{'unusual_evolution'} = $unusual_evolution;			
			unless ( exists ${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} ) {
				${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} = $line;
			} else {
				${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} .= $line;
			}			
		}		
		elsif ( defined $transcript_id and ($line =~ /^\t+([^\:]+)\:([^\_]+)\:([^\t]+)\t([^\n]+)\n+$/) )
		{
			my ($start) = $1;
			my ($end) = $2;
			my ($strand) = $3;
			my ($exon_annotation) = $4;
		
			my ($exon_report) = {
							'start'					=> $start,
							'end'					=> $end,
							'strand'				=> $strand,
							'unusual_evolution'		=> $exon_annotation						
			};
			push( @{${$ref_cutoffs}->{$transcript_id}->{$type}->{'residues'}}, $exon_report );
			${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} .= $line;
		}		
	}	
} # End _parse_inertia_file

# Parser result file of Omega-INERTIA
sub _parse_omega_file($$\$)
{
	my ($type, $result, $ref_cutoffs) = @_;

	my (@results) = split( '\n', $result);
	
	foreach my $line (@results)
	{
		next if( $line =~/^#/ ); # Skip comment line
		$line.="\n"; # Due we are spliting by '\n'
				
		# omega_average omega_exon_id   start_exon      end_exon        strand_exon     difference_value        p_value st_desviation   exon_annotation transcript_list
		if ( $line =~ /^([^\t]+)\t+([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\n]+)\n+$/ )
		{
			my ($omega_mean) = $1;
			my ($omega_exon_id) = $2;
			my ($start) = $3;
			my ($end) = $4;
			my ($strand) = $5;
			my ($d_value) = $6;
			my ($p_value) = $7;
			my ($st_desviation) = $8;
			my ($exon_annotation) = $9;
			my ($exon_transcrits_list) = $10;
		
			# Get the trasncipt with omega exons
			my (@exon_transcrits);
			if ( $exon_transcrits_list ne 'NULL' ) {
				@exon_transcrits = split(';',$exon_transcrits_list);			
			}
			
			foreach my $transcript_id (@exon_transcrits)
			{
				my ($omega_exon_report) = {
							'omega_exon_id'			=> $omega_exon_id,
							'start'					=> $start,
							'end'					=> $end,
							'strand'				=> $strand,
							'omega_mean'			=> $omega_mean,
							'st_deviation'			=> $st_desviation,
							'difference_value'		=> $d_value,
							'p_value'				=> $p_value,
							'unusual_evolution'		=> $exon_annotation						
				};
				push( @{${$ref_cutoffs}->{$transcript_id}->{$type}->{'residues'}}, $omega_exon_report );
				unless ( exists ${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} ) {
					${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} = $line;
				} else {
					${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} .= $line;
				}
			}
		}

		# # omega_average omega_exon_id   start_exon      end_exon        difference_value        p_value st_desviation   exon_annotation transcript_list
		if ( $line =~ /^>([^\t]+)\t+([^\n]+)\n+$/ )
		{
			my ($transcript_id) = $1;
			my ($unusual_evolution) = $2;

			${$ref_cutoffs}->{$transcript_id}->{$type}->{'unusual_evolution'} = $unusual_evolution;			
			${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} .= "----------------------------------------------------------------------\n";
			${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} .= $line;

			${$ref_cutoffs}->{$transcript_id}->{$type}->{'omega_average'} = 0; # DEPRECATED
			${$ref_cutoffs}->{$transcript_id}->{$type}->{'omega_st_desviation'} = 0; # DEPRECATED			
		}		
	}
} # End _parse_omega_file

1;