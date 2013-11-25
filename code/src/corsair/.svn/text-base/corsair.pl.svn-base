#!/usr/bin/perl -W
# _________________________________________________________________
# $Id$
# $Revision$
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________

use strict;
use FindBin;
use Getopt::Long;
use Bio::SeqIO;
use Config::IniFiles;
use Data::Dumper;

use APPRIS::Utils::Logger;
use APPRIS::Utils::File qw( printStringIntoFile );

###################
# Global variable #
###################
use vars qw(
	$LOCAL_PWD
	$PROG_IN_SUFFIX
	$PROG_OUT_SUFFIX
	$GIVEN_SPECIES
	$WSPACE_BASE
	$WSPACE_CACHE
	$RUN_PROGRAM
	$PROG_DB
	$PROG_EVALUE
	$APPRIS_CUTOFF
	$OK_LABEL
	$UNKNOWN_LABEL
	$NO_LABEL
	$SCORES
);
		
# Input parameters
my ($config_file) = undef;
my ($gff_file) = undef;
my ($input_file) = undef;
my ($output_file) = undef;
my ($appris) = undef;
my ($logfile) = undef;
my ($logpath) = undef;
my ($logappend) = undef;
my ($loglevel) = undef;
&GetOptions(
	'conf=s'			=> \$config_file,
	'gff=s'				=> \$gff_file,
	'input=s'			=> \$input_file,
	'output=s'			=> \$output_file,
	'appris'			=> \$appris,
	'loglevel=s'		=> \$loglevel,
	'logfile=s'			=> \$logfile,
	'logpath=s'			=> \$logpath,
	'logappend'			=> \$logappend,	
);

# Required arguments
unless ( defined $config_file and defined $gff_file and defined $input_file and defined $output_file )
{
	print `perldoc $0`;
	exit 1;
}

# Get conf vars
my ($cfg) = new Config::IniFiles( -file =>  $config_file );
$LOCAL_PWD			= $FindBin::Bin;
$GIVEN_SPECIES		= $cfg->val('APPRIS_PIPELINE', 'species');
$WSPACE_BASE		= $ENV{APPRIS_PROGRAMS_TMP_DIR}.'/'.$cfg->val('APPRIS_PIPELINE', 'workspace').'/'.$cfg->val('CORSAIR_VARS', 'name').'/';
$WSPACE_CACHE		= $ENV{APPRIS_PROGRAMS_TMP_DIR}.'/'.$cfg->val('APPRIS_PIPELINE', 'workspace').'/'.$cfg->val('CACHE_VARS', 'name').'/';
$RUN_PROGRAM		= $cfg->val( 'CORSAIR_VARS', 'program');
$PROG_DB			= $ENV{APPRIS_PROGRAMS_DB_DIR}.'/'.$cfg->val('CORSAIR_VARS', 'db');
$PROG_EVALUE		= $cfg->val('CORSAIR_VARS', 'evalue');
$PROG_IN_SUFFIX		= 'faa';
$PROG_OUT_SUFFIX	= 'refseq';
$APPRIS_CUTOFF		= $cfg->val( 'CORSAIR_VARS', 'cutoff');
$OK_LABEL			= 'YES';
$UNKNOWN_LABEL		= 'UNKNOWN';
$NO_LABEL			= 'NO';
$SCORES = {
	'REST_OF_SPECIES' => {
		'Homo sapiens'				=> 1,
		'Pan troglodytes'			=> 1,
		'Mus musculus'				=> 1.1,
		'Rattus norvegicus'			=> 1.1,
		'Bos taurus'				=> 1.2,
		'Canis lupus familiaris'	=> 1.2,
		'Sus scrofa'				=> 1.2,
		'Monodelphis domestica'		=> 1.3,
		'Gallus gallus'				=> 2,
		'Taeniopygia guttata'		=> 2,
		'Anolis carolinensis'		=> 2,
		'Xenopus tropicalis'		=> 2.2,
		'Tetraodon nigroviridis'	=> 2,
		'Danio rerio'				=> 2.5,		
	},	
	'Homo sapiens' => {
		'Homo sapiens'				=> 0.5,
		'Pan troglodytes'			=> 1,
		'Mus musculus'				=> 1.1,
		'Rattus norvegicus'			=> 1.1,
		'Bos taurus'				=> 1.2,
		'Canis lupus familiaris'	=> 1.2,
		'Sus scrofa'				=> 1.2,
		'Monodelphis domestica'		=> 1.3,
		'Gallus gallus'				=> 2,
		'Taeniopygia guttata'		=> 2,
		'Anolis carolinensis'		=> 2,
		'Xenopus tropicalis'		=> 2.2,
		'Tetraodon nigroviridis'	=> 2,
		'Danio rerio'				=> 2.5,		
	},
	'Mus musculus' => {
		'Mus musculus'				=> 0.5,
		'Rattus norvegicus'			=> 1,	
		'Homo sapiens'				=> 1.2,
		'Pan troglodytes'			=> 1.2,
		'Bos taurus'				=> 1.2,
		'Canis lupus familiaris'	=> 1.2,
		'Sus scrofa'				=> 1.2,	
		'Monodelphis domestica'		=> 1.3,
		'Gallus gallus'				=> 2,
		'Taeniopygia guttata'		=> 2,
		'Anolis carolinensis'		=> 2,
		'Xenopus tropicalis'		=> 2.2,
		'Tetraodon nigroviridis'	=> 2,
		'Danio rerio'				=> 2.5,
	},
	'Rattus norvegicus' => {
		'Rattus norvegicus'			=> 0.5,
		'Mus musculus'				=> 1,
		'Homo sapiens'				=> 1.2,
		'Pan troglodytes'			=> 1.2,
		'Bos taurus'				=> 1.2,
		'Canis lupus familiaris'	=> 1.2,
		'Sus scrofa'				=> 1.2,	
		'Monodelphis domestica'		=> 1.3,
		'Gallus gallus'				=> 2,
		'Taeniopygia guttata'		=> 2,
		'Anolis carolinensis'		=> 2,
		'Xenopus tropicalis'		=> 2.2,
		'Tetraodon nigroviridis'	=> 2,
		'Danio rerio'				=> 2.5,
	},
	'Danio rerio' => {
		'Danio rerio'				=> 0.5,			
		'Homo sapiens'				=> 2.5,
		'Pan troglodytes'			=> 2,
		'Mus musculus'				=> 2.3,
		'Rattus norvegicus'			=> 2.3,
		'Bos taurus'				=> 2.2,
		'Canis lupus familiaris'	=> 2.2,
		'Sus scrofa'				=> 2.2,
		'Monodelphis domestica'		=> 2.1,
		'Gallus gallus'				=> 1,
		'Taeniopygia guttata'		=> 1,
		'Anolis carolinensis'		=> 1,
		'Xenopus tropicalis'		=> 1.1,
		'Tetraodon nigroviridis'	=> 1,
	},
	'Lynx pardinus' => {
		'Homo sapiens'				=> 1,
		'Pan troglodytes'			=> 1,
		'Mus musculus'				=> 1,
		'Rattus norvegicus'			=> 1,
		'Bos taurus'				=> 1,
		'Canis lupus familiaris'	=> 0.8,
		'Sus scrofa'				=> 1,
		'Monodelphis domestica'		=> 1,
		'Gallus gallus'				=> 2,
		'Taeniopygia guttata'		=> 2,
		'Anolis carolinensis'		=> 2,
		'Xenopus tropicalis'		=> 2.2,
		'Tetraodon nigroviridis'	=> 2,
		'Danio rerio'				=> 2.5,		
	},
};


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
sub parse_blast($$$);
sub check_alignment;

#################
# Method bodies #
#################
# Main subroutine
sub main()
{
	# Declare variables
	my ($vertebrate_score);
	my ($output_content) = "";
	
	# Handle sequence file
	my $in = Bio::SeqIO->new(
						-file => $input_file,
						-format => 'Fasta'
	);
	
	# Scan every fasta sequence
	while ( my $seq = $in->next_seq() )
	{
		if ( $seq->id=~/([^|]*)/ )
		{
			my ($sequence_id) = $1;
			my ($sequence) = $seq->seq;
			my ($sequence_length) = $seq->length;
			
			$logger->info("$sequence_id ---------------\n");
			
			# Create temporal file
			my ($fasta_sequence_file) = $WSPACE_BASE.'/'.$sequence_id.'.'.$PROG_IN_SUFFIX;
			unless(-e $fasta_sequence_file and (-s $fasta_sequence_file > 0) ) # Cached fasta
			{			
				my ($fasta_sequence_cont) = ">$sequence_id\n$sequence";
				my ($print_out) = printStringIntoFile($fasta_sequence_cont, $fasta_sequence_file);
				unless( defined $print_out ) {
					$logger->error("Can not create tmp file: $!\n");
				}
			}
			
			# Get the exons info
			my($exons);
			my(@global_sequence_exon_info)=`grep $sequence_id $gff_file`;
			foreach my $sequence_exon_info (@global_sequence_exon_info)
			{
				my(@exon_info) = split /\t/, $sequence_exon_info;				
				my($edges) = join ":", $exon_info[3], $exon_info[4];
				push(@{$exons}, $edges);
			}

			if(defined $exons and (scalar(@{$exons}) > 0))
			{
				# Run blast
				my ($blast_sequence_file) = $WSPACE_CACHE.'/'.$sequence_id.'.'.$PROG_OUT_SUFFIX;
				unless (-e $blast_sequence_file and (-s $blast_sequence_file > 0) ) # Blast Cache
				{
					eval
					{
						$logger->info("Running blast\n");
						my ($cmd) = "$RUN_PROGRAM -d $PROG_DB -i $fasta_sequence_file -e0.0001 -o $blast_sequence_file";
						$logger->debug("$cmd\n");						
						system("$RUN_PROGRAM -d $PROG_DB -i $fasta_sequence_file -e0.0001 -o $blast_sequence_file");
					};
					$logger->error("Running blast: $!\n") if($@);
				}
				
				# Parse blast
				$logger->info("Parsing blast\n");				
				my ($score, $species_points_found) = parse_blast($blast_sequence_file, $exons, $sequence_length);

				# Save score data
				push(@{$vertebrate_score->{$score}},$sequence_id);

				# print record
				$output_content .= ">".$sequence_id."\t".$score."\n";
				foreach my $sp_found (@{$species_points_found})
				{
					$output_content .= $sp_found."\n";
				}
			}
			else
			{
				$logger->warning("peptide $sequence_id has not exon info");

				my ($score) = '0';
				my ($num_aligned_species) = '0';
				
				# Save score data
				push(@{$vertebrate_score->{$score}},$sequence_id);
				
				# print record
				$output_content .= ">".$sequence_id."\t".$score."\n";
			}
		}
	}
	
	# Get the annotations for the main isoform /* APPRIS */ ----------------
	if ( defined $appris )
	{		
		$output_content .= get_appris_annotations($vertebrate_score);
	}
	
	# Print records by transcript ---------------
	my ($print_out) = printStringIntoFile($output_content, $output_file);
	unless( defined $print_out ) {
		$logger->error("Can not create output file: $!\n");
	}	
	

	$logger->finish_log();
	
	exit 0;	
}

sub parse_blast($$$)				# reads headers for each alignment in the blast output
{
	my ($blast_file,$exons,$sequence_length) = @_;

	open (BLASTFILE, $blast_file) or die "on the spot";

	my $corsair_score = 0;

	
	my $string = "";
	my $align_flag = 0;	
	my @species_found = ();
	my $species_points_found;
	my $got_species = 0;
	my $length = 0;
	my $faalen = 0;
	my $species = "";

	while (<BLASTFILE>)
		{
		if ($_ eq "\n")
			{$string = "";}
		chomp;
		$_ =~ s/^\s+//;
		if(/letters+\)/)			# gets query seqlen once
			{
			my @temp = split " ";
			$faalen = $temp[0];
			$faalen =~ s/\(//;
			if ($faalen != $sequence_length)
				{ $logger->warning("Length of Blast's query is different than input sequence\n"); }
			}
		$string = join " ", $string, $_;	# cos BLAST has bad habit of printing species name over two lines
		if($string =~ /[a-z]+\]/)		# ... has species name
			{
			$got_species = 0;
			my @data = split /\[/, $string;
			$string = "";
			$species = $data[$#data];
			$species =~ s/\]//;
			for (my $i=0;$i<=$#species_found;$i++)		#check if species already scored a point
				{
				if ($species_found[$i] eq $species)
					{ $got_species = 1; next}
				}
			}
		if(/Length =/)						# gets subject sequence length
			{
			my @data = split " ";
			$length = $data[2];
			}
		if(/Identities/)
			{
			my @data = split " ";
			my @iden = split /\//, $data[2];
			$length = $length - $faalen;
			$length = abs($length);				# difference in length between query and subject
			my @identities = split " ", $iden[0];
			my $identity = $iden[0]/$iden[1]*100;
			if ($identity < 50)				# gets no points for this sequence
				{ }
			elsif ($length > 20)				# gets no points for this sequence
				{ }
			elsif ($got_species)				# gets no points for this sequence
				{ }
			else
				{ 
					my $align_log = '';
					($align_flag,$align_log) = check_alignment($species,$faalen,$exons,$_); 	
					if ( $align_flag != 0 ) 
					{
						push @species_found, $species; 	# record species

						if ( ($species =~ /$GIVEN_SPECIES/) and (exists $SCORES->{$GIVEN_SPECIES}) ) # Punish the specie that is equal than given as input.
						{
							my ($point) = $SCORES->{$GIVEN_SPECIES}->{$species};
							$corsair_score = $corsair_score + $point;
							push(@{$species_points_found}, "$species\t$identity\t$point\t$align_log"); # Record species and points for the same specie								
						}
						elsif ( exists $SCORES->{$GIVEN_SPECIES}->{$species} ) # known species
						{
							my ($point) = 0;
							if ( $align_flag != 0 ) { # the points depends on the correct alignment
								$point = $SCORES->{$GIVEN_SPECIES}->{$species};
							}							
							$corsair_score = $corsair_score + $point;
							push(@{$species_points_found}, "$species\t$identity\t$point\t$align_log"); # Record species and points								
						}
						elsif ( exists $SCORES->{'REST_OF_SPECIES'}->{$species} ) # the rest of species
						{
							my ($point) = 0;
							if ( $align_flag != 0 ) { # the points depends on the correct alignment
								$point = $SCORES->{'REST_OF_SPECIES'}->{$species};
							}							
							$corsair_score = $corsair_score + $point;
							push(@{$species_points_found}, "$species\t$identity\t$point\t$align_log"); # Record species and points	
						}						
						else
						{
							#my ($point) = 0;
							#push(@{$species_points_found}, "$species\t$identity\t$point\t$align_log"); # Record species without points (we don't find our species)
						}
					}
					else
					{
						#my ($point) = 0;
						#push(@{$species_points_found}, "$species\t$identity\t$point\t$align_log"); # Record species without points						
					}
					#last if ($species =~ /Danio/); # Finish with Danio
				}
			}
		}

	return ($corsair_score,$species_points_found);
}


sub check_alignment						#parses BLAST alignments exon by exon
{
	my $specie = shift;	
	my $query_length = shift;
	my $exons = shift;
	my $oldinput = "dummy";
	my @target = ();
	my @startq = ();
	my @endq = ();
	my @candidate = ();
	my @startc = ();
	my @endc = ();

	while (<BLASTFILE>)
		{
		chomp;
		if (/^Query:/)						# read in query line
			{
			my @query = split " ";
			push @target, $query[2];
			push @startq, $query[1];
			push @endq, $query[3];
			}
		if (/^Sbjct:/)						# read in subject line
			{
			my @subject = split " ";
			push @candidate, $subject[2];
			push @startc, $subject[1];
			push @endc, $subject[3];
			}
		if ($_ eq $oldinput)					# two carriage returns in a row mean alignment has ended
			{last}
		$oldinput = $_;
		}
	
	# process alignment ...
	
	my $target = join "", @target;
	my $candidate = join "", @candidate;
	
	my $targstart = $startq[0];
	my $targend = $endq[$#endq];
	my $candstart = $startc[0];
	my $candend = $endc[$#endc];
	
	if ($targstart > 4)						# reject if different N-terminal
		{return (0,"It has different N-terminal")}
	
	my $length_start = abs($targstart - $candstart);
	if ($length_start > 4)						# reject if subject has longer N-terminal
		{return (0,"Subject has longer N-terminal")}
	
	my $length_end = abs($query_length - $candend);
	if ($length_end > 6)						# reject if subject has longer C-terminal
		{return (0,"Subject has longer C-terminal")}
	
	@target = split "", $target;
	@candidate = split "", $candidate;
	
	my $loopstart = 0;
	for (my $i=0;$i<scalar(@{$exons});$i++)
	{
		my @boundaries = split ":", $exons->[$i];
		if ($boundaries[0] < $targstart)
			{ $boundaries[0] = $targstart; }
		my $identities = 0;
		my $gapres = 0;
		my $totalres = $boundaries[1] - $boundaries[0] + 1;
		my $res = 0;
		my $j = 0;
		for ($res=$loopstart,$j=$boundaries[0];$j<=$boundaries[1];$j++,$res++)
			{
				if(defined $target[$res] and $candidate[$res])
				{				
					if ($target[$res] eq $candidate[$res])
						{$identities++}
					if ($target[$res] eq "-")
						{$gapres++;$j--}
					if ($candidate[$res]eq "-")
						{$gapres++;}
				}
			}
		$loopstart = $res;

		my $identity = 0;
		my $gaps = 0;
		if ($totalres > 0)
		{
			$identity = $identities/$totalres*100;
			$gaps = $gapres/$totalres*100;
		}
		if ($identity < 40 && $totalres > 8)			# reject if two exons are too different
			{return (0,"Two exons are too different")}
		if ($gaps > 33)						# reject if exons have substantial gaps
			{return (0,"Exons have substantial gaps")}
	}
	
	return (1,"");							# if sequence passes all tests
}

# This method selects the best isoform. It works taking into account the corsair score, or using the num. of difference species 
sub get_appris_annotations($)
{
	my ($vertebrate_score) = @_;
	my ($cutoffs);
	my ($output_content) = '';

	$output_content .= "\n";
	$output_content .= "# ================================ #\n";
	$output_content .= "# Conservation against vertebrates #\n";
	$output_content .= "# ================================ #\n";
	
	if(defined $vertebrate_score)
	{
		my(@vertebrate_score_list) = sort { $a <= $b } keys(%{$vertebrate_score} );
		
		if(scalar(@vertebrate_score_list)>0)
		{
			# We tag the transcript as UNKOWN whose num domains are biggest
			my(@trans_biggest_score);
			my($biggest_vertebrate_score)=$vertebrate_score_list[0];
			foreach my $trans_id (@{$vertebrate_score->{$biggest_vertebrate_score}})
			{
				push(@trans_biggest_score,$trans_id);
			}
			my($unique)=1;
			for(my $i = 1; $i < scalar(@vertebrate_score_list); $i++)
			{
				my ($current_score) = $vertebrate_score_list[$i];
				
				# If the biggest score is bigger or equal than $APPRIS_CUTOFF => the transcripts are rejected
				if ( ($biggest_vertebrate_score - $current_score) >= $APPRIS_CUTOFF )
				{
					foreach my $trans_id (@{$vertebrate_score->{$current_score}})
					{
						$cutoffs->{$trans_id} = $NO_LABEL;
					}
				}
				else
				{
					$unique=0;
					foreach my $trans_id (@{$vertebrate_score->{$current_score}})
					{
						$cutoffs->{$trans_id} = $UNKNOWN_LABEL;
					}					
				}
			}
			# There is one transcript with the biggest score
			if (($unique == 1) and scalar(@trans_biggest_score) == 1)
			{
				foreach my $trans_id (@trans_biggest_score)
				{
					$cutoffs->{$trans_id} = $OK_LABEL;				
				}
			}
			else
			{
				foreach my $trans_id (@trans_biggest_score)
				{
					$cutoffs->{$trans_id} = $UNKNOWN_LABEL;				
				}
			}
		}
	}
	
	# Get appris output
	while ( my ($trans_id,$annot) = each (%{$cutoffs}) ) {
		$output_content .= ">".$trans_id."\t".$annot."\n";
	}
	return $output_content;
}

main();

__END__

=head1 NAME

corsair

=head1 DESCRIPTION

Run CORSAIR program

=head1 VERSION

0.1

=head2 Required arguments:

	--conf <Config file>

	--gff <GFF file that contains exon information>
	
	--input <Fasta sequence file>
	
	--output <Annotation output file>

=head2 Optional arguments:

	--appris <Flag that enables the output for APPRIS (default: NONE)>

	--loglevel=LEVEL <define log level (default: NONE)>	

	--logfile=FILE <Log to FILE (default: *STDOUT)>
	
	--logpath=PATH <Write logfile to PATH (default: .)>
	
	--logappend <Append to logfile (default: truncate)>
	

=head1 EXAMPLE

perl corsair.pl

	--conf=../conf/pipeline.ini

	--gff=example/peptide_cds_chr9.gff
	
	--input=example/OTTHUMG00000020713.faa
	
	--output=example/OTTHUMG00000020713.output

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut