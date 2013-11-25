# _________________________________________________________________
# $Id$
# $Revision$
# Developed by:
#       Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________
#
#1  chromosome name  		chr{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,M}
#2 	annotation source 		{APPRIS,FIRESTAR,MATADOR3D,SPADE,...}
#3 	feature-type 			{principal_isoform,functional_residue,conservation_structure,functional_domain,...}
#4 	genomic start location 	integer-value
#5 	genomic end location 	integer-value
#6 	score (if applicated)	integer-value
#7 	genomic strand 			{+,-}
#8 	genomic phase (for CDS)	{.}
#9 	additional information as key-value pairs
#
#
# additional information:
#
#
# 1. Mandatory fields: (key_name value_format)
# gene_id				ENSGXXXXXXXXXXX *
# transcript_id			ENSTXXXXXXXXXXX *
# transcript_name		String
# version				String
# date					%Y-%m-%dT%H:%M:%S
#
# 2. Optional fields: (key_name value_format)
# appris_annotation		{YES,NO,UKNOWN}
# 
package Export::GFF;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/..";
require Constant;
#use Constant;

###################
# Global variable #
###################
use vars qw($GTF_CONSTANTS);

$GTF_CONSTANTS={
	'appris'=>{
		'source'=>'APPRIS',
		'type'=>'principal_isoform',
		'annotation'=>['Principal Isoform','Principal Isoform (Vertebrate Conservation)','Possible Principal Isoform','No Principal Isoform']		
	},
	'firestar'=>{
		'source'=>'FIRESTAR',
		'type'=>'functional_residue',
		'annotation'=>'Functional residue'
	},
	'matador3d'=>{
		'source'=>'MATADOR3D',
		'type'=>'homologous_structure',
		'annotation'=>'Homologous structure'
	},
	'spade'=>{
		'source'=>'SPADE',
		'type'=>'functional_domain',
		'annotation'=>['Whole domain','Slightly damaged Pfam domain','Damaged Pfam domain', 'Wrong Pfam domain']				
	},
	'inertia'=>{
		'source'=>['INERTIA_Consensus','INERTIA_MAFF','INERTIA_Prank','INERTIA_Kalign'],		
		'type'=>'neutral_evolution',
		'annotation'=>['Neutrally evolving exon','Unusually evolving exon']
	},
	'crash'=>{
		'source'=>'CRASH',
		'type'=>['signal_peptide','mitochondrial_signal'],
		'annotation'=>{
			'signal_peptide' => ['Signal sequence','Doubtful signal sequence','No signal sequence'],
			'mitochondrial_signal' => ['Mitochondrial signal sequence','Doubtful mitochondrial signal sequence','No mitochondrial signal sequence']
		}
	},
	'thump'=>{
		'source'=>'THUMP',
		'type'=>'transmembrane_signal',
		'annotation'=>['Transmembrane helix','Damaged transmembrane helix']
	},
	'cexonic'=>{
		'source'=>'CEXONIC',
		'type'=>['conservation_exon','non-aligned_introns'],
		'annotation'=>['Exonic structure conserved in Mouse','Exonic structure not conserved in Mouse'],
	},
	'corsair'=>{
		'source'=>'CORSAIR',
		'type'=>'vertebrate_conservation',
		'annotation'=>['Vertebrate conservation','Doubtful vertebrate conservation','No vertebrate conservation']
	}
};


#####################
# Method prototypes #
#####################
sub printAnnotations($$);
sub getAPPRISAnnotations($$$$$$);
sub getAPPRISAnnotations2($$$$$$$);
sub getFirestarAnnotations($$$$$);
sub getMatador3DAnnotations($$$$$);
sub getSPADEAnnotations($$$$$);
sub getInertiaAnnotations($$$$$);
sub getSignalPAnnotations($$$$$);
sub getTargetPAnnotations($$$$$);
sub getTHUMPAnnotations($$$$$);
sub getCExonicAnnotations($$$$$);
sub getCORSAIRAnnotations($$$$$);

#################
# Method bodies #
#################
sub printAnnotations($$)
{
	my($common_attributes,$optional_attributes)=@_;
	
	my($output_annotation)='';

	# <seqname> <source> <feature> <start> <end>  <score> <strand> <frame> [attributes] [comments]
	#  Print feature: Common feature
	$output_annotation.=$common_attributes->{'seqname'}."\t".
						$common_attributes->{'source'}."\t".
						$common_attributes->{'type'}."\t".
						$common_attributes->{'start'}."\t".
						$common_attributes->{'end'}."\t".
						$common_attributes->{'score'}."\t".
						$common_attributes->{'strand'}."\t".
						$common_attributes->{'phase'}."\t";
	#  Print feature
	while(my($key,$value)=each(%{$optional_attributes}))
	{
		$output_annotation.=$key.' "'.$value.'"; ';
	}
	$output_annotation=~s/\; $/\n/;
	return $output_annotation;

} # End printAnnotations

sub getAPPRISAnnotations($$$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$appris_annotation,$appris_source_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($method_score)='.';
	my($method_phase)='.';
	my($method_source)=$GTF_CONSTANTS->{'appris'}->{'source'};
	my($method_type)=$GTF_CONSTANTS->{'appris'}->{'type'};

	my($method_annotation);
	if($appris_annotation eq $Constant::NO_LABEL)
	{		
		$method_annotation=$GTF_CONSTANTS->{'appris'}->{'annotation'}->[3];

		return ''; # If we don't find a principal isform => Print anything
	}
	elsif($appris_annotation eq $Constant::UNKNOWN_LABEL)
	{
		$method_annotation=$GTF_CONSTANTS->{'appris'}->{'annotation'}->[2];		
		
		return ''; # If we don't find a principal isform => Print anything
	}
	elsif($appris_annotation eq $Constant::OK_LABEL)
	{
		if($appris_source_annotation eq 'vertebrate_signal')
		{			
			$method_annotation=$GTF_CONSTANTS->{'appris'}->{'annotation'}->[1];			
		}
		else
		{
			$method_annotation=$GTF_CONSTANTS->{'appris'}->{'annotation'}->[0];
		}
	}
	return '' unless(defined $method_annotation);

	# Common attributes
	my($common_attributes)={
							'seqname'	=> $transcript_features->{'chr'},
							'source'	=> $method_source,
							'type'		=> $method_type,
							'start'		=> $transcript_features->{'start'},
							'end'		=> $transcript_features->{'end'},
							'score'		=> $method_score,
							'strand'	=> $transcript_features->{'strand'},
							'phase'		=> $method_phase
	};		
	# Optinal attributes
	my($optional_attributes);
	$optional_attributes->{'annotation'}		= $method_annotation;
	$optional_attributes->{'gene_id'}			= $gene_id;
	$optional_attributes->{'transcript_id'}		= $transcript_id;
	$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
	if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
		$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
	}
	$optional_attributes->{'version'}			= $version;		
	if(defined $common_attributes and defined $optional_attributes)
	{
		$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
	}
	return $output_annotation;

} # End getAPPRISAnnotations

sub getAPPRISAnnotations2($$$$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$method_type,$method_score,$appris_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($method_phase)='.';
	my($method_source)=$GTF_CONSTANTS->{'appris'}->{'source'};

	# Common attributes
	my($common_attributes)={
							'seqname'	=> $transcript_features->{'chr'},
							'source'	=> $method_source,
							'type'		=> $method_type,
							'start'		=> $transcript_features->{'start'},
							'end'		=> $transcript_features->{'end'},
							'score'		=> $method_score,
							'strand'	=> $transcript_features->{'strand'},
							'phase'		=> $method_phase
	};		
	# Optinal attributes
	my($optional_attributes);
	$optional_attributes->{'annotation'}		= $appris_annotation;
	$optional_attributes->{'gene_id'}			= $gene_id;
	$optional_attributes->{'transcript_id'}		= $transcript_id;
	$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
	if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
		$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
	}
	$optional_attributes->{'version'}			= $version;		
	if(defined $common_attributes and defined $optional_attributes)
	{
		$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
	}
	return $output_annotation;

} # End getAPPRISAnnotations2

sub getFirestarAnnotations($$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($method_score)='.';
	my($method_phase)='.';	
	my($method_source)=$GTF_CONSTANTS->{'firestar'}->{'source'};	
	my($method_type)=$GTF_CONSTANTS->{'firestar'}->{'type'};
	my($method_annotation)=$GTF_CONSTANTS->{'firestar'}->{'annotation'};

	# Get Residue Annotations
	my($method_residues_annotation)=DB::get_firestar_residues_annotations($transcript_id);
	foreach my $residue_annotation (@{$method_residues_annotation})
	{
		# Common attributes
		my($common_attributes)={
								'seqname'	=> $transcript_features->{'chr'},
								'source'	=> $method_source,
								'type'		=> $method_type,
								'start'		=> $residue_annotation->{'start'},
								'end'		=> $residue_annotation->{'end'},
								'score'		=> $residue_annotation->{'score'},
								'strand'	=> $residue_annotation->{'strand'},
								'phase'		=> $method_phase
		};							
		# Optinal attributes
		my($optional_attributes);
		$optional_attributes->{'annotation'}		= $method_annotation;
		$optional_attributes->{'note'}				= "peptide_position:".$residue_annotation->{'peptide_position'};
		$optional_attributes->{'gene_id'}			= $gene_id;
		$optional_attributes->{'transcript_id'}		= $transcript_id;
		$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
		if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
			$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
		}
		$optional_attributes->{'version'}			= $version;
		if(defined $common_attributes and defined $optional_attributes)
		{
			$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
		}	
	}

	# Get APPRIS Annotations
	my($firestar_annotation)=DB::get_firestar_annotations($transcript_id);
	if((ref($firestar_annotation) eq 'HASH') and exists $firestar_annotation->{'num_residues'} and defined $firestar_annotation->{'num_residues'})
		{ $method_score=$firestar_annotation->{'num_residues'} }
	$output_annotation.=getAPPRISAnnotations2($gene_id,$transcript_id,$transcript_features,$method_type,$method_score,$appris_annotation,$version);
	
	return $output_annotation;
	
} # End getFirestarAnnotations

sub getMatador3DAnnotations($$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($method_score)='.';
	my($method_phase)='.';
	my($method_source)=$GTF_CONSTANTS->{'matador3d'}->{'source'};
	my($method_type)=$GTF_CONSTANTS->{'matador3d'}->{'type'};
	my($method_annotation)=$GTF_CONSTANTS->{'matador3d'}->{'annotation'};
	my($num_conserve_struct)=0;

	# Get Main Annotation
	my($residue_annotation)=DB::get_matador3d_annotations($transcript_id);
	if(ref($residue_annotation) eq 'HASH')
	{
		$method_score = $residue_annotation->{'score'};
	}
		
	# Get Residue Annotations
	my($method_residues_annotation)=DB::get_matador3d_alignments_annotations($transcript_id);
	foreach my $residue_annotation (@{$method_residues_annotation})
	{
		# Common attributes
		my($common_attributes)={
								'seqname'	=> $transcript_features->{'chr'},
								'source'	=> $method_source,
								'type'		=> $method_type,
								'start'		=> $residue_annotation->{'trans_start'},
								'end'		=> $residue_annotation->{'trans_end'},
								'score'		=> $residue_annotation->{'alignment_score'},
								'strand'	=> $residue_annotation->{'trans_strand'},
								'phase'		=> $method_phase
		};							
		# Optinal attributes
		my($optional_attributes);
		$optional_attributes->{'annotation'}		= $method_annotation;
		if(exists $residue_annotation->{'pdb_id'} and defined $residue_annotation->{'pdb_id'}) {
			$optional_attributes->{'note'}			= "PDB_list:".$residue_annotation->{'pdb_id'};			
		}		
		$optional_attributes->{'gene_id'}			= $gene_id;
		$optional_attributes->{'transcript_id'}		= $transcript_id;
		$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
		if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
			$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
		}		
		$optional_attributes->{'version'}			= $version;
		if(defined $common_attributes and defined $optional_attributes)
		{
			$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
		}
		# Count the conserve structures (with score)
		$num_conserve_struct ++ if($residue_annotation->{'alignment_score'} > '0');
	}
	$method_score = $num_conserve_struct if ($method_score eq '.');

	# Get APPRIS Annotations
	$output_annotation.=getAPPRISAnnotations2($gene_id,$transcript_id,$transcript_features,$method_type,$method_score,$appris_annotation,$version);
	
	return $output_annotation;
	
} # End getMatador3DAnnotations

sub getSPADEAnnotations($$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($method_score)='.';
	my($method_phase)='.';
	my($method_source)=$GTF_CONSTANTS->{'spade'}->{'source'};
	my($method_type)=$GTF_CONSTANTS->{'spade'}->{'type'};
	
	# Get Residue Annotations
	my($method_residues_annotation)=DB::get_spade_alignments_annotations($transcript_id);
	foreach my $residue_annotation (@{$method_residues_annotation})
	{
		my($method_annotation);
		if($residue_annotation->{'type_domain'} eq 'domain')
		{
			$method_annotation=$GTF_CONSTANTS->{'spade'}->{'annotation'}->[0];
		}
		elsif($residue_annotation->{'type_domain'} eq 'domain_possibly_damaged')
		{
			$method_annotation=$GTF_CONSTANTS->{'spade'}->{'annotation'}->[1];

		}
		elsif($residue_annotation->{'type_domain'} eq 'domain_damaged')
		{
			$method_annotation=$GTF_CONSTANTS->{'spade'}->{'annotation'}->[2];
		}
		elsif($residue_annotation->{'type_domain'} eq 'domain_wrong')
		{
			$method_annotation=$GTF_CONSTANTS->{'spade'}->{'annotation'}->[3];
		}
		next unless(defined $method_annotation); # No annotations

		# Common attributes
		my($common_attributes)={
								'seqname'	=> $transcript_features->{'chr'},
								'source'	=> $method_source,
								'type'		=> $method_type,
								'start'		=> $residue_annotation->{'trans_start'},
								'end'		=> $residue_annotation->{'trans_end'},
								'score'		=> $residue_annotation->{'score'},
								'strand'	=> $residue_annotation->{'trans_strand'},
								'phase'		=> $method_phase
		};							
		# Optinal attributes
		my($optional_attributes);
		$optional_attributes->{'annotation'}		= $method_annotation;
		$optional_attributes->{'gene_id'}			= $gene_id;
		$optional_attributes->{'transcript_id'}		= $transcript_id;
		$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
		if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
			$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
		}		
		$optional_attributes->{'version'}			= $version;			
		if(defined $common_attributes and defined $optional_attributes)
		{
			$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
		}
	}

	# Get APPRIS Annotations
	$output_annotation.=getAPPRISAnnotations2($gene_id,$transcript_id,$transcript_features,$method_type,$method_score,$appris_annotation,$version);
	
	return $output_annotation;
	
} # End getSPADEAnnotations

sub getInertiaAnnotations($$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($appris_score)='.';	
	my($appris_phase)='.';
	my($method_score)='.';
	my($method_phase)='.';
	my($method_source)=$GTF_CONSTANTS->{'inertia'}->{'source'}->[0];
	my($method_type)=$GTF_CONSTANTS->{'inertia'}->{'type'};

	# Get Residue of INERTIA Annotations 
	my($method_residues_annotation)=DB::get_inertia_residues_annotations($transcript_id);
	foreach my $residue_annotation (@{$method_residues_annotation})
	{
		my($method_annotation);
		if($residue_annotation->{'unusual_evolution'} eq $Constant::UNKNOWN_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'inertia'}->{'annotation'}->[0];
		}
		elsif($residue_annotation->{'unusual_evolution'} eq $Constant::NO_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'inertia'}->{'annotation'}->[1];	
		}
		else
		{
			$method_annotation='No data';
		}
		next unless(defined $method_annotation); # No annotations

		# Common attributes
		my($common_attributes)={
								'seqname'	=> $transcript_features->{'chr'},
								'source'	=> $method_source,
								'type'		=> $method_type,
								'start'		=> $residue_annotation->{'start'},
								'end'		=> $residue_annotation->{'end'},
								'score'		=> $method_score,
								'strand'	=> $transcript_features->{'strand'},
								'phase'		=> $method_phase
		};							
		# Optinal attributes
		my($optional_attributes);
		$optional_attributes->{'annotation'}		= $method_annotation;
		$optional_attributes->{'gene_id'}			= $gene_id;
		$optional_attributes->{'transcript_id'}		= $transcript_id;
		$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
		if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
			$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
		}		
		$optional_attributes->{'version'}			= $version;			
		if(defined $common_attributes and defined $optional_attributes)
		{
			$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
		}		
	}

	# Get Residue Annotations
	# 1 | filter | Filtered Alignment coming directly from Maf    | 
	# 2 | prank  | Filtered Alignment coming from Prank software  | 
	# 3 | kalign | Filtered Alignment coming from Kalign software | 
	my($method_residues_annotation2)=DB::get_omega_residues_annotations($transcript_id);
	foreach my $residue_annotation2 (@{$method_residues_annotation2})
	{
		my($method_annotation2);
		if($residue_annotation2->{'unusual_evolution'} eq $Constant::UNKNOWN_LABEL)
		{
			$method_annotation2=$GTF_CONSTANTS->{'inertia'}->{'annotation'}->[0];
		}
		elsif($residue_annotation2->{'unusual_evolution'} eq $Constant::NO_LABEL)
		{
			$method_annotation2=$GTF_CONSTANTS->{'inertia'}->{'annotation'}->[1];	
		}
		else
		{
			$method_annotation2='No data';
		}		
		my($method_source2)=$GTF_CONSTANTS->{'inertia'}->{'source'}->[$residue_annotation2->{'slr_type_id'}];

		next unless(defined $method_annotation2); # No annotations

		# Common attributes
		my($common_attributes)={
								'seqname'	=> $transcript_features->{'chr'},
								'source'	=> $method_source2,
								'type'		=> $method_type,
								'start'		=> $residue_annotation2->{'start'},
								'end'		=> $residue_annotation2->{'end'},
								'score'		=> $residue_annotation2->{'omega_mean'},
								'strand'	=> $transcript_features->{'strand'},
								'phase'		=> $method_phase
		};							
		# Optinal attributes
		my($optional_attributes);
		$optional_attributes->{'annotation'}		= $method_annotation2;
		$optional_attributes->{'note'}				= "p_value:".$residue_annotation2->{'p_value'};
		$optional_attributes->{'gene_id'}			= $gene_id;
		$optional_attributes->{'transcript_id'}		= $transcript_id;
		$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
		if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
			$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
		}		
		$optional_attributes->{'version'}			= $version;			
		if(defined $common_attributes and defined $optional_attributes)
		{
			$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
		}		
	}
		
	# Get APPRIS Annotations
	$output_annotation.=getAPPRISAnnotations2($gene_id,$transcript_id,$transcript_features,$method_type,$method_score,$appris_annotation,$version);

	return $output_annotation;
	
} # End getInertiaAnnotations

sub getSignalPAnnotations($$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($method_score)='.';
	my($method_phase)='.';
	my($method_source)=$GTF_CONSTANTS->{'crash'}->{'source'};	
	my($method_type)=$GTF_CONSTANTS->{'crash'}->{'type'}->[0];

	# Get Residue Annotations
	my($residue_annotation)=DB::get_signalp_annotations($transcript_id);
	if(ref($residue_annotation) eq 'HASH')
	{
		my($method_annotation);
		if($appris_annotation eq $Constant::NO_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'crash'}->{'annotation'}->{'signal_peptide'}->[2];		
		}
		elsif($appris_annotation eq $Constant::UNKNOWN_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'crash'}->{'annotation'}->{'signal_peptide'}->[1];
		}
		elsif($appris_annotation eq $Constant::OK_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'crash'}->{'annotation'}->{'signal_peptide'}->[0];
		}
		else
		{
			$method_annotation='No data';
		}
		return '' unless(defined $method_annotation); # No annotations

		# Common attributes
		my($common_attributes)={
								'seqname'	=> $transcript_features->{'chr'},
								'source'	=> $method_source,
								'type'		=> $method_type,
								'start'		=> $residue_annotation->{'trans_start'},
								'end'		=> $residue_annotation->{'trans_end'},
								'score'		=> $residue_annotation->{'score'},
								'strand'	=> $residue_annotation->{'trans_strand'},
								'phase'		=> $method_phase
		};							
		# Optinal attributes
		my($optional_attributes);
		$optional_attributes->{'annotation'}		= $method_annotation;
		$optional_attributes->{'note'}				= "s_mean:".$residue_annotation->{'s_mean'}.",".
										  			  "s_prob:".$residue_annotation->{'s_prob'}.",".
													  "d_score:".$residue_annotation->{'d_score'}.",".
													  "c_max:".$residue_annotation->{'c_max'}."";
		$optional_attributes->{'gene_id'}			= $gene_id;
		$optional_attributes->{'transcript_id'}		= $transcript_id;
		$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
		if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
			$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
		}		
		$optional_attributes->{'version'}			= $version;
		if(defined $common_attributes and defined $optional_attributes)
		{
			$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
		}
	}

	# Get APPRIS Annotations
	$output_annotation.=getAPPRISAnnotations2($gene_id,$transcript_id,$transcript_features,$method_type,$method_score,$appris_annotation,$version);
	
	return $output_annotation;
	
} # End getSignalPAnnotations

sub getTargetPAnnotations($$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($method_score)='.';
	my($method_phase)='.';
	my($method_source)=$GTF_CONSTANTS->{'crash'}->{'source'};	
	my($method_type)=$GTF_CONSTANTS->{'crash'}->{'type'}->[1];

	# Get Residue Annotations
	my($residue_annotation)=DB::get_targetp_annotations($transcript_id);
	if(ref($residue_annotation) eq 'HASH')
	{
		my($method_annotation);
		if($appris_annotation eq $Constant::NO_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'crash'}->{'annotation'}->{'mitochondrial_signal'}->[2];
		}
		elsif($appris_annotation eq $Constant::UNKNOWN_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'crash'}->{'annotation'}->{'mitochondrial_signal'}->[1];
		}
		elsif($appris_annotation eq $Constant::OK_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'crash'}->{'annotation'}->{'mitochondrial_signal'}->[0];
		}
		else
		{
			$method_annotation='No data';
		}
		return '' unless(defined $method_annotation); # No annotations

		# Common attributes
		my($common_attributes)={
								'seqname' 	=> $transcript_features->{'chr'},
								'source'	=> $method_source,
								'type'		=> $method_type,
								'start'		=> $residue_annotation->{'trans_start'},
								'end'		=> $residue_annotation->{'trans_end'},
								'score'		=> $residue_annotation->{'score'},
								'strand'	=> $residue_annotation->{'trans_strand'},
								'phase'		=> $method_phase
		};							
		# Optinal attributes
		my($optional_attributes);
		$optional_attributes->{'annotation'}		= $method_annotation;
		$optional_attributes->{'note'}				= "reliability:".$residue_annotation->{'reliability'}.",".
													  "localization:".$residue_annotation->{'localization'}."";
		$optional_attributes->{'gene_id'}			= $gene_id;
		$optional_attributes->{'transcript_id'}		= $transcript_id;
		$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
		if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
			$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
		}		
		$optional_attributes->{'version'}			= $version;
		if(defined $common_attributes and defined $optional_attributes)
		{
			$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
		}		
	}

	# Get APPRIS Annotations
	$output_annotation.=getAPPRISAnnotations2($gene_id,$transcript_id,$transcript_features,$method_type,$method_score,$appris_annotation,$version);
	
	return $output_annotation;
	
} # End getTargetPAnnotations

sub getTHUMPAnnotations($$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($method_score)='.';
	my($method_phase)='.';
	my($method_source)=$GTF_CONSTANTS->{'thump'}->{'source'};	
	my($method_type)=$GTF_CONSTANTS->{'thump'}->{'type'};
	my($num_helixes)=0;
	my($num_damaged_helixes)=0;
	
	# Get Residue Annotations
	my($method_residues_annotation)=DB::get_thump_helixes_annotations($transcript_id);
	foreach my $residue_annotation (@{$method_residues_annotation})
	{
		my($method_annotation);
		if($residue_annotation->{'damaged'} eq '0')
		{
			$method_annotation=$GTF_CONSTANTS->{'thump'}->{'annotation'}->[0];
			$num_helixes++;		
		}
		elsif($residue_annotation->{'damaged'} eq '1')
		{
			$method_annotation=$GTF_CONSTANTS->{'thump'}->{'annotation'}->[1];
			$num_damaged_helixes++;
		}
		else
		{
			$method_annotation='No data';
		}
		next unless(defined $method_annotation); # No annotations

		# Common attributes
		my($common_attributes)={
								'seqname'	=> $transcript_features->{'chr'},
								'source'	=> $method_source,
								'type'		=> $method_type,
								'start'		=> $residue_annotation->{'trans_start'},
								'end'		=> $residue_annotation->{'trans_end'},
								'score'		=> $method_score,
								'strand'	=> $residue_annotation->{'trans_strand'},
								'phase'		=> $method_phase
		};							
		# Optinal attributes
		my($optional_attributes);
		$optional_attributes->{'annotation'}		= $method_annotation;
		$optional_attributes->{'gene_id'}			= $gene_id;
		$optional_attributes->{'transcript_id'}		= $transcript_id;
		$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
		if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
			$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
		}		
		$optional_attributes->{'version'}			= $version;
		if(defined $common_attributes and defined $optional_attributes)
		{
			$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
		}		
	}
	
	# Get APPRIS Annotations
	#$method_score="$num_helixes\+$num_damaged_helixes";
	$method_score=$num_helixes;
	$output_annotation.=getAPPRISAnnotations2($gene_id,$transcript_id,$transcript_features,$method_type,$method_score,$appris_annotation,$version);

	return $output_annotation;
	
} # End getTHUMPAnnotations

sub getCExonicAnnotations($$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($appris_score)='.';
	my($appris_phase)='.';
	my($method_score)='.';
	my($method_phase)='.';
	my($method_source)=$GTF_CONSTANTS->{'cexonic'}->{'source'};	
	my($method_type)=$GTF_CONSTANTS->{'cexonic'}->{'type'}->[0];
	my($method_type2)=$GTF_CONSTANTS->{'cexonic'}->{'type'}->[1];

	my($method_annotation);
	if($appris_annotation eq $Constant::NO_LABEL)
	{
		$method_annotation=$GTF_CONSTANTS->{'cexonic'}->{'annotation'}->[1];
	}
	elsif($appris_annotation eq $Constant::UNKNOWN_LABEL)
	{
		$method_annotation=$GTF_CONSTANTS->{'cexonic'}->{'annotation'}->[0];
	}
	else
	{
		$method_annotation='No data';
	}
	return '' unless(defined $method_annotation); # No annotations

	# Common attributes
	my($common_attributes)={
							'seqname'	=> $transcript_features->{'chr'},
							'source'	=> $method_source,
							'type'		=> $method_type,
							'start'		=> $transcript_features->{'start'},
							'end'		=> $transcript_features->{'end'},
							'score'		=> $appris_score,
							'strand'	=> $transcript_features->{'strand'},
							'phase'		=> $appris_phase
	};							
	# Optinal attributes
	my($optional_attributes);
	$optional_attributes->{'annotation'}		= $method_annotation;
	$optional_attributes->{'gene_id'}			= $gene_id;
	$optional_attributes->{'transcript_id'}		= $transcript_id;
	$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
	if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
		$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
	}	
	$optional_attributes->{'version'}			= $version;
	if(defined $common_attributes and defined $optional_attributes)
	{
		$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
	}
			
	# Get Residue Annotations
	my($method_residues_annotation)=DB::get_cexonic_residues_annotations($transcript_id);
	foreach my $residue_annotation (@{$method_residues_annotation})
	{
		# Common attributes
		my($common_attributes)={
								'seqname'	=> $transcript_features->{'chr'},
								'source'	=> $method_source,
								'type'		=> $method_type2,
								'start'		=> $residue_annotation->{'start'},
								'end'		=> $residue_annotation->{'end'},
								'score'		=> $method_score,
								'strand'	=> $residue_annotation->{'strand'},
								'phase'		=> $method_phase
		};							
		# Optinal attributes
		my($optional_attributes);
		$optional_attributes->{'gene_id'}			= $gene_id;
		$optional_attributes->{'transcript_id'}		= $transcript_id;
		$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
		if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
			$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
		}		
		$optional_attributes->{'version'}			= $version;
		if(defined $common_attributes and defined $optional_attributes)
		{
			$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
		}	
	}
	
	# Get APPRIS Annotations
	$output_annotation.=getAPPRISAnnotations2($gene_id,$transcript_id,$transcript_features,$method_type,$method_score,$appris_annotation,$version);

	return $output_annotation;
	
} # End getCExonicAnnotations

sub getCORSAIRAnnotations($$$$$)
{
	my($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version)=@_;
	
	my($output_annotation)='';
	my($method_score)='.';
	my($method_phase)='.';
	my($method_source)=$GTF_CONSTANTS->{'corsair'}->{'source'};	
	my($method_type)=$GTF_CONSTANTS->{'corsair'}->{'type'};

	# Get Residue Annotations
	my($residue_annotation)=DB::get_corsair_annotations($transcript_id);
	if(ref($residue_annotation) eq 'HASH')
	{
		my($method_annotation);
		if($appris_annotation eq $Constant::NO_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'corsair'}->{'annotation'}->[2];
		}
		elsif($appris_annotation eq $Constant::UNKNOWN_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'corsair'}->{'annotation'}->[1];
		}
		elsif($appris_annotation eq $Constant::OK_LABEL)
		{
			$method_annotation=$GTF_CONSTANTS->{'corsair'}->{'annotation'}->[0];
		}
		else
		{
			$method_annotation='No data';
		}
		return '' unless(defined $method_annotation); # No annotations

		# Common attributes
		my($common_attributes)={
								'seqname'	=> $transcript_features->{'chr'},
								'source'	=> $method_source,
								'type'		=> $method_type,
								'start'		=> $transcript_features->{'start'},
								'end'		=> $transcript_features->{'end'},
								'score'		=> $residue_annotation->{'score'},
								'strand'	=> $transcript_features->{'strand'},
								'phase'		=> $method_phase
		};							
		# Optinal attributes
		my($optional_attributes);
		$optional_attributes->{'annotation'}		= $method_annotation;			
		$optional_attributes->{'gene_id'}			= $gene_id;
		$optional_attributes->{'transcript_id'}		= $transcript_id;
		$optional_attributes->{'transcript_name'}	= $transcript_features->{'external_id'};
		if (exists $transcript_features->{'ccds_id'} and defined $transcript_features->{'ccds_id'} and $transcript_features->{'ccds_id'} ne '') {
			$optional_attributes->{'ccds_id'} = $transcript_features->{'ccds_id'};
		}		
		$optional_attributes->{'version'}			= $version;
		if(defined $common_attributes and defined $optional_attributes)
		{
			$output_annotation.=printAnnotations($common_attributes,$optional_attributes);			
		}	
	}
	
	# Get APPRIS Annotations
	if(ref($residue_annotation) eq 'HASH')
		{ $method_score=$residue_annotation->{'score'} }
	$output_annotation.=getAPPRISAnnotations2($gene_id,$transcript_id,$transcript_features,$method_type,$method_score,$appris_annotation,$version);

	return $output_annotation;
	
} # End getCORSAIRAnnotations

1;