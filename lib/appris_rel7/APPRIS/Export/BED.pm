=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Export::BED - Utility functions for error handling

=head1 SYNOPSIS

  use APPRIS::Export::BED qw(get_annotations);
  
  or to get all methods just

  use APPRIS::Export::BED;

  eval { get_annotations("text to file",file_path) };
  if ($@) {
    print "Caught exception:\n$@";
  }

=head1 DESCRIPTION

The functions exported by this package provide a set of useful methods 
to export database values as BED format.

=head1 METHODS

=cut

package APPRIS::Export::BED;

use strict;
use warnings;
use Data::Dumper;

use APPRIS::Utils::Exception qw(throw warning deprecate);
use APPRIS::Utils::Constant qw(
	$OK_LABEL
	$NO_LABEL
	$UNKNOWN_LABEL
);

###################
# Global variable #
###################
use vars qw($LABEL_TRACKS $BED_TRACKS); # See at the end of the package

$LABEL_TRACKS = {
	'unknown'	=> $APPRIS::Utils::Constant::UNKNOWN_LABEL,
	'ok'		=> $APPRIS::Utils::Constant::OK_LABEL,
	'no'		=> $APPRIS::Utils::Constant::NO_LABEL,
};

$BED_TRACKS = [
	# APPRIS
	[
		{
			'title' => "track name=APPRIS_principal_isoform description='APPRIS principal isoform' visibility=2 color='0,0,0' group='0'",
			'body' => '' 
		},
	],
	# Firestar
	{
			'title' => "track name=Known_functional_residues description='Known functional residues' visibility=2 color='210,145,35' group='0'",
			'body' => '' 
	},		
	# Matador3D
	[
		{
				'title' => "track name=Known_3D_structure description='Regions with known 3D structure' visibility=2 color='198,8,6' group='0'",
				'body' => '' 
		},
	],		
	# SPADE
	[
		{
			'title' => "track name=Functional_domains description='Whole Pfam functional domains' visibility=2 color='118,156,2' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Damaged_functional_domains description='Damaged Pfam functional domains' visibility=2 color='118,156,2' group='0'",
			'body' => '' 
		},
	],
	# CORSAIR
	[	
		{
			'title' => "track name=Cross_species_evidence description='Isoform with most cross-species evidence' visibility=2 color='44,136,91' group='0'",
			'body' => '' 
		},	
	],	
	# INERTIA
	[
		{
			'title' => "track name=Neutrally_evolving_exons description='Neutrally evolving exons' visibility=2 color='0,64,128' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Unusually_evolving_exons description='Unusually evolving exons' visibility=2 color='0,64,128' group='0'",
			'body' => '' 
		}
	],
	# CRASH
	[
		{
			'title' => "track name=Signal_peptide_sequence description='Signal peptide sequences' visibility=2 color='117,91,45' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Mitochondrial_signal_sequence description='Mitochondrial signal sequences' visibility=2 color='117,91,45' group='0'",
			'body' => '' 
		}
	],
	# THUMP
	[
		{
			'title' => "track name=Transmembrane_helices description='Transmembrane helices' visibility=2 color='0,65,66' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Damaged_transmembrane_helices description='Damaged transmembrane helices' visibility=2 color='0,65,66' group='0'",
			'body' => '' 
		}
	],	
	# CExonic
	[
		{
			'title' => "track name=Exonic_structure_conserved_in_Mouse description='Exonic structures conserved in Mouse' visibility=2 color='122,92,159' group='0'",
			'body' => '' 
		},
		{
			'title' => "track name=Exonic_structure_not_conserved_in_Mouse description='Exonic structures not conserved in Mouse' visibility=2 color='122,92,159' group='0'",
			'body' => '' 
		}
	],	
];

=head2 get_annotations

  Arg [1]    : Listref of APPRIS::Gene or undef
  Arg [2]    : String - $position
               genome position (chr22:20116979-20137016)
  Arg [3]    : String - $source
               List of sources ('all', ... )
  Arg [4]    : String - $head
               flag of head title ('yes','no','only')
  Arg [5]    : String - $version
  Arg [6]    : String - $date
  Example    : get_annotations($feature,'chr22:20116979-20137016','no','appris');  
  Description: Retrieves text as BED format with the annotations.
  Returntype : String or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub get_annotations {
    my ($feature, $position, $source, $head, $version, $date) = @_;
    my ($output) = '';

	# Get the bed annotations
    if ( defined $head and ($head =~ /^only/) ) { # get only the head of bed track
    
	    if ( $position =~ /^chr([^\:]*):([^\-]*)-([^\$]*)$/ ) {
			my ($chromosome) = $1;
			my ($start) = $2;
			my ($end) = $3;
			
			#"ensGene ccdsGene burgeRnaSeqGemMapperAlign"			
			if ( $head =~ /^only:([^\$]*)$/ ) {
				my ($btrack) = $1;
		       	$output .=	"browser pack ";
		       	my (@btracks) = split(',',$btrack);
		       	foreach my $bt (@btracks) {
		       		$output .=	" $bt";
		       	}
		       	$output .= "\n";
			} 	       	
			$output .=	"track name=Empty description='' visibility=0 color='255,255,255'\n".
						"chr$chromosome\t$start\t$end\n";
	    }
	}
    elsif ( defined $head and (($head =~ /^yes/) or ($head =~ /^no/)) and
			defined $source and ($source ne '') and 
				(
					($source eq 'all') or 
					($source =~ /appris/) or
					($source =~ /firestar/) or
					($source =~ /matador3d/) or
					($source =~ /inertia_corsair/) or
					($source =~ /spade/) or
					($source =~ /corsair/) or
					($source =~ /inertia/) or
					($source =~ /crash/) or
					($source =~ /thump/) or
					($source =~ /cexonic/)
				)
	) {
		if ($feature and (ref($feature) ne 'ARRAY')) {
	    	if ($feature->isa("APPRIS::Gene")) {
				foreach my $transcript (@{$feature->transcripts}) {
					get_trans_annotations($transcript, $position, $source);
				}
	    	}
	    	elsif ($feature->isa("APPRIS::Transcript")) {
	    		get_trans_annotations($feature, $position, $source);
	    	}
	    	else {
				throw('Argument must be an APPRIS::Gene or APPRIS::Transcript');
	    	}
	    }
		elsif ($feature and (ref($feature) eq 'ARRAY') ) { # in the case that we have a list of objects
	    	foreach my $feat (@{$feature}) {
		    	if ($feat->isa("APPRIS::Gene")) {
					foreach my $transcript (@{$feat->transcripts}) {
			    		get_trans_annotations($transcript, $position, $source);
					}
		    	}
		    	elsif ($feat->isa("APPRIS::Transcript")) {
		    		get_trans_annotations($feature, $position, $source);
		    	}
		    	else {
					throw('Argument must be an APPRIS::Gene or APPRIS::Transcript');
		    	}    		
	    	}
		}
	    else {
			throw('Argument must be define');
	   	}
	   	
		#"ensGene ccdsGene burgeRnaSeqGemMapperAlign"			
		if ( $head =~ /^yes:([^\$]*)$/ ) {
			my ($btrack) = $1;
	       	$output .=	"browser pack ";
	       	my (@btracks) = split(',',$btrack);
	       	foreach my $bt (@btracks) {
	       		$output .=	" $bt";
	       	}
	       	$output .= "\n";
		} 	       	
		$output .= print_annotations($BED_TRACKS);
    }
    else {
		throw('Arguments must be define');
    }
    
    # Print output
	if ( $output ne '' ) {
		$output =
			"# --------------------------------------------------------------------------------------#\n".
			"# Date: $date                                                                     #\n".
			"# Version: $version                                                                    #\n".
			"# Description: Annotations for determining principal splice isoforms (APPRIS)           #\n".
			"# note: the start values of tracks are -1 due the UCSC Genome Growser does not so good. #\n".          
			"# --------------------------------------------------------------------------------------#\n".
			"browser position $position"."\n".
			"browser pix 800"."\n".
			"browser hide all"."\n".

			$output;
	}
	return $output;
}

=head2 get_trans_annotations

  Arg [1]    : APPRIS::Transcript or undef
  Arg [2]    : String - $position
               genome position (chr22:20116979-20137016)
  Arg [3]    : String - $source
               List of sources ('all', ... )
  Example    : get_annotations($feature,'chr22:20116979-20137016','appris');  
  Description: Retrieves bed information of transcript.
  Returntype : Nothing (reference output)

=cut

sub get_trans_annotations {
    my ($feature, $position, $source) = @_;

    if (ref($feature) and $feature->isa("APPRIS::Transcript")) {
   	    
		if ($feature->stable_id) {
			if ($feature->translate and $feature->translate->sequence) {
				my ($gene_id);
				my ($transcript_id) = $feature->stable_id;
				my ($external_id) = $feature->external_name;
				if ($feature->xref_identify) {
					foreach my $xref_identify (@{$feature->xref_identify}) {
						if ( $xref_identify->dbname eq 'Ensembl_Gene_Id' ) {
							$gene_id = $xref_identify->id;							
						}
					}		
				}
				if ( ($source =~ /appris/) or ($source eq 'all') ) {				
					get_appris_annotations(	$transcript_id,
	           									$feature,
	           									\$BED_TRACKS->[0]
					);
				}
				if ( ($source =~ /firestar/) or ($source eq 'all') ) {				
					get_firestar_annotations(	$transcript_id,
	           									$feature,
	           									\$BED_TRACKS->[1]
					);
				}
				if ( ($source =~ /matador3d/) or ($source eq 'all') ) {				
					get_matador3d_annotations(	$transcript_id,
	           									$feature,
	           									\$BED_TRACKS->[2]
					);
				}
				if ( ($source =~ /spade/) or ($source eq 'all') ) {				
					get_spade_annotations(	$transcript_id,
	           									$feature,
	           									\$BED_TRACKS->[3]
					);
				}
				if ( ($source =~ /corsair/) or ($source eq 'all') ) {				
					get_corsair_annotations(	$transcript_id,
	           									$feature,
	           									\$BED_TRACKS->[4]
					);
				}
				if ( ($source =~ /inertia/) or ($source eq 'all') ) {				
					get_inertia_annotations(	$transcript_id,
	           									$feature,
	           									\$BED_TRACKS->[5]
					);
				}
				if ( ($source =~ /crash/) or ($source eq 'all') ) {				
					get_crash_annotations(	$transcript_id,
	           									$feature,
	           									\$BED_TRACKS->[6]
					);
				}
				if ( ($source =~ /thump/) or ($source eq 'all') ) {				
					get_thump_annotations(	$transcript_id,
	           									$feature,
	           									\$BED_TRACKS->[7]
					);
				}
				if ( ($source =~ /cexonic/) or ($source eq 'all') ) {				
					get_cexonic_annotations(	$transcript_id,
	           									$feature,
	           									\$BED_TRACKS->[8]
					);
				}
			}
		}
    }
    else {
		throw('Argument must be correct');
   	}
}

=head2 print_data

  Arg [1]    : Hast - data attributes of bed
               $data = {
                   'chr'          => ''
                   'start'        => ''
                   'end'          => ''
                   'name'         => ''
                   'score'        => ''
                   'strand'       => ''
                   'thick_start'  => ''
                   'thick_end'    => ''
                   'color'        => ''
                   'blocks'       => ''
                   'block_sizes'  => ''
                   'block_starts' => ''
               };
  Example    : $annot = print_data($data);
  Description: Print the bed annotations.
               Chromosome Start End Name Score Strand 
                 ThickStart ThickEnd Color Blocks BlockSizes BlockStarts
                 
                 The start values are -1 due to UCSC Genome browser prints bad
  Returntype : String or ''

=cut

sub print_data {
	my ($data) = @_;
	
	my ($output) = '';
	my ($chromStart) = ($data->{'start'}-1);
	my ($chromEnd) = $data->{'end'};
	my ($chromStarts) = 0;

	$output .= 'chr'.$data->{'chr'}."\t".
						($data->{'start'}-1)."\t".
						$data->{'end'}."\t".
						$data->{'name'}."\t";

	if (exists $data->{'score'} and defined $data->{'score'} and
		exists $data->{'strand'} and defined $data->{'strand'}
	){
		$output .= $data->{'score'}."\t".
							$data->{'strand'}."\t";
	}

	if (exists $data->{'thick_start'} and defined $data->{'thick_start'} and
		exists $data->{'thick_end'} and defined $data->{'thick_end'} and
		exists $data->{'color'} and defined $data->{'color'} and
		exists $data->{'blocks'} and defined $data->{'blocks'}
	){
		$output .= ($data->{'thick_start'}-1)."\t".
							$data->{'thick_end'}."\t".
							$data->{'color'}."\t".
							$data->{'blocks'}."\t";
	}
	if (exists $data->{'block_sizes'} and defined $data->{'block_sizes'}) {
		my (@block_sizes) = @{$data->{'block_sizes'}};
		if ($data->{'strand'} eq '-') {
			@block_sizes=reverse @{$data->{'block_sizes'}};
		}
		
		foreach my $size (@block_sizes)
		{
			$output .= $size.',';
			$chromStarts += $size;
		}
		$output =~ s/,$/\t/;
	}

	if (exists $data->{'block_starts'} and defined $data->{'block_starts'}) {
		my (@block_starts) = @{$data->{'block_starts'}};
		if($data->{'strand'} eq '-') {
			@block_starts = reverse @{$data->{'block_starts'}};
		}
		
		foreach my $start (@block_starts) {
			$output .= $start.',';
		}
		$output =~ s/,$/\t/;
	}
	$output =~ s/\t$/\n/;
	
	# BED chromStarts[i]+chromStart must be less or equal than chromEnd:
	unless ( ($chromStart + $chromStarts) <= $chromEnd ) {
		$output = '#'.$output;
	}
	
	return $output;
}

=head2 print_annotations

  Arg [1]    : Hash - internal hash of bed annotations
  Example    : $annot = print_annotations($report);
  Description: Print the bed annotations.
  Returntype : String or ''

=cut
sub print_annotations {
	my ($report) = @_;
	my ($output) = '';
	
	foreach my $method_report (@{$report}) {
		if (ref($method_report) eq 'ARRAY') {
			foreach my $track_report (@{$method_report}) {
				unless($track_report->{'body'} eq '') {
					$output.=$track_report->{'title'}."\n".$track_report->{'body'};				
				}
			}
		}
		elsif (ref($method_report) eq 'HASH') {
			unless($method_report->{'body'} eq '') {
				$output.=$method_report->{'title'}."\n".$method_report->{'body'};			
			}
		}
	}
	return $output;
}

=head2 get_block_from_exon

  Arg [1]    : Int - start position
  Arg [2]    : Int - end position
  Arg [3]    : Int - start position of exon
  Arg [4]    : Int - end position of exon
  Example    : get_block_from_exon($e_start, $e_end, $b_start, $b_end);
  Description: Get the BED block from exon.
  Returntype : (Int- init, Int- size) or (undef,undef)
  Exceptions : none

=cut

sub get_block_from_exon {
	my ($pos_start, $pos_end, $exon_strand, $block_start, $block_end) = @_;
	my ($init,$length);
		
	my ($residue_start);
	my ($residue_size);
	my ($residue_end);
	if ($exon_strand eq '-') {
		$residue_start = abs($pos_end - $block_start);
		$residue_size = abs($pos_end - $pos_start) +1;
		
#print DATA_7 "\nRES_START:$exon_strand: residue_start = abs(pos_end - block_start): $residue_start = abs($pos_end - $block_start)\n";
#print DATA_7 "\nRES_SIZE:$exon_strand: residue_size = abs(pos_end - (pos_start +1)): $residue_size = abs($pos_end - ($pos_start +1))\n";
	} else {
		$residue_start = abs($pos_start - $block_start);
		$residue_size = abs($pos_start - $pos_end) +1;
		
#print DATA_7 "\nRES_START:$exon_strand: residue_start = abs(pos_start - block_start): $residue_start = abs($pos_start - $block_start)\n";
#print DATA_7 "\nRES_SIZE:$exon_strand: residue_size = abs((pos_start+1) - pos_end): $residue_size = abs(($pos_start+1) - $pos_end)\n";
	}		
	

	#if ( defined $residue_start and defined $residue_end and defined $residue_size ) {
	if ( defined $residue_start and defined $residue_size ) {
		$init = $residue_start;
		$length = $residue_size;
	}
	return ($init, $length);
}

=head2 get_appris_annotations

  Arg [1]    : String - the stable identifier of transcript
  Arg [4]    : APPRIS::Transcript
  Arg [5]    : Object - internal BED variable 
  Example    : $annot = get_appris_annotations($trans_id, $feat, $ref_out);  
  Description: Retrieves specific annotation.
  Returntype : String or undef

=cut

sub get_appris_annotations {
	my ($transcript_id, $feature, $ref_output) = @_;

	# Get annotations
 	if ( $feature->analysis ) {
 		my ($analysis) = $feature->analysis;
 		if ( $analysis->appris ) {
	 		my ($method) = $analysis->appris;
			if ( $method->principal_isoform_signal and ($method->principal_isoform_signal eq $APPRIS::Utils::Constant::OK_LABEL) ) {
				if ( $feature->exons ) {
					# get initial data					
					my ($exon_list) = $feature->exons;
					my ($num_exons) = scalar(@{$exon_list});
					my ($trans_chr) = $feature->chromosome;
					my ($trans_start) = $feature->start;
					my ($trans_end) = $feature->end;
					my ($trans_strand) = $feature->strand;
					my ($score) = 0;
					my ($thick_start) = $feature->start;
					my ($thick_end) = $feature->end;
					my ($color) = 0;
					my ($blocks) = $num_exons;					
					if ( $feature->translate and $feature->translate->cds ) {
						my ($cds_list) = $feature->translate->cds;
						my ($num_cds) = scalar(@{$cds_list});						
						if ($trans_strand eq '-') {
							$thick_start = $cds_list->[$num_cds-1]->start;
							$thick_end = $cds_list->[0]->end;
						}
						else {
							$thick_start = $cds_list->[0]->start; 
							$thick_end = $cds_list->[$num_cds-1]->end;
						}			
					}
					my ($data) = {
							'chr'			=> $trans_chr,
							'name'			=> $transcript_id,
							'start'			=> $trans_start,
							'end'			=> $trans_end,
							'strand'		=> $trans_strand,
							'score'			=> $score,
							'thick_start'	=> $thick_start,
							'thick_end'		=> $thick_end,			
							'color'			=> $color,
							'blocks'		=> $blocks
					};
					# get block annotations
					foreach my $exon (@{$exon_list}) {
						my ($pos_start) = $exon->start;
						my ($pos_end) = $exon->end;
						my ($pos_strand) = $exon->strand;
						if ($trans_strand eq '-') {
							$pos_start = $exon->end;
							$pos_end = $exon->start;
						}
						else {
							$pos_start = $exon->start;
							$pos_end = $exon->end;
						}
						my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'start'}, $data->{'end'});
						push(@{$data->{'block_starts'}}, $init);
						push(@{$data->{'block_sizes'}}, $length);
					}
					${$ref_output}->[0]->{'body'} .= print_data($data);
				}
			}
 		}
 	}
}

=head2 get_firestar_annotations

  Arg [1]    : String - the stable identifier of transcript
  Arg [4]    : APPRIS::Transcript
  Arg [5]    : Object - internal BED variable 
  Example    : $annot = get_firestar_annotations($trans_id, $feat, $ref_out);  
  Description: Retrieves specific annotation.
  Returntype : String or undef

=cut

sub get_firestar_annotations {
	my ($transcript_id, $feature, $ref_output) = @_;

	# Get annotations
 	if ( $feature->analysis ) {
 		my ($analysis) = $feature->analysis;
 		if ( $analysis->firestar ) {
	 		my ($method) = $analysis->firestar;
	 		# get residue annotations
			if ( defined $method->residues ) {

#open(DATA_7_F, ">>/tmp/data7.firestar.log");

				# get initial data
				my ($res_list) = $method->residues;				
				my ($num_res) = scalar(@{$res_list});
				my ($trans_chr) = $feature->chromosome;
				my ($trans_start) = $feature->start;
				my ($trans_end) = $feature->end;
				my ($trans_strand) = $feature->strand;
				my ($score) = 0;
				my ($thick_start) = $feature->start;
				my ($thick_end) = $feature->end;
				my ($color) = 0;
				my ($blocks) = 0;
				if ( $trans_strand eq '-' ) {
					$trans_start = $res_list->[$num_res-1]->end;
					$trans_end = $res_list->[0]->start;
					$thick_start = $trans_start;
					$thick_end = $trans_end;
				}
				else {
					$trans_start = $res_list->[0]->start; 
					$trans_end = $res_list->[$num_res-1]->end;
					$thick_start = $trans_start;
					$thick_end = $trans_end;
				}
				my ($data) = {
						'chr'			=> $trans_chr,
						'name'			=> $transcript_id,
						'start'			=> $trans_start,
						'end'			=> $trans_end,
						'strand'		=> $trans_strand,
						'score'			=> $score,
						'thick_start'	=> $thick_start,
						'thick_end'		=> $thick_end,			
						'color'			=> $color,
						'blocks'		=> $blocks
				};
#print DATA_7_F "RES_LIST: $transcript_id:\n".Dumper($res_list)."\n";				
#print DATA_7_F "DATA_7: $transcript_id:\n".Dumper($data)."\n";
				
				# get block annotations
				if ( $feature->translate and $feature->translate->cds ) {
					my ($translation) = $feature->translate;
					my ($cds_list) = $translation->cds;
					my ($num_cds) = scalar(@{$cds_list});
					foreach my $res (@{$res_list}) {
						my ($res_start) = $res->start;
						my ($res_end) = $res->end;
						my ($res_strand) = $res->strand;
						if ($res_strand eq '-') {
							$res_start = $res->end;
							$res_end = $res->start;
						}
#print DATA_7_F "RESIDUE:$transcript_id: start: $res_start end: $res_end\n";

						my ($contained_cds) = $translation->get_overlapping_cds($res_start, $res_end);

#print DATA_7_F "CONTAINED_CDS: $transcript_id:\n".Dumper($contained_cds)."\n";
						
						my (@sorted_contained_cds) = @{$contained_cds};
						for (my $i = 0; $i < scalar(@sorted_contained_cds); $i++) {
							my ($cds_out) = $sorted_contained_cds[$i];
							my ($cds_strand) = $cds_out->strand;
							my ($cds_phase) = $cds_out->phase;							
							if ( scalar(@sorted_contained_cds) == 1 ) { # Within one CDS
								my ($pos_start) = $res->start;
								my ($pos_end) = $res->end;
								my ($pos_strand) = $res->strand;
#print DATA_7_F "\nPOSITION:1cds: start: $pos_start end: $pos_end strand: $pos_strand thick_start: ".$data->{'thick_start'}. " thick_end: ".$data->{'thick_end'}."\n";					
								my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'thick_start'}, $data->{'thick_end'});
#print DATA_7_F "\nINIT:1cds: ($init, $length)\n";
								push(@{$data->{'block_starts'}}, $init);
								push(@{$data->{'block_sizes'}}, $length);
								$data->{'blocks'}++;	
								last;
							}												
							else { # Within several CDS
								my ($pos_start) = $cds_out->start;
								my ($pos_end) = $cds_out->end;
								my ($thick_start) = $data->{'thick_start'};
								my ($thick_end) = $data->{'thick_end'};
								if ( $i==0 ) {
									if ($trans_strand eq '-') {
										$pos_start = $cds_out->start;
										$pos_end = $res->start;
										# the residue falls down between two CDS
										if ( $cds_phase eq '0') {
											$thick_start = $thick_start;	
										}
										elsif ( $cds_phase eq '2') {
											$thick_start = $thick_start +1;
										}
									}
									else {
										$pos_start = $res->start;
										$pos_end = $cds_out->end;
									}
								}
								elsif ( $i == scalar(@sorted_contained_cds)-1 ) {
									if ( $trans_strand eq '-' ) {
										$pos_start = $res->end;
										$pos_end = $cds_out->end;
										# the residue falls down between two CDS
										if ( $cds_phase eq '0') {
											$thick_start = $thick_start;	
										}
										elsif ( $cds_phase eq '2') {
											$thick_start = $thick_start +1;
										}
									}
									else {
										$pos_start = $cds_out->start;
										$pos_end = $res->end;
									}
								}

#print DATA_7_F "\nPOSITION:+1cds: start: $pos_start end: $pos_end strand: $cds_strand thick_start: ".$data->{'thick_start'}. " thick_end: ".$data->{'thick_end'}."\n";					
#print DATA_7_F "\t\tres_start: ".$res->start." res_end".$res->end."\n";
								my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $cds_strand, $thick_start, $thick_end);
#print DATA_7_F "\nINIT:+1cds: ($init, $length)\n";
								push(@{$data->{'block_starts'}}, $init);
								push(@{$data->{'block_sizes'}}, $length);
								$data->{'blocks'}++;
							}
						}
					}
				}
				${$ref_output}->{'body'} .= print_data($data);
				
#close(DATA_7_F);
			}
 		}
 	}
}

=head2 get_matador3d_annotations

  Arg [1]    : String - the stable identifier of transcript
  Arg [4]    : APPRIS::Transcript
  Arg [5]    : Object - internal BED variable 
  Example    : $annot = get_matador3d_annotations($trans_id, $feat, $ref_out);  
  Description: Retrieves specific annotation.
  Returntype : String or undef

=cut

sub get_matador3d_annotations {
	my ($transcript_id, $feature, $ref_output) = @_;

	# Get annotations
 	if ( $feature->analysis ) {
 		my ($analysis) = $feature->analysis;
 		if ( $analysis->spade ) { 			
	 		my ($method) = $analysis->matador3d;
	 		# get residue annotations
			if ( defined $method->alignments ) {
				
				# get the residues with 'mini-exon' info
				my ($res_list) = $method->alignments;				
				my ($num_res) = scalar(@{$res_list});
				my ($res_exon);
				my ($res_mini_exon);
				foreach my $res (@{$res_list}) {
					if ( $res->type eq 'exon' ) {
						push(@{$res_exon}, $res);
					}
					elsif ( $res->type eq 'mini-exon' ) {
						push(@{$res_mini_exon}, $res);
					}
				}
				
				_aux_get_matador3d_annotations('mini-exon',
											$transcript_id,
											$feature,
											$res_mini_exon,
											$ref_output);
			}
 		}
 	}
}

sub _aux_get_matador3d_annotations {
	my ($type, $transcript_id, $feature, $aux_res_list, $ref_output) = @_;

	if ( (ref($aux_res_list) eq 'ARRAY') and (scalar(@{$aux_res_list}) > 0) ) {
		
		# sort the list of alignments
		my ($res_list);
		if ($feature->strand eq '-') {
			@{$res_list} = sort { $b->start <=> $a->start } @{$aux_res_list};
		}
		else {
			@{$res_list} = sort { $a->start <=> $b->start } @{$aux_res_list};
		}		
		# get initial data
		my ($num_res) = scalar(@{$res_list});		
		my ($trans_chr) = $feature->chromosome;
		my ($trans_start) = $feature->start;
		my ($trans_end) = $feature->end;
		my ($trans_strand) = $feature->strand;
		my ($score) = 0;
		my ($thick_start) = $feature->start;
		my ($thick_end) = $feature->end;
		my ($color) = 0;
		my ($blocks) = 0;
		if ( $trans_strand eq '-' ) {
			$trans_start = $res_list->[$num_res-1]->start;
			$trans_end = $res_list->[0]->end;
			$thick_start = $trans_start;
			$thick_end = $trans_end;
		}
		else {
			$trans_start = $res_list->[0]->start; 
			$trans_end = $res_list->[$num_res-1]->end;
			$thick_start = $trans_start;
			$thick_end = $trans_end;
		}
		my ($data) = {
				'chr'			=> $trans_chr,
				'name'			=> $transcript_id,
				'start'			=> $trans_start,
				'end'			=> $trans_end,
				'strand'		=> $trans_strand,
				'score'			=> $score,
				'thick_start'	=> $thick_start,
				'thick_end'		=> $thick_end,			
				'color'			=> $color,
				'blocks'		=> $blocks
		};
		# get block annotations
		if ( $feature->translate and $feature->translate->cds ) {
			my ($translation) = $feature->translate;
			my ($cds_list) = $translation->cds;
			my ($num_cds) = scalar(@{$cds_list});						
		
			foreach my $res (@{$res_list}) {
				my ($contained_cds) = $translation->get_overlapping_cds($res->start, $res->end);
				my (@sorted_contained_cds) = @{$contained_cds};
				for (my $i = 0; $i < scalar(@sorted_contained_cds); $i++) {
						
					if ( scalar(@sorted_contained_cds) == 1 ) { # Within one CDS
						my ($pos_start) = $res->start;
						my ($pos_end) = $res->end;
						my ($pos_strand) = $res->strand;
						if ($trans_strand eq '-') {
							$pos_start = $res->end;
							$pos_end = $res->start;
						}
						my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'thick_start'}, $data->{'thick_end'});
						push(@{$data->{'block_starts'}}, $init);
						push(@{$data->{'block_sizes'}}, $length);
						$data->{'blocks'}++;	
						last;
					}								
					else { # Within several CDS
						my ($cds_out) = $sorted_contained_cds[$i];
						my ($pos_start) = $cds_out->start;
						my ($pos_end) = $cds_out->end;
						my ($pos_strand) = $cds_out->strand;
						if ( $trans_strand eq '-' ) {
							$pos_start = $cds_out->end;
							$pos_end = $cds_out->start;
						}

						if ( $i==0 ) {
							if ($trans_strand eq '-') {
								$pos_start = $res->end;
								$pos_end = $cds_out->start;
							}
							else {
								$pos_start = $res->start;
								$pos_end = $cds_out->end;
							}
						}
						elsif ( $i == scalar(@sorted_contained_cds)-1 ) {
							if ( $trans_strand eq '-' ) {
								$pos_start = $cds_out->end;
								$pos_end = $res->start;
							}
							else {
								$pos_start = $cds_out->start;
								$pos_end = $res->end;
							}
						}
						my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'thick_start'}, $data->{'thick_end'});
						push(@{$data->{'block_starts'}}, $init);
						push(@{$data->{'block_sizes'}}, $length);
						$data->{'blocks'}++;	
					}
				}
			}
		}
		if ( $type eq 'mini-exon' ) {
			${$ref_output}->[0]->{'body'} .= print_data($data);							
		}
	}	
}

=head2 get_spade_annotations

  Arg [1]    : String - the stable identifier of transcript
  Arg [4]    : APPRIS::Transcript
  Arg [5]    : Object - internal BED variable 
  Example    : $annot = get_spade_annotations($trans_id, $feat, $ref_out);  
  Description: Retrieves specific annotation.
  Returntype : String or undef

=cut

sub get_spade_annotations {
	my ($transcript_id, $feature, $ref_output) = @_;

	# Get annotations
 	if ( $feature->analysis ) {
 		my ($analysis) = $feature->analysis;
 		if ( $analysis->spade ) { 			
	 		my ($method) = $analysis->spade;
	 		# get residue annotations
			if ( defined $method->regions ) {

#open(DATA_7, ">>/tmp/data7.spade.log");
				
				# get the residues with 'domain', 'domain_possibly_damaged', 'domain_damaged', and 'domain_wrong' separetly
				my ($res_list) = $method->regions;
				my ($num_res) = scalar(@{$res_list});
				my ($res_domains);
				my ($res_damaged_domains);
				foreach my $res (@{$res_list}) {
					if ( $res->type_domain eq 'domain' ) {
						push(@{$res_domains}, $res);
					}
					elsif ( $res->type_domain eq 'domain_possibly_damaged' ) {
						push(@{$res_damaged_domains}, $res);
					}
					elsif ( $res->type_domain eq 'domain_damaged' ) {
						push(@{$res_damaged_domains}, $res);
					}
					elsif ( $res->type_domain eq 'domain_wrong' ) {
						push(@{$res_damaged_domains}, $res);
					}
				}
				
				_aux_get_spade_annotations('domain',
											$transcript_id,
											$feature,
											$res_domains,
											$ref_output);
				_aux_get_spade_annotations('damaged_domain',
											$transcript_id,
											$feature,
											$res_damaged_domains,
											$ref_output);

#print DATA_7 "\nREPORT:$transcript_id:\n".Dumper($ref_output)."\n";
#close(DATA_7);

			}
 		}
 	}
}

sub _aux_get_spade_annotations {
	my ($type, $transcript_id, $feature, $aux_res_list, $ref_output) = @_;

#print DATA_7 "AUX_RES_LIST: $transcript_id:\n".Dumper($aux_res_list)."\n";
	if ( (ref($aux_res_list) eq 'ARRAY') and (scalar(@{$aux_res_list}) > 0) ) {
		
		# sort the list of alignments
		my ($res_list);
		if ($feature->strand eq '-') {
			@{$res_list} = sort { $b->start <=> $a->start } @{$aux_res_list};
		}
		else {
			@{$res_list} = sort { $a->start <=> $b->start } @{$aux_res_list};
		}
#print DATA_7 "RES_LIST: $transcript_id:\n".Dumper($res_list)."\n";
		
		# get initial data
		my ($num_res) = scalar(@{$res_list});		
		my ($trans_chr) = $feature->chromosome;
		my ($trans_start) = $feature->start;
		my ($trans_end) = $feature->end;
		my ($trans_strand) = $feature->strand;
		my ($score) = 0;
		my ($thick_start) = $feature->start;
		my ($thick_end) = $feature->end;
		my ($color) = 0;
		my ($blocks) = 0;
		if ( $trans_strand eq '-' ) {
			$trans_start = $res_list->[$num_res-1]->start;
			$trans_end = $res_list->[0]->end;
			$thick_start = $trans_start;
			$thick_end = $trans_end;
		}
		else {
			$trans_start = $res_list->[0]->start; 
			$trans_end = $res_list->[$num_res-1]->end;
			$thick_start = $trans_start;
			$thick_end = $trans_end;
		}
		my ($data) = {
				'chr'			=> $trans_chr,
				'name'			=> $transcript_id,
				'start'			=> $trans_start,
				'end'			=> $trans_end,
				'strand'		=> $trans_strand,
				'score'			=> $score,
				'thick_start'	=> $thick_start,
				'thick_end'		=> $thick_end,			
				'color'			=> $color,
				'blocks'		=> $blocks
		};
		# get block annotations
		if ( $feature->translate and $feature->translate->cds ) {
			my ($translation) = $feature->translate;
			my ($cds_list) = $translation->cds;
			my ($num_cds) = scalar(@{$cds_list});						
		
			foreach my $res (@{$res_list}) {
				my ($contained_cds) = $translation->get_overlapping_cds($res->start, $res->end);

#print DATA_7 "RES:$transcript_id: start: ".$res->start." end: ".$res->end."\n";
#print DATA_7 "CONTAINED_CDS:$transcript_id:\n".Dumper($contained_cds)."\n";
				
				my (@sorted_contained_cds) = @{$contained_cds};
				for (my $i = 0; $i < scalar(@sorted_contained_cds); $i++) {
						
					if ( scalar(@sorted_contained_cds) == 1 ) { # Within one CDS
						my ($pos_start) = $res->start;
						my ($pos_end) = $res->end;
						my ($pos_strand) = $res->strand;
						if ($trans_strand eq '-') {
							$pos_start = $res->end;
							$pos_end = $res->start;
						}

#print DATA_7 "\nPOSITION:1cds: start: $pos_start end: $pos_end strand: $pos_strand\n";
#print DATA_7 "\nTRACK:1cds: start: ".$data->{'thick_start'}." end: ".$data->{'thick_end'}."\n";													
						my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'thick_start'}, $data->{'thick_end'});
#print DATA_7 "\nINIT:1cds: ($init, $length)\n";
						push(@{$data->{'block_starts'}}, $init);
						push(@{$data->{'block_sizes'}}, $length);
						$data->{'blocks'}++;	
						last;
					}								
					else { # Within several CDS
						my ($cds_out) = $sorted_contained_cds[$i];
						my ($pos_start) = $cds_out->start;
						my ($pos_end) = $cds_out->end;
						my ($pos_strand) = $cds_out->strand;
						if ( $trans_strand eq '-' ) {
							$pos_start = $cds_out->end;
							$pos_end = $cds_out->start;
						}

						if ( $i==0 ) {
							if ($trans_strand eq '-') {
								$pos_start = $res->end;
								$pos_end = $cds_out->start;
							}
							else {
								$pos_start = $res->start;
								$pos_end = $cds_out->end;
							}
						}
						elsif ( $i == scalar(@sorted_contained_cds)-1 ) {
							if ( $trans_strand eq '-' ) {
								$pos_start = $cds_out->end;
								$pos_end = $res->start;
							}
							else {
								$pos_start = $cds_out->start;
								$pos_end = $res->end;
							}
						}
#print DATA_7 "\nPOSITION:1+cds: start: $pos_start end: $pos_end strand: $pos_strand\n";
						my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'thick_start'}, $data->{'thick_end'});
#print DATA_7 "\nINIT:1+cds: ($init, $length)\n";
						push(@{$data->{'block_starts'}}, $init);
						push(@{$data->{'block_sizes'}}, $length);
						$data->{'blocks'}++;	
					}
				}
			}
		}

#print DATA_7 "\nTYPE: $type\n";
		if ( $type eq 'domain' ) {
			${$ref_output}->[0]->{'body'} .= print_data($data);								
		}
		elsif ( $type eq 'damaged_domain' ) { # join the whole damaged domains
#print DATA_7 "\nENTRA\n";
			${$ref_output}->[1]->{'body'} .= print_data($data);								
		}
	}	
}

=head2 get_corsair_annotations

  Arg [1]    : String - the stable identifier of transcript
  Arg [4]    : APPRIS::Transcript
  Arg [5]    : Object - internal BED variable 
  Example    : $annot = get_corsair_annotations($trans_id, $feat, $ref_out);  
  Description: Retrieves specific annotation.
  Returntype : String or undef

=cut

sub get_corsair_annotations {
	my ($transcript_id, $feature, $ref_output) = @_;

	# Get annotations
 	if ( $feature->analysis ) {
 		my ($analysis) = $feature->analysis;
 		if ( $analysis->corsair ) {
	 		my ($method) = $analysis->corsair;
			if ( $feature->exons ) {

#open(DATA_7, ">/tmp/data7.log");
				
				# get initial data					
				my ($exon_list) = $feature->exons;
				my ($num_exons) = scalar(@{$exon_list});
				my ($trans_chr) = $feature->chromosome;
				my ($trans_start) = $feature->start;
				my ($trans_end) = $feature->end;
				my ($trans_strand) = $feature->strand;
				my ($score) = 0;
				my ($thick_start) = $feature->start;
				my ($thick_end) = $feature->end;
				my ($color) = 0;
				my ($blocks) = $num_exons;					
				if ( $feature->translate and $feature->translate->cds ) {
					my ($cds_list) = $feature->translate->cds;
					my ($num_cds) = scalar(@{$cds_list});						
					if ($trans_strand eq '-') {
						$thick_start = $cds_list->[$num_cds-1]->start;
						$thick_end = $cds_list->[0]->end;						
					}
					else {
						$thick_start = $cds_list->[0]->start; 
						$thick_end = $cds_list->[$num_cds-1]->end;
					}
#print DATA_7 "\nCDS:\n".Dumper($cds_list)."\n";

				}
				my ($data) = {
						'chr'			=> $trans_chr,
						'name'			=> $transcript_id,
						'start'			=> $trans_start,
						'end'			=> $trans_end,
						'strand'		=> $trans_strand,
						'score'			=> $score,
						'thick_start'	=> $thick_start,
						'thick_end'		=> $thick_end,			
						'color'			=> $color,
						'blocks'		=> $blocks
				};
#print DATA_7 "DATA_7: $transcript_id:\n".Dumper($data)."\n";
				
				# get block annotations
				foreach my $exon (@{$exon_list}) {
#print DATA_7 "\nRES:\n".Dumper($exon)."\n";
					
					my ($pos_start) = $exon->start;
					my ($pos_end) = $exon->end;
					my ($pos_strand) = $exon->strand;
					if ($trans_strand eq '-') {
						$pos_start = $exon->end;
						$pos_end = $exon->start;
					}
					else {
						$pos_start = $exon->start;
						$pos_end = $exon->end;
					}
#print DATA_7 "\nPOSITION_2: start: $pos_start end: $pos_end strand: $pos_strand\n";
#print DATA_7 "TRACK_7_2: $transcript_id:\n".Dumper($data)."\n";					
					my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'start'}, $data->{'end'});
#print DATA_7 "\nINIT_2: ($init, $length)\n";
					push(@{$data->{'block_starts'}}, $init);
					push(@{$data->{'block_sizes'}}, $length);
				}		
				if ( $method->vertebrate_signal and 
						( ($method->vertebrate_signal eq $APPRIS::Utils::Constant::OK_LABEL) or 
						($method->vertebrate_signal eq $APPRIS::Utils::Constant::UNKNOWN_LABEL) ) 
				) {
					${$ref_output}->[0]->{'body'} .= print_data($data);								
				}
				
#close(DATA_7);

			}
 		}
 	}
}

=head2 get_inertia_annotations

  Arg [1]    : String - the stable identifier of transcript
  Arg [4]    : APPRIS::Transcript
  Arg [5]    : Object - internal BED variable 
  Example    : $annot = get_inertia_annotations($trans_id, $feat, $ref_out);  
  Description: Retrieves specific annotation.
  Returntype : String or undef

=cut

sub get_inertia_annotations {
	my ($transcript_id, $feature, $ref_output) = @_;

	# Get annotations
 	if ( $feature->analysis ) {
 		my ($analysis) = $feature->analysis;
 		if ( $analysis->inertia ) {
	 		my ($method) = $analysis->inertia;
	 		# get residue annotations
			if ( defined $method->regions ) {
				# get the residues with 'neutral_evolution', and 'unusual_evolution' separetly
				my ($res_list) = $method->regions;
				my ($num_res) = scalar(@{$res_list});
				my ($res_evol);
				my ($res_u_evol);
				foreach my $res (@{$res_list}) {
					if ( $res->unusual_evolution eq $APPRIS::Utils::Constant::UNKNOWN_LABEL ) {
						push(@{$res_evol}, $res);
					}
					elsif ( $res->unusual_evolution eq $APPRIS::Utils::Constant::NO_LABEL ) {
						push(@{$res_u_evol}, $res);
					}
				}
#open(DATA_7, ">/tmp/data7.log");
				
				_aux_get_inertia_annotations('neutral_evolution',
											$transcript_id,
											$feature,
											$res_evol,
											$ref_output);
				_aux_get_inertia_annotations('unusual_evolution',
											$transcript_id,
											$feature,
											$res_u_evol,
											$ref_output);

#print DATA_7 "\nREPORT:\n".Dumper($ref_output)."\n";
#close(DATA_7);

			}
 		}
 	}
}

sub _aux_get_inertia_annotations {
	my ($type, $transcript_id, $feature, $res_list2, $ref_output) = @_;

	my ($res_list);
	if (defined $res_list2) {
		if($feature->strand eq '-') {
			@{$res_list} = sort { $b->{'start'} <=> $a->{'start'} } @{$res_list2};
		}
		else {
			@{$res_list} = sort { $a->{'start'} <=> $b->{'start'} } @{$res_list2};
		}		
	}

#print DATA_7 "RES_LIST: $transcript_id:\n".Dumper($res_list)."\n";
	if ( (ref($res_list) eq 'ARRAY') and (scalar(@{$res_list}) > 0) ) {
		# get initial data
		my ($num_res) = scalar(@{$res_list});		
		my ($trans_chr) = $feature->chromosome;
		my ($trans_start) = $feature->start;
		my ($trans_end) = $feature->end;
		my ($trans_strand) = $feature->strand;
		my ($score) = 0;
		my ($thick_start) = $feature->start;
		my ($thick_end) = $feature->end;
		my ($color) = 0;
		my ($blocks) = 0;
		if ( $trans_strand eq '-' ) {
			$trans_start = $res_list->[$num_res-1]->start;
			$trans_end = $res_list->[0]->end;
			$thick_start = $trans_start;
			$thick_end = $trans_end;
		}
		else {
			$trans_start = $res_list->[0]->start; 
			$trans_end = $res_list->[$num_res-1]->end;
			$thick_start = $trans_start;
			$thick_end = $trans_end;
		}
				
		my ($data) = {
				'chr'			=> $trans_chr,
				'name'			=> $transcript_id,
				'start'			=> $trans_start,
				'end'			=> $trans_end,
				'strand'		=> $trans_strand,
				'score'			=> $score,
				'thick_start'	=> $thick_start,
				'thick_end'		=> $thick_end,			
				'color'			=> $color,
				'blocks'		=> $blocks
		};
					
		# get block annotations
		foreach my $res (@{$res_list}) {
			my ($pos_start) = $res->start;
			my ($pos_end) = $res->end;
			my ($pos_strand) = $res->strand;
			if ($trans_strand eq '-') {
				$pos_start = $res->end;
				$pos_end = $res->start;
			}
			else {
				$pos_start = $res->start;
				$pos_end = $res->end;
			}
			my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'thick_start'}, $data->{'thick_end'});
			push(@{$data->{'block_starts'}}, $init);
			push(@{$data->{'block_sizes'}}, $length);
			$data->{'blocks'}++;	

		}
		if ( $type eq 'neutral_evolution' ) {
			${$ref_output}->[0]->{'body'} .= print_data($data);								
		}
		elsif ( $type eq 'unusual_evolution' ) {
			${$ref_output}->[1]->{'body'} .= print_data($data);								
		}		
	}	
}

=head2 get_crash_annotations

  Arg [1]    : String - the stable identifier of transcript
  Arg [4]    : APPRIS::Transcript
  Arg [5]    : Object - internal BED variable 
  Example    : $annot = get_crash_annotations($trans_id, $feat, $ref_out);  
  Description: Retrieves specific annotation.
  Returntype : String or undef

=cut

sub get_crash_annotations {
	my ($transcript_id, $feature, $ref_output) = @_;

	# Get annotations
 	if ( $feature->analysis ) {
 		my ($analysis) = $feature->analysis;
 		if ( $analysis->crash ) {
	 		my ($method) = $analysis->crash;
	 		# get residue annotations
			if ( defined $method->regions ) {

#open(DATA_7_F, ">/tmp/data7.firestar.log");

				# get initial data
				my ($res_list) = $method->regions;				
				my ($num_res) = scalar(@{$res_list});
				my ($trans_chr) = $feature->chromosome;
				my ($trans_start) = $feature->start;
				my ($trans_end) = $feature->end;
				my ($trans_strand) = $feature->strand;
				my ($score) = 0;
				my ($thick_start) = $feature->start;
				my ($thick_end) = $feature->end;
				my ($color) = 0;
				my ($blocks) = 0;
				if ( $trans_strand eq '-' ) {
					$trans_start = $res_list->[$num_res-1]->start;
					$trans_end = $res_list->[0]->end;
					$thick_start = $trans_start;
					$thick_end = $trans_end;
				}
				else {
					$trans_start = $res_list->[0]->start; 
					$trans_end = $res_list->[$num_res-1]->end;
					$thick_start = $trans_start;
					$thick_end = $trans_end;
				}
				my ($data) = {
						'chr'			=> $trans_chr,
						'name'			=> $transcript_id,
						'start'			=> $trans_start,
						'end'			=> $trans_end,
						'strand'		=> $trans_strand,
						'score'			=> $score,
						'thick_start'	=> $thick_start,
						'thick_end'		=> $thick_end,			
						'color'			=> $color,
						'blocks'		=> $blocks
				};
#print DATA_7_F "RES_LIST: $transcript_id:\n".Dumper($res_list)."\n";				
#print DATA_7_F "DATA_7: $transcript_id:\n".Dumper($data)."\n";
				
				# get block annotations
				if ( $feature->translate and $feature->translate->cds ) {
					my ($translation) = $feature->translate;
					my ($cds_list) = $translation->cds;
					my ($num_cds) = scalar(@{$cds_list});						
					foreach my $res (@{$res_list}) {
						my ($contained_cds) = $translation->get_overlapping_cds($res->start, $res->end);
						my (@sorted_contained_cds) = @{$contained_cds};
						for (my $i = 0; $i < scalar(@sorted_contained_cds); $i++) {
							
							if ( scalar(@sorted_contained_cds) == 1 ) { # Within one CDS
								my ($pos_start) = $res->start;
								my ($pos_end) = $res->end;
								my ($pos_strand) = $res->strand;
								if ($trans_strand eq '-') {
									$pos_start = $res->end;
									$pos_end = $res->start;
								}
#print DATA_7_F "\nPOSITION: start: $pos_start end: $pos_end strand: $pos_strand\n";								
								my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'thick_start'}, $data->{'thick_end'});
#print DATA_7_F "\nINIT: ($init, $length)\n";
								push(@{$data->{'block_starts'}}, $init);
								push(@{$data->{'block_sizes'}}, $length);
								$data->{'blocks'}++;	
								last;
							}
							else { # Within several CDS
								my ($cds_out) = $sorted_contained_cds[$i];
								my ($pos_start) = $cds_out->start;
								my ($pos_end) = $cds_out->end;
								my ($pos_strand) = $cds_out->strand;				
								if ( $i==0 ) {
									if ($trans_strand eq '-') {
										#$pos_start = $cds_out->start;
										#$pos_end = $res->end;
										$pos_start = $res->end;
										$pos_end = $cds_out->start;
									}
									else {
										$pos_start = $res->start;
										$pos_end = $cds_out->end;
									}
								}
								elsif ( $i == scalar(@sorted_contained_cds)-1 ) {
									if ( $trans_strand eq '-' ) {
										#$pos_start = $res->start;
										#$pos_end = $cds_out->end;
										$pos_start = $cds_out->end;
										$pos_end = $res->start;
									}
									else {
										$pos_start = $cds_out->start;
										$pos_end = $res->end;
									}
								}
#print DATA_7_F "\nPOSITION: start: $pos_start end: $pos_end strand: $pos_strand\n";
								my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'thick_start'}, $data->{'thick_end'});
#print DATA_7_F "\nINIT: ($init, $length)\n";
								push(@{$data->{'block_starts'}}, $init);
								push(@{$data->{'block_sizes'}}, $length);
								$data->{'blocks'}++;	
							}
						}
					}
				}
				if ( $method->peptide_signal and ($method->peptide_signal eq $APPRIS::Utils::Constant::OK_LABEL) ){
					${$ref_output}->[0]->{'body'} .= print_data($data);								
				}
				if ( $method->mitochondrial_signal and ($method->mitochondrial_signal eq $APPRIS::Utils::Constant::OK_LABEL) ){
					${$ref_output}->[1]->{'body'} .= print_data($data);								
				}
				
#close(DATA_7_F);
			}
 		}
 	}
}

=head2 get_thump_annotations

  Arg [1]    : String - the stable identifier of transcript
  Arg [4]    : APPRIS::Transcript
  Arg [5]    : Object - internal BED variable 
  Example    : $annot = get_thump_annotations($trans_id, $feat, $ref_out);  
  Description: Retrieves specific annotation.
  Returntype : String or undef

=cut

sub get_thump_annotations {
	my ($transcript_id, $feature, $ref_output) = @_;

	# Get annotations
 	if ( $feature->analysis ) {
 		my ($analysis) = $feature->analysis;
 		if ( $analysis->thump ) {
	 		my ($method) = $analysis->thump;
	 		# get residue annotations
			if ( defined $method->regions ) {
				# get the residues with 'transmembrane_helixes', and 'damaged_transmembrane_helixes' separetly
				my ($res_list) = $method->regions;
				my ($num_res) = scalar(@{$res_list});
				my ($res_helix);
				my ($res_helix_damaged);
#print STDERR "\nREGIONS:\n".Dumper($res_list)."\n";
				foreach my $res (@{$res_list}) {
					if (defined $res->damaged and ($res->damaged eq '1') ) {
						push(@{$res_helix_damaged}, $res);
					}
					else {
						push(@{$res_helix}, $res);
					}
				}
#open(DATA_7, ">/tmp/data7.log");
				
				_aux_get_thump_annotations('transmembrane_helixes',
											$transcript_id,
											$feature,
											$res_helix,
											$ref_output);
				_aux_get_thump_annotations('damaged_transmembrane_helixes',
											$transcript_id,
											$feature,
											$res_helix_damaged,
											$ref_output);
#print DATA_7 "\nREPORT:\n".Dumper($ref_output)."\n";
#close(DATA_7);

			}
 		}
 	}
}

sub _aux_get_thump_annotations {
	my ($type, $transcript_id, $feature, $res_list, $ref_output) = @_;

#print DATA_7 "RES_LIST: $transcript_id:\n".Dumper($res_list)."\n";
	if ( (ref($res_list) eq 'ARRAY') and (scalar(@{$res_list}) > 0) ) {
		# get initial data
		my ($num_res) = scalar(@{$res_list});		
		my ($trans_chr) = $feature->chromosome;
		my ($trans_start) = $feature->start;
		my ($trans_end) = $feature->end;
		my ($trans_strand) = $feature->strand;
		my ($score) = 0;
		my ($thick_start) = $feature->start;
		my ($thick_end) = $feature->end;
		my ($color) = 0;
		my ($blocks) = 0;
		if ( $trans_strand eq '-' ) {
			$trans_start = $res_list->[$num_res-1]->start;
			$trans_end = $res_list->[0]->end;
			$thick_start = $trans_start;
			$thick_end = $trans_end;
		}
		else {
			$trans_start = $res_list->[0]->start; 
			$trans_end = $res_list->[$num_res-1]->end;
			$thick_start = $trans_start;
			$thick_end = $trans_end;
		}
						
		my ($data) = {
				'chr'			=> $trans_chr,
				'name'			=> $transcript_id,
				'start'			=> $trans_start,
				'end'			=> $trans_end,
				'strand'		=> $trans_strand,
				'score'			=> $score,
				'thick_start'	=> $thick_start,
				'thick_end'		=> $thick_end,			
				'color'			=> $color,
				'blocks'		=> $blocks
		};
#print DATA_7 "\nDATA: \n".Dumper($data)."\n";
		
		# get block annotations
		if ( $feature->translate and $feature->translate->cds ) {
			my ($translation) = $feature->translate;
			my ($cds_list) = $translation->cds;
			my ($num_cds) = scalar(@{$cds_list});						
			foreach my $res (@{$res_list}) {
				my ($contained_cds) = $translation->get_overlapping_cds($res->start, $res->end);
				my (@sorted_contained_cds) = @{$contained_cds};
				for (my $i = 0; $i < scalar(@sorted_contained_cds); $i++) {
					
					if ( scalar(@sorted_contained_cds) == 1 ) { # Within one CDS
						my ($pos_start) = $res->start;
						my ($pos_end) = $res->end;
						my ($pos_strand) = $res->strand;
						if ($trans_strand eq '-') {
							$pos_start = $res->end;
							$pos_end = $res->start;
						}
												
#print DATA_7 "\nPOSITION: start: $pos_start end: $pos_end strand: $pos_strand\n";
#print DATA_7 "\nTRACK: start: ".$data->{'thick_start'}." end: ".$data->{'thick_end'}."\n";
						my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'thick_start'}, $data->{'thick_end'});
#print DATA_7 "\nINIT: ($init, $length)\n";
						push(@{$data->{'block_starts'}}, $init);
						push(@{$data->{'block_sizes'}}, $length);
						$data->{'blocks'}++;	
						last;
					}
					else { # Within several CDS
						my ($cds_out) = $sorted_contained_cds[$i];
						my ($pos_start) = $cds_out->start;
						my ($pos_end) = $cds_out->end;
						my ($pos_strand) = $cds_out->strand;				
						if ( $i==0 ) {
							if ($trans_strand eq '-') {
								#$pos_start = $cds_out->start;
								#$pos_end = $res->end;
								$pos_start = $res->end;
								$pos_end = $cds_out->start;
							}
							else {
								$pos_start = $res->start;
								$pos_end = $cds_out->end;
							}
						}
						elsif ( $i == scalar(@sorted_contained_cds)-1 ) {
							if ( $trans_strand eq '-' ) {
								#$pos_start = $res->start;
								#$pos_end = $cds_out->end;
								$pos_start = $cds_out->end;
								$pos_end = $res->start;
							}
							else {
								$pos_start = $cds_out->start;
								$pos_end = $res->end;
							}
						}
#print DATA_7 "\nPOSITION_2: start: $pos_start end: $pos_end strand: $pos_strand\n";
						my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'thick_start'}, $data->{'thick_end'});
#print DATA_7 "\nINIT_2: ($init, $length)\n";
						push(@{$data->{'block_starts'}}, $init);
						push(@{$data->{'block_sizes'}}, $length);
						$data->{'blocks'}++;	
					}
				}
			}
		}
		if ( $type eq 'transmembrane_helixes' ) {
			${$ref_output}->[0]->{'body'} .= print_data($data);								
		}
		elsif ( $type eq 'damaged_transmembrane_helixes' ) {
			${$ref_output}->[1]->{'body'} .= print_data($data);								
		}
	}	
}

=head2 get_cexonic_annotations

  Arg [1]    : String - the stable identifier of transcript
  Arg [4]    : APPRIS::Transcript
  Arg [5]    : Object - internal BED variable 
  Example    : $annot = get_cexonic_annotations($trans_id, $feat, $ref_out);  
  Description: Retrieves specific annotation.
  Returntype : String or undef

=cut

sub get_cexonic_annotations {
	my ($transcript_id, $feature, $ref_output) = @_;

	# Get annotations
 	if ( $feature->analysis ) {
 		my ($analysis) = $feature->analysis;
 		if ( $analysis->cexonic ) {
	 		my ($method) = $analysis->cexonic;
			if ( $feature->exons ) {

#print STDERR "\nENTRA!!!!!!!!!!!\n";
#open(DATA_7, ">/tmp/data7.log");
				
				# get initial data					
				my ($exon_list) = $feature->exons;
				my ($num_exons) = scalar(@{$exon_list});
				my ($trans_chr) = $feature->chromosome;
				my ($trans_start) = $feature->start;
				my ($trans_end) = $feature->end;
				my ($trans_strand) = $feature->strand;
				my ($score) = 0;
				my ($thick_start) = $feature->start;
				my ($thick_end) = $feature->end;
				my ($color) = 0;
				my ($blocks) = $num_exons;					
				if ( $feature->translate and $feature->translate->cds ) {
					my ($cds_list) = $feature->translate->cds;
					my ($num_cds) = scalar(@{$cds_list});						
					if ($trans_strand eq '-') {
						$thick_start = $cds_list->[$num_cds-1]->start;
						$thick_end = $cds_list->[0]->end;						
					}
					else {
						$thick_start = $cds_list->[0]->start; 
						$thick_end = $cds_list->[$num_cds-1]->end;
					}
#print DATA_7 "\nCDS:\n".Dumper($cds_list)."\n";

				}
				my ($data) = {
						'chr'			=> $trans_chr,
						'name'			=> $transcript_id,
						'start'			=> $trans_start,
						'end'			=> $trans_end,
						'strand'		=> $trans_strand,
						'score'			=> $score,
						'thick_start'	=> $thick_start,
						'thick_end'		=> $thick_end,			
						'color'			=> $color,
						'blocks'		=> $blocks
				};
#print DATA_7 "DATA_7: $transcript_id:\n".Dumper($data)."\n";
				
				# get block annotations
				foreach my $exon (@{$exon_list}) {
#print DATA_7 "\nRES:\n".Dumper($exon)."\n";
					
					my ($pos_start) = $exon->start;
					my ($pos_end) = $exon->end;
					my ($pos_strand) = $exon->strand;
					if ($trans_strand eq '-') {
						$pos_start = $exon->end;
						$pos_end = $exon->start;
					}
					else {
						$pos_start = $exon->start;
						$pos_end = $exon->end;
					}
#print DATA_7 "\nPOSITION_2: start: $pos_start end: $pos_end strand: $pos_strand\n";
#print DATA_7 "TRACK_7_2: $transcript_id:\n".Dumper($data)."\n";					
					my ($init, $length) = get_block_from_exon($pos_start, $pos_end, $pos_strand, $data->{'start'}, $data->{'end'});
#print DATA_7 "\nINIT_2: ($init, $length)\n";
					push(@{$data->{'block_starts'}}, $init);
					push(@{$data->{'block_sizes'}}, $length);
				}

#print STDERR "DATA: $transcript_id:\n".Dumper($data)."\n";					
#print STDERR "METHOD:\n".Dumper($method)."\n";					

				if ( $method->conservation_exon and ($method->conservation_exon eq $APPRIS::Utils::Constant::UNKNOWN_LABEL) ) {
					${$ref_output}->[0]->{'body'} .= print_data($data);								
				}
				elsif ( $method->conservation_exon and ($method->conservation_exon eq $APPRIS::Utils::Constant::NO_LABEL) ) {
					${$ref_output}->[1]->{'body'} .= print_data($data);								
				}
				
#close(DATA_7);

			}
 		}
 	}
}

1;