# _________________________________________________________________
# $Id$
# $Revision$
# Developed by:
#       Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________
package Export::BED;

use strict;
use warnings;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/..";
require Constant;
require CDS;
#use Constant;
#use CDS;


###################
# Global variable #
###################
use vars qw($BED_TRACKS);

$BED_TRACKS=[
	# APPRIS
	[
		{
			'title' => "track name=Principal_Isoform description='Principal isoform' visibility=2 color='0,0,0' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Principal_Isoform_Vertebrate_Conservation description='Principal isoforms (Vertebrate conservation)' visibility=2 color='0,0,0' group='0'",
			'body' => '' 
		}
	],
	# Firestar
	{
			'title' => "track name=Functional_Residue description='Functional residues' visibility=2 color='210,145,35' group='0'",
			'body' => '' 
	},		
	# Matador3D
	{
			'title' => "track name=Homologous_Structure description='Homologous structures' visibility=2 color='198,8,6' group='0'",
			'body' => '' 
	},		
	# SPADE
	[
		{
			'title' => "track name=Whole_Domain description='Whole domains' visibility=2 color='118,156,2' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Slightly_Damaged_Pfam_Domain description='Slightly damaged pfam domains' visibility=2 color='118,156,2' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Damaged_Pfam_Domain description='Damaged pfam domains' visibility=2 color='118,156,2' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Wrong_Pfam_Domain description='Wrong pfam domains' visibility=2 color='118,156,2' group='0'",
			'body' => '' 
		}
	],
	# INERTIA
	[
		{
			'title' => "track name=Neutral_Evolution_Exon description='Neutral evolution of exons' visibility=2 color='0,64,128' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Unusual_Evolution_Exon description='Unusual evolution of exons' visibility=2 color='0,64,128' group='0'",
			'body' => '' 
		}
	],
	# CRASH
	[
		{
			'title' => "track name=Signal_Sequence description='Signal Peptide Sequences' visibility=2 color='117,91,45' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Mitochondrial_Signal_Sequence description='Mitochondrial Signal Sequences' visibility=2 color='117,91,45' group='0'",
			'body' => '' 
		}
	],
	# THUMP
	[
		{
			'title' => "track name=Transmembrane_Helix description='Transmembrane Helices' visibility=2 color='0,65,66' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Damaged_Transmembrane_Helix description='Damaged Transmembrane Helices' visibility=2 color='0,65,66' group='0'",
			'body' => '' 
		}
	],	
	# CExonic
	[
		{
			'title' => "track name=Exonic_Structure_Conserved_in_Mouse description='Exonic Structures Conserved in Mouse' visibility=2 color='122,92,159' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Exonic_Structure_Not_Conserved_in_Mouse description='Exonic Structures Not Conserved in Mouse' visibility=2 color='122,92,159' group='0'",
			'body' => '' 
		}
	],	
	# CORSAIR
	[
		{
			'title' => "track name=Vertebrate_Conservation description='Vertebrate Conservation' visibility=2 color='44,136,91' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Doubtful_Vertebrate_Conservation description='Doubtful Vertebrate Conservation' visibility=2 color='44,136,91' group='0'",
			'body' => '' 
		},
		# DISABLED
		#{
		#	'title' => "track name=No_Vertebrate_Conservation description='No Vertebrate Conservation' visibility=2 color='44,136,91' group='0'",
		#	'body' => '' 
		#}
		# DISABLED
	]
];


#####################
# Method prototypes #
#####################
sub getAnnotations($$);
sub printData($);
sub printAnnotations($);
sub getAPPRISAnnotations($$$$\$);
sub getFirestarAnnotations($$$\$);
sub getMatador3DAnnotations($$$\$);
sub getSPADEAnnotations($$$$);
sub _auxSPADEAnnotations($$$$\$);
sub getInertiaAnnotations($$$$);
sub _auxINERTIAAnnotations($$$$\$);
sub getCRASHAnnotations($$$$\$);
sub getTHUMPAnnotations($$$$);
sub _auxTHUMPAnnotations($$$$\$);
sub getCExonicAnnotations($$$\$);
sub getCORSAIRAnnotations($$$\$);



#################
# Method bodies #
#################
sub getAnnotations($$)
{
	my($method,$chromosome_features)=@_;

	my($output_annotation)='';	

	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			my($principal_isoform_annotation)=DB::get_appris_annotations($transcript_id);
			next unless(defined $principal_isoform_annotation);

			if(defined $transcript_id and exists $transcript_features->{'peptide'} and defined $transcript_features->{'peptide'})
			{
				while(my($peptide_id, $peptide_features)=each(%{$transcript_features->{'peptide'}}))
				{
					if(exists $peptide_features->{'sequence'} and defined $peptide_features->{'sequence'})
					{
						if(		$method eq 'appris' and
								exists $principal_isoform_annotation->{'principal_isoform'} and
								defined $principal_isoform_annotation->{'principal_isoform'})
						{
							my($appris_annotation)=$principal_isoform_annotation->{'principal_isoform'};
							my($appris_source_annotation)='';
							$appris_source_annotation=$principal_isoform_annotation->{'source'} if(exists $principal_isoform_annotation->{'source'} and defined $principal_isoform_annotation->{'source'});
							getAPPRISAnnotations($transcript_id,$transcript_features,$appris_annotation,$appris_source_annotation,$BED_TRACKS->[0]);

						}
						elsif(	$method eq 'firestar' and
								exists $principal_isoform_annotation->{'functional_residue'} and
								defined $principal_isoform_annotation->{'functional_residue'})
						{
							my($appris_annotation)=$principal_isoform_annotation->{'functional_residue'};
							getFirestarAnnotations($transcript_id,$transcript_features,$appris_annotation,$BED_TRACKS->[1]);
						}
						elsif(	$method eq 'matador3d' and
								exists $principal_isoform_annotation->{'conservation_structure'} and
								defined $principal_isoform_annotation->{'conservation_structure'})
						{
							my($appris_annotation)=$principal_isoform_annotation->{'conservation_structure'};
							getMatador3DAnnotations($transcript_id,$transcript_features,$appris_annotation,$BED_TRACKS->[2]);
						}
						elsif(	$method eq 'spade' and
								exists $principal_isoform_annotation->{'domain_signal'} and
								defined $principal_isoform_annotation->{'domain_signal'})
						{
							my($appris_annotation)=$principal_isoform_annotation->{'domain_signal'};
							getSPADEAnnotations($transcript_id,$transcript_features,$appris_annotation,$BED_TRACKS->[3]);
						}
						elsif(	$method eq 'inertia' and
								exists $principal_isoform_annotation->{'unusual_evolution'} and
								defined $principal_isoform_annotation->{'unusual_evolution'})
						{
							my($appris_annotation)=$principal_isoform_annotation->{'unusual_evolution'};
							getInertiaAnnotations($transcript_id,$transcript_features,$appris_annotation,$BED_TRACKS->[4]);
						}
						elsif(	$method eq 'crash' and
								exists $principal_isoform_annotation->{'peptide_signal'} and
								defined $principal_isoform_annotation->{'peptide_signal'} and
								exists $principal_isoform_annotation->{'mitochondrial_signal'} and
								defined $principal_isoform_annotation->{'mitochondrial_signal'})
						{
							my($appris_annotation_signalp)=$principal_isoform_annotation->{'peptide_signal'};
							my($appris_annotation_targetp)=$principal_isoform_annotation->{'mitochondrial_signal'};
							getCRASHAnnotations($transcript_id,$transcript_features,$appris_annotation_signalp,$appris_annotation_targetp,$BED_TRACKS->[5]);
						}
						elsif(	$method eq 'thump' and
								exists $principal_isoform_annotation->{'transmembrane_signal'} and
								defined $principal_isoform_annotation->{'transmembrane_signal'})
						{
							my($appris_annotation)=$principal_isoform_annotation->{'transmembrane_signal'};
							getTHUMPAnnotations($transcript_id,$transcript_features,$appris_annotation,$BED_TRACKS->[6]);
						}
						elsif(	$method eq 'cexonic' and
								exists $principal_isoform_annotation->{'conservation_exon'} and
								defined $principal_isoform_annotation->{'conservation_exon'})
						{
							my($appris_annotation)=$principal_isoform_annotation->{'conservation_exon'};
							getCExonicAnnotations($transcript_id,$transcript_features,$appris_annotation,$BED_TRACKS->[7]);
						}
						elsif(	$method eq 'corsair' and
								exists $principal_isoform_annotation->{'vertebrate_signal'} and
								defined $principal_isoform_annotation->{'vertebrate_signal'})
						{
							my($appris_annotation)=$principal_isoform_annotation->{'vertebrate_signal'};
							getCORSAIRAnnotations($transcript_id,$transcript_features,$appris_annotation,$BED_TRACKS->[8]);
						}
					}
				}
			}
		}
	}
	return $BED_TRACKS;
		
} # End getAnnotations
#my($data)={
#		'chr'			=>
#		'start'			=>
#		'end'			=>
#		'name'			=>
#		'score'			=>
#		'strand'		=>
#		'thick_start'	=>
#		'thick_end'		=>
#		'color'			=>
#		'blocks'		=>
#		'block_sizes'	=>
#		'block_starts'	=>
#};
#
# Chromosome Start End Name Score Strand ThickStart ThickEnd Color Blocks BlockSizes BlockStarts
#
# The start values are -1 due to UCSC Genome browser prints bad
#		
sub printData($)
{
	my($data)=@_;
	
	my($output_annotation)='';

	$output_annotation.='chr'.$data->{'chr'}."\t".
						($data->{'start'}-1)."\t".
						$data->{'end'}."\t".
						$data->{'name'}."\t";

	if(	exists $data->{'score'} and defined $data->{'score'} and
		exists $data->{'strand'} and defined $data->{'strand'}
	){
		$output_annotation.=$data->{'score'}."\t".
							$data->{'strand'}."\t";
	}

	if(	exists $data->{'thick_start'} and defined $data->{'thick_start'} and
		exists $data->{'thick_end'} and defined $data->{'thick_end'} and
		exists $data->{'color'} and defined $data->{'color'} and
		exists $data->{'blocks'} and defined $data->{'blocks'}
	){
		$output_annotation.=($data->{'thick_start'}-1)."\t".
							$data->{'thick_end'}."\t".
							$data->{'color'}."\t".
							$data->{'blocks'}."\t";
	}
	if(exists $data->{'block_sizes'} and defined $data->{'block_sizes'})
	{
		my(@block_sizes)=@{$data->{'block_sizes'}};
		if($data->{'strand'} eq '-') {
			@block_sizes=reverse @{$data->{'block_sizes'}};
		}
		
		foreach my $size (@block_sizes)
		{
			$output_annotation.=$size.',';
		}
		$output_annotation=~s/,$/\t/;
	}

	if(exists $data->{'block_starts'} and defined $data->{'block_starts'})
	{
		my(@block_starts)=@{$data->{'block_starts'}};
		if($data->{'strand'} eq '-') {
			@block_starts=reverse @{$data->{'block_starts'}};
		}
		
		foreach my $start (@block_starts)
		{
			$output_annotation.=$start.',';
		}
		$output_annotation=~s/,$/\t/;
	}
	$output_annotation=~s/\t$/\n/;
	
	return $output_annotation;

} # End printData

sub printAnnotations($)
{
	my($report)=@_;
	
	my($output)='';
	
	foreach my $method_report (@{$report})	
	{
		if(ref($method_report) eq 'ARRAY')
		{
			foreach my $track_report (@{$method_report})
			{
				unless($track_report->{'body'} eq '')
				{
					$output.=$track_report->{'title'}."\n".$track_report->{'body'};				
				}
			}
		}
		elsif(ref($method_report) eq 'HASH')
		{
			unless($method_report->{'body'} eq '')
			{
				$output.=$method_report->{'title'}."\n".$method_report->{'body'};			
			}
		}
	}
	return $output;
	
} # End printAnnotations

sub getAPPRISAnnotations($$$$\$)
{
	my($transcript_id,$transcript_features,$annotation,$source_annotation,$ref_output)=@_;

	# Get the sorted Exons
	my($transcript_orientation)=$transcript_features->{'strand'};	
	my($sort_exon_list)=CDS::sort_exons($transcript_orientation,$transcript_features);
		
	if(	$annotation eq $Constant::OK_LABEL and 
		ref($sort_exon_list) eq 'ARRAY' and scalar(@{$sort_exon_list})>0
	){
		my($num_exons)=scalar(@{$sort_exon_list});
				
		# The starts and thick_start is the the first CDS coordinate.
		# The end and thick_end is the last CDS coordinate.
		my($sort_cds_list)=CDS::sort_cds($transcript_orientation,$transcript_features);
		my($thick_start)=$transcript_features->{'start'};
		my($thick_end)=$transcript_features->{'end'};
		if(ref($sort_cds_list) eq 'ARRAY' and scalar(@{$sort_cds_list})>0)
		{
			my($num_cds)=scalar(@{$sort_cds_list});
			if($transcript_orientation eq '-') 
			{
				$thick_start=$sort_cds_list->[$num_cds-1]->{'start'};
				$thick_end=$sort_cds_list->[0]->{'end'};
			}
			else
			{
				$thick_start=$sort_cds_list->[0]->{'start'}; 
				$thick_end=$sort_cds_list->[$num_cds-1]->{'end'};
			}			
		}
			
		my($data)={
				'chr'			=> $transcript_features->{'chr'},
				'name'			=> $transcript_id,
				'start'			=> $transcript_features->{'start'},
				'end'			=> $transcript_features->{'end'},
				'strand'		=> $transcript_features->{'strand'},
				'score'			=> 0,
				'thick_start'	=> $thick_start,
				'thick_end'		=> $thick_end,			
				'color'			=> 0,
				'blocks'		=> $num_exons
		};
		
		foreach my $exon (@{$sort_exon_list})
		{
			my($position)={
					'start'		=> $exon->{'start'},
					'end'		=> $exon->{'end'},
					'strand'	=> $exon->{'strand'}
			};
			my($block)=CDS::get_block_from_transcript($position,
																{
																	'start'	=> $data->{'start'},
																	'end'	=> $data->{'end'}
																});					
			push(@{$data->{'block_starts'}},$block->{'start'});
			push(@{$data->{'block_sizes'}},$block->{'size'});
		}		
		if($source_annotation eq 'vertebrate_signal')
		{
			${$ref_output}->[1]->{'body'}.=printData($data);								
		}
		else
		{
			${$ref_output}->[0]->{'body'}.=printData($data);								
		}
	}

} # End getAPPRISAnnotations

sub getFirestarAnnotations($$$\$)
{
	my($transcript_id,$transcript_features,$annotation,$ref_output)=@_;

	my($transcript_strand)=$transcript_features->{'strand'};
	my($method_residues_annotation)=DB::get_firestar_residues_annotations($transcript_id);

	if(ref($method_residues_annotation) eq 'ARRAY' and scalar(@{$method_residues_annotation})>0)
	{	
		# Get initial range of track
		my($transcript_start);
		my($transcript_end);
		my($score)=0;
		my($color)=0;
		
		my($num_residues)=scalar(@{$method_residues_annotation});		

		# The starts and thick_start is the the first residue. The end and thick_end is the last residue
		if($transcript_strand eq '-') 
		{
			$transcript_start=$method_residues_annotation->[$num_residues-1]->{'start'};
			$transcript_end=$method_residues_annotation->[0]->{'end'};
		}
		else
		{
			$transcript_start=$method_residues_annotation->[0]->{'start'}; 
			$transcript_end=$method_residues_annotation->[$num_residues-1]->{'end'};
		}
		
		my($data)={
				'chr'			=> $transcript_features->{'chr'},
				'name'			=> $transcript_id,
				'start'			=> $transcript_start, 
				'end'			=> $transcript_end,
				'strand'		=> $transcript_strand,
				'score'			=> $score,
				'thick_start'	=> $transcript_start, 
				'thick_end'		=> $transcript_end, 
				'color'			=> $color,
				'blocks'		=> 0
		};

		# Get Block Annotations
		foreach my $residue_annotation (@{$method_residues_annotation})
		{
			my($residue_position)={
					'start'		=> $residue_annotation->{'start'},
					'end'		=> $residue_annotation->{'end'},
					'strand'	=> $residue_annotation->{'strand'}
			};				

			my($contained_cds)=CDS::get_contained_cds($residue_position,$transcript_features);
			my(@sorted_contained_cds)=@{$contained_cds};

			for(my $i=0; $i<scalar(@sorted_contained_cds); $i++)
			{
				my($track_features)={
						'start'	=> $data->{'thick_start'},
						'end'	=> $data->{'thick_end'}
				};
				
				if(scalar(@sorted_contained_cds) == 1) # Within one CDS
				{
					my($block)=CDS::get_block_from_transcript($residue_position,$track_features);									
					push(@{$data->{'block_starts'}},$block->{'start'});
					push(@{$data->{'block_sizes'}},$block->{'size'});
					$data->{'blocks'}++;	
					last;
				}
				else # Within several CDS
				{
					my($cds_out)=$sorted_contained_cds[$i];
					my($position);					
					if($i==0)
					{
						if($transcript_strand eq '-')
						{
							$position->{'start'}=$cds_out->{'start'};
							$position->{'end'}=$residue_position->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};								
						}
						else
						{
							$position->{'start'}=$residue_position->{'start'};
							$position->{'end'}=$cds_out->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};							
						}
					}
					elsif($i==scalar(@sorted_contained_cds)-1)
					{
						if($transcript_strand eq '-')
						{
							$position->{'start'}=$residue_position->{'start'};
							$position->{'end'}=$cds_out->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};								
						}
						else
						{
							$position->{'start'}=$cds_out->{'start'};
							$position->{'end'}=$residue_position->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};							
						}
					}
					else
					{
						$position->{'start'}=$cds_out->{'start'};
						$position->{'end'}=$cds_out->{'end'};
						$position->{'strand'}=$cds_out->{'strand'};						
					}
							
					my($block)=CDS::get_block_from_transcript($position,$track_features);										
					push(@{$data->{'block_starts'}},$block->{'start'});
					push(@{$data->{'block_sizes'}},$block->{'size'});
					$data->{'blocks'}++;					
				}
			}
		}
		${$ref_output}->{'body'}.=printData($data);
	}

} # End getFirestarAnnotations

sub getMatador3DAnnotations($$$\$)
{
	my($transcript_id,$transcript_features,$annotation,$ref_output)=@_;

	my($transcript_strand)=$transcript_features->{'strand'};
	my($method_residues_annotation)=DB::get_matador3d_alignments_annotations($transcript_id);

	if(ref($method_residues_annotation) eq 'ARRAY' and scalar(@{$method_residues_annotation})>0)
	{
		# We print the residues with conservation
		my($aux_sorted_method_residues_annotation);
		foreach my $aux_method_residues_annotation (@{$method_residues_annotation}) {
			if($aux_method_residues_annotation->{'alignment_score'} != 0) {
				push(@{$aux_sorted_method_residues_annotation},$aux_method_residues_annotation)
			}
		}
		my(@sorted_method_residues_annotation)=();
		if(defined $aux_sorted_method_residues_annotation)
		{ @sorted_method_residues_annotation = @{$aux_sorted_method_residues_annotation} }
		
		if(scalar(@sorted_method_residues_annotation)>0)
		{
			my($transcript_start);
			my($transcript_end);
			my($score)=0;
			my($color)=0;

			# The starts and thick_start is the the first residue. The end and thick_end is the last residue
			my($num_residues)=scalar(@sorted_method_residues_annotation);
			if($transcript_strand eq '-') 
			{
				$transcript_start=$sorted_method_residues_annotation[$num_residues-1]->{'trans_start'};
				$transcript_end=$sorted_method_residues_annotation[0]->{'trans_end'};
			}
			else
			{
				$transcript_start=$sorted_method_residues_annotation[0]->{'trans_start'}; 
				$transcript_end=$sorted_method_residues_annotation[$num_residues-1]->{'trans_end'};
			}
			
			my($data)={
					'chr'			=> $transcript_features->{'chr'},
					'name'			=> $transcript_id,
					'start'			=> $transcript_start, 
					'end'			=> $transcript_end,
					'strand'		=> $transcript_strand,
					'score'			=> $score,
					'thick_start'	=> $transcript_start, 
					'thick_end'		=> $transcript_end, 
					'color'			=> $color,
					'blocks'		=> 0
			};
			# Get Block Annotations
			foreach my $residue_annotation (@sorted_method_residues_annotation)
			{
				my($residue_position)={
						'start'		=> $residue_annotation->{'trans_start'},
						'end'		=> $residue_annotation->{'trans_end'},
						'strand'	=> $residue_annotation->{'trans_strand'}
				};				
				my($track_features)={
						'start'	=> $data->{'thick_start'},
						'end'	=> $data->{'thick_end'}
				};
				
				my($block)=CDS::get_block_from_transcript($residue_position,$track_features);									
				push(@{$data->{'block_starts'}},$block->{'start'});
				push(@{$data->{'block_sizes'}},$block->{'size'});
				$data->{'blocks'}++;
			}
			${$ref_output}->{'body'}.=printData($data);
		}
	}

} # End getMatador3DAnnotations

sub getSPADEAnnotations($$$$)
{
	my($transcript_id,$transcript_features,$annotation,$output)=@_;

	my($transcript_strand)=$transcript_features->{'strand'};
	my($method_residues_annotation)=DB::get_spade_alignments_annotations($transcript_id);

	if(ref($method_residues_annotation) eq 'ARRAY' and scalar(@{$method_residues_annotation})>0)
	{	
		# Get initial range of track
		my($transcript_start);
		my($transcript_end);
		my($score)=0;
		my($color)=0;
		
		my($num_residues)=scalar(@{$method_residues_annotation});		

		# Get the residues with 'domain', 'domain_possibly_damaged', and 'domain_damaged' separetly
		my($residues_annotation_domain);
		my($residues_annotation_possibly_damaged_domain);
		my($residues_annotation_damaged_domain);
		my($residues_annotation_domain_wrong);
		foreach my $residue_annotation (@{$method_residues_annotation})
		{
			if($residue_annotation->{'type_domain'} eq 'domain')
			{
				push(@{$residues_annotation_domain},$residue_annotation);
			}
			elsif($residue_annotation->{'type_domain'} eq 'domain_possibly_damaged')
			{
				push(@{$residues_annotation_possibly_damaged_domain},$residue_annotation);
			}
			elsif($residue_annotation->{'type_domain'} eq 'domain_damaged')
			{
				push(@{$residues_annotation_damaged_domain},$residue_annotation);
			}			
			elsif($residue_annotation->{'type_domain'} eq 'domain_wrong')
			{
				push(@{$residues_annotation_domain_wrong},$residue_annotation);
			}
		}
		_auxSPADEAnnotations($transcript_id,$transcript_features,'domain',$residues_annotation_domain,$output);
		_auxSPADEAnnotations($transcript_id,$transcript_features,'domain_possibly_damaged',$residues_annotation_possibly_damaged_domain,$output);
		_auxSPADEAnnotations($transcript_id,$transcript_features,'domain_damaged',$residues_annotation_damaged_domain,$output);
		_auxSPADEAnnotations($transcript_id,$transcript_features,'domain_wrong',$residues_annotation_domain_wrong,$output);
	}

} # End getSPADEAnnotations

sub _auxSPADEAnnotations($$$$\$)
{
	my($transcript_id,$transcript_features,$type_domain,$method_residues_annotation,$ref_output)=@_;

	my($transcript_strand)=$transcript_features->{'strand'};

	if(ref($method_residues_annotation) eq 'ARRAY' and scalar(@{$method_residues_annotation})>0)
	{	
		# Get initial range of track
		my($transcript_start);
		my($transcript_end);
		my($score)=0;
		my($color)=0;
		
		my($num_residues)=scalar(@{$method_residues_annotation});		

		# the starts and thick_start is the the first residue. The end and thick_end is the last residue
		if($transcript_strand eq '-') 
		{
			$transcript_start=$method_residues_annotation->[$num_residues-1]->{'trans_start'};
			$transcript_end=$method_residues_annotation->[0]->{'trans_end'};
		}
		else
		{
			$transcript_start=$method_residues_annotation->[0]->{'trans_start'}; 
			$transcript_end=$method_residues_annotation->[$num_residues-1]->{'trans_end'};
		}
		
		my($data)={
				'chr'			=> $transcript_features->{'chr'},
				'name'			=> $transcript_id,
				'start'			=> $transcript_start, 
				'end'			=> $transcript_end,
				'strand'		=> $transcript_strand,
				'score'			=> $score,
				'thick_start'	=> $transcript_start, 
				'thick_end'		=> $transcript_end, 
				'color'			=> $color,
				'blocks'		=> 0
		};
			
		
		# Get Block Annotations
		foreach my $residue_annotation (@{$method_residues_annotation})
		{
			my($residue_position)={
					'start'		=> $residue_annotation->{'trans_start'},
					'end'		=> $residue_annotation->{'trans_end'},
					'strand'	=> $residue_annotation->{'trans_strand'}
			};				

			my($contained_cds)=CDS::get_contained_cds($residue_position,$transcript_features);
			my(@sorted_contained_cds)=@{$contained_cds};

			for(my $i=0; $i<scalar(@sorted_contained_cds); $i++)
			{
				my($track_features)={
						'start'	=> $data->{'thick_start'},
						'end'	=> $data->{'thick_end'}
				};
				
				if(scalar(@sorted_contained_cds) == 1) # Within one CDS
				{
					my($block)=CDS::get_block_from_transcript($residue_position,$track_features);									
					push(@{$data->{'block_starts'}},$block->{'start'});
					push(@{$data->{'block_sizes'}},$block->{'size'});
					$data->{'blocks'}++;	
					last;
				}
				else # Within several CDS
				{
					my($cds_out)=$sorted_contained_cds[$i];
					my($position);					
					if($i==0)
					{
						if($transcript_strand eq '-')
						{
							$position->{'start'}=$cds_out->{'start'};
							$position->{'end'}=$residue_position->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};								
						}
						else
						{
							$position->{'start'}=$residue_position->{'start'};
							$position->{'end'}=$cds_out->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};							
						}
					}
					elsif($i==scalar(@sorted_contained_cds)-1)
					{
						if($transcript_strand eq '-')
						{
							$position->{'start'}=$residue_position->{'start'};
							$position->{'end'}=$cds_out->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};								
						}
						else
						{
							$position->{'start'}=$cds_out->{'start'};
							$position->{'end'}=$residue_position->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};							
						}
					}
					else
					{
						$position->{'start'}=$cds_out->{'start'};
						$position->{'end'}=$cds_out->{'end'};
						$position->{'strand'}=$cds_out->{'strand'};						
					}
					
					my($block)=CDS::get_block_from_transcript($position,$track_features);										
					push(@{$data->{'block_starts'}},$block->{'start'});
					push(@{$data->{'block_sizes'}},$block->{'size'});
					$data->{'blocks'}++;					
				}
			}
		}
		if($type_domain eq 'domain')
		{
			${$ref_output}->[0]->{'body'}.=printData($data);
		}
		elsif($type_domain eq 'domain_possibly_damaged')
		{
			${$ref_output}->[1]->{'body'}.=printData($data);
		}
		elsif($type_domain eq 'domain_damaged')
		{
			${$ref_output}->[2]->{'body'}.=printData($data);
		}
		elsif($type_domain eq 'domain_wrong')
		{
			${$ref_output}->[3]->{'body'}.=printData($data);
		}
	}

} # End _auxSPADEAnnotations

sub getInertiaAnnotations($$$$)
{
	my($transcript_id,$transcript_features,$annotation,$output)=@_;

	my($transcript_strand)=$transcript_features->{'strand'};
	my($method_residues_annotation)=DB::get_inertia_residues_annotations($transcript_id);
	
	if(ref($method_residues_annotation) eq 'ARRAY' and scalar(@{$method_residues_annotation})>0)
	{	
		# Get initial range of track
		my($transcript_start);
		my($transcript_end);
		my($score)=0;
		my($color)=0;
		
		# Get the residues with 'Neutrally evolving exon' and 'Unusually evolving exon' separetly
		my($residues_annotation_neutral_exons);
		my($residues_annotation_unusual_exons); 
		foreach my $residue_annotation (@{$method_residues_annotation})
		{
			if($residue_annotation->{'unusual_evolution'} eq $Constant::UNKNOWN_LABEL)
			{
				push(@{$residues_annotation_neutral_exons},$residue_annotation);
			}
			elsif($residue_annotation->{'unusual_evolution'} eq $Constant::NO_LABEL)
			{
				push(@{$residues_annotation_unusual_exons},$residue_annotation);
			}			
		}

		_auxINERTIAAnnotations($transcript_id,$transcript_features,'neutral_evolution',$residues_annotation_neutral_exons,$output);
		_auxINERTIAAnnotations($transcript_id,$transcript_features,'unusual_evolution',$residues_annotation_unusual_exons,$output);
	}

} # End getInertiaAnnotations

sub _auxINERTIAAnnotations($$$$\$)
{
	my($transcript_id,$transcript_features,$exon_evolution,$method_residues_annotation,$ref_output)=@_;

	my($transcript_strand)=$transcript_features->{'strand'};

	# Sort the residues
	my($sorted_method_residues_annotation);
	if(defined $method_residues_annotation) {
		if($transcript_strand eq '-')
		{
			@{$sorted_method_residues_annotation} = sort { $b->{'start'} <=> $a->{'start'} } @{$method_residues_annotation};
		}
		else
		{
			@{$sorted_method_residues_annotation} = sort { $a->{'start'} <=> $b->{'start'} } @{$method_residues_annotation};
		}		
	}

	if(ref($sorted_method_residues_annotation) eq 'ARRAY' and scalar(@{$sorted_method_residues_annotation})>0)
	{
		# Get initial range of track
		my($transcript_start);
		my($transcript_end);
		my($score)=0;
		my($color)=0;
		
		my($num_residues)=scalar(@{$sorted_method_residues_annotation});

		# The starts and thick_start is the the first residue. The end and thick_end is the last residue
		if($transcript_strand eq '-') 
		{
			$transcript_start=$sorted_method_residues_annotation->[$num_residues-1]->{'start'};
			$transcript_end=$sorted_method_residues_annotation->[0]->{'end'};
		}
		else
		{
			$transcript_start=$sorted_method_residues_annotation->[0]->{'start'}; 
			$transcript_end=$sorted_method_residues_annotation->[$num_residues-1]->{'end'};
		}

		my($data)={
				'chr'			=> $transcript_features->{'chr'},
				'name'			=> $transcript_id,
				'start'			=> $transcript_start, 
				'end'			=> $transcript_end,
				'strand'		=> $transcript_strand,
				'score'			=> $score,
				'thick_start'	=> $transcript_start, 
				'thick_end'		=> $transcript_end, 
				'color'			=> $color,
				'blocks'		=> 0
		};

		# Get Block Annotations
		foreach my $residue_annotation (@{$sorted_method_residues_annotation})
		{
			my($residue_position)={
					'start'		=> $residue_annotation->{'start'},
					'end'		=> $residue_annotation->{'end'},
					'strand'	=> $residue_annotation->{'strand'}
			};
			my($track_features)={
					'start'	=> $data->{'thick_start'},
					'end'	=> $data->{'thick_end'}
			};
			my($block)=CDS::get_block_from_transcript($residue_annotation,$track_features);									
			push(@{$data->{'block_starts'}},$block->{'start'});
			push(@{$data->{'block_sizes'}},$block->{'size'});
			$data->{'blocks'}++;
		}	
		if($exon_evolution eq 'neutral_evolution')
		{
			${$ref_output}->[0]->{'body'}.=printData($data);
		}
		elsif($exon_evolution eq 'unusual_evolution')
		{
			${$ref_output}->[1]->{'body'}.=printData($data);
		}
	}

} # End _auxINERTIAAnnotations

sub getCRASHAnnotations($$$$\$)
{
	my($transcript_id,$transcript_features,$signalp_annotation,$targetp_annotation,$ref_output)=@_;	

	my($transcript_strand)=$transcript_features->{'strand'};
	my($method_residues_annotation)=DB::get_signalp_annotations($transcript_id);

	if(ref($method_residues_annotation) eq 'HASH' and defined $method_residues_annotation)
	{	
		# Get initial range of track
		my($transcript_start);
		my($transcript_end);
		my($score)=0;
		my($color)=0;
		
		# The starts and thick_start is the the first residue. The end and thick_end is the last residue
# TODO: BEGIN -> TIENE ALGòN SENTIDO ESTO??????????????????????? 
		if($transcript_strand eq '-') 
		{
			$transcript_start=$method_residues_annotation->{'trans_start'};
			$transcript_end=$method_residues_annotation->{'trans_end'};
		}
		else
		{
			$transcript_start=$method_residues_annotation->{'trans_start'}; 
			$transcript_end=$method_residues_annotation->{'trans_end'};
		}
# TODO: END -> TIENE ALGòN SENTIDO ESTO???????????????????????		
		
		my($data)={
				'chr'			=> $transcript_features->{'chr'},
				'name'			=> $transcript_id,
				'start'			=> $transcript_start, 
				'end'			=> $transcript_end,
				'strand'		=> $transcript_strand,
				'score'			=> $score,
				'thick_start'	=> $transcript_start, 
				'thick_end'		=> $transcript_end, 
				'color'			=> $color,
				'blocks'		=> 0
		};
		
		# Get Block Annotations
		my($residue_position)={
				'start'		=> $method_residues_annotation->{'trans_start'},
				'end'		=> $method_residues_annotation->{'trans_end'},
				'strand'	=> $method_residues_annotation->{'trans_strand'}
		};				

		my($contained_cds)=CDS::get_contained_cds($residue_position,$transcript_features);
		my(@sorted_contained_cds)=@{$contained_cds};

		for(my $i=0; $i<scalar(@sorted_contained_cds); $i++)
		{
			my($track_features)={
					'start'	=> $data->{'thick_start'},
					'end'	=> $data->{'thick_end'}
			};
			
			if(scalar(@sorted_contained_cds) == 1) # Within one CDS
			{
				my($block)=CDS::get_block_from_transcript($residue_position,$track_features);									
				push(@{$data->{'block_starts'}},$block->{'start'});
				push(@{$data->{'block_sizes'}},$block->{'size'});
				$data->{'blocks'}++;	
				last;
			}
			else # Within several CDS
			{
				my($cds_out)=$sorted_contained_cds[$i];
				my($position);					
				if($i==0)
				{
					if($transcript_strand eq '-')
					{
						$position->{'start'}=$cds_out->{'start'};
						$position->{'end'}=$residue_position->{'end'};
						$position->{'strand'}=$cds_out->{'strand'};								
					}
					else
					{
						$position->{'start'}=$residue_position->{'start'};
						$position->{'end'}=$cds_out->{'end'};
						$position->{'strand'}=$cds_out->{'strand'};							
					}
				}
				elsif($i==scalar(@sorted_contained_cds)-1)
				{
					if($transcript_strand eq '-')
					{
						$position->{'start'}=$residue_position->{'start'};
						$position->{'end'}=$cds_out->{'end'};
						$position->{'strand'}=$cds_out->{'strand'};								
					}
					else
					{
						$position->{'start'}=$cds_out->{'start'};
						$position->{'end'}=$residue_position->{'end'};
						$position->{'strand'}=$cds_out->{'strand'};							
					}
				}
				else
				{
					$position->{'start'}=$cds_out->{'start'};
					$position->{'end'}=$cds_out->{'end'};
					$position->{'strand'}=$cds_out->{'strand'};						
				}
							
				my($block)=CDS::get_block_from_transcript($position,$track_features);										
				push(@{$data->{'block_starts'}},$block->{'start'});
				push(@{$data->{'block_sizes'}},$block->{'size'});
				$data->{'blocks'}++;					
			}
		}
		if($signalp_annotation eq $Constant::OK_LABEL)
		{
			${$ref_output}->[0]->{'body'}.=printData($data);								
		}
		if($targetp_annotation eq $Constant::OK_LABEL)
		{
			${$ref_output}->[1]->{'body'}.=printData($data);								
		}
	}

} # End getCRASHAnnotations

sub getTHUMPAnnotations($$$$)
{
	my($transcript_id,$transcript_features,$annotation,$output)=@_;

	my($transcript_strand)=$transcript_features->{'strand'};
	my($method_residues_annotation)=DB::get_thump_helixes_annotations($transcript_id);

	if(ref($method_residues_annotation) eq 'ARRAY' and scalar(@{$method_residues_annotation})>0)
	{	
		# Get initial range of track
		my($transcript_start);
		my($transcript_end);
		my($score)=0;
		my($color)=0;
		
		# Get the residues with 'Transmembrane Helices' and 'Damaged Transmembrane Helices' separetly
		my($residues_annotation_helixes);
		my($residues_annotation_damaged_helixes); 
		foreach my $residue_annotation (@{$method_residues_annotation})
		{
			if($residue_annotation->{'damaged'} eq '0')
			{
				push(@{$residues_annotation_helixes},$residue_annotation);
			}
			elsif($residue_annotation->{'damaged'} eq '1')
			{
				push(@{$residues_annotation_damaged_helixes},$residue_annotation);
			}			
		}
		_auxTHUMPAnnotations($transcript_id,$transcript_features,'transmembrane_helixes',$residues_annotation_helixes,$output);
		_auxTHUMPAnnotations($transcript_id,$transcript_features,'damaged_transmembrane_helixes',$residues_annotation_damaged_helixes,$output);
	}

} # End getTHUMPAnnotations

sub _auxTHUMPAnnotations($$$$\$)
{
	my($transcript_id,$transcript_features,$damaged_helixes,$method_residues_annotation,$ref_output)=@_;

	my($transcript_strand)=$transcript_features->{'strand'};

	if(ref($method_residues_annotation) eq 'ARRAY' and scalar(@{$method_residues_annotation})>0)
	{	
		# Get initial range of track
		my($transcript_start);
		my($transcript_end);
		my($score)=0;
		my($color)=0;
		
		my($num_residues)=scalar(@{$method_residues_annotation});		

		# the starts and thick_start is the the first residue. The end and thick_end is the last residue
		if($transcript_strand eq '-') 
		{
			$transcript_start=$method_residues_annotation->[$num_residues-1]->{'trans_start'};
			$transcript_end=$method_residues_annotation->[0]->{'trans_end'};
		}
		else
		{
			$transcript_start=$method_residues_annotation->[0]->{'trans_start'}; 
			$transcript_end=$method_residues_annotation->[$num_residues-1]->{'trans_end'};
		}
		
		my($data)={
				'chr'			=> $transcript_features->{'chr'},
				'name'			=> $transcript_id,
				'start'			=> $transcript_start, 
				'end'			=> $transcript_end,
				'strand'		=> $transcript_strand,
				'score'			=> $score,
				'thick_start'	=> $transcript_start, 
				'thick_end'		=> $transcript_end, 
				'color'			=> $color,
				'blocks'		=> 0
		};
			
		
		# Get Block Annotations
		foreach my $residue_annotation (@{$method_residues_annotation})
		{
			my($residue_position)={
					'start'		=> $residue_annotation->{'trans_start'},
					'end'		=> $residue_annotation->{'trans_end'},
					'strand'	=> $residue_annotation->{'trans_strand'}
			};				

			my($contained_cds)=CDS::get_contained_cds($residue_position,$transcript_features);
			my(@sorted_contained_cds)=@{$contained_cds};

			for(my $i=0; $i<scalar(@sorted_contained_cds); $i++)
			{
				my($track_features)={
						'start'	=> $data->{'thick_start'},
						'end'	=> $data->{'thick_end'}
				};
				
				if(scalar(@sorted_contained_cds) == 1) # Within one CDS
				{
					my($block)=CDS::get_block_from_transcript($residue_position,$track_features);									
					push(@{$data->{'block_starts'}},$block->{'start'});
					push(@{$data->{'block_sizes'}},$block->{'size'});
					$data->{'blocks'}++;	
					last;
				}
				else # Within several CDS
				{
					my($cds_out)=$sorted_contained_cds[$i];
					my($position);					
					if($i==0)
					{
						if($transcript_strand eq '-')
						{
							$position->{'start'}=$cds_out->{'start'};
							$position->{'end'}=$residue_position->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};								
						}
						else
						{
							$position->{'start'}=$residue_position->{'start'};
							$position->{'end'}=$cds_out->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};							
						}
					}
					elsif($i==scalar(@sorted_contained_cds)-1)
					{
						if($transcript_strand eq '-')
						{
							$position->{'start'}=$residue_position->{'start'};
							$position->{'end'}=$cds_out->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};								
						}
						else
						{
							$position->{'start'}=$cds_out->{'start'};
							$position->{'end'}=$residue_position->{'end'};
							$position->{'strand'}=$cds_out->{'strand'};							
						}
					}
					else
					{
						$position->{'start'}=$cds_out->{'start'};
						$position->{'end'}=$cds_out->{'end'};
						$position->{'strand'}=$cds_out->{'strand'};						
					}
					
					my($block)=CDS::get_block_from_transcript($position,$track_features);										
					push(@{$data->{'block_starts'}},$block->{'start'});
					push(@{$data->{'block_sizes'}},$block->{'size'});
					$data->{'blocks'}++;					
				}
			}
		}
		if($damaged_helixes eq 'transmembrane_helixes')
		{
			${$ref_output}->[0]->{'body'}.=printData($data);
		}
		elsif($damaged_helixes eq 'damaged_transmembrane_helixes')
		{
			${$ref_output}->[1]->{'body'}.=printData($data);
		}
	}

} # End _auxTHUMPAnnotations

sub getCExonicAnnotations($$$\$)
{
	my($transcript_id,$transcript_features,$annotation,$ref_output)=@_;

	# Get the sorted Exons
	my($transcript_orientation)=$transcript_features->{'strand'};	
	my($sort_exon_list)=CDS::sort_exons($transcript_orientation,$transcript_features);

	if(ref($sort_exon_list) eq 'ARRAY' and scalar(@{$sort_exon_list})>0)
	{
		my($num_exons)=scalar(@{$sort_exon_list});

		# The starts and thick_start is the the first CDS coordinate.
		# The end and thick_end is the last CDS coordinate.
		my($sort_cds_list)=CDS::sort_cds($transcript_orientation,$transcript_features);
		my($thick_start)=$transcript_features->{'start'};
		my($thick_end)=$transcript_features->{'end'};
		if(ref($sort_cds_list) eq 'ARRAY' and scalar(@{$sort_cds_list})>0)
		{
			my($num_cds)=scalar(@{$sort_cds_list});
			if($transcript_orientation eq '-') 
			{
				$thick_start=$sort_cds_list->[$num_cds-1]->{'start'};
				$thick_end=$sort_cds_list->[0]->{'end'};
			}
			else
			{
				$thick_start=$sort_cds_list->[0]->{'start'}; 
				$thick_end=$sort_cds_list->[$num_cds-1]->{'end'};
			}			
		}
		
		my($data)={
				'chr'			=> $transcript_features->{'chr'},
				'name'			=> $transcript_id,
				'start'			=> $transcript_features->{'start'},
				'end'			=> $transcript_features->{'end'},
				'strand'		=> $transcript_features->{'strand'},
				'score'			=> 0,
				'thick_start'	=> $thick_start,
				'thick_end'		=> $thick_end,			
				'color'			=> 0,
				'blocks'		=> $num_exons
		};
		
		foreach my $exon (@{$sort_exon_list})
		{
			my($position)={
					'start'		=> $exon->{'start'},
					'end'		=> $exon->{'end'},
					'strand'	=> $exon->{'strand'}
			};
			my($block)=CDS::get_block_from_transcript($position,
																{
																	'start'	=> $data->{'start'},
																	'end'	=> $data->{'end'}
																});					
			push(@{$data->{'block_starts'}},$block->{'start'});
			push(@{$data->{'block_sizes'}},$block->{'size'});
		}		
		if($annotation eq $Constant::UNKNOWN_LABEL)
		{
			${$ref_output}->[0]->{'body'}.=printData($data);								
		}
		elsif($annotation eq $Constant::NO_LABEL)
		{
			${$ref_output}->[1]->{'body'}.=printData($data);								
		}
	}

} # End getCExonicAnnotations

sub getCORSAIRAnnotations($$$\$)
{
	my($transcript_id,$transcript_features,$annotation,$ref_output)=@_;

	# Get the sorted Exons
	my($transcript_orientation)=$transcript_features->{'strand'};	
	my($sort_exon_list)=CDS::sort_exons($transcript_orientation,$transcript_features);

	if(ref($sort_exon_list) eq 'ARRAY' and scalar(@{$sort_exon_list})>0)
	{
		my($num_exons)=scalar(@{$sort_exon_list});
		
		# The starts and thick_start is the the first CDS coordinate.
		# The end and thick_end is the last CDS coordinate.
		my($sort_cds_list)=CDS::sort_cds($transcript_orientation,$transcript_features);
		my($thick_start)=$transcript_features->{'start'};
		my($thick_end)=$transcript_features->{'end'};
		if(ref($sort_cds_list) eq 'ARRAY' and scalar(@{$sort_cds_list})>0)
		{
			my($num_cds)=scalar(@{$sort_cds_list});
			if($transcript_orientation eq '-') 
			{
				$thick_start=$sort_cds_list->[$num_cds-1]->{'start'};
				$thick_end=$sort_cds_list->[0]->{'end'};
			}
			else
			{
				$thick_start=$sort_cds_list->[0]->{'start'}; 
				$thick_end=$sort_cds_list->[$num_cds-1]->{'end'};
			}			
		}
		
		my($data)={
				'chr'			=> $transcript_features->{'chr'},
				'name'			=> $transcript_id,
				'start'			=> $transcript_features->{'start'},
				'end'			=> $transcript_features->{'end'},
				'strand'		=> $transcript_features->{'strand'},
				'score'			=> 0,
				'thick_start'	=> $thick_start,
				'thick_end'		=> $thick_end,			
				'color'			=> 0,
				'blocks'		=> $num_exons
		};
		
		foreach my $exon (@{$sort_exon_list})
		{
			my($position)={
					'start'		=> $exon->{'start'},
					'end'		=> $exon->{'end'},
					'strand'	=> $exon->{'strand'}
			};
			my($block)=CDS::get_block_from_transcript($position,
																{
																	'start'	=> $data->{'start'},
																	'end'	=> $data->{'end'}
																});					
			push(@{$data->{'block_starts'}},$block->{'start'});
			push(@{$data->{'block_sizes'}},$block->{'size'});
		}		
		if($annotation eq $Constant::OK_LABEL)
		{
			${$ref_output}->[0]->{'body'}.=printData($data);								
		}
		elsif($annotation eq $Constant::UNKNOWN_LABEL)
		{
			${$ref_output}->[1]->{'body'}.=printData($data);								
		}
		# DISABLED
		#elsif($annotation eq $Constant::NO_LABEL)
		#{
		#	${$ref_output}->[2]->{'body'}.=printData($data);								
		#}
	}

} # End getCORSAIRAnnotations

1;