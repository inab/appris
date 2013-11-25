=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

Retrieve

=head1 DESCRIPTION

Package the retrieves the results of methods

=head1 METHODS

=cut

package Retrieve;

use strict;
use warnings;
use FindBin;
use APPRIS::Registry;
use APPRIS::Exporter;
use APPRIS::Utils::Constant qw(
        $OK_LABEL
);

use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(
	get_method_result
	get_report_by_stable_id
	get_report_by_xref_entry
	get_report_by_position
	get_vmethod_result
	get_sequence_result
	get_img_seq_result
	get_residues_result
);

###################
# Global variable #
###################
my ($OK_LABEL) = $APPRIS::Utils::Constant::OK_LABEL;

use vars qw(
	$CONFIG_INI_FILE
	$HEAD
	$VHEAD
	$SEQ_FORMAT
	$DESC
);

$CONFIG_INI_FILE = "$FindBin::Bin/../conf/config.ini";
$HEAD = {
	'appris' => 
"# gene_id\ttrans_id\n",	
};
$VHEAD = {
	'cexonic' =>
"# human exons no.\tmouse exons no.\tnon-aligned introns no.\n",
	'corsair' =>
"# nearest homologue\t%ID\n",
	'crash'	=>
"# type signal\tstart\tend\n",
	'firestar' =>
"# residue\tamino acid\tligand\treliability score (1-->6)\n",
	'inertia' =>
"# SLR Omega score\texon start\texon end\n",
	'matador3d' =>
"# residues\tbest template\t%ID\n",
	'spade' =>
"# start\tend\tdomain name\tthe best e-value\n",
	'thump' =>
"# helix start\thelix end\tdamaged\n",
};

$SEQ_FORMAT = 'fasta';

$DESC = <<EOF; 
/*
 * APPRIS (http://appris.bioinfo.cnio.es)
 *   is a database server that deploys a range of computational methods 
 *   to provide value to the annotations of the human genome.
 *   The database selects one of the CDS for each gene as the 
 *   principal functional combining protein structural information, 
 *   functionally important residues and evidences of non-netrual 
 *   evolution of exons amongst others.
 *   
 *   For more information, please read the documentation of REST web services.
 *   http://appris.bioinfo.cnio.es/docs/aws.html#rest
 *
 *   APPRIS is powered by the Structural Computational Biology Group 
 *   at the Spanish National Cancer Research Centre (CNIO, http://www.cnio.es).
 *
 *   If you have questions or comments, please write to:
 *   Jose Manuel Rodriguez (jmrodriguez\@cnio.es)
 *   or
 *   Michael Tress (mtress\@cnio.es)
 * 
 */

EOF

#####################
# Method prototypes #
#####################


=head2 get_method_result

  Arg [1]    : String $type
               type of input: 'id' or 'name'
  Arg [2]    : String $input
               gene or transcript identifier (or name)
  Arg [3]    : String $method
               method name
  Example    : use Retrieve qw(get_method_result);
               my $rst = get_method_result($type, $input, $method);
  Description: Throws an exception which if not caught by an eval will
               provide a stack trace to STDERR and die.  If the verbosity level
               is lower than the level of the throw, then no error message is
               displayed but the program will still die (unless the exception
               is caught).
  Returntype : none
  Exceptions : thrown every time
  Caller     : generally on error

=cut
sub get_method_result {
	my ($type, $input, $method) = @_;
	
	my ($analysis);
	my ($result);	
	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);	

	if ( $type eq 'id' ) {
		$analysis = $registry->fetch_analysis_by_stable_id($input, $method);
	}
	elsif ( $type eq 'name' ) {
		$analysis = $registry->fetch_analysis_by_xref_entry($input, $method);
	}

	if ( defined $analysis and ($method eq 'appris') ) {
		if ( $analysis->appris and $analysis->appris->result ) {
			$result .= $analysis->appris->result;
		}		
	}
	elsif ( defined $analysis and ($method eq 'cexonic') ) {
		if ( $analysis->cexonic and $analysis->cexonic->result ) {
			$result .= $analysis->cexonic->result;
		}	
	}
	elsif ( defined $analysis and ($method eq 'corsair') ) {
		if ( $analysis->corsair and $analysis->corsair->result ) {
			$result .= $analysis->corsair->result;
		}	
	}
	elsif ( defined $analysis and ($method eq 'crash') ) {
		if ( $analysis->crash and $analysis->crash->result ) {
			$result .= $analysis->crash->result;
		}	
	}
	elsif ( defined $analysis and ($method eq 'firestar') ) {
		if ( $analysis->firestar and $analysis->firestar->result ) {
			$result .= $analysis->firestar->result;
		}	
	}
	elsif ( defined $analysis and ($method eq 'inertia') ) {
		if ( $analysis and $analysis->inertia ) {		
			$result = get_inertia_report($analysis);
		}
	}
	elsif ( defined $analysis and ($method eq 'matador3d') ) {
		if ( $analysis->matador3d and $analysis->matador3d->result ) {
			$result .= $analysis->matador3d->result;
		}	
	}
	elsif ( defined $analysis and ($method eq 'spade') ) {
		if ( $analysis->spade and $analysis->spade->result ) {
			$result .= $analysis->spade->result;
		}	
	}
	elsif ( defined $analysis and ($method eq 'thump') ) {
		if ( $analysis->thump and $analysis->thump->result ) {
			$result .= $analysis->thump->result;
		}	
	}
	
	return $result;
}

=head2 get_report_by_position

  Arg [1]    : String $position
               input: chr(\w*):(\d*)-(\d*)
  Example    : use Retrieve qw(get_method_result);
               my $rst = get_report_by_position($position);
  Example    : $gene = $registry->fetch_basic_by_region('M:1-1000');
  Description: Retrieves a listref of gene object 
               from the database via its stable id.
               If the regions is not found undef is returned instead.
  Returntype : Listref of APPRIS::Gene or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut
sub get_report_by_position($)
{
	my ($position) = @_;
	my ($features);
	
	if ( $position =~ /^chr(\w*):(\d*)-(\d*)$/ ) {
		my ($chr) = $1;
		my ($start) = $2;
		my ($end) = $3;
		
		my ($registry) = APPRIS::Registry->new();
		$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);			
		$features = $registry->fetch_by_position($chr, $start, $end);		
	}
	
	return $features;	
}

=head2 get_report_by_stable_id

  Arg [1]    : String $id 
               The stable ID of the entity to retrieve
  Example    : use Retrieve qw(get_report_by_stable_id);
               my $rst = get_report_by_stable_id($id);
  Description: Retrieves a entity object (gene or transcript) 
               from the database via its stable id.
               If the gene or transcript is not found
               undef is returned instead.
               Note: Entity object contains the results of analysis methods.
  Returntype : APPRIS::Gene or APPRIS::Transcript or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut
sub get_report_by_stable_id($)
{
	my ($id) = @_;
	my ($features);

	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);			

	if ( $id=~/^ENSG/ ) {
		$features = $registry->fetch_by_stable_id('gene', $id);
	}
	elsif ( $id=~/^ENST/ ) {
		$features = $registry->fetch_by_stable_id('transcript', $id);
	}
	
	return $features;	
}

=head2 get_report_by_xref_entry

  Arg [1]    : String $xref_entry 
               An external identifier of the entity to be obtained
  Example    : use Retrieve qw(get_report_by_xref_entry);
               my $rst = get_report_by_xref_entry($id);
  Description: Retrieves a entity object (gene or transcript) 
               from the database via external reference entry.
               If the gene or transcript is not found
               undef is returned instead.
               Note: Entity object contains the results of analysis methods.
  Returntype : APPRIS::Gene or APPRIS::Transcript or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut
sub get_report_by_xref_entry($)
{
	my ($name) = @_;

	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);			
	my ($features) = $registry->fetch_by_xref_entry($name);
	
	return $features;	
}
		

sub get_inertia_report($)
{
	my ($analysis) = @_;
	my ($result);

	if ( $analysis->inertia->result ) {
		$result .= "### Neutral evolutionary rates of exons ###\n";
 		$result .= $analysis->inertia->result."\n";
	}
	
	if ( $analysis->inertia->mafft_alignment and $analysis->inertia->mafft_alignment->result ) {
		$result .= "### Evolutionary rates of exons from MAF alignment ###\n";
 		$result .= $analysis->inertia->mafft_alignment->result."\n";
	}
	
	if ( $analysis->inertia->prank_alignment and $analysis->inertia->prank_alignment->result ) {
		$result .= "### Evolutionary rates of exons from Prank alignment ###\n";
 		$result .= $analysis->inertia->prank_alignment->result."\n";
	}
			
	if ( $analysis->inertia->kalign_alignment and $analysis->inertia->kalign_alignment->result ) {
		$result .= "### Evolutionary rates of exons from Kalign alignment ###\n";
		$result .= $analysis->inertia->kalign_alignment->result."\n";
	}
	return $result;
}

=head2 get_vmethod_result

  Arg [1]    : String $type
               type of input: 'id' or 'name'
  Arg [2]    : String $input
               gene or transcript identifier (or name)
  Arg [3]    : String $method
               method name
  Example    : use Retrieve qw(get_method_result);
               my $rst = get_vmethod_result($type, $input, $method);
  Description: Throws an exception which if not caught by an eval will
               provide a stack trace to STDERR and die.  If the verbosity level
               is lower than the level of the throw, then no error message is
               displayed but the program will still die (unless the exception
               is caught).
  Returntype : none
  Exceptions : thrown every time
  Caller     : generally on error

=cut
sub get_vmethod_result {
	my ($type, $input, $method) = @_;
	
	my ($analysis);
	my ($result);	
	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);	

	if ( $type eq 'id' ) {
		$analysis = $registry->fetch_analysis_by_stable_id($input, $method);
	}
	elsif ( $type eq 'name' ) {
		$analysis = $registry->fetch_analysis_by_xref_entry($input, $method);
	}
	
	if ( defined $analysis and ($method eq 'cexonic') ) {
		if ( $analysis->cexonic and $analysis->cexonic->result ) {
			my ($rst) = parser_vcexonic_result($analysis);
			if ( defined $rst and $rst ne '' ) {
				$result = $VHEAD->{$method}.$rst;				
			}			
		}	
	}
	elsif ( defined $analysis and ($method eq 'corsair') ) {
		if ( $analysis->corsair and $analysis->corsair->result ) {
			my ($rst) = parser_vcorsair_result($analysis->corsair->result);
			if ( defined $rst and $rst ne '' ) {
				$result = $VHEAD->{$method}.$rst;				
			}
		}	
	}
	elsif ( defined $analysis and ($method eq 'crash') ) {
		if ( $analysis->crash and $analysis->crash->result ) {
			my ($rst) = parser_vcrash_result($analysis);
			if ( defined $rst and $rst ne '' ) {
				$result = $VHEAD->{$method}.$rst;				
			}
		}	
	}
	elsif ( defined $analysis and ($method eq 'firestar') ) {
		if ( $analysis->firestar and $analysis->firestar->result ) {
			my ($rst) = parser_vfirestar_result($analysis);
			if ( defined $rst and $rst ne '' ) {
				$result = $VHEAD->{$method}.$rst;				
			}
		}	
	}
	elsif ( defined $analysis and ($method eq 'inertia') ) {
		if ( $analysis and $analysis->inertia ) {	
			$result .= parser_vinertia_result($method,$analysis);
		}
	}
	elsif ( defined $analysis and ($method eq 'matador3d') ) {
		if ( $analysis->matador3d and $analysis->matador3d->result ) {
			my ($rst) = parser_vmatador3d_result($analysis);
			if ( defined $rst and $rst ne '' ) {
				$result = $VHEAD->{$method}.$rst;				
			}
		}	
	}	
	elsif ( defined $analysis and ($method eq 'spade') ) {
		if ( $analysis->spade and $analysis->spade->result ) {
			my ($rst) = parser_vspade_result($analysis);
			if ( defined $rst and $rst ne '' ) {
				$result = $VHEAD->{$method}.$rst;				
			}
		}	
	}
	elsif ( defined $analysis and ($method eq 'thump') ) {
		if ( $analysis->thump and $analysis->thump->result ) {
			my ($rst) = parser_vthump_result($analysis);
			if ( defined $rst and $rst ne '' ) {
				$result = $VHEAD->{$method}.$rst;				
			}
		}	
	}
		
	return $result;
}


sub parser_vcexonic_result {
	my ($analysis) = @_;
	my ($result) = '';
	my ($method) = $analysis->cexonic;
	
	if ( defined $method->conservation_exon and defined $method->result ) {
		if ( defined $method->first_specie_num_exons and defined $method->second_specie_num_exons and  defined $method->num_introns ) {
			$result .=	$method->first_specie_num_exons."\t".
						$method->second_specie_num_exons."\t".
						$method->num_introns."\n";

			if ( defined $method->regions ) {
				$result .= "# Coordinates for the non-aligned introns:\n";				
				foreach my $region (@{$method->regions}) {
					if ( defined $region->start and defined $region->end and defined $region->strand ) {
						my (%parameters) = (
										trans_start			=> $region->start,
										trans_end			=> $region->end,
										trans_strand		=> $region->strand						
						);
						$result .=	$parameters{trans_start}."\t".
									$parameters{trans_end}."\t".
									$parameters{trans_strand}."\n";
					}
				}
			}
			my ($rst) = $method->result;
			$rst =~ s/^1\:/# Alignment between 1\:/;
			$rst =~ s/2\:/and 2\:/;
			$rst =~ s/##[^\$]*$//;
			$result .= 	"\n".$rst;
		}
	}

	return $result;
}

sub parser_vcorsair_result {
	my ($result) = @_;
	my ($p_result) = '';
	
	$result =~ s/^\>[^\n]*\n//;
	while ( $result =~ /([^\n]*)\n/g ) {
		my ($line) = $1;
		my (@cols) = split(/\t/,$line);
		if ( $cols[2] ne '0' ) {
			my ($sp) = $cols[0];
			my ($id) = sprintf ("%.2f",$cols[1]);
			$p_result .=	$sp."\t".
							$id."\n";			
		}
	}
	return $p_result;	
}

sub parser_vcrash_result {
	my ($analysis) = @_;
	my ($result) = '';
	my ($method) = $analysis->crash;
	if ( defined $method->result and defined $method->peptide_signal and defined $method->mitochondrial_signal ) {
		if ( ($method->peptide_signal eq $OK_LABEL) or ($method->mitochondrial_signal eq $OK_LABEL) ) {
			if ( defined $method->regions ) {
				if ( ($method->peptide_signal eq $OK_LABEL) and ($method->mitochondrial_signal eq $OK_LABEL) ) {
					$result .=	"Peptide-Mitochondrial signal\t";					
				}
				elsif ( $method->peptide_signal eq $OK_LABEL ) {
					$result .=	"Peptide signal\t";
				}					
				elsif ( $method->mitochondrial_signal eq $OK_LABEL ) {
					$result .=	"Mitochondrial signal\t";
				}					
				
				foreach my $region (@{$method->regions}) {
					if ( defined $region->pstart and defined $region->pend ) {
						my (%parameters) = (
											start				=> $region->pstart,
											end					=> $region->pend,
						);
					$result .=	$parameters{start}."\t".
								$parameters{end}."\n";
					}					
				}
			}						
		}
	}
	return $result;
}

sub parser_vfirestar_result {
	my ($analysis) = @_;
	my ($result) = '';
	my ($method) = $analysis->firestar;
	if ( defined $method->residues and defined $method->result ) {
		foreach my $region (@{$method->residues}) {
			if ( defined $region->residue ) {
				my (%parameters) = (
								peptide_position	=> $region->residue,
				);
				if ( $region->domain ) {
					$parameters{domain} = $region->domain;
					$parameters{domain} =~ s/^[\w|\-]{6}//;
					$parameters{domain} =~ s/[\w|\-]{6}$//;
				}				
				if ( $region->ligands ) {
					my ($lig) = '';
					my ($sc) = '';
					my (@ligands) = split(/\|/, $region->ligands);
					foreach my $ligs (@ligands) {
						if ( $ligs =~ /^([^\[]*)\[/ ) {
							$lig .= $1.',';
						}
						$ligs =~ s/^[^\[]*\[[^\,]*\,//;
						$ligs =~ s/\,[^\]]*\]$//;					
						$sc .= $ligs.',';						
					}
					$lig =~ s/\,$//;
					$sc =~ s/\,$//;
					$parameters{ligands} = $lig if ( $lig ne '' );
					$parameters{rel_score} = $sc if ( $sc ne '' );
					
				}				
				$result .=	$parameters{peptide_position}."\t".
							$parameters{domain}."\t".
							$parameters{ligands}."\t".
							$parameters{rel_score}."\n";
			}
		}
	}
	return $result;	
} 

sub parser_vinertia_result {
	my ($method,$analysis) = @_;
	my ($result);
		
	if ( $analysis->inertia->mafft_alignment and $analysis->inertia->mafft_alignment->result ) {
		my ($alignment) = $analysis->inertia->mafft_alignment;
		my ($rst) = _parser_vinertia_result($alignment);
		if ( defined $rst and $rst ne '' ) {
			$result .= "### Evolutionary rates of exons from MAF alignment ###\n";
			$result .= $VHEAD->{$method};
	 		$result .= $rst;
	 		$result .= "----------------------------------------------------------------------\n";		
		}		
	}
	
	if ( $analysis->inertia->prank_alignment and $analysis->inertia->prank_alignment->result ) {
		my ($alignment) = $analysis->inertia->prank_alignment;
		my ($rst) = _parser_vinertia_result($alignment);
		if ( defined $rst and $rst ne '' ) {
			$result .= "### Evolutionary rates of exons from Prank alignment ###\n";
			$result .= $VHEAD->{$method};			
	 		$result .= $rst;
	 		$result .= "----------------------------------------------------------------------\n";		
		}		
	}
			
	if ( $analysis->inertia->kalign_alignment and $analysis->inertia->kalign_alignment->result ) {
		my ($alignment) = $analysis->inertia->kalign_alignment;
		my ($rst) = _parser_vinertia_result($alignment);
		if ( defined $rst and $rst ne '' ) {
			$result .= "### Evolutionary rates of exons from Kalign alignment ###\n";
			$result .= $VHEAD->{$method};
	 		$result .= $rst;
	 		$result .= "----------------------------------------------------------------------\n";			
		}		
	}
	
	return $result;
}

sub _parser_vinertia_result {
	my ($alignment) = @_;
	my ($rst) = '';
		
	if ( defined $alignment->regions ) {
		for (my $icds = 0; $icds < scalar(@{$alignment->regions}); $icds++) {
			my ($region2) = $alignment->regions->[$icds];
			if ( defined $region2->omega_mean and defined $region2->start and defined $region2->end ) {
				$rst .=	$region2->omega_mean."\t".
						$region2->start."\t".
						$region2->end."\n";
			}
		}
	}
	return $rst;
}

sub parser_vmatador3d_result {
	my ($analysis) = @_;
	my ($result) = '';
	my ($method) = $analysis->matador3d;
	
	if ( defined $method->conservation_structure and defined $method->result ) {
		if ( defined $method->alignments ) {
			foreach my $region (@{$method->alignments}) {
				if ( ($region->type eq 'mini-exon') and 
					defined $region->pstart and defined $region->pend and 
					defined $region->pdb_id and defined $region->identity ) {
						$result .=	$region->pstart.':'.$region->pend."\t".
									$region->pdb_id."\t".
									$region->identity."\n";
				}
			}
		}
	}
	
	return $result;
}

sub parser_vspade_result {
	my ($analysis) = @_;
	my ($result) = '';
	my ($method) = $analysis->spade;

	
	if ( defined $method->domain_signal and defined $method->result ) {
		if ( defined $method->regions ) {
			foreach my $region (@{$method->regions}) {
	
				if ( defined $region->alignment_start and defined $region->alignment_end and
					 defined $region->hmm_name and defined $region->evalue ) {
					my (%parameters) = (
										alignment_start		=> $region->alignment_start,
										alignment_end		=> $region->alignment_end,
										hmm_name			=> $region->hmm_name,
										evalue				=> $region->evalue,
					);
					$result .=	$parameters{alignment_start}."\t".
								$parameters{alignment_end}."\t".
								$parameters{hmm_name}."\t".							
								$parameters{evalue}."\n";				
				}
			}
		}
		if ( $result eq '' ) {
			$result .= "No domains\n";
		}
		else {
			my ($rst) = $method->result;
			$rst =~ s/^\>[^\>]*//;
			$result .= 	"\n";
			$result .= "### PfamScan alignments ###\n";
			$result .= "----------------------------------------------------------------------\n";
			$result .= 	$rst;
		}
	}
	
	return $result;
}

sub parser_vthump_result {
	my ($analysis) = @_;
	my ($result) = '';
	my ($method) = $analysis->thump;
	
	if ( defined $method->transmembrane_signal and defined $method->result ) {
		if ( defined $method->regions ) {
			foreach my $region (@{$method->regions}) {
				if ( defined $region->pstart and defined $region->pend ) {
					my (%parameters) = (
									start				=> $region->pstart,
									end					=> $region->pend,
					);
					my ($dam) = '-';
					$dam = 'damaged' if ( defined $region->damaged );
					$result .=	$parameters{start}."\t".
								$parameters{end}."\t".
								$dam."\n";
				}
			}
		}
	}
	
	return $result;
}

=head2 get_sequence_result

  Arg [1]    : String $type
               type of input: 'id' or 'name'
  Arg [2]    : String $input
               gene or transcript identifier (or name)
  Arg [3]    : String $method
               method name
  Example    : use Retrieve qw(get_sequence_result);
               my $rst = get_sequence_result($type, $input, $method);
  Description: Throws an exception which if not caught by an eval will
               provide a stack trace to STDERR and die.  If the verbosity level
               is lower than the level of the throw, then no error message is
               displayed but the program will still die (unless the exception
               is caught).
  Returntype : none
  Exceptions : thrown every time
  Caller     : generally on error

=cut
sub get_sequence_result {
	my ($id_list, $type, $format) = @_;
	my ($result) = '';
	
	# APPRIS database connection
	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);	
	
	# Get sequence for each id
	my(@ids)=split(',',$id_list);
	foreach my $id (@ids) {
		my ($features);
		if ($id=~/^ENSG/) {
			my ($region) = $1;
			$features = $registry->fetch_basic_by_stable_id('gene',$id);
		}
		elsif($id=~/^ENST/) {
			my ($region) = $1;
			$features = $registry->fetch_basic_by_stable_id('transcript',$id);
		}
		
		# Export data
		if ( defined $features ) {
			if ($format eq 'fasta') {
				my ($exporter) = APPRIS::Exporter->new();
				$result .= $exporter->get_seq_annotations($features,$type,$format);
			}			
		}
	}
	
	return $result;	
}

=head2 get_img_seq_result

  Arg [1]    : String $type
               type of input: 'id' or 'name'
  Arg [2]    : String $input
               gene or transcript identifier (or name)
  Example    : use Retrieve qw(get_img_seq_result);
               my $rst = get_img_seq_result($type, $input);
  Description: Throws an exception which if not caught by an eval will
               provide a stack trace to STDERR and die.  If the verbosity level
               is lower than the level of the throw, then no error message is
               displayed but the program will still die (unless the exception
               is caught).
  Returntype : none
  Exceptions : thrown every time
  Caller     : generally on error

=cut
sub get_img_seq_result {
	my ($type, $input) = @_;
	
	my ($features);
	my ($result);	
	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);	

	if ( defined $registry ) {
		if ( $type eq 'id' ) {
			$features = $registry->fetch_by_stable_id('transcript',$input);		
		}
		elsif ( $type eq 'name' ) {
			$features = $registry->fetch_by_xref_entry($input);
		}
	}

	# Export data
	if ( defined $features ) {
		my ($exporter) = APPRIS::Exporter->new();
		$result .= $exporter->get_img_seq_annotations($features);
	}
	
	return $result;
}

=head2 get_residues_result

  Arg [1]    : String $type
               type of input: 'id' or 'name'
  Arg [2]    : String $input
               gene or transcript identifier (or name)
  Arg [3]    : String $method
               method name
  Example    : use Retrieve qw(get_method_result);
               my $rst = get_residues_result($type, $input, $method);
  Description: Throws an exception which if not caught by an eval will
               provide a stack trace to STDERR and die.  If the verbosity level
               is lower than the level of the throw, then no error message is
               displayed but the program will still die (unless the exception
               is caught).
  Returntype : none
  Exceptions : thrown every time
  Caller     : generally on error

=cut
sub get_residues_result {
	my ($id_list) = @_;
	my ($result) = '';
	
	# APPRIS database connection
	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $CONFIG_INI_FILE);	
	
	# Get sequence for each id
	my(@ids)=split(',',$id_list);
	foreach my $id (@ids) {
		my ($features);
		if ($id=~/^ENSG/) {
			my ($region) = $1;
			$features = $registry->fetch_by_stable_id('gene',$id);
		}
		elsif($id=~/^ENST/) {
			my ($region) = $1;
			$features = $registry->fetch_by_stable_id('transcript',$id);
		}
		
		# Export data
		if ( defined $features ) {
			my ($exporter) = APPRIS::Exporter->new();
			$result .= $exporter->get_res_annotations($features);
		}
	}
	
	return $result;	
}

1;