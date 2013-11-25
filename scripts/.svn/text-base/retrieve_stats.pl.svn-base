#!/usr/bin/perl -W

use strict;
use warnings;

use FindBin;
use Getopt::Long;
use Bio::SeqIO;

use APPRIS::Utils::File qw( printStringIntoFile getTotalStringFromFile );
use APPRIS::Utils::Logger;
use Data::Dumper;

###################
# Global variable #
###################
use vars qw(
	@METHODS
	@METHODS_LEN
);

@METHODS = (
	'firestar',
	'matador3d',
	'corsair',
	'spade',
	'inertia',
	'cexonic',
	'thump',
	'crash_sp',
	'crash_tp',
	'appris'
);
@METHODS_LEN = (
	'firestar',
	'matador3d',
	'corsair',
	'spade',
	'inertia',
	'cexonic',
	'thump',
	'crash_sp',
	'crash_tp',
	'appris',
	'longest_len'
);
	
# Input parameters
my ($input_main_file) = undef;
my ($input_detail_file) = undef;
my ($input_seq_file) = undef;
my ($output_ccds_file) = undef;
my ($output_rej_file) = undef;
my ($output_rejccds_file) = undef;
my ($output_rejccds2_file) = undef;
my ($logfile) = undef;
my ($logpath) = undef;
my ($logappend) = undef;
my ($loglevel) = undef;

&GetOptions(
	'input-main=s' 		=> \$input_main_file,
	'input-detail=s'	=> \$input_detail_file,
	'input-seq=s'    	=> \$input_seq_file,
	'output-ccds=s'		=> \$output_ccds_file,
	'output-rej=s'		=> \$output_rej_file,
	'output-rejccds=s'	=> \$output_rejccds_file,
	'output-rejccds2=s'	=> \$output_rejccds2_file,
	'loglevel=s'		=> \$loglevel,
	'logfile=s'			=> \$logfile,
	'logpath=s'			=> \$logpath,
	'logappend'			=> \$logappend,
);

# Required arguments
unless(
	defined $input_main_file and
	defined $input_detail_file and
	defined $input_seq_file and
	defined $output_ccds_file and
	defined $output_rej_file and
	defined $output_rejccds_file and
	defined $output_rejccds2_file
) {
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
sub _parse_sequence($);
sub _get_longest_pep_seq($);
sub _get_main_report($$);
sub _get_detail_report($);
sub _get_stats($$$);
sub _get_ccds_stats_content($$$$$$);
sub _get_rej_stats_content($$$$);
sub _get_rejccds_stats_content($$$);
sub _get_rejccds2_stats_content($$$);

#################
# Method bodies #
#################
# Main subroutine
sub main()
{
	# Get sequences
	$logger->info("##Get sequences -----------\n");
	my ($transl_seq) = _parse_sequence($input_seq_file);
	my ($longest_transl_seq) = _get_longest_pep_seq($transl_seq);
	#$logger->debug("TRANSL_SEQ:\n".Dumper($transl_seq)."\n");
	#$logger->debug("LON_TRANSL_SEQ:\n".Dumper($longest_transl_seq)."\n");

	# Get content
	$logger->info("##Get content -----------\n");
	my ($main_content) = getTotalStringFromFile($input_main_file);
	my ($detail_content) = getTotalStringFromFile($input_detail_file);
	my ($main_report) = _get_main_report($main_content, $transl_seq);
	my ($detail_report) = _get_detail_report($detail_content);
	$logger->debug("REPORT:\n".Dumper($main_report)."\n");
	$logger->debug("REPORT_2:\n".Dumper($detail_report)."\n");
	
	# Get the stats
	$logger->info("##Get stats -----------\n");
	my ($rejections, $decisions, $rejections_ccds, $comparison_ccds, $comparison_ccds_more_trans, $method_trans_rejected, $method_trans_ccds_rejected, $method_gene_rejected, $method_gene_ccds_rejected) = _get_stats($main_report, $detail_report, $longest_transl_seq);
	$logger->debug("REJECTIONS:\n".Dumper($rejections)."\n");
	$logger->debug("DECISITIONS:\n".Dumper($decisions)."\n");
	$logger->debug("REJECTIONS_CCDS:\n".Dumper($rejections_ccds)."\n");
	$logger->debug("COMPARISONS_CCDS:\n".Dumper($comparison_ccds)."\n");
	$logger->debug("TRANS_REPORT:\n".Dumper($method_trans_rejected)."\n");
	$logger->debug("TRANS_CCDS_REPORT:\n".Dumper($method_trans_ccds_rejected)."\n");
	$logger->debug("GENE_REPORT:\n".Dumper($method_gene_rejected)."\n");
	$logger->debug("GENE_CCDS_REPORT:\n".Dumper($method_gene_ccds_rejected)."\n");

	# Get the content of CCDS stats
	$logger->info("##Get ccds stats -----------\n");
	my ($output_ccds_content) = _get_ccds_stats_content($method_trans_rejected, $method_trans_ccds_rejected, $method_gene_rejected, $method_gene_ccds_rejected, $comparison_ccds, $comparison_ccds_more_trans);
	my ($printing_file_log) = printStringIntoFile($output_ccds_content, $output_ccds_file);
	$logger->error("Printing _get_ccds_stats_content\n") unless(defined $printing_file_log);	

	# Get Rejection stats
	$logger->info("##Get rejection stats -----------\n");
	my ($output_rej_content) = _get_rej_stats_content($main_report, $detail_report, $rejections, $decisions);	
	my ($printing_file_log2) = printStringIntoFile($output_rej_content, $output_rej_file);
	$logger->error("Printing _get_rej_stats_content\n") unless(defined $printing_file_log2);	

	# Get CCDS Rejections stats
	$logger->info("##Get ccds rejection stats -----------\n");
	my ($output_rejccds_content) = _get_rejccds_stats_content($main_report, $detail_report, $rejections_ccds);	
	my ($printing_file_log3) = printStringIntoFile($output_rejccds_content, $output_rejccds_file);
	$logger->error("Printing _get_rejccds_stats_content\n") unless(defined $printing_file_log3);	

	# Get CCDS Rejections stats
	$logger->info("##Get ccds rejection stats -----------\n");
	my ($output_rejccds2_content) = _get_rejccds2_stats_content($main_report, $detail_report, $rejections_ccds);	
	my ($printing_file_log4) = printStringIntoFile($output_rejccds2_content, $output_rejccds2_file);
	$logger->error("Printing _get_rejccds_stats_content\n") unless(defined $printing_file_log4);	

	$logger->finish_log();
	
	exit 0;
		
}

sub _parse_sequence($)
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
			if ( $seq->id=~/([^|]*)\|([^|]*)/ )
			{
				my ($trans_id) = $1;
				my ($gene_id) = $2;
				$trans_id =~ s/\.\d*$//; # delete suffix
				$gene_id =~ s/\.\d*$//; # delete suffix
				if(exists $data->{$gene_id}->{'transcripts'}->{$trans_id}) {
					throw("Duplicated sequence: $trans_id");
				}
				else {
					$data->{$gene_id}->{'transcripts'}->{$trans_id} = $seq->seq; 
				}
			}
		}		
	}
	return $data;
} # End _parse_sequence

sub _get_longest_pep_seq($)
{
	my ($transl_seq) = @_;
	my ($report);
	
	while ( my ($gene_id, $g_report) = each (%{$transl_seq}) ) {
		if ( exists $g_report->{'transcripts'} ) {
			my ($aux_report);
			while ( my ($transcript_id, $translation_seq) = each (%{$g_report->{'transcripts'}}) ) {
				$report->{$gene_id}->{'longest_len'}->{$transcript_id} = '0';
				my ($translation_length) = length($translation_seq);	
				if (defined $aux_report) {
					if ( $translation_length > $aux_report->{'translation_length'} ) { # maximum length
						# discard the last assignments
						foreach my $t (@{$aux_report->{'transcript_id'}}) {
							$report->{$gene_id}->{'longest_len'}->{$t}			= '0';								
						}
						$report->{$gene_id}->{'longest_len'}->{$transcript_id}	= '1'; #assign the new value
						$aux_report->{'translation_length'}						= $translation_length;
						$aux_report->{'transcript_id'}							= undef;
						push(@{$aux_report->{'transcript_id'}}, $transcript_id);
					}
					elsif ( $translation_length == $aux_report->{'translation_length'} ) { # equal length
						$report->{$gene_id}->{'longest_len'}->{$transcript_id}	= '1';
						$aux_report->{'translation_length'}						= $translation_length;
						push(@{$aux_report->{'transcript_id'}}, $transcript_id);
					}					
				}
				else { # init
					$report->{$gene_id}->{'longest_len'}->{$transcript_id}	= '1';
					$aux_report->{'translation_length'}						= $translation_length;
					push(@{$aux_report->{'transcript_id'}}, $transcript_id);
				}
			}
		}
    }		
	return $report;	
} # End _get_longest_pep_seq

sub _get_main_report($$)
{
	my($content, $transl_seq) = @_;
	my($report);
	
	# Main Content:
	#gene_id	transcript_id	status	biotype	no_codons ccds_id
	#fun_res
	#con_struct
	#vert_signal
	#dom_signal
	#u_evol
	#exon_signal
	#tmh_signal
	#pep_mit_signal
	#score
	#prin_isoform
	#reliability
		
	foreach my $input_line (@{$content})
	{
		$input_line=~s/\n*$//;
		my(@split_line)=split("\t", $input_line);
		next if(scalar(@split_line)<=0);

		my($gene_id)=$split_line[0];
		my($transcript_id)=$split_line[1];
		my($trans_translation)=$split_line[2];
		my($trans_status)=$split_line[3];
		my($trans_biotype)=$split_line[4];
		my($no_codons)=$split_line[5];
		my($ccds_id)=$split_line[6];

		my($firestar_annot)=$split_line[7];
		my($matador3d_annot)=$split_line[8];
		my($corsair_annot)=$split_line[9];
		my($spade_annot)=$split_line[10];
		my($inertia_annot)=$split_line[11];		
		my($cexonic_annot)=$split_line[12];
		my($thump_annot)=$split_line[13];
		my($crash_annot)=$split_line[14];
		my($appris_score)=$split_line[15];
		my($appris_annot)=$split_line[16];
		my($appris_relia)=$split_line[17];

		if(	defined $gene_id and defined $transcript_id and defined $trans_translation and 
			defined $trans_status and defined $trans_biotype and defined $no_codons and defined $ccds_id
		){				
			unless (exists $report->{$gene_id}->{'num_trans'}) {
				$report->{$gene_id}->{'num_trans'}=0;		
			}
			$report->{$gene_id}->{'num_trans'}++;
			if($no_codons ne '-') {
				$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'no_codons'}=$no_codons;
			}

			# get ccds taking into account the pep sequence. We take into account the unique ccds,
			# then we add new ccds if the seq is unique.				
			if($ccds_id ne '-') {
				$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'ccds_id'}=$ccds_id;
				my ($g_transl_seq);
				if ( exists $transl_seq->{$gene_id} ) {
					$g_transl_seq = $transl_seq->{$gene_id};
				}
				if ( defined $g_transl_seq and
					 exists $g_transl_seq->{'transcripts'} and 
					 exists $g_transl_seq->{'transcripts'}->{$transcript_id} and defined $g_transl_seq->{'transcripts'}->{$transcript_id} )
				{
					my ($new_seq) = $g_transl_seq->{'transcripts'}->{$transcript_id};
					if (exists $report->{$gene_id}->{'ccds_id'} and
						exists $report->{$gene_id}->{'ccds_id'}->{$ccds_id} and 
						defined $report->{$gene_id}->{'ccds_id'}->{$ccds_id}) {
							my ($old_seq) = $report->{$gene_id}->{'ccds_id'}->{$ccds_id};
							if ($old_seq ne $new_seq) { # add new ccds if the seq is different
								my $key = $ccds_id.'-'.$transcript_id;
								$report->{$gene_id}->{'ccds_id'}->{$key} = $new_seq;
							}
					}
					else {
						$report->{$gene_id}->{'ccds_id'}->{$ccds_id} = $new_seq;
					}
				}
			}
			
			if(	defined $firestar_annot and defined $matador3d_annot and defined $corsair_annot and 
				defined $corsair_annot and defined $corsair_annot and 
				defined $inertia_annot and defined $cexonic_annot and
				defined $thump_annot and defined $crash_annot and 
				defined $appris_annot and defined $appris_relia
			){						
				push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'annotations'}},
					$firestar_annot,
					$matador3d_annot,
					$corsair_annot,
					$spade_annot,
					$inertia_annot,
					$cexonic_annot,
					$thump_annot,
					$crash_annot,
					$appris_score,
					$appris_annot,
					$appris_relia
				);
			}			
		}		
	}
	return $report;
} # End _get_main_report

sub _get_detail_report($)
{
	my($content) = @_;
	my($report);
	
	# Main Content:
	#gene_id	transcript_id	status	biotype	ccds_id	
	#fun_res
	#con_struct
	#vert_signal
	#dom_signal
	#u_evol
	#exon_signal
	#tmh_signal
	#pep_mit_signal
	#prin_isoform
	
	foreach my $input_line (@{$content})
	{
		$input_line=~s/\n*$//;
		my(@split_line)=split("\t", $input_line);
		next if(scalar(@split_line)<=0);

		my($gene_id)=$split_line[0];
		my($transcript_id)=$split_line[1];
		my($trans_translation)=$split_line[2];
		my($trans_status)=$split_line[3];
		my($trans_biotype)=$split_line[4];
		my($no_codons)=$split_line[5];
		my($ccds_id)=$split_line[6];
		
		my($firestar_annot)=$split_line[7];
		my($matador3d_annot)=$split_line[8];
		my($corsair_annot)=$split_line[9];
		my($spade_annot)=$split_line[10];	
		my($inertia_annot)=$split_line[11];		
		my($cexonic_annot)=$split_line[12];
		my($thump_annot)=$split_line[13];
		my($crash_sp_annot)=$split_line[14];
		my($crash_tp_annot)=$split_line[15];
		my($appris_annot)=$split_line[16];
		
		if(	defined $gene_id and defined $transcript_id and defined $trans_translation and 
			defined $trans_status and defined $trans_biotype and defined $no_codons and defined $ccds_id			
		){
			unless (exists $report->{$gene_id}->{'num_trans'}) {
				$report->{$gene_id}->{'num_trans'}=0;
				$report->{$gene_id}->{'num_translations'}=0;
				$report->{$gene_id}->{'num_no_translations'}=0;
				$report->{$gene_id}->{'num_nmd'}=0;
				$report->{$gene_id}->{'num_pc'}=0;	
			}
			$report->{$gene_id}->{'num_trans'}++;
			if ( $trans_translation eq 'TRANSLATION' ) {
				$report->{$gene_id}->{'num_translations'}++;
			}
			else {
				$report->{$gene_id}->{'num_no_translations'}++;	
			}
				
			if ( $trans_biotype eq 'protein_coding' ) {
				$report->{$gene_id}->{'num_pc'}++;
			}
			elsif ( $trans_biotype eq 'nonsense_mediated_decay' ) {
				$report->{$gene_id}->{'num_nmd'}++;	
			}

			if($no_codons ne '-') {
				$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'no_codons'}=$no_codons;
			}
			
			if($ccds_id ne '-') {
				$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'ccds_id'}=$ccds_id;
			}
			push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'summary'}},
														$trans_translation,
														$trans_status,
														$trans_biotype
			);			
			if(	defined $firestar_annot and defined $matador3d_annot and defined $corsair_annot and 
				defined $corsair_annot and defined $corsair_annot and 
				defined $inertia_annot and defined $cexonic_annot and
				defined $thump_annot and defined $crash_sp_annot and defined $crash_tp_annot and 
				defined $appris_annot 
			){			
				push(@{$report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'annotations'}},
					$firestar_annot,
					$matador3d_annot,
					$corsair_annot,
					$spade_annot,
					$inertia_annot,
					$cexonic_annot,
					$thump_annot,
					$crash_sp_annot,
					$crash_tp_annot,
					$appris_annot
				);
			}			
		}		
	}
	return $report;
} # End _get_detail_report

sub _get_stats($$$)
{
	my ($main_report, $detail_report, $transl_seq) = @_;
	my ($rejections);
	my ($decisions);
	my ($rejections_ccds);
	my ($comparison_ccds);
	my ($comparison_ccds_more_trans);
	my ($method_gene_rejected);
	my ($method_gene_ccds_rejected);
	my ($method_trans_rejected);
	my ($method_trans_ccds_rejected);
	foreach my $method (@METHODS_LEN) {
		$method_gene_rejected->{$method}			= 0;
		$method_gene_ccds_rejected->{$method}		= 0;
		$method_trans_rejected->{$method}			= 0;
		$method_trans_ccds_rejected->{$method}		= 0;
	}

	foreach my $gene_id (keys %{$main_report})	
	{
		my ($gene_report) = $main_report->{$gene_id};
		my ($gene_report_detail) = $detail_report->{$gene_id};		
		my ($num_ccds) = scalar( keys(%{$gene_report->{'ccds_id'}}) );
		my ($num_trans) = scalar( keys(%{$gene_report->{'transcripts'}}) );

		my ($method_gene_rejected_annot);
		my ($method_gene_ccds_rejected_annot);
		foreach my $method (@METHODS_LEN) {
			$rejections->{$gene_id}->{$method}			= 0;
			$decisions->{$gene_id}->{'NO'} 				= 0;
			$decisions->{$gene_id}->{'UNKNOWN'}			= 0;
			$decisions->{$gene_id}->{'YES'}				= 0;	
			$method_gene_rejected_annot->{$method}		= 0;
			$method_gene_ccds_rejected_annot->{$method}	= 0;
		}
		
		# for each transcript		
		foreach my $transcript_id (keys %{$gene_report->{'transcripts'}})
		{
			my ($trans_report) = $gene_report->{'transcripts'}->{$transcript_id};
			my ($trans_report_detail) = $gene_report_detail->{'transcripts'}->{$transcript_id};
			my ($ccds_annot);
			if ( exists $trans_report->{'ccds_id'} and defined $trans_report->{'ccds_id'} and $trans_report->{'ccds_id'} ne '-' ) {
				$ccds_annot=$trans_report->{'ccds_id'};
			}
			
			# get the num. genes that has one CCDS and there is possible APPRIS isoform
			
			# get the rejections of methods comparing agains CCDS (unique within gene)			
			if ( exists $trans_report->{'annotations'} )
			{
				my($annotation_list)=$trans_report->{'annotations'};
				my($annotation_list_detail)=$trans_report_detail->{'annotations'};
				for(my$method_index=0;$method_index<scalar(@{$annotation_list});$method_index++)
				{
					if($method_index == 0) { # firestar
						if($annotation_list->[$method_index] eq '0') {
							my ($key) = 'firestar';						
							if(defined $ccds_annot and $num_ccds == 1) {
								$method_trans_ccds_rejected->{$key}++;							
								$method_gene_ccds_rejected_annot->{$key}=1;
								push(@{$rejections_ccds->{$gene_id}->{$key}}, $transcript_id);
							}
							$method_trans_rejected->{$key}++;
							$method_gene_rejected_annot->{$key}=1;
							$rejections->{$gene_id}->{$key}++;
						}
					}
					if($method_index == 1) { # matador3d
						if($annotation_list->[$method_index] eq '0') {
							my ($key) = 'matador3d';						
							if(defined $ccds_annot and $num_ccds == 1) {
								$method_trans_ccds_rejected->{$key}++;
								$method_gene_ccds_rejected_annot->{$key}=1;
								push(@{$rejections_ccds->{$gene_id}->{$key}}, $transcript_id);
							}
							$method_trans_rejected->{$key}++;
							$method_gene_rejected_annot->{$key}=1;
							$rejections->{$gene_id}->{$key}++;					
						}
					}
					if($method_index == 2) { # corsair
						if($annotation_list->[$method_index] eq '0') {
							my ($key) = 'corsair';
							if(defined $ccds_annot and $num_ccds == 1) {
								$method_trans_ccds_rejected->{$key}++;							
								$method_gene_ccds_rejected_annot->{$key}=1;
								push(@{$rejections_ccds->{$gene_id}->{$key}}, $transcript_id);
							}
							$method_trans_rejected->{$key}++;
							$method_gene_rejected_annot->{$key}=1;
							$rejections->{$gene_id}->{$key}++;
						}
					}				
					if($method_index == 3) { # spade
						if($annotation_list->[$method_index] eq '0') {
							my ($key) = 'spade';						
							if(defined $ccds_annot and $num_ccds == 1) {
								$method_trans_ccds_rejected->{$key}++;
								$method_gene_ccds_rejected_annot->{$key}=1;
								push(@{$rejections_ccds->{$gene_id}->{$key}}, $transcript_id);
							}
							$method_trans_rejected->{$key}++;
							$method_gene_rejected_annot->{$key}=1;
							$rejections->{$gene_id}->{$key}++;						
						}
					}
					if($method_index == 4) { # inertia
						if($annotation_list->[$method_index] eq '0') {
							my ($key) = 'inertia';
							if(defined $ccds_annot and $num_ccds == 1) {
								$method_trans_ccds_rejected->{$key}++;							
								$method_gene_ccds_rejected_annot->{$key}=1;
								push(@{$rejections_ccds->{$gene_id}->{$key}}, $transcript_id);
							}
							$method_trans_rejected->{$key}++;
							$method_gene_rejected_annot->{$key}=1;
							$rejections->{$gene_id}->{$key}++;
						}
					}
					if($method_index == 5) { # cexonic
						if($annotation_list->[$method_index] eq '0') {
							my ($key) = 'cexonic';
							if(defined $ccds_annot and $num_ccds == 1) {
								$method_trans_ccds_rejected->{$key}++;							
								$method_gene_ccds_rejected_annot->{$key}=1;
								push(@{$rejections_ccds->{$gene_id}->{$key}}, $transcript_id);
							}
							$method_trans_rejected->{$key}++;
							$method_gene_rejected_annot->{$key}=1;
							$rejections->{$gene_id}->{$key}++;
						}
					}
					if($method_index == 6) { # thump
						if($annotation_list->[$method_index] eq '0') {
							my ($key) = 'thump';							
							if(defined $ccds_annot and $num_ccds == 1) {
								$method_trans_ccds_rejected->{$key}++;							
								$method_gene_ccds_rejected_annot->{$key}=1;
								push(@{$rejections_ccds->{$gene_id}->{$key}}, $transcript_id);
							}
							$method_trans_rejected->{$key}++;
							$method_gene_rejected_annot->{$key}=1;
							$rejections->{$gene_id}->{$key}++;
						}
					}
					if($method_index == 7) { # crash
						if($annotation_list->[$method_index] eq '0') {
							# crash_sp
							my ($key_sp) = 'crash_sp';							
							my ($m_index_sp) = 7;
							#my ($m_annot_sp,$m_score_sp);
							#if ( $annotation_list_detail->[$m_index_sp] =~ /([^\[]*)\[([^\]]*)\]/ ) {
							#	($m_annot_sp,$m_score_sp) = ($1,$2);
							#}
							my ($m_annot_sp) = $annotation_list_detail->[$m_index_sp];
							if($m_annot_sp eq "NO") {
								if(defined $ccds_annot and $num_ccds == 1) {
									$method_trans_ccds_rejected->{$key_sp}++;							
									$method_gene_ccds_rejected_annot->{$key_sp}=1;
									push(@{$rejections_ccds->{$gene_id}->{$key_sp}}, $transcript_id);									
								}
								$method_trans_rejected->{$key_sp}++;
								$method_gene_rejected_annot->{$key_sp}=1;
								$rejections->{$gene_id}->{$key_sp}++;
							}
							# crash_tp
							my ($key_tp) = 'crash_tp';
							my ($m_index_tp) = 8;
							#my ($m_annot_tp,$m_score_tp);
							#if ( $annotation_list_detail->[$m_index_tp] =~ /([^\[]*)\[([^\]]*)\]/ ) {
							#	($m_annot_tp,$m_score_tp) = ($1,$2);
							#}
							my ($m_annot_tp) = $annotation_list_detail->[$m_index_tp];
							if($m_annot_tp eq "NO") {
								if(defined $ccds_annot and $num_ccds == 1) {
									$method_trans_ccds_rejected->{$key_tp}++;							
									$method_gene_ccds_rejected_annot->{$key_tp}=1;
									push(@{$rejections_ccds->{$gene_id}->{$key_tp}}, $transcript_id);
								}
								$method_trans_rejected->{$key_tp}++;
								$method_gene_rejected_annot->{$key_tp}=1;
								$rejections->{$gene_id}->{$key_tp}++;
							}												
						}
					}
					if($method_index == 9) { # appris
						if($annotation_list->[$method_index] eq "NO") {
							my ($key) = 'appris';
							if(defined $ccds_annot and $num_ccds == 1) {
								$method_trans_ccds_rejected->{$key}++;
								$method_gene_ccds_rejected_annot->{$key}=1;
								#$rejections_ccds->{$gene_id}->{$key} = $transcript_id;
								push(@{$rejections_ccds->{$gene_id}->{$key}}, $transcript_id);	
							}
							$method_trans_rejected->{$key}++;
							$method_gene_rejected_annot->{$key}=1;
							$rejections->{$gene_id}->{$key}++;
							$decisions->{$gene_id}->{'NO'}++;
						}
						elsif($annotation_list->[$method_index] eq "UNKNOWN") {
							$decisions->{$gene_id}->{'UNKNOWN'}++;
							if ( $num_ccds == 1 )  {
								push(@{$comparison_ccds->{$gene_id}}, $transcript_id);
								if ( $num_trans > 1 ) {
									push(@{$comparison_ccds_more_trans->{$gene_id}}, $transcript_id);
								}
							}
						}
						elsif($annotation_list->[$method_index] eq "YES") {
							$decisions->{$gene_id}->{'YES'}++;
							if ( $num_ccds == 1 ) {
								push(@{$comparison_ccds->{$gene_id}}, $transcript_id);
								if ( $num_trans > 1 ) {
									push(@{$comparison_ccds_more_trans->{$gene_id}}, $transcript_id);
								}								
							}
						}
					}
				}
				# get the rejection of CCDS when a transcript has longest peptide sequences
				if ( exists $transl_seq->{$gene_id} and exists $transl_seq->{$gene_id}->{'longest_len'} ) {
					my ($longest_length_list) = $transl_seq->{$gene_id}->{'longest_len'};
					if($longest_length_list->{$transcript_id} eq '0') {
						my ($key) = 'longest_len';						
						if(defined $ccds_annot and $num_ccds == 1) {
							$method_trans_ccds_rejected->{$key}++;							
							$method_gene_ccds_rejected_annot->{$key}=1;
						}
						$method_trans_rejected->{$key}++;
						$method_gene_rejected_annot->{$key}=1;
						$rejections->{$gene_id}->{$key}++;
					}					
				}
			}
		}
		foreach my $method (@METHODS_LEN) {
			if($method_gene_ccds_rejected_annot->{$method} == 1) {
				$method_gene_ccds_rejected_annot->{$method}=1;
				$method_gene_ccds_rejected->{$method}++;
			}
			if($method_gene_rejected_annot->{$method} == 1) {
				$method_gene_rejected->{$method}++;
			}			
		}				
	}
	return ($rejections, $decisions, $rejections_ccds, $comparison_ccds, $comparison_ccds_more_trans, $method_trans_rejected, $method_trans_ccds_rejected, $method_gene_rejected, $method_gene_ccds_rejected);
} # End _get_stats

sub _get_ccds_stats_content($$$$$$)
{
	my ($method_trans_rejected, $method_trans_ccds_rejected, $method_gene_rejected, $method_gene_ccds_rejected, $comparison_ccds, $comparison_ccds_more_trans) = @_;
	my ($method_per_trans_ccds_rejected);
	my ($method_per_gene_ccds_rejected);
	my ($method_per_gene_ccds_comparision);
	my ($method_per_gene_ccds_comparision2);
	foreach my $method (@METHODS_LEN) {
		$method_per_trans_ccds_rejected->{$method}		= 0;
		$method_per_gene_ccds_rejected->{$method} 		= 0;
		$method_per_gene_ccds_comparision->{$method} 	= 0;
		$method_per_gene_ccds_comparision2->{$method} 	= 0;
	}

	# Print summary and totals (CDS rejected) By Transcript ------------------
	my($content) = "\t".
						"\t";
	foreach my $method (@METHODS_LEN) {
		$content .= "\t".$method;
	}
	$content .= "\n";
						
	# Print Total rejected transcripts
	$content.="Total rejected transcripts\t".
							"\t";
	foreach my $method (@METHODS_LEN) {
		$content .= "\t".$method_trans_rejected->{$method};
	}
	$content .= "\n";

	# Print Total rejected transcripts with CCDS									
	$content.="Total rejected transcripts with CCDS\t".
							"\t";
	foreach my $method (@METHODS_LEN) {
		$content .= "\t".$method_trans_ccds_rejected->{$method};
	}
	$content .= "\n";

	# Get the values of percentage of rejected transcripts with CCDS
	foreach my $method (@METHODS_LEN) {
		my ($percentage) = 0;
		eval {
			$percentage = ($method_trans_ccds_rejected->{$method}/$method_trans_rejected->{$method})*100;
		};				
		$method_per_trans_ccds_rejected->{$method} = sprintf("%.2f",$percentage);
	}

	# Print Pecentage of rejected transcripts with CCDS
	$content.="Percentage of rejected transcripts with CCDS\t".
							"\t";
	foreach my $method (@METHODS_LEN) {
		$content .= "\t".$method_per_trans_ccds_rejected->{$method}."%";
	}
	$content .= "\n";

	# Print summary and totals (CDS rejected) By GENE ------------------
	$content .= "Total rejected genes\t".
							"\t";
	foreach my $method (@METHODS_LEN) {
		$content .= "\t".$method_gene_rejected->{$method};
	}
	$content .= "\n";

	# Print Total rejected genes with CCDS									
	$content.="Total rejected genes with unique CCDS\t".
							"\t";
	foreach my $method (@METHODS_LEN) {
		$content .= "\t".$method_gene_ccds_rejected->{$method};
	}
	$content .= "\n";

	# Get the values of percentage of rejected transcripts with CCDS
	foreach my $method (@METHODS_LEN) {
		my ($percentage) = 0;
		eval {
			$percentage = ($method_gene_ccds_rejected->{$method}/$method_gene_rejected->{$method})*100;
		};		
		$method_per_gene_ccds_rejected->{$method} = sprintf("%.2f",$percentage);
	}

	# Print Percentage of rejected genes with CCDS
	$content.="Percentage of rejected genes with unique CCDS\t".
							"\t";
	foreach my $method (@METHODS_LEN) {
		$content .= "\t".$method_per_gene_ccds_rejected->{$method}."%";
	}
	$content .= "\n";
	
	# Get the number of genes with unique CCDS and there is a possible APPRIS isoform
	my ($num_gene_ccds) = scalar( keys(%{$comparison_ccds}) );
	my ($num_gene_ccds_more_trans) = scalar( keys(%{$comparison_ccds_more_trans}) );
	$content.="Genes with unique CCDS and one or more isoform\t".$num_gene_ccds."\n";
	$content.="Genes with unique CCDS with more than one isoform\t".$num_gene_ccds_more_trans."\n";
	$content.="Total rejected genes with unique CCDS\t".
							"\t";
	foreach my $method (@METHODS_LEN) {
		$content .= "\t".$method_gene_ccds_rejected->{$method};
	}
	$content .= "\n";
	foreach my $method (@METHODS_LEN) {
		my ($percentage) = 0;
		my ($percentage2) = 0;
		eval {
			$percentage = ($method_gene_ccds_rejected->{$method}/$num_gene_ccds)*100;
			$percentage2 = ($method_gene_ccds_rejected->{$method}/$num_gene_ccds_more_trans)*100;
		};		
		$method_per_gene_ccds_comparision->{$method} = sprintf("%.2f",$percentage);
		$method_per_gene_ccds_comparision2->{$method} = sprintf("%.2f",$percentage2);
	}
	# print Percentage of rejected genes with CCDS
	$content.="Percentage of rejected genes with unique CCDS in one or more isoform\t".
							"\t";
	foreach my $method (@METHODS_LEN) {
		$content .= "\t".$method_per_gene_ccds_comparision->{$method}."%";
	}
	$content .= "\n";
	$content.="Percentage of rejected genes with unique CCDS in more than one isoform\t".
							"\t";
	foreach my $method (@METHODS_LEN) {
		$content .= "\t".$method_per_gene_ccds_comparision2->{$method}."%";
	}
	$content .= "\n";	
	
	
	
	return $content;
} # End _get_ccds_stats_content

sub _get_rej_stats_content($$$$)
{
	my ($main_report, $detail_report, $rejections, $decisions) = @_;
	my ($content) = '';
	$content .= 'gene_id'."\t".'num_translations'."\t".'num_nmd'."\t";
	foreach my $method (@METHODS) {
		$content .= $method."\t";
	}
	$content .= 'reject'."\t";
	$content .= 'unknown'."\t";
	$content .= 'principal'."\n";	

	foreach my $gene_id (keys %{$rejections})	
	{
		if ( exists $rejections->{$gene_id} ) {
			my ($rej_report) = $rejections->{$gene_id};
			my ($num_translations) = 0;
			my ($num_nmd) = 0;			
			if ( exists $detail_report->{$gene_id}->{'num_translations'} ) {
				$num_translations = $detail_report->{$gene_id}->{'num_translations'};
				if ( $num_translations != 0 ) {
					$num_nmd = $detail_report->{$gene_id}->{'num_nmd'} if ( exists $detail_report->{$gene_id}->{'num_nmd'} );
					$content .= $gene_id."\t".$num_translations."\t".$num_nmd."\t";
					foreach my $method (@METHODS) {
						$content .= $rejections->{$gene_id}->{$method}."\t";
					}
					$content .= $decisions->{$gene_id}->{'NO'}."\t";
					$content .= $decisions->{$gene_id}->{'UNKNOWN'}."\t";
					$content .= $decisions->{$gene_id}->{'YES'}."\n";					
				}
			}
		}
	}
	return $content;	
} # End _get_rej_stats_content
 
sub _get_rejccds_stats_content($$$)
{
	my ($main_report, $detail_report, $rejections) = @_;
	my ($content) = '';
	$content .= 'gene_id'."\t".'transcript_id'."\t".'ccds_id'."\t";
	foreach my $method (@METHODS) {
		$content .= $method."\t";
	}
	$content =~ s/\t$/\n/;	

	foreach my $gene_id (keys %{$rejections})	
	{
		if ( exists $rejections->{$gene_id}->{'appris'} ) {
			foreach my $transcript_id (@{$rejections->{$gene_id}->{'appris'}}) {
				#my ($transcript_id) = $rejections->{$gene_id}->{'appris'};
				my ($ccds_id) = '-';
				if ( exists $main_report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'ccds_id'} ) {
					$ccds_id = $main_report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'ccds_id'};
					$content .= $gene_id."\t".$transcript_id."\t".$ccds_id."\t";					
					if ( exists $detail_report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'annotations'} ) {
						$content .= join ("\t", @{$detail_report->{$gene_id}->{'transcripts'}->{$transcript_id}->{'annotations'}});
					}
					$content =~ s/\t*$/\n/;					
				}				
			}
		}
	}
	return $content;	
} # End _get_rejccds_stats_content

sub _get_rejccds2_stats_content($$$)
{
	my ($main_report, $detail_report, $rejections) = @_;
	my ($content) = '';
	foreach my $method (@METHODS) {
		$content .= $method."\t";
	}
	$content =~ s/\t$/\n/;	

	foreach my $gene_id (keys %{$rejections})	
	{
		foreach my $method (@METHODS) {
			if ( exists $rejections->{$gene_id}->{$method} ) {
				$content .= $gene_id."\t";
			}
			else {
				$content .= '-'."\t";
			}			
		}
		$content =~ s/\t*$/\n/;
	}
	return $content;	
} # End _get_rejccds2_stats_content

main();

1;


__END__

=head1 NAME

stats_appris

=head1 DESCRIPTION

Count the rejected CCDS for transcript.

=head1 VERSION

0.1

=head2 Options

	--input-main <Input main tabular file>

	--input-detail <Input detailed tabular file>
	
	--input-seq <Input sequence comment file>

	--output-ccds <Output file that has the rejections of CCDS>
	
	--output-rej <Output file that has the rejections>
	
	--output-rejccds <Output file that has the list of genes that APPRIS rejects CCDS>
	
	--output-rejccds2 <Output file that has the list of genes that methods reject CCDS>	

=head2 Examples

	perl stats_appris.pl

		--input-main=../features/stats/appris.results.rel7.v1.output
		
		--input-detail=../features/stats/appris.results.rel7.v1.output.detail

		--input-seq=../features/gencode.v7.pc_translations.fa
		
		--output-ccds=../features/stats/appris.results.rel7.v1.output.stats.ccds
		
		--output-rej=../features/stats/appris.results.rel7.v1.output.stats.rej
		
		--output-rejccds=../features/stats/appris.results.rel7.v1.output.stats.rejccds
		
		--output-rejccds2=../features/stats/appris.results.rel7.v1.output.stats.rejccds2		
		
=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut

