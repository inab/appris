#!/usr/bin/perl -W

use strict;
use warnings;
use Getopt::Long;
use FindBin;

use APPRIS::Registry;
use APPRIS::Utils::File qw( printStringIntoFile );
use APPRIS::Utils::Logger;

use Data::Dumper;

###################
# Global variable #
###################
use vars qw(
	$LOCAL_PWD
	$CONFIG_INI_APPRIS_DB_FILE
);

$LOCAL_PWD					= $FindBin::Bin; $LOCAL_PWD =~ s/bin//;
$CONFIG_INI_APPRIS_DB_FILE	= $LOCAL_PWD.'/conf/apprisdb.ini';

# Input parameters
my ($position) = undef;
my ($output_file) = undef;
my ($apprisdb_conf_file) = undef;
my ($logfile) = undef;
my ($logpath) = undef;
my ($logappend) = undef;
my ($loglevel) = undef;
&GetOptions(
	'position=s'		=> \$position,
	'output=s'			=> \$output_file,
	'apprisdb-conf=s'	=> \$apprisdb_conf_file,	
	'loglevel=s'		=> \$loglevel,
	'logfile=s'			=> \$logfile,
	'logpath=s'			=> \$logpath,
	'logappend'			=> \$logappend,
);

# Required arguments
unless ( defined $output_file )
{
	print `perldoc $0`;
	exit 1;
}

# Optional arguments
# get vars of appris db
unless ( defined $apprisdb_conf_file ) {
	$apprisdb_conf_file = $CONFIG_INI_APPRIS_DB_FILE;
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
sub get_data_by_position($$);


#################
# Method bodies #
#################
# Main subroutine
sub main()
{
	# APPRIS Registry
	# The Registry system allows to tell your programs where to find the APPRIS databases and how to connect to them.
	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $apprisdb_conf_file);	
	
	$logger->info("fetch_basic_by_region ---------------\n");
	my ($region);
	if ( defined $position and $position =~ /^([^\:]*):([^\-]*)-([^\$]*)$/ ) {
		my ($position_chr) = $1;
		my ($position_start) = $2;
		my ($position_end) = $3;
		$region = $registry->fetch_basic_by_region($position_chr, $position_start, $position_end);			
	}
	elsif ( defined $position and $position =~ /^chr([^\$]*)$/ ) {
		my ($position_chr) = $1;
		$region = $registry->fetch_basic_by_region($position_chr);
	}
	else {
		$region = $registry->fetch_basic_by_region($position);
	}
	$logger->info("OK\n");
	
	# Get data by region
	$logger->info("-- get_data_by_position\n");
	my ($output_content) = get_data_by_position($registry, $region);
	if ($output_content ne '') {
		my ($printing_file_log) = printStringIntoFile($output_content,$output_file);
		$logger->error("printing") unless(defined $printing_file_log);		
	}

	$logger->finish_log();
	
	exit 0;	
}

sub get_data_by_position($$)
{
	my ($registry, $region) = @_;
	my ($c_report);
	my ($output) = '';
	
	foreach my $gene (@{$region}) {
		my ($g_report);		
		my ($e_report);
		my ($num_transc) = 0;		
		my ($gene_id) = $gene->stable_id;
		my ($chr) = $gene->chromosome;
		$logger->info("-- $gene_id\n");
		
		foreach my $transcript (@{$gene->transcripts}) {
			my ($t_report);
			my ($transcript_id) = $transcript->stable_id;
			my ($transcript_name) = $transcript->external_name;

			if ($transcript->translate and $transcript->translate->cds) {
				my ($translate) = $transcript->translate;
				#my ($cds) = $translate->cds;			
				my ($ccds_id) = '-';				
				if ( $transcript->xref_identify ) {
					foreach my $xref_identify (@{$transcript->xref_identify}) {								
						if ($xref_identify->dbname eq 'CCDS') {
							$ccds_id = $xref_identify->id;
						}
					}					
				}
				# get appris annotation
				my ($a_analysis) = $registry->fetch_analysis_by_stable_id($transcript_id,'appris');				
				if ( $a_analysis and $a_analysis->appris and $a_analysis->appris->principal_isoform_signal ) {
					my ($appris_annot) = $a_analysis->appris->principal_isoform_signal;
					my ($a_annot);
					if ( $appris_annot eq 'YES' ) {
						$a_annot = 'PRINCIPAL';
					}
					elsif ( $appris_annot eq 'UNKNOWN' ) {
						$a_annot = 'POTENTIAL';					
					}
					if ( defined $a_annot ) {
						
						# get isoform annotation (appris)
						$t_report->{'name'}				= $transcript_name;
						$t_report->{'ccds_id'}			= $ccds_id;
						$t_report->{'appris_annot'}		= $a_annot;
						#$g_report->{'cds'}				= $cds;
						
						# get specie conservation (corsair)
						my ($c_analysis) = $registry->fetch_analysis_by_stable_id($transcript_id,'corsair');
						if ( $c_analysis and $c_analysis->corsair and $c_analysis->corsair->vertebrate_signal ) {
							my ($corsair_annot) = $c_analysis->corsair->vertebrate_signal;
							my ($c_annot);
							if ( ($corsair_annot eq 'YES') or ($corsair_annot eq 'UNKNOWN') ) {
								$c_annot = 'CONSERVE';								
							}
							elsif ( $corsair_annot eq 'NO' ) {
								$c_annot = 'NO_CONSERVE';
							}
							if ( defined $c_annot ) {
								$t_report->{'corsair_annot'}		= $c_annot;								
							}
						}

						# cds annotation
						for (my $icds = 0; $icds < scalar(@{$translate->cds}); $icds++) {
							my ($cds) = $translate->cds->[$icds];	
							my ($cds_start) = $cds->start;
							my ($cds_end) = $cds->end;
							my ($cds_strand) = $cds->strand;
							my ($cds_phase) = $cds->phase;
							my ($cds_index) = $cds_start.':'.$cds_end.':'.$cds_strand;
							if ( exists $e_report->{$cds_index} and exists $e_report->{$cds_index}->{'annot'} and ($e_report->{$cds_index}->{'annot'} ne $a_annot) ) {
								$logger->error("exon $cds_index of $gene_id $transcript_id has incoherent annotation\n");									
							}
							else {
								$e_report->{$cds_index}->{'annot'}		= $a_annot;
								#push(@{$e_report->{$cds_index}->{'trans'}}, $transcript_id);
								if ( exists $t_report->{'appris_annot'} and defined $t_report->{'appris_annot'} ) {
									$e_report->{$cds_index}->{'trans'}->{$transcript_id}->{'appris_annot'} = $t_report->{'appris_annot'};
								}
								if ( exists $t_report->{'corsair_annot'} and defined $t_report->{'corsair_annot'} ) {
									$e_report->{$cds_index}->{'trans'}->{$transcript_id}->{'corsair_annot'} = $t_report->{'corsair_annot'};
								}
							}
						}
																		
						# save trans report
						$g_report->{'chr'}								= $chr;					
						$g_report->{'transcripts'}->{$transcript_id}	= $t_report if ( defined $t_report );
						$num_transc++;
					}											
				}
			}
		}
		$c_report->{$gene_id} = $g_report if ( defined $g_report );
		
		# print sorted exons per gene
		foreach my $cds_index (sort { $a cmp $b } keys %{$e_report} ) {
			my ($cds_report) = $e_report->{$cds_index};
			my ($a_annot) = $cds_report->{'annot'};
			my ($c_annot) = 'CONSERVE';
			my ($o_annot) = 'OVERLAP';
			my ($transc_list) = '';
			while ( my ($transc_id, $trans_report) = each(%{$cds_report->{'trans'}}) ) {
				$transc_list .= $transc_id.';';
				if ( exists $trans_report->{'corsair_annot'} and defined $trans_report->{'corsair_annot'} and 
				($trans_report->{'corsair_annot'} eq 'NO_CONSERVE') ) {
						$c_annot = 'NO_CONSERVE';
				}
			}
			$transc_list =~ s/\;$//mg;
			if ( $num_transc != scalar(keys(%{$cds_report->{'trans'}})) ) {
				$o_annot = 'NO_OVERLAP';
			}
			
			if ( $transc_list ne '' ) {
				$output .=	$chr."\t".
							$cds_index."\t".
							$gene_id."\t".
							$transc_list."\t".
							$a_annot."\t".
							$c_annot."\t".
							$o_annot."\n";
			}			
		}
		$logger->info("\n");
	}
	return $output;
}

main();


1;

__END__

=head1 NAME

export_exon_data

=head1 DESCRIPTION

Get the sorted list of exons per gene.
Each exon is labeled which the following column:
	PRINCIPAL/POTENTIAL -> the exon belongs to principal isoform or the variant is possible principal isoform.
	CONSERVE/NO_CONSERVE -> the exon is conserve agains vertebrates.
	OVERLAP/NO_OVERLAP -> the exon is not in the whole variants labaled as principal isoform. 

=head1 SYNOPSIS

export_exon_data

=head2 Required arguments:

	--output <Output file that has the main isoforms>	
	
=head2 Optional arguments:

	--position= <Genome position> (chr21 or chr1:109102711-109187522)

	--apprisdb-conf <Config file of APPRIS database (default: 'conf/apprisdb.ini' file)>

=head2 Optional arguments:

	--loglevel=LEVEL <define log level (default: NONE)>	

	--logfile=FILE <Log to FILE (default: *STDOUT)>
	
	--logpath=PATH <Write logfile to PATH (default: .)>
	
	--logappend <Append to logfile (default: truncate)>


=head1 EXAMPLE

	perl export_exon_data.pl
	
		--position=21

		--output=../data/export_exon_data.chr21.txt
	

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
