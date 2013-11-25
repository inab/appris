#!/usr/bin/perl -W

use strict;
use FindBin;
use Getopt::Long;
use Config::IniFiles;
use Data::Dumper;

use APPRIS::Parser qw(
	parse_gencode
	parse_appris_methods
	parse_corsair
);
use APPRIS::Utils::Logger;
use APPRIS::Utils::File;

###################
# Global variable #
###################
use vars qw(
	$LOCAL_PWD
	$OK_LABEL
	$UNKNOWN_LABEL
	$NO_LABEL
	$NR_SCORE
	$NR_LEN_SCORE
	$NO_SCORE
	$FIRESTAR_ACCEPT_LABEL
	$FIRESTAR_REJECT_LABEL
	$GLOBAL_SCORES
	$METHODS
);

# Input parameters
my ($config_file) = undef;
my ($data_file) = undef;
my ($transcripts_file) = undef;
my ($translations_file) = undef;
my ($firestar_file) = undef;
my ($matador3d_file) = undef;
my ($corsair_file) = undef;
my ($spade_file) = undef;
my ($inertia_file) = undef;
my ($inertia_maf_file) = undef;
my ($inertia_prank_file) = undef;
my ($inertia_kalign_file) = undef;
my ($cexonic_file) = undef;
my ($thump_file) = undef;
my ($crash_file) = undef;
my ($output_main_file) = undef;
my ($output_label_file) = undef;
my ($output_score_file) = undef;
my ($logfile) = undef;
my ($logpath) = undef;
my ($logappend) = undef;
my ($loglevel) = undef;

&GetOptions(
	'conf=s'			=> \$config_file,
	'data=s'			=> \$data_file,
	'transcripts=s'		=> \$transcripts_file,
	'translations=s'	=> \$translations_file,
	'firestar=s'		=> \$firestar_file,
	'matador3d=s'		=> \$matador3d_file,
	'corsair=s'			=> \$corsair_file,
	'spade=s'			=> \$spade_file,
	'inertia=s'			=> \$inertia_file,
	'inertia_maf=s'		=> \$inertia_maf_file,
	'inertia_prank=s'	=> \$inertia_prank_file,
	'inertia_kalign=s'	=> \$inertia_kalign_file,	
	'cexonic=s'			=> \$cexonic_file,
	'thump=s'			=> \$thump_file,
	'crash=s'			=> \$crash_file,
	'output=s'			=> \$output_main_file,	
	'output_label=s'	=> \$output_label_file,
	'output_score=s'	=> \$output_score_file,
	'loglevel=s'		=> \$loglevel,
	'logfile=s'			=> \$logfile,
	'logpath=s'			=> \$logpath,
	'logappend'			=> \$logappend,
);

# Get conf vars
my ($cfg) = new Config::IniFiles( -file =>  $config_file );
$LOCAL_PWD				= $FindBin::Bin;
$OK_LABEL				= 'YES';
$UNKNOWN_LABEL			= 'UNKNOWN';
$NO_LABEL				= 'NO';
$NR_SCORE				= 'NR';
$NR_LEN_SCORE			= 'NR*';
$NO_SCORE				= '-';
$FIRESTAR_ACCEPT_LABEL	= 'ACCEPT';
$FIRESTAR_REJECT_LABEL	= 'REJECT';
$GLOBAL_SCORES = {
	'firestar'	=> 6,
	'matador3d'	=> 5,
	'spade'		=> 4,
	'corsair'	=> 3,
	'thump'		=> 2,
	'crash'		=> 1,
	'inertia'	=> 0,
	'cexonic'	=> 0,
	'reject'	=> 0
};
$METHODS = {
	'firestar'	=> [ 'functional_residue',				'num_functional_residues'				],
	'matador3d'	=> [ 'conservation_structure',			'score_homologous_structure'			],
	'corsair'	=> [ 'vertebrate_signal',				'score_vertebrate_signal'				],
	'spade'		=> [ 'domain_signal',					'score_domain_signal'					],
	'inertia'	=> [ 'unusual_evolution',				'num_unusual_exons'						],
	'cexonic'	=> [ 'conservation_exon',				'score_conservation_exon'				],
	'thump'		=> [ 'transmembrane_signal',			'score_transmembrane_signal'			],
	'crash'		=> [ 'peptide_signal',					'score_peptide_signal',
					 'mitochondrial_signal',			'score_mitochondrial_signal'			],
	'appris'	=> [ 'annotation',						'reliability'							]
};
 

# Required arguments
unless ( defined $config_file and defined $data_file and defined $transcripts_file and defined $translations_file and 
		defined $firestar_file and defined $matador3d_file and defined $corsair_file and defined $spade_file and
		#defined $inertia_file and defined $cexonic_file and 
		#defined $thump_file and defined $crash_file and 
		defined $output_main_file and defined $output_label_file and defined $output_score_file )
{
    print `perldoc $0`;
    exit 1;
}

# Get log filehandle and print heading and parameters to logfile
my ($logger) = new APPRIS::Utils::Logger(
	-LOGFILE      => $logfile,
	-LOGPATH      => $logpath,
	-LOGAPPEND    => $logappend,
	-LOGLEVEL     => $loglevel,
);
$logger->init_log();


#####################
# Method prototypes #
#####################
sub get_scores($$);
sub get_annotations($$$);
sub get_main_output($$$);
sub get_label_output($$$);
sub get_score_output($$$);
sub get_strange_output($$);
sub get_crash_annots($$$);
sub get_crash_annot($$);
sub get_num_unusual_exons($);

#################
# Method bodies #
#################
# Main subroutine
sub main()
{
	# Local variables
	my ($firestar_result);
	my ($matador3d_result);
	my ($corsair_result);
	my ($spade_result);
	my ($inertia_result);
	my ($inertia_maf_result);
	my ($inertia_prank_result);
	my ($inertia_kalign_result);	
	my ($cexonic_result);
	my ($thump_result);
	my ($crash_result);


	# Get gencode data
	$logger->info("-- get data files\n");
	my ($gencode_data) = parse_gencode($data_file, $transcripts_file, $translations_file);
	unless ( defined $gencode_data ) {
		$logger->error("can not get gene result: $!\n");
	}

	# get the gene object
	my ($gene);
	if ( UNIVERSAL::isa($gencode_data, 'ARRAY') and (scalar(@{$gencode_data}) > 0) ) {
		$gene = $gencode_data->[0];
	}

	# get reports
	$logger->info("get firestar result\n");
	if ( -e $firestar_file and (-s $firestar_file > 0) ) {
		$firestar_result = getStringFromFile($firestar_file);
		unless ( defined $firestar_result ) {
			$logger->error("can not open method result: $!\n");
		}
	}
	else {
		$logger->info("file does not exit\n");
	}
	$logger->info("get matador3d result\n");
	if ( -e $matador3d_file and (-s $matador3d_file > 0) ) {
		$matador3d_result = getStringFromFile($matador3d_file);
		unless ( defined $matador3d_result ) {
			$logger->error("can not open method result: $!\n");
		}
	}
	else {
		$logger->info("file does not exit\n");
	}
	$logger->info("get corsair result\n");
	if ( -e $corsair_file and (-s $corsair_file > 0) ) {
		$corsair_result = getStringFromFile($corsair_file);
		unless ( defined $corsair_result ) {
			$logger->error("can not open method result: $!\n");
		}
	}
	else {
		$logger->info("file does not exit\n");
	}	
	$logger->info("get spade result\n");
	if ( -e $spade_file and (-s $spade_file > 0) ) {
		$spade_result = getStringFromFile($spade_file);
		unless ( defined $spade_result ) {
			$logger->error("can not open method result: $!\n");
		}
	}
	else {
		$logger->info("file does not exit\n");
	}
	$logger->info("get inertia result\n");
	if ( -e $inertia_file and (-s $inertia_file > 0) ) {
		$inertia_result = getStringFromFile($inertia_file);
		unless ( defined $inertia_result ) {
			$logger->error("can not open method result: $!\n");
		}
	}
	else {
		$logger->info("file does not exit\n");
	}
	if ( defined $inertia_maf_file ) {
		$logger->info("get inertia_maf result\n");
		if ( -e $inertia_maf_file and (-s $inertia_maf_file > 0) ) {
			$inertia_maf_result = getStringFromFile($inertia_maf_file);
			unless ( defined $inertia_maf_result ) {
				$logger->error("can not open method result: $!\n");
			}
		}
		else {
			$logger->info("file does not exit\n");
		}		
	}
	if ( defined $inertia_prank_file ) {
		$logger->info("get inertia_prank result\n");
		if ( -e $inertia_prank_file and (-s $inertia_prank_file > 0) ) {
			$inertia_prank_result = getStringFromFile($inertia_prank_file);
			unless ( defined $inertia_prank_result ) {
				$logger->error("can not open method result: $!\n");
			}
		}
		else {
			$logger->info("file does not exit\n");
		}
	}
	if ( defined $inertia_kalign_file ) {
		$logger->info("get inertia_kalign result\n");
		if ( -e $inertia_kalign_file and (-s $inertia_kalign_file > 0) ) {
			$inertia_kalign_result = getStringFromFile($inertia_kalign_file);
			unless ( defined $inertia_kalign_result ) {
				$logger->error("can not open method result: $!\n");
			}
		}
		else {
			$logger->info("file does not exit\n");
		}
	}	
	$logger->info("get cexonic result\n");
	if ( -e $cexonic_file and (-s $cexonic_file > 0) ) {
		$cexonic_result = getStringFromFile($cexonic_file);
		unless ( defined $cexonic_result ) {
			$logger->error("can not open method result: $!\n");
		}
	}
	else {
		$logger->info("file does not exit\n");
	}
	$logger->info("get thump result\n");
	if ( -e $thump_file and (-s $thump_file > 0) ) {
		$thump_result = getStringFromFile($thump_file);
		unless ( defined $thump_result ) {
			$logger->error("can not open method result: $!\n");
		}
	}
	else {
		$logger->info("file does not exit\n");
	}	
		
	$logger->info("get crash result\n");
	if ( -e $crash_file and (-s $crash_file > 0) ) {
		$crash_result = getStringFromFile($crash_file);
		unless ( defined $crash_result ) {
			$logger->error("can not open method result: $!\n");
		}
	}
	else {
		$logger->info("file does not exit\n");
	}

	# get object of reports
	$logger->info("-- create reports\n");
	my ($reports) = parse_appris_methods($gene, $firestar_result, $matador3d_result, $spade_result, $inertia_result, $corsair_result, $cexonic_result, $crash_result, $thump_result, $inertia_maf_result, $inertia_prank_result, $inertia_kalign_result);
	$logger->debug(Dumper($reports)."\n");

	# get scores of each transcript
	$logger->info("-- get scores for each variant\n");
	my ($cutoffs, $scores, $g_scores) = get_scores($gene, $reports);
	
	# get annotations indexing each transcript
	$logger->info("-- get final annotations\n");
	my ($annots) = get_annotations($gene, $g_scores, $scores);
	
	# print outputs
	my ($main_content) = get_main_output($gene, $scores, $annots);
	my ($p_main_out) = APPRIS::Utils::File::printStringIntoFile($main_content, $output_main_file);
	unless( defined $p_main_out ) {
		$logger->error("Can not create output file: $!\n");
	}
	my ($label_content) = get_label_output($gene, $cutoffs, $annots);
	my ($p_label_out) = APPRIS::Utils::File::printStringIntoFile($label_content, $output_label_file);
	unless( defined $p_label_out ) {
		$logger->error("Can not create output trace file: $!\n");
	}
	my ($score_content) = get_score_output($gene, $cutoffs, $annots);
	my ($p_score_out) = APPRIS::Utils::File::printStringIntoFile($score_content, $output_score_file);
	unless( defined $p_score_out ) {
		$logger->error("Can not create output trace file: $!\n");
	}
	my ($strange_content) = get_strange_output($gene, $annots);
	if ( $strange_content ne '' ) {
		my ($output_strange_file) = $output_main_file.'.strange';
		my ($p_strange_out) = APPRIS::Utils::File::printStringIntoFile($strange_content, $output_strange_file);
		unless( defined $p_strange_out ) {
			$logger->error("Can not create output strange file: $!\n");
		}		
	}
	
	$logger->finish_log();
	
	exit 0;	
	
}

# get the main functional isoform from methods of appris
sub get_scores($$)
{
	my ($gene, $reports) = @_;

	my ($stable_id) = $gene->stable_id;
	my ($cutoffs);
	my ($scores);
	my ($g_scores);
	my ($s_cases);
	
	# get annotations for each method (or group of method) -------------------
	foreach my $transcript (@{$gene->transcripts}) {		
		my ($transcript_id) = $transcript->stable_id;
		if ( $transcript->translate and $transcript->translate->sequence ) {
			 # init trans for translation
			foreach my $method ( keys(%{$METHODS}) ) {
				if ( $method eq 'appris' ) {
					$scores->{$transcript_id}->{$method} = 0;
				}
				else {
					$scores->{$transcript_id}->{$method} = '-'; # init trans without result	
				}				
			}
			my ($index) = $reports->{'_index_transcripts'}->{$transcript_id};
			my ($result) = $reports->transcripts->[$index];
			
			# get firestar
			my ($m) = 'firestar';
			if ( $result and $result->analysis and $result->analysis->firestar ) {				
				my ($k_annot) = $METHODS->{$m}->[0];
				my ($k_annot2) = $METHODS->{$m}->[1];
				my ($analysis) = $result->analysis->firestar;
				if ( $analysis->functional_residue and ($analysis->functional_residue eq $FIRESTAR_REJECT_LABEL) ) {	
					$cutoffs->{$transcript_id}->{$k_annot} = $NO_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};
				}
				elsif ( $analysis->functional_residue and ($analysis->functional_residue eq $FIRESTAR_ACCEPT_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $UNKNOWN_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				if ( defined $analysis->num_residues ) {
					$cutoffs->{$transcript_id}->{$k_annot2} = $analysis->num_residues;
				}				
			}
			else { # we give the points because we don't have reasons to not do (when we don't have results)
				$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
			}
			# get matador3d
			$m = 'matador3d';
			if ( $result and $result->analysis and $result->analysis->matador3d ) {				
				my ($k_annot) = $METHODS->{$m}->[0];
				my ($k_annot2) = $METHODS->{$m}->[1];				
				my ($analysis) = $result->analysis->matador3d;
				if ( $analysis->conservation_structure and ($analysis->conservation_structure eq $NO_LABEL) ) {	
					$cutoffs->{$transcript_id}->{$k_annot} = $NO_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};
				}
				elsif ( $analysis->conservation_structure and ($analysis->conservation_structure eq $UNKNOWN_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $UNKNOWN_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				elsif ( $analysis->conservation_structure and ($analysis->conservation_structure eq $OK_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $OK_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				if ( defined $analysis->score ) {
					$cutoffs->{$transcript_id}->{$k_annot2} = $analysis->score;
				}				
			}
			else { # we give the points because we don't have reasons to not do (when we don't have results)
				$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
			}
			# get corsair
			$m = 'corsair';
			if ( $result and $result->analysis and $result->analysis->corsair ) {
				my ($k_annot) = $METHODS->{$m}->[0];
				my ($k_annot2) = $METHODS->{$m}->[1];
				my ($analysis) = $result->analysis->corsair;
				if ( $analysis->vertebrate_signal and ($analysis->vertebrate_signal eq $NO_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $NO_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};
				}
				elsif ( $analysis->vertebrate_signal and ($analysis->vertebrate_signal eq $UNKNOWN_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $UNKNOWN_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				elsif ( $analysis->vertebrate_signal and ($analysis->vertebrate_signal eq $OK_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $OK_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				if ( defined $analysis->score ) {
					$cutoffs->{$transcript_id}->{$k_annot2} = $analysis->score;
				}			
			}
			else { # we give the points because we don't have reasons to not do (when we don't have results)
				$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
			}
			# get spade
			$m = 'spade';
			if ( $result and $result->analysis and $result->analysis->spade ) {				
				my ($k_annot) = $METHODS->{$m}->[0];
				my ($k_annot2) = $METHODS->{$m}->[1];
				my ($analysis) = $result->analysis->spade;
				if ( $analysis->domain_signal and ($analysis->domain_signal eq $NO_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $NO_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};
				}
				elsif ( $analysis->domain_signal and ($analysis->domain_signal eq $UNKNOWN_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $UNKNOWN_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				elsif ( $analysis->domain_signal and ($analysis->domain_signal eq $OK_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $OK_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				if ( defined $analysis->num_domains and 
					 defined $analysis->num_possibly_damaged_domains and
					 defined $analysis->num_damaged_domains and
					 defined $analysis->num_wrong_domains ) {
					 	my ($sum_domains) = $analysis->num_domains + $analysis->num_possibly_damaged_domains;
					 	my ($sum_damaged_domains) = $analysis->num_damaged_domains + $analysis->num_wrong_domains;
						$cutoffs->{$transcript_id}->{$k_annot2} = $sum_domains . '.' . $sum_damaged_domains;																				
				}				
			}
			else { # we give the points because we don't have reasons to not do (when we don't have results)
				$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
			}
			# get inertia
			$m = 'inertia';
			if ( $result and $result->analysis and $result->analysis->inertia ) {				
				my ($k_annot) = $METHODS->{$m}->[0];
				my ($k_annot2) = $METHODS->{$m}->[1];				
				my ($analysis) = $result->analysis->inertia;
				if ( $analysis->unusual_evolution and ($analysis->unusual_evolution eq $NO_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $NO_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};
				}
				elsif ( $analysis->unusual_evolution and ($analysis->unusual_evolution eq $UNKNOWN_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $UNKNOWN_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				elsif ( $analysis->unusual_evolution and ($analysis->unusual_evolution eq $OK_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $OK_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				if ( defined $analysis->regions ) {
					 my ($num_un_exons) = get_num_unusual_exons($analysis);
					$cutoffs->{$transcript_id}->{$k_annot2} = $num_un_exons->{'inertia'} . '.'. 	
																		$num_un_exons->{'maf'} .
																		$num_un_exons->{'prank'} .
																		$num_un_exons->{'kalign'};
				}
			}
			else { # we give the points because we don't have reasons to not do (when we don't have results)
				$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
			}
			# get cexonic
			$m = 'cexonic';
			if ( $result and $result->analysis and $result->analysis->cexonic ) {
				my ($k_annot) = $METHODS->{$m}->[0];
				my ($k_annot2) = $METHODS->{$m}->[1];
				my ($analysis) = $result->analysis->cexonic;
				if ( $analysis->conservation_exon and ($analysis->conservation_exon eq $NO_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $NO_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};
				}
				elsif ( $analysis->conservation_exon and ($analysis->conservation_exon eq $UNKNOWN_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $UNKNOWN_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				elsif ( $analysis->conservation_exon and ($analysis->conservation_exon eq $OK_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $OK_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
			}
			else { # we give the points because we don't have reasons to not do (when we don't have results)
				$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
			}
			# get thump
			$m = 'thump';
			if ( $result and $result->analysis and $result->analysis->thump ) {
				my ($k_annot) = $METHODS->{$m}->[0];
				my ($k_annot2) = $METHODS->{$m}->[1];
				my ($analysis) = $result->analysis->thump;
				if ( $analysis->transmembrane_signal and ($analysis->transmembrane_signal eq $NO_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $NO_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};
				}
				elsif ( $analysis->transmembrane_signal and ($analysis->transmembrane_signal eq $UNKNOWN_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $UNKNOWN_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				elsif ( $analysis->transmembrane_signal and ($analysis->transmembrane_signal eq $OK_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $OK_LABEL;
					$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
				}
				if ( defined $analysis->num_tmh and 
					 defined $analysis->num_damaged_tmh ) {
					$cutoffs->{$transcript_id}->{$k_annot2} = $analysis->num_tmh.'.'.$analysis->num_damaged_tmh;																				
				}				
			}
			else { # we give the points because we don't have reasons to not do (when we don't have results)
				$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
			}
			# get crash: signalp + targetp
			$m = 'crash';
			if ( $result and $result->analysis and $result->analysis->crash ) {
				my ($k_annot) = $METHODS->{$m}->[0];
				my ($k_annot1) = $METHODS->{$m}->[1];
				my ($k_annot2) = $METHODS->{$m}->[2];
				my ($k_annot3) = $METHODS->{$m}->[3];		
				my ($analysis) = $result->analysis->crash;
				# signalp
				if ( $analysis->peptide_signal and ($analysis->peptide_signal eq $NO_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $NO_LABEL;
				}
				elsif ( $analysis->peptide_signal and ($analysis->peptide_signal eq $UNKNOWN_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $UNKNOWN_LABEL;
				}
				elsif ( $analysis->peptide_signal and ($analysis->peptide_signal eq $OK_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot} = $OK_LABEL;
				}
				my ($crash_sp_annot, $crash_sp_signal) = get_crash_annots('crash_sp', $transcript_id, $reports);
				if ( defined $crash_sp_annot ) {
					if ( defined $analysis->sp_score ) {
						$cutoffs->{$transcript_id}->{$k_annot1} = $analysis->sp_score;							
					}
					# if there is peptide signal, we take into account for the global score
					if ( $crash_sp_signal == 1 ) {
						if ( $crash_sp_annot eq $NO_LABEL ) {
							$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};
						}
						elsif ( $crash_sp_annot eq $UNKNOWN_LABEL ) {
							$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};				
						}
						elsif ( $crash_sp_annot eq $OK_LABEL ) {
							$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};						
						}
					}
				}
				# targetp
				if ( $analysis->mitochondrial_signal and ($analysis->mitochondrial_signal eq $NO_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot2} = $NO_LABEL;
				}
				elsif ( $analysis->mitochondrial_signal and ($analysis->mitochondrial_signal eq $UNKNOWN_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot2} = $UNKNOWN_LABEL;
				}
				elsif ( $analysis->mitochondrial_signal and ($analysis->mitochondrial_signal eq $OK_LABEL) ) {
					$cutoffs->{$transcript_id}->{$k_annot2} = $OK_LABEL;
				}
				my ($crash_tp_annot, $crash_tp_signal) = get_crash_annots('crash_tp', $transcript_id, $reports);				
				if ( defined $crash_tp_annot ) {
					if ( defined $analysis->tp_score ) {
						$cutoffs->{$transcript_id}->{$k_annot3} = $analysis->tp_score;							
					}					
					# if there is not signal peptide, then we include the score of the mitochondrial signal
					if ( ($crash_sp_signal == 0) and ($crash_tp_signal == 1) ) {
						if ( $crash_tp_annot eq $NO_LABEL ) {
							$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};
						}
						elsif ( $crash_tp_annot eq $UNKNOWN_LABEL ) {
							$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{'reject'};
						}
						elsif ( $crash_tp_annot eq $OK_LABEL ) {
							$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
						}
					}
				}			
			}
			else { # we give the points because we don't have reasons to not do (when we don't have results)
				$scores->{$transcript_id}->{$m} = $GLOBAL_SCORES->{$m};
			}

			# get appris score (sum score)
			$m = 'appris';
			my ($appris_score) = 0;
			if ( $scores->{$transcript_id}->{'firestar'} ne '-' ) {
				$appris_score += $scores->{$transcript_id}->{'firestar'};
			}
			if ( $scores->{$transcript_id}->{'matador3d'} ne '-' ) {
				$appris_score += $scores->{$transcript_id}->{'matador3d'};
			}
			if ( $scores->{$transcript_id}->{'corsair'} ne '-' ) {
				$appris_score += $scores->{$transcript_id}->{'corsair'};
			}
			if ( $scores->{$transcript_id}->{'spade'} ne '-' ) {
				$appris_score += $scores->{$transcript_id}->{'spade'};
			}
			if ( $scores->{$transcript_id}->{'inertia'} ne '-' ) {
				$appris_score += $scores->{$transcript_id}->{'inertia'};
			}
			if ( $scores->{$transcript_id}->{'cexonic'} ne '-' ) {
				$appris_score += $scores->{$transcript_id}->{'cexonic'};
			}
			if ( $scores->{$transcript_id}->{'thump'} ne '-' ) {
				$appris_score += $scores->{$transcript_id}->{'thump'};
			}
			if ( $scores->{$transcript_id}->{'crash'} ne '-' ) {
				$appris_score += $scores->{$transcript_id}->{'crash'};
			}
			
			# reject the cases when transcript is NMD or the codons have not found
			if ( $transcript->biotype eq 'nonsense_mediated_decay' ) {
				$appris_score = 0;
			}
			if ( $transcript->translate->codons ) {
				my ($aux_codons) = '';
				foreach my $codon (@{$transcript->translate->codons}) {
					if ( ($codon->type eq 'start') or ($codon->type eq 'stop') ) {
						$aux_codons .= $codon->type.',';							
					}
				}
				unless ( ($aux_codons =~ /start/) and ($aux_codons =~ /stop/) ) {
					$appris_score = 0;
				}
			}
			
			$scores->{$transcript_id}->{$m} = $appris_score;
			push(@{$g_scores->{$appris_score}}, $transcript_id);
		}
	}

	return ($cutoffs, $scores, $g_scores);
	
} # End get_scores

# get the final annotation
sub get_annotations($$$)
{
	my ($gene, $g_scores, $scores) = @_;
	my ($annotations);

	# from sorted scores of appris
	my (@sorted_scores) = sort { $b <=> $a } keys (%{$g_scores});
	if ( scalar(@sorted_scores) >= 1 )
	{	
		# get annotation of trans of biggest score
		my ($biggest_score) = $sorted_scores[0];
		my ($pep_seq) = '';
		my ($same_seq) = 1;
		foreach my $transcript_id (@{$g_scores->{$biggest_score}}) {			
			my ($index) = $gene->{'_index_transcripts'}->{$transcript_id};
			my ($transcript) = $gene->transcripts->[$index];
			if ( $pep_seq eq '' ) {
				$pep_seq = $transcript->translate->sequence;				
			}
			unless ( $pep_seq eq $transcript->translate->sequence ) {
				$same_seq = 0;
			}		
			#$annotations->{$transcript_id}->{'annotation'} = $UNKNOWN_LABEL;
			#$annotations->{$transcript_id}->{'reliability'} = $NR_SCORE;
			
			# check if there is strange case
			if (
				( $scores->{$transcript_id}->{'firestar'} == 0 and $scores->{$transcript_id}->{'matador3d'} != 0 and $scores->{$transcript_id}->{'corsair'} != 0 ) or
				( $scores->{$transcript_id}->{'matador3d'} == 0 and $scores->{$transcript_id}->{'firestar'} != 0 and $scores->{$transcript_id}->{'corsair'} != 0 ) or
				( $scores->{$transcript_id}->{'corsair'} == 0 and $scores->{$transcript_id}->{'matador3d'} != 0 and $scores->{$transcript_id}->{'firestar'} != 0 )
			) { $annotations->{$transcript_id}->{'strange'} = 1 }
			
			# get reliability score
			if ( scalar(@sorted_scores) >= 2 ) {
				my ($second_score) = $sorted_scores[1];
				my ($diff_score) = $biggest_score - $second_score;
				
				if ( $diff_score >= 5 ) {
					$annotations->{$transcript_id}->{'reliability'} = 100;
				}
				elsif ( ($diff_score >= 3) and ($biggest_score >= 17) ) {
					$annotations->{$transcript_id}->{'reliability'} = 90;
				}
				elsif ( ($diff_score >= 3) and ($biggest_score >= 14) ) {
					$annotations->{$transcript_id}->{'reliability'} = 85;
				}
				elsif ( ($diff_score >= 3) and ($biggest_score >= 10) ) {
					$annotations->{$transcript_id}->{'reliability'} = 80;
				}
				elsif ( ($diff_score >= 3) and ($biggest_score >= 5) ) {
					$annotations->{$transcript_id}->{'reliability'} = 75;
				}
				elsif ( ($diff_score >= 1) and ($biggest_score >= 14) ) {
					$annotations->{$transcript_id}->{'reliability'} = 65;
				}
				elsif ( ($diff_score >= 1) and ($biggest_score >= 5) ) {
					$annotations->{$transcript_id}->{'reliability'} = 60;
				}
				else {
					$annotations->{$transcript_id}->{'reliability'} = 50;
				}
			}				                			
		}

		# get the annotations
		my ($num_biggest_score) = scalar(@{$g_scores->{$biggest_score}});
		
		# one trans has the best score.
		if ( ($same_seq == 1) and ($num_biggest_score == 1) ) {
			foreach my $transcript_id (@{$g_scores->{$biggest_score}}) {
				$annotations->{$transcript_id}->{'annotation'} = $OK_LABEL;
			}			
		}
		# more than one trans (with the same sequence) have the same score but their reliabilty score is 'NR*'
		elsif ( ($same_seq == 1) and ($num_biggest_score >= 2) ) {
			foreach my $transcript_id (@{$g_scores->{$biggest_score}}) {
				$annotations->{$transcript_id}->{'annotation'} = $OK_LABEL;
				$annotations->{$transcript_id}->{'reliability'} = $NR_LEN_SCORE;
			}			
		}
		# more than one trans have the best score. their reliabilty score is 'NR'
		elsif ( ($same_seq == 0) and ($num_biggest_score >= 2) ) {
			foreach my $transcript_id (@{$g_scores->{$biggest_score}}) {
				$annotations->{$transcript_id}->{'annotation'} = $UNKNOWN_LABEL;
				$annotations->{$transcript_id}->{'reliability'} = $NR_SCORE;
			}			
		}
		# rejects the rest of trans
		for ( my $i = 1; $i < scalar(@sorted_scores); $i++ ) {
			foreach my $transcript_id (@{$g_scores->{$sorted_scores[$i]}}) {
				$annotations->{$transcript_id}->{'annotation'} = $NO_LABEL;
				$annotations->{$transcript_id}->{'reliability'} = $NO_SCORE;
			}	
		}
	}
	
	return $annotations;
	
} # End get_annotations

sub get_main_output($$$)
{
	my ($gene, $scores, $annots) = @_;
	my ($stable_id) = $gene->stable_id;
	my ($content) = '';

	foreach my $transcript (@{$gene->transcripts})
	{
		my ($transcript_id) = $transcript->stable_id;
		my ($status) = $transcript->status;
		my ($biotype) = $transcript->biotype;
		my ($translation) = 'TRANSLATION';
		my ($no_codons) = '-';
		my ($ccds_id) = '-';
		if ( $transcript->xref_identify ) {
			foreach my $xref (@{$transcript->xref_identify}) {
				if ( $xref->dbname eq 'CCDS') {
					$ccds_id = $xref->id;
					last;					
				}
			}
		}
		my ($firestar_score) = '-';
		my ($matador3d_score) = '-';
		my ($corsair_score) = '-';
		my ($spade_score) = '-';
		my ($inertia_score) = '-';
		my ($cexonic_score) = '-';
		my ($thump_score) = '-';
		my ($crash_score) = '-';
		my ($appris_score) = '-';
		my ($appris_annot) = '-';
		my ($appris_relia) = '-';		
		if ( $transcript->translate and $transcript->translate->sequence ) {			
			$firestar_score = $scores->{$transcript_id}->{'firestar'};
			$matador3d_score = $scores->{$transcript_id}->{'matador3d'};
			$corsair_score = $scores->{$transcript_id}->{'corsair'};
			$spade_score = $scores->{$transcript_id}->{'spade'};
			$inertia_score = $scores->{$transcript_id}->{'inertia'};
			$cexonic_score = $scores->{$transcript_id}->{'cexonic'};
			$thump_score = $scores->{$transcript_id}->{'thump'};
			$crash_score = $scores->{$transcript_id}->{'crash'};
			$appris_score = $scores->{$transcript_id}->{'appris'};
			$appris_annot = $annots->{$transcript_id}->{'annotation'};
			if ( $annots->{$transcript_id}->{'reliability'} ) {
				$appris_relia = $annots->{$transcript_id}->{'reliability'};
			}
			if ( $transcript->translate->codons ) {
				my ($aux_codons) = '';
				foreach my $codon (@{$transcript->translate->codons}) {
					if ( ($codon->type eq 'start') or ($codon->type eq 'stop') ) {
						$aux_codons .= $codon->type.',';							
					}
				}
				$no_codons = 'start/' unless ( $aux_codons =~ /start/ );
				$no_codons .= 'stop' unless ( $aux_codons =~ /stop/ );
				$no_codons =~ s/^\-// if ($no_codons ne '-');
				$no_codons =~ s/\/$// if ($no_codons ne '-');
			}
			$content .= $stable_id."\t".
						$transcript_id."\t".
						$translation."\t".					
						$status."\t".
						$biotype."\t".
						$no_codons."\t".
						$ccds_id."\t".			
						$firestar_score."\t".
						$matador3d_score."\t".
						$corsair_score."\t".
						$spade_score."\t".
						$inertia_score."\t".
						$cexonic_score."\t".
						$thump_score."\t".
						$crash_score."\t".
						$appris_score."\t".
						$appris_annot."\t".
						$appris_relia."\n";
		}
		else {
			$translation = 'NO_TRANSLATION';
			$content .= $stable_id."\t".
						$transcript_id."\t".
						$translation."\t".					
						$status."\t".
						$biotype."\t".
						$no_codons."\t".
						$ccds_id."\n";			
		}		
	}
	
	return $content;
	
} # End get_main_output

sub get_label_output($$$)
{
	my ($gene, $cutoffs, $annots) = @_;
	my ($stable_id) = $gene->stable_id;
	my ($content) = '';

	foreach my $transcript (@{$gene->transcripts})
	{	
		my ($transcript_id) = $transcript->stable_id;
		my ($status) = $transcript->status;
		my ($biotype) = $transcript->biotype;
		my ($translation) = 'TRANSLATION';
		my ($ccds_id) = '-';
		my ($no_codons) = '-';
		my ($firestar_annot) = '-';
		my ($matador3d_annot) = '-';
		my ($corsair_annot) = '-';
		my ($spade_annot) = '-';
		my ($inertia_annot) = '-';
		my ($cexonic_annot) = '-';
		my ($thump_annot) = '-';
		my ($crash_sp_annot) = '-';
		my ($crash_tp_annot) = '-';
		my ($appris_annot) = '-';
		my ($appris_relia) = '-';		
		if ( $transcript->translate and $transcript->translate->sequence ) {
			
			$firestar_annot = $cutoffs->{$transcript_id}->{'functional_residue'} if ( exists $cutoffs->{$transcript_id}->{'functional_residue'} );
			$matador3d_annot = $cutoffs->{$transcript_id}->{'conservation_structure'}if ( exists $cutoffs->{$transcript_id}->{'conservation_structure'} );
			$corsair_annot = $cutoffs->{$transcript_id}->{'vertebrate_signal'} if ( exists $cutoffs->{$transcript_id}->{'vertebrate_signal'} );
			$spade_annot = $cutoffs->{$transcript_id}->{'domain_signal'} if ( exists $cutoffs->{$transcript_id}->{'domain_signal'} );
			$inertia_annot = $cutoffs->{$transcript_id}->{'unusual_evolution'} if ( exists $cutoffs->{$transcript_id}->{'unusual_evolution'} );
			$cexonic_annot = $cutoffs->{$transcript_id}->{'conservation_exon'} if ( exists $cutoffs->{$transcript_id}->{'conservation_exon'} );
			$thump_annot = $cutoffs->{$transcript_id}->{'transmembrane_signal'} if ( exists $cutoffs->{$transcript_id}->{'transmembrane_signal'} );
			$crash_sp_annot = $cutoffs->{$transcript_id}->{'peptide_signal'} if ( exists $cutoffs->{$transcript_id}->{'peptide_signal'} );
			$crash_tp_annot = $cutoffs->{$transcript_id}->{'mitochondrial_signal'} if ( exists $cutoffs->{$transcript_id}->{'mitochondrial_signal'} );
			
			$appris_annot = $annots->{$transcript_id}->{'annotation'} if ( exists $annots->{$transcript_id}->{'annotation'} );
			$appris_relia = $annots->{$transcript_id}->{'reliability'} if ( exists $annots->{$transcript_id}->{'reliability'} );
			
			if ( $transcript->xref_identify ) {
				foreach my $xref (@{$transcript->xref_identify}) {
					if ( $xref->dbname eq 'CCDS') {
						$ccds_id = $xref->id;
						last;					
					}
				}
			}		
			if ( $transcript->translate->codons ) {
				my ($aux_codons) = '';
				foreach my $codon (@{$transcript->translate->codons}) {
					if ( ($codon->type eq 'start') or ($codon->type eq 'stop') ) {
						$aux_codons .= $codon->type.',';							
					}
				}
				$no_codons = 'start/' unless ( $aux_codons =~ /start/ );
				$no_codons .= 'stop' unless ( $aux_codons =~ /stop/ );
				$no_codons =~ s/^\-// if ($no_codons ne '-');
				$no_codons =~ s/\/$// if ($no_codons ne '-');
			}
						
			$content .= $stable_id."\t".
						$transcript_id."\t".
						$translation."\t".						
						$status."\t".
						$biotype."\t".
						$no_codons."\t".
						$ccds_id."\t".						
						$firestar_annot."\t".
						$matador3d_annot."\t".
						$corsair_annot."\t".
						$spade_annot."\t".
						$inertia_annot."\t".
						$cexonic_annot."\t".
						$thump_annot."\t".
						$crash_sp_annot."\t".
						$crash_tp_annot."\t".
						$appris_relia."\n";
		}
		else {
			$translation = 'NO_TRANSLATION';
			$content .= $stable_id."\t".
						$transcript_id."\t".
						$translation."\t".						
						$status."\t".
						$biotype."\t".
						$no_codons."\t".
						$ccds_id."\n";						
		}
	}
	
	return $content;
	
} # End get_label_output

sub get_score_output($$$)
{
	my ($gene, $cutoffs, $annots) = @_;
	my ($stable_id) = $gene->stable_id;
	my ($content) = '';

	foreach my $transcript (@{$gene->transcripts})
	{	
		my ($transcript_id) = $transcript->stable_id;
		my ($status) = $transcript->status;
		my ($biotype) = $transcript->biotype;
		my ($translation) = 'TRANSLATION';
		my ($ccds_id) = '-';
		my ($no_codons) = '-';
		my ($firestar_annot) = '-';
		my ($matador3d_annot) = '-';
		my ($corsair_annot) = '-';
		my ($spade_annot) = '-';
		my ($inertia_annot) = '-';
		my ($cexonic_annot) = '-';
		my ($thump_annot) = '-';
		my ($crash_sp_annot) = '-';
		my ($crash_tp_annot) = '-';
		my ($appris_annot) = '-';
		my ($appris_relia) = '-';
		my ($transl_len) = 0;
		if ( $transcript->translate and $transcript->translate->sequence ) {
			
			$firestar_annot = $cutoffs->{$transcript_id}->{'num_functional_residues'} if ( exists $cutoffs->{$transcript_id}->{'num_functional_residues'} );
			$matador3d_annot = $cutoffs->{$transcript_id}->{'score_homologous_structure'} if ( exists $cutoffs->{$transcript_id}->{'score_homologous_structure'} );
			$corsair_annot = $cutoffs->{$transcript_id}->{'score_vertebrate_signal'} if ( exists $cutoffs->{$transcript_id}->{'score_vertebrate_signal'} );		
			$spade_annot = $cutoffs->{$transcript_id}->{'score_domain_signal'} if ( exists $cutoffs->{$transcript_id}->{'score_domain_signal'} );
			$inertia_annot = $cutoffs->{$transcript_id}->{'num_unusual_exons'} if ( exists $cutoffs->{$transcript_id}->{'num_unusual_exons'} );
			$cexonic_annot = $cutoffs->{$transcript_id}->{'conservation_exon'} if ( exists $cutoffs->{$transcript_id}->{'conservation_exon'} );
			$thump_annot = $cutoffs->{$transcript_id}->{'score_transmembrane_signal'} if ( exists $cutoffs->{$transcript_id}->{'score_transmembrane_signal'} );
			$crash_sp_annot = $cutoffs->{$transcript_id}->{'score_peptide_signal'} if ( exists $cutoffs->{$transcript_id}->{'score_peptide_signal'} );
			$crash_tp_annot = $cutoffs->{$transcript_id}->{'score_mitochondrial_signal'} if ( exists $cutoffs->{$transcript_id}->{'score_mitochondrial_signal'} );
			
			$appris_annot = $annots->{$transcript_id}->{'annotation'} if ( exists $annots->{$transcript_id}->{'annotation'} );
			$appris_relia = $annots->{$transcript_id}->{'reliability'} if ( exists $annots->{$transcript_id}->{'reliability'} );
			
			$transl_len = length($transcript->translate->sequence);
			
			if ( $transcript->xref_identify ) {
				foreach my $xref (@{$transcript->xref_identify}) {
					if ( $xref->dbname eq 'CCDS') {
						$ccds_id = $xref->id;
						last;					
					}
				}
			}		
			if ( $transcript->translate->codons ) {
				my ($aux_codons) = '';
				foreach my $codon (@{$transcript->translate->codons}) {
					if ( ($codon->type eq 'start') or ($codon->type eq 'stop') ) {
						$aux_codons .= $codon->type.',';							
					}
				}
				$no_codons = 'start/' unless ( $aux_codons =~ /start/ );
				$no_codons .= 'stop' unless ( $aux_codons =~ /stop/ );
				$no_codons =~ s/^\-// if ($no_codons ne '-');
				$no_codons =~ s/\/$// if ($no_codons ne '-');
			}
						
			$content .= $stable_id."\t".
						$transcript_id."\t".
						$translation."\t".						
						$status."\t".
						$biotype."\t".
						$no_codons."\t".
						$ccds_id."\t".						
						$firestar_annot."\t".
						$matador3d_annot."\t".
						$corsair_annot."\t".
						$spade_annot."\t".
						$inertia_annot."\t".
						$cexonic_annot."\t".
						$thump_annot."\t".
						$crash_sp_annot."\t".
						$crash_tp_annot."\t".
						$appris_relia."\t".
						$transl_len."\n";
		}
		else {
			$translation = 'NO_TRANSLATION';
			$content .= $stable_id."\t".
						$transcript_id."\t".
						$translation."\t".						
						$status."\t".
						$biotype."\t".
						$no_codons."\t".
						$ccds_id."\n";						
		}
	}
	
	return $content;
	
} # End get_score_output

# Get the content of strange cases
sub get_strange_output($$)
{
	my ($gene, $annots) = @_;
	my ($stable_id) = $gene->stable_id;
	my ($content) = '';
	
	foreach my $transcript (@{$gene->transcripts})
	{	
		my ($transcript_id) = $transcript->stable_id;
		if ( exists $annots->{$transcript_id}->{'strange'} ) {
			my ($chr) = $transcript->chromosome;
			my ($ccds_id) = '-';		
			if ( $transcript->xref_identify ) {
				foreach my $xref (@{$transcript->xref_identify}) {
					if ( $xref->dbname eq 'CCDS') {
						$ccds_id = $xref->id;
						last;					
					}
				}
			}			
			$content .= $chr."\t".
						$stable_id."\t".
						$transcript_id."\t".
						$ccds_id."\n";
		}
	}
	
	return $content;
	
} # End get_strange_output

# Get annotation of several methods
sub get_method_annot($$)
{
	my ($method, $result) = @_;
	
	my ($annot) = {
		'not_defined'	=> 0,
		'ok'			=> 0,
		'unknown'		=> 0,
		'rejected'		=> 0,
	};
		
	if ( $method eq 'inertia' ) { # get inertia
		if ( $result and $result->analysis and $result->analysis->inertia ) {
			my ($analysis) = $result->analysis->inertia;
			if ( $analysis->unusual_evolution and ($analysis->unusual_evolution eq $UNKNOWN_LABEL) ) {
				$annot->{'unknown'} = 1;
			}
			elsif ( $analysis->unusual_evolution and ($analysis->unusual_evolution eq $NO_LABEL) ) {
				$annot->{'rejected'} = 1;			
			}
			else {
				$annot->{'not_defined'} = 1;
			}
		}
		else {
			$annot->{'not_defined'} = 1;
		}
	}	
	elsif ( $method eq 'corsair' ) { # get corsair
		if ( $result and $result->analysis and $result->analysis->corsair ) {
			my ($analysis) = $result->analysis->corsair;
			if ( $analysis->vertebrate_signal and ($analysis->vertebrate_signal eq $OK_LABEL) ) {
				$annot->{'ok'} = 1;
			}
			elsif ( $analysis->vertebrate_signal and ($analysis->vertebrate_signal eq $UNKNOWN_LABEL) ) {
				$annot->{'unknown'} = 1;
			}
			elsif ( $analysis->vertebrate_signal and ($analysis->vertebrate_signal eq $NO_LABEL) ) {
				$annot->{'rejected'} = 1;
			}
			else {
				$annot->{'not_defined'} = 1;
			}
		}
		else {
			$annot->{'not_defined'} = 1;
		}
	}
	elsif ( $method eq 'crash_sp' ) { # get crash: signalp
		if ( $result and $result->analysis and $result->analysis->crash ) {
			my ($analysis) = $result->analysis->crash;
			if ( $analysis->peptide_signal and ($analysis->peptide_signal eq $NO_LABEL) ) {
				$annot->{'rejected'} = 1;
			}
			elsif ( $analysis->peptide_signal and ($analysis->peptide_signal eq $UNKNOWN_LABEL) ) {
				$annot->{'unknown'} = 1;
			}
			elsif ( $analysis->peptide_signal and ($analysis->peptide_signal eq $OK_LABEL) ) {
				$annot->{'ok'} = 1;
			}
			else {
				$annot->{'not_defined'} = 1;
			}
		} else {
			$annot->{'not_defined'} = 1;
		}
	}
	elsif ( $method eq 'crash_tp' ) { # get crash: targetp
		if ( $result and $result->analysis and $result->analysis->crash ) {
			my ($analysis) = $result->analysis->crash;
			if ( $analysis->mitochondrial_signal and ($analysis->mitochondrial_signal eq $NO_LABEL) ) {
				$annot->{'rejected'} = 1;
			}
			elsif ( $analysis->mitochondrial_signal and ($analysis->mitochondrial_signal eq $UNKNOWN_LABEL) ) {
				$annot->{'unknown'} = 1;
			}
			elsif ( $analysis->mitochondrial_signal and ($analysis->mitochondrial_signal eq $OK_LABEL) ) {
				$annot->{'ok'} = 1;
			}
			else {
				$annot->{'not_defined'} = 1;
			}
		} else {
			$annot->{'not_defined'} = 1;
		}
	}
	elsif ( $method eq 'thump' ) { # get thump
		if ( $result and $result->analysis and $result->analysis->thump ) {
			my ($analysis) = $result->analysis->thump;
			if ( $analysis->transmembrane_signal and ($analysis->transmembrane_signal eq $NO_LABEL) ) {
				$annot->{'rejected'} = 1;
			}
			elsif ( $analysis->transmembrane_signal and ($analysis->transmembrane_signal eq $UNKNOWN_LABEL) ) {
				$annot->{'unknown'} = 1;
			}
			elsif ( $analysis->transmembrane_signal and ($analysis->transmembrane_signal eq $OK_LABEL) ) {
				$annot->{'ok'} = 1;
			}
			else {
				$annot->{'not_defined'} = 1;
			}
		} else {
			$annot->{'not_defined'} = 1;
		}
	}
	elsif ( $method eq 'cexonic' ) { # get cexonic
		if ( $result and $result->analysis and $result->analysis->cexonic ) {
			my ($analysis) = $result->analysis->cexonic;
			if ( $analysis->conservation_exon and ($analysis->conservation_exon eq $NO_LABEL) ) {
				$annot->{'rejected'} = 1;
			}
			elsif ( $analysis->conservation_exon and ($analysis->conservation_exon eq $UNKNOWN_LABEL) ) {
				$annot->{'unknown'} = 1;
			}
			elsif ( $analysis->conservation_exon and ($analysis->conservation_exon eq $OK_LABEL) ) {
				$annot->{'ok'} = 1;
			}
			else {
				$annot->{'not_defined'} = 1;
			}
		} else {
			$annot->{'not_defined'} = 1;
		}
	}
		
	return $annot;
}

# CRASH: get annotation from SignalP and TargetP
sub get_crash_annots($$$)
{
	my ($method, $transcript_id, $reports) = @_;
	my ($signal) = 0;
	my ($annot);

	# Scan every transcript if there is a pep-mit signal	
	foreach my $rst (@{$reports->transcripts}) {	
		my ($all_annots) = get_method_annot($method, $rst);
		if ( ($all_annots->{'ok'} == 1) ) {
				$signal = 1;			
		}
	}
	# Get consensus result for current transcript:
	# if there is signal for both methods, we take the consensus annotation. Otherwise, we don't know
	if ( $signal == 1 ) {
		my ($index) = $reports->{'_index_transcripts'}->{$transcript_id};
		my ($result) = $reports->transcripts->[$index];		
		$annot = get_crash_annot($method, $result);
	}
	else {
		$annot = $UNKNOWN_LABEL;
	}
	
	return ($annot,$signal);
		
} # End get_crash_annots

sub get_crash_annot($$)
{
	my ($method, $result) = @_;
	my ($annot);

	# get crash: signalp or targetp
	my ($m_annot) = get_method_annot($method, $result);
	
	# get consensus
	if ( $m_annot->{'not_defined'} == 1	) { # we don't results
		$annot = undef;		
	}
	elsif ( $m_annot->{'rejected'} == 1	) { # reject if all methods reject
		$annot = $NO_LABEL;
	}
	elsif ( $m_annot->{'ok'} == 1	) {
		$annot = $OK_LABEL;
	}
	else { # other cases, we don't know
		$annot = $UNKNOWN_LABEL;
	}
	
	return $annot;
		
} # End get_crash_annot

# INERTIA: get the number of unusual exons
sub get_num_unusual_exons($)
{
	my ($analysis) = @_;
	
	my (@types) = ('inertia','maf', 'prank', 'kalign');	
	my ($num_un_exons);
	
	foreach my $type (@types) {	
					
		$num_un_exons->{$type} = 0;
		my ($regions);

		if ( ($type eq 'inertia') and $analysis->regions ) { # consensus
			$regions = $analysis->regions;
		}
		elsif ( ($type eq 'maf') and $analysis->mafft_alignment and $analysis->mafft_alignment->regions ) {
			$regions = $analysis->mafft_alignment->regions;
		}
		elsif ( ($type eq 'prank') and $analysis->prank_alignment and $analysis->prank_alignment->regions ) {
			$regions = $analysis->prank_alignment->regions;
		}
		elsif ( ($type eq 'kalign') and $analysis->kalign_alignment and $analysis->kalign_alignment->regions ) {
			$regions = $analysis->kalign_alignment->regions;
		}

		foreach my $residue (@{$regions}) {
			if ( $residue->unusual_evolution and defined $residue->unusual_evolution and ($residue->unusual_evolution eq $NO_LABEL) ) {
				$num_un_exons->{$type} += 1
			}		
		}
	}
	
	return $num_un_exons;
	
} # End get_num_unusual_exons


main();



__END__

=head1 NAME

appris

=head1 DESCRIPTION

Run APPRIS program

=head1 SYNOPSIS

appris

=head2 Required arguments:

	--conf <Config file>
	
	--data=  <Gencode data file>
	
	--transcripts=  <Gencode transcript file>
	
	--translations=  <Gencode translations file>
	
	--firestar <firestar results for a gene>
	
	--matador3d <Matador3D results for a gene>

	--corsair <CORSAIR results for a gene>

	--spade <SPADE results for a gene>
	
	--inertia <INERTIA results for a gene>

	--cexonic <CExonic results for a gene>

	--thump <THUMP results for a gene>

	--crash <CRASH results for a gene>
	
	--output <Annotation output file>
    
	--output_label <Output file of labels>
	
	--output_score <Output file of method scores>

=head2 Optional arguments:

	--inertia_maf <INERTIA results for a gene using MAF align>
	
	--inertia_prank <INERTIA results for a gene using Prank align>
	
	--inertia_kalign <INERTIA results for a gene using KAlign align>


	--loglevel=LEVEL <define log level (default: NONE)>	

	--logfile=FILE <Log to FILE (default: *STDOUT)>
	
	--logpath=PATH <Write logfile to PATH (default: .)>
	
	--logappend <Append to logfile (default: truncate)>
    

=head1 EXAMPLE

perl appris.pl

	--conf=../conf/pipeline.ini
	
	--data=examples/ENSG00000142185/ENSG00000142185.gencode.v7.annotation.gtf
	
	--transcripts=examples/ENSG00000142185/ENSG00000142185.gencode.v7.pc_transcripts.fa
	
	--translations=examples/ENSG00000142185/ENSG00000142185.gencode.v7.pc_translations.fa

	--firestar=examples/ENSG00000142185/ENSG00000142185.firestar
	
	--matador3d=examples/ENSG00000142185/ENSG00000142185.matador3d
	
	--corsair=examples/ENSG00000142185/ENSG00000142185.corsair

	--spade=examples/ENSG00000142185/ENSG00000142185.spade
	
	--inertia=examples/ENSG00000142185/ENSG00000142185.inertia
	
	--inertia_maf=examples/ENSG00000142185/ENSG00000142185.inertia.maf

	--inertia_prank=examples/ENSG00000142185/ENSG00000142185.inertia.prank

	--inertia_kalign=examples/ENSG00000142185/ENSG00000142185.inertia.kalign	
	
	--cexonic=examples/ENSG00000142185/ENSG00000142185/ENSG00000142185.cexonic # DEPRECATED

	--thump=examples/ENSG00000142185/ENSG00000142185.thump

	--crash=examples/ENSG00000142185/ENSG00000142185.crash
	
	--output=examples/ENSG00000142185/ENSG00000016864.appris
	
	--output_label=examples/ENSG00000142185/ENSG00000016864.appris.label
	
	--output_score=examples/ENSG00000142185/ENSG00000016864.appris.score


=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut