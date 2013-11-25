# _________________________________________________________________
# $Id: Otter.pm 472 2009-12-17 09:32:52Z jmrodriguez $
# $Revision: 472 $
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________
package Otter;

use strict;
use Bio::Das::Lite;
use Bio::SeqIO;
use File;

use Data::Dumper;

###################
# Global variable #
###################

use vars qw($TIME_OUT $DSN_DAS $DSN_PEP_SEQUENCE $DSN_TRANS_SEQUENCE);
$TIME_OUT=3000;
$DSN_DAS='http://das.sanger.ac.uk/das/otter_das';
$DSN_PEP_SEQUENCE='http://das.sanger.ac.uk/das/otter_das_pep';
$DSN_TRANS_SEQUENCE='http://das.sanger.ac.uk/das/otter_transcripts';

#####################
# Method prototypes #
#####################
sub sort_exons($$);
sub get_extended_peptide_sequence(\$);
sub get_transcript_sequence(\$);
sub get_peptide_sequence(\$);
sub get_segment_report($$\$);
sub get_chromosome_report($);
sub get_chromosome_report_test($);
sub get_genconde_chromosome_report($);
sub get_genconde_transcript_sequence($\$);
sub get_gencode_peptide_sequence($\$);

sub get_gencode_peptide_sequence($\$)
{
	my($translations_file,$ref_chromosome_features)=@_;
	my($chromosome_features);

	my($translations_file_content)=File::getStringFromFile($translations_file);
	return undef unless (defined $translations_file_content);

	# Handle sequence file
	my($sequence_report);
	my($in)=Bio::SeqIO->new(
						-file => $translations_file,
						-format => 'Fasta'
	);
	while ( my $seq = $in->next_seq() )
	{
		my($sequence_id);
		if($seq->id=~/([^|]*)/)
		{
			$sequence_id=$1;
			if(exists $sequence_report->{$sequence_id})
			{
				print STDERR "MACHACA:".$seq->id."\n"."SEQ:\n".$seq->seq."\n";
			}
			else
			{
				$sequence_report->{$sequence_id}=$seq->seq;				
			}
		}
	}

	while(my ($gene_id, $gene_features)=each(%{$$ref_chromosome_features}))
	{
		while(my ($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))		
		{
			# Check if we don't have the sequence yet. We have to know the "real" values of input report
			unless(defined $$ref_chromosome_features->{$gene_id}->{$transcript_id} and exists $$ref_chromosome_features->{$gene_id}->{$transcript_id} and exists $$ref_chromosome_features->{$gene_id}->{$transcript_id}->{'sequence'})			
			{
				my($sequence);
				if(exists $sequence_report->{$transcript_id} and defined $sequence_report->{$transcript_id})
				{
					$sequence=$sequence_report->{$transcript_id};
					$sequence=~s/\n$//;
					# With this condition we know transcript has pepetide sequence although we don't know its identifier
					my($peptide_id)='UNKNOWN'; 
					if(exists $$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'})
					{
						my(@peptide_ids)=keys(%{$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}});
						$peptide_id=$peptide_ids[0] unless(scalar(@peptide_ids)<=0);
					}
					$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'sequence'}=$sequence if (defined $sequence);
				}
			}
		}
	}
	return undef;
	
} # End get_gencode_peptide_sequence

sub get_genconde_transcript_sequence($\$)
{
	my($transcript_file,$ref_chromosome_features)=@_;
	my($chromosome_features);

	my($transcript_file_content)=File::getStringFromFile($transcript_file);
	return undef unless (defined $transcript_file_content);
	
	# Handle sequence file
	my($sequence_report);
	my($in)=Bio::SeqIO->new(
						-file => $transcript_file,
						-format => 'Fasta'
	);
	while ( my $seq = $in->next_seq() )
	{
		my($sequence_id);
		if($seq->id=~/([^|]*)/)
		{
			$sequence_id=$1;
			if(exists $sequence_report->{$sequence_id})
			{
				print STDERR "MACHACA:".$seq->id."\n"."SEQ:\n".$seq->seq."\n";
			}
			else
			{
				$sequence_report->{$sequence_id}=$seq->seq;				
			}
		}
	}

	while(my ($gene_id, $gene_features)=each(%{$$ref_chromosome_features}))
	{
		while(my ($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))		
		{
			# Check if we don't have the sequence yet. We have to know the "real" values of input report
			unless(defined $$ref_chromosome_features->{$gene_id}->{$transcript_id} and exists $$ref_chromosome_features->{$gene_id}->{$transcript_id} and exists $$ref_chromosome_features->{$gene_id}->{$transcript_id}->{'sequence'})			
			{
				my($sequence);
				if(exists $sequence_report->{$transcript_id} and defined $sequence_report->{$transcript_id})
				{
					$sequence=$sequence_report->{$transcript_id};
					$sequence=~s/\n$//;
					$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'sequence'}=$sequence if (defined $sequence);
				}				
			}
		}
	}
	return undef;
	
} # End get_genconde_transcript_sequence

sub get_genconde_chromosome_report($)
{
	my($gencode_file)=@_;
	my($chromosome_features);
	
	open(GENCONDE_FILE, $gencode_file) or die "Can't open $gencode_file: $!\n";
	while(<GENCONDE_FILE>)
	{
		#ignore header
		next if(/^##/);

		chomp;

		my($chr,$source,$type,$start,$end,$score,$strand,$phase,$attributes) = split("\t");
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
		my($fields)={
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
			$chr=$1 if(defined $1);
		}
		
		#store ids and additional information in second hash
		my($attribs);
		my(@add_attributes)=split(";", $attributes);				
		for(my $i=0; $i<scalar @add_attributes; $i++)
		{
			$add_attributes[$i] =~ /^(.+)\s(.+)$/;
			my($c_type)=$1;
			my($c_value)=$2;
			if(	defined $c_type and !($c_type=~/^\s*$/) and
				defined $c_value and !($c_value=~/^\s*$/))
			{
				$c_type =~ s/^\s//;
				$c_value =~ s/"//g;
				if(!exists($attribs->{$c_type}))
				{
					$attribs->{$c_type}=$c_value;
				}
			}
		}

		# Always we have Gene Id
		if(exists $attribs->{'gene_id'} and defined $attribs->{'gene_id'})
		{
			my($gene_id)=$attribs->{'gene_id'};
			
			# Gene Information
			if($type eq 'gene')
			{
				$chromosome_features->{$gene_id}->{'chr'}=$chr if(defined $chr);			
				$chromosome_features->{$gene_id}->{'start'}=$start if(defined $start);
				$chromosome_features->{$gene_id}->{'end'}=$end if(defined $end);
				$chromosome_features->{$gene_id}->{'strand'}=$strand if(defined $strand);

				if(defined $source and ($source eq $Constant::HAVANA_SOURCE or $source eq $Constant::ENSEMBL_SOURCE))
				{
					$chromosome_features->{$gene_id}->{'source'}=$source; 					
				}
				if(exists $attribs->{'gene_status'} and defined $attribs->{'gene_status'})
				{
					$chromosome_features->{$gene_id}->{'status'}=$attribs->{'gene_status'};	
				}			
				if(exists $attribs->{'gene_type'} and defined $attribs->{'gene_type'})
				{
					$chromosome_features->{$gene_id}->{'class'}=$attribs->{'gene_type'};	
				}
				if(exists $attribs->{'gene_name'} and defined $attribs->{'gene_name'})
				{
					$chromosome_features->{$gene_id}->{'external_id'}=$attribs->{'gene_name'};	
				}
				if(exists $attribs->{'havana_gene'} and defined $attribs->{'havana_gene'})
				{
					$chromosome_features->{$gene_id}->{'havana_gene'}=$attribs->{'havana_gene'};	
				}
				if(exists $attribs->{'level'} and defined $attribs->{'level'})
				{
					$chromosome_features->{$gene_id}->{'level'}=$attribs->{'level'};	
				}
			}
			elsif($type eq 'transcript') # Transcript Information
			{
				if(exists $attribs->{'transcript_id'} and defined $attribs->{'transcript_id'})
				{
					my($transcript_id)=$attribs->{'transcript_id'};
			
					my($transcript);
					$transcript->{'chr'}=$chr if(defined $chr);
					$transcript->{'start'}=$start if(defined $start);
					$transcript->{'end'}=$end if(defined $end);
					$transcript->{'strand'}=$strand if(defined $strand);					

					if(defined $source and ($source eq $Constant::HAVANA_SOURCE or $source eq $Constant::ENSEMBL_SOURCE))
					{
						$transcript->{'source'}=$source;
					}
					if(exists $attribs->{'transcript_status'} and defined $attribs->{'transcript_status'})
					{
						$transcript->{'status'}=$attribs->{'transcript_status'};	
					}			
					if(exists $attribs->{'transcript_type'} and defined $attribs->{'transcript_type'})
					{
						$transcript->{'class'}=$attribs->{'transcript_type'};	
					}
					if(exists $attribs->{'transcript_name'} and defined $attribs->{'transcript_name'})
					{
						$transcript->{'external_id'}=$attribs->{'transcript_name'};	
					}
					if(exists $attribs->{'havana_transcript'} and defined $attribs->{'havana_transcript'})
					{
						$transcript->{'havana_transcript'}=$attribs->{'havana_transcript'};	
					}
					if(exists $attribs->{'level'} and defined $attribs->{'level'})
					{
						$transcript->{'level'}=$attribs->{'level'};	
					}
					
					$chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}=$transcript if(defined $transcript);					
				}
			}
			elsif($type eq 'exon') # Exon Information
			{
				if(exists $attribs->{'transcript_id'} and defined $attribs->{'transcript_id'})
				{
					my($transcript_id)=$attribs->{'transcript_id'};
	
					my($exon);
					$exon->{'start'}=$start if(defined $start);
					$exon->{'end'}=$end if(defined $end);
					$exon->{'strand'}=$strand if(defined $strand);
					
					push(@{$chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'exons'}},$exon);
				}
			}			
			elsif($type eq 'CDS') # CDS Information
			{
				if(exists $attribs->{'transcript_id'} and defined $attribs->{'transcript_id'})
				{
					my($transcript_id)=$attribs->{'transcript_id'};
	
					my($cds);
					$cds->{'start'}=$start if(defined $start);
					$cds->{'end'}=$end if(defined $end);
					$cds->{'strand'}=$strand if(defined $strand);
					$cds->{'phase'}=$phase if(defined $phase);
					
					push(@{$chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds'}},$cds);
				}
			}
			elsif($type eq 'start_codon') # Codon Information
			{
				if(exists $attribs->{'transcript_id'} and defined $attribs->{'transcript_id'})
				{
					my($transcript_id)=$attribs->{'transcript_id'};

					my($codon);
					$codon->{'type'}='start';
					$codon->{'start'}=$start if(defined $start);
					$codon->{'end'}=$end if(defined $end);
					$codon->{'strand'}=$strand if(defined $strand);
					$codon->{'phase'}=$phase if(defined $phase);
					
					push(@{$chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'codons'}},$codon) if(defined $codon);
				}
			}
			elsif($type eq 'stop_codon') # Codon Information
			{
				if(exists $attribs->{'transcript_id'} and defined $attribs->{'transcript_id'})
				{
					my($transcript_id)=$attribs->{'transcript_id'};

					my($codon);
					$codon->{'type'}='stop';
					$codon->{'start'}=$start if(defined $start);
					$codon->{'end'}=$end if(defined $end);
					$codon->{'strand'}=$strand if(defined $strand);
					$codon->{'phase'}=$phase if(defined $phase);
					
					push(@{$chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'codons'}},$codon) if(defined $codon);
				}
			}
		}
	}
	close(GENCONDE_FILE);

	# Re-annotated
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			# Check if Codons are not found (start and end)
			if(exists $transcript_features->{'codons'} and scalar(@{$transcript_features->{'codons'}}>0))
			{
				my($codon_report);
				foreach my $codon (@{$transcript_features->{'codons'}})
				{
					$codon_report->{'start'}=1 if($codon->{'type'} eq 'start');
					$codon_report->{'stop'}=1 if($codon->{'type'} eq 'stop');
				}
				if(exists $codon_report->{'start'} and !(exists $codon_report->{'stop'}))
				{
					$chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_end'}=0;	
				}
				if(exists $codon_report->{'stop'} and !(exists $codon_report->{'start'}))
				{
					$chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_start'}=0;	
				}
			}

			# Sort exons
			if(exists $transcript_features->{'exons'} and scalar(@{$transcript_features->{'exons'}}>0))
			{
				my($sort_exon_list)=sort_exons($transcript_features->{'strand'},$transcript_features);
				$transcript_features->{'exons'}=$sort_exon_list if(defined $sort_exon_list and scalar(@{$sort_exon_list})>0);
			}
			# Sort cds
			if(exists $transcript_features->{'cds'} and scalar(@{$transcript_features->{'cds'}}>0))
			{
				my($sort_cds_list)=sort_exons($transcript_features->{'strand'},$transcript_features);
				$transcript_features->{'exons'}=$sort_cds_list if(defined $sort_cds_list and scalar(@{$sort_cds_list})>0);
			}
		}
	}
	
	return $chromosome_features;
} # End get_genconde_chromosome_report

# For test scripts
sub get_chromosome_report_test($)
{
	my ($chromosome) = @_;
	my($chromosome_features);
	my($das);
	$das = Bio::Das::Lite->new({
			      'timeout'    => $TIME_OUT,
			      'dsn'        => $DSN_DAS,
	});

	get_segment_report($das,"$chromosome",$chromosome_features);
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(exists $transcript_features->{'exons'} and defined $transcript_features->{'exons'})
			{
				my($sort_exon_list)=sort_exons($transcript_features->{'strand'},$transcript_features);
				$transcript_features->{'exons'}=$sort_exon_list if(defined $sort_exon_list and scalar(@{$sort_exon_list})>0);
			}
		}
	}
	return $chromosome_features;
} # End get_chromosome_report_test

sub get_chromosome_report($)
{
	my ($chromosome) = @_;
	my($chromosome_features);
	my($das);
	$das = Bio::Das::Lite->new({
			      'timeout'    => $TIME_OUT,
			      'dsn'        => $DSN_DAS,
	});

	#fetch DAS features
	my($segment_size);
	my($entry_points)=$das->entry_points();
	while(my ($url, $entry_point_features)=each(%{$entry_points}))
	{
		if(ref $entry_point_features eq "ARRAY" and ref $entry_point_features->[0] eq "HASH")
		{			
			while(my($key,$segments)=each(%{$entry_point_features->[0]}))
			{
				if($key eq "segment")
				{
					foreach my $segment (@{$segments})
					{
						if(($segment->{'segment_id'} eq $chromosome) and ($segment->{'segment_subparts'} eq 'yes')) 
						{
							$segment_size=$segment->{'segment_size'};
						}
					}	
				}
			}
		}
	}
	return undef unless(defined $segment_size);

	my($spliting_segment);
	my($index)=1;
	while($index<=$segment_size)
	{
		push(@{$spliting_segment},$index) if($index != 1);
		$index+=10000000;
	}
	if($index>$segment_size)
	{
		push(@{$spliting_segment},$segment_size);
	}

	my($index_segment_start)=1;
	my($index_segment_end);
	 	
	foreach my $split_segment (@{$spliting_segment})
	{
		$index_segment_end=$split_segment;
		print STDERR " $chromosome:$index_segment_start,$index_segment_end ";
		# Get report for each segment
		get_segment_report($das,"$chromosome:$index_segment_start,$index_segment_end",$chromosome_features);
		$index_segment_start=$split_segment;
	}

	# Sort exons
	while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
	{
		while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
		{
			if(exists $transcript_features->{'exons'} and defined $transcript_features->{'exons'})
			{
				my($sort_exon_list)=sort_exons($transcript_features->{'strand'},$transcript_features);
				$transcript_features->{'exons'}=$sort_exon_list if(defined $sort_exon_list and scalar(@{$sort_exon_list})>0);
			}
		}
	}
	return $chromosome_features;
	
} # End get_chromosome_report

sub get_segment_report($$\$)
{
	my($das,$segment,$ref_chromosome_features)=@_;
	
	#fetch DAS features
	my($response)=$das->features({'segment' => $segment});

	while(my ($url, $features)=each(%{$response}))
	{
		if(ref $features eq "ARRAY")
		{
			foreach my $feature (@$features)
			{
				# Gene Information
				my($group)=$feature->{'group'}->[0];
				my($gene_id)=$group->{'group_type'} if(defined $group->{'group_type'});
				my($gene_description);
				if(exists $group->{'note'} and defined $group->{'note'})
				{
					foreach my $note (@{$group->{'note'}})
					{
						if($note=~/Description=([^\$]*)$/)
						{
							$gene_description=$1;
						}
					}
				}
				$$ref_chromosome_features->{$gene_id}->{'description'}=$gene_description if(defined $gene_description);
				
				if(exists $feature->{'target'} and defined $feature->{'target'})
				{
					if($feature->{'target'}=~/^Gene=([0-9]+)\-([0-9]+)$/)
					{
						$$ref_chromosome_features->{$gene_id}->{'start'}=$1;
						$$ref_chromosome_features->{$gene_id}->{'end'}=$2;
						$$ref_chromosome_features->{$gene_id}->{'strand'}=$feature->{'orientation'} if(defined $feature->{'orientation'});
						$$ref_chromosome_features->{$gene_id}->{'chr'}=$feature->{'segment_id'} if(defined $feature->{'segment_id'});						
					}
				}
 
 				# Trancript Information
				if(	defined $feature->{'feature_id'} and exists $feature->{'feature_id'})
				{
					my($transcript_id)=$feature->{'feature_id'};				
					unless(exists $$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id})
					{
						my($transcript);
						$transcript->{'chr'}=$feature->{'segment_id'} if(defined $feature->{'segment_id'});
						$transcript->{'strand'}=$feature->{'orientation'} if(defined $feature->{'orientation'});
						$transcript->{'start'}=$feature->{'target_start'} if(defined $feature->{'target_start'});
						$transcript->{'end'}=$feature->{'target_stop'} if(defined $feature->{'target_stop'});
						$transcript->{'external_id'}=$feature->{'target_id'} if(defined $feature->{'target_id'});						
						$transcript->{'description'}=$gene_description if(defined $gene_description);

						$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}=$transcript;					
					}

					# CDS Information
					unless(	exists $$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_start'} or
							exists $$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_end'}
					)
					{
						if(defined $feature->{'note'} and exists $feature->{'note'} and scalar($feature->{'note'})>0)
						{
							foreach my $note (@{$feature->{'note'}})
							{
								$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_start'}=0 if($note=~/^Note=CDS start not found$/);
								$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'cds_end'}=0 if($note=~/^Note=CDS end not found$/);
							}
						}						
					}
										
					# Add Gene class and Trasncript class
					my($protein_coding_flag);
					my($gene_class);
					my($gene_status);
					my($transcript_class);
					my($transcript_status);
					if(exists $feature->{'note'} and defined $feature->{'note'})
					{
						foreach my $note (@{$feature->{'note'}})
						{
							if(!defined $transcript_class and $note=~/Transcripttype=([^\$]*)$/)
							{
								$transcript_class=$1;
							}
							if(!defined $transcript_status and $note=~/Transcriptstatus=([^\$]*)$/)
							{
								$transcript_status=$1;
							}
							if(!defined $gene_class and $note=~/Genetype=([^\$]*)$/)
							{
								$gene_class=$1;
							}
							if(!defined $gene_status and $note=~/Genestatus=([^\$]*)$/)
							{
								$gene_status=$1;
							}
						}
					}
					$$ref_chromosome_features->{$gene_id}->{'class'}=$gene_class if(defined $gene_class);
					$$ref_chromosome_features->{$gene_id}->{'status'}=$gene_status if(defined $gene_status);
					$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'class'}=$transcript_class if(defined $transcript_class);
					$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'status'}=$transcript_status if(defined $transcript_status);					
					$protein_coding_flag=1 if($transcript_class eq 'protein_coding');

					# Add Exon coordiantes into list (Check if the given transcript is "protein_coding")
					my($exon_list);
					if(defined $protein_coding_flag and exists $feature->{'feature_id'} and defined $feature->{'feature_id'} and ($feature->{'feature_id'} eq $transcript_id))
					{
						$exon_list=''; # Flag variable to control if Exon feature has been added
						if(	exists $feature->{'type_id'} and 
							defined $feature->{'type_id'} and 
							$feature->{'type_id'}=~/exon/
							)
						{
							# Add Exons coordiantes into list
							unless(exists $$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'exons'})
							{
								$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'exons'}=();
							}	
							if(	exists $feature->{'start'} and defined $feature->{'start'} and 
								exists $feature->{'end'} and defined $feature->{'end'} and 
								exists $feature->{'orientation'} and defined $feature->{'orientation'})
							{
								my($exon_start)=$feature->{'start'};
								my($exon_end)=$feature->{'end'};
								my($exon_orientation)=$feature->{'orientation'};
								my($cds)={ 	'start'	=> $exon_start,
											'end'	=> $exon_end,
											'strand'=> $exon_orientation
								};
								my($exon_flag)=$exon_start.'-'.$exon_end.':'.$exon_orientation;
								unless($exon_list=~/$exon_flag/)
								{
									push(@{$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'exons'}}, $cds);
									$exon_list.=$exon_flag.'|'; # Flag variable
								}
							}
						}
					}					
				}
			}
		}
	}
	return;

} # End get_segment_report

sub sort_exons($$)
{
	my ($orientation,$transcript_report) = @_;
	my($sort_exon_list);

	# Sort the exons depending orientation from transcript
	if($orientation eq '-')
	{
		@{$sort_exon_list}= sort { $a->{'start'} <= $b->{'start'} } @{$transcript_report->{'exons'}};			
	}
	else
	{
		@{$sort_exon_list}= sort { $a->{'start'} >= $b->{'start'} } @{$transcript_report->{'exons'}};				
	}
	return $sort_exon_list;
	
} # End sort exons

sub get_transcript_sequence(\$)
{
	my ($ref_chromosome_features) = @_;
	my($das);
	$das=Bio::Das::Lite->new({
			      'timeout'    => $TIME_OUT,
			      'dsn'        => $DSN_TRANS_SEQUENCE,
	});

	while(my ($gene_id, $gene_features)=each(%{$$ref_chromosome_features}))
	{
		while(my ($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))		
		{
			# Check if we don't have the sequence yet. We have to know the "real" values of input report
			unless(defined $$ref_chromosome_features->{$gene_id}->{$transcript_id} and exists $$ref_chromosome_features->{$gene_id}->{$transcript_id} and exists $$ref_chromosome_features->{$gene_id}->{$transcript_id}->{'sequence'})			
			{
				my($sequence);	
				my($response)=$das->sequence({'segment' => $transcript_id});
				my($daskey)=join(", ",keys %{$response});
				my($response_hash)=$response->{$daskey}->[0];
				if(defined $response_hash->{'sequence'} and $response_hash->{'sequence'})
				{
					$sequence=$response_hash->{'sequence'}; 
				}
				# Add sequence within reference report
				$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'sequence'}=$sequence if (defined $sequence);				
			}
		}
	}
	return undef;
	
} # End get_transcript_sequence

sub get_peptide_sequence(\$)
{
	my ($ref_chromosome_features) = @_;
	my($das);
	$das=Bio::Das::Lite->new({
			      'timeout'    => $TIME_OUT,
			      'dsn'        => $DSN_PEP_SEQUENCE,
	});

	while(my ($gene_id, $gene_features)=each(%{$$ref_chromosome_features}))
	{
		while(my ($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))		
		{
			# Check if we don't have the sequence yet. We have to know the "real" values of input report
			unless(defined $$ref_chromosome_features->{$gene_id}->{$transcript_id} and exists $$ref_chromosome_features->{$gene_id}->{$transcript_id} and exists $$ref_chromosome_features->{$gene_id}->{$transcript_id}->{'sequence'})			
			{
				my($response)=$das->sequence({'segment' => $transcript_id});
				my($daskey)=join(", ",keys %{$response});
				my($response_hash)=$response->{$daskey}->[0];
				if(defined $response_hash->{'sequence'} and $response_hash->{'sequence'})
				{
					my($sequence)=$response_hash->{'sequence'};
					
					# With this condition we know transcript has pepetide sequence although we don't know its identifier
					my($peptide_id)='UNKNOWN'; 
					if(exists $$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'})
					{
						my(@peptide_ids)=keys(%{$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}});
						$peptide_id=$peptide_ids[0] unless(scalar(@peptide_ids)<=0);
					}
					$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'sequence'}=$sequence if (defined $sequence);
				}
			}
		}
	}
	return undef;
	
} # End get_peptide_sequence

sub get_extended_peptide_sequence(\$)
{
	my($ref_chromosome_features) = @_;

	while(my ($gene_id, $gene_features)=each(%{$$ref_chromosome_features}))
	{
		my($transcript_list);
		while(my ($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))		
		{
			if(exists $transcript_features->{'peptide'})
			{
				my(@peptide_ids)=keys(%{$transcript_features->{'peptide'}});
				my($peptide_id)=$peptide_ids[0];
	
				my($sequence)=$transcript_features->{'peptide'}->{$peptide_id}->{'sequence'};
				$transcript_list->{$transcript_id}->{'sequence'}=$transcript_features->{'peptide'}->{$peptide_id}->{'sequence'};
				
				if(exists $transcript_features->{'cds_start'} and ($transcript_features->{'cds_start'}==0)) # CDS start not found
				{
					$transcript_list->{$transcript_id}->{'cds_start'}=$transcript_features->{'cds_start'};
				}
				if(exists $transcript_features->{'cds_end'} and ($transcript_features->{'cds_end'}==0)) # CDS end not found
				{
					$transcript_list->{$transcript_id}->{'cds_end'}=$transcript_features->{'cds_end'}; 	
				}
			}			
		}

		my(@transcript_list_ids)=keys(%{$transcript_list});
		while(my ($transcript_id, $transcript_features)=each(%{$transcript_list}))		
		{
			#pass if not fragment
			if(	defined $transcript_features and 
				(exists $transcript_features->{'cds_start'} and ($transcript_features->{'cds_start'}==0)) or
				(exists $transcript_features->{'cds_end'} and ($transcript_features->{'cds_end'}==0)))
			{
				# Check if sequence has got '*' character
				my($aux_sequence)=$transcript_features->{'sequence'};
				my($num_asterisk)=$aux_sequence=~s/\*//g;
				if(!(defined $num_asterisk) or $num_asterisk == 0)
				{					
					$transcript_features->{'sequence'} =~ s/X//g;
					#adds N-termini to fragments
					if (exists $transcript_features->{'cds_start'} and ($transcript_features->{'cds_start'}==0))
					{
						my($start7)=substr($transcript_features->{'sequence'}, 0, 7);
						my($longN)=0;
						my($seqN)="";
						foreach my $repeat_id (@transcript_list_ids)
						{
							if($transcript_list->{$repeat_id}->{'sequence'} =~ /$start7/)
							{
								my(@temp)=split /$start7/, $transcript_list->{$repeat_id}->{'sequence'};
								my($templen)=length($temp[0]);
								if ($templen > $longN)
								{
									$longN = $templen;
									$seqN = $temp[0];
								}
							}
						}
						#$transcript_features->{'extended'}=join "", $seqN, $transcript_features->{'sequence'};
						my(@peptide_ids)=keys(%{$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}});
						return "1:" if(scalar(@peptide_ids)<=0);
						my($peptide_id)=$peptide_ids[0];
						$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'extended'}=join "", $seqN, $transcript_features->{'sequence'};
					}
				#adds C-termini to fragments
					if (exists $transcript_features->{'cds_end'} and ($transcript_features->{'cds_end'}==0))
					{						
						my(@varres)=split "", $transcript_features->{'sequence'};
						my($offset)=$#varres-6;
						my($end7)=substr($transcript_features->{'sequence'}, $offset, 7);
						my($longC)=0;
						my($seqC)="";
						foreach my $repeat_id (@transcript_list_ids)
						{
							if ($transcript_list->{$repeat_id}->{'sequence'} =~ /$end7/)
							{
								my(@temp)=split /$end7/, $transcript_list->{$repeat_id}->{'sequence'};							
								my($templen)=length($temp[1]);
								if ($templen > $longC)
								{
									$longC = $templen;
									$seqC = $temp[1];
								}
							}
						}
						#$transcript_features->{'extended'} = join "", $transcript_features->{'sequence'}, $seqC;
						my(@peptide_ids)=keys(%{$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}});
						return "2:" if(scalar(@peptide_ids)<=0);
						my($peptide_id)=$peptide_ids[0];
						$$ref_chromosome_features->{$gene_id}->{'transcripts'}->{$transcript_id}->{'peptide'}->{$peptide_id}->{'extended'}=join "", $transcript_features->{'sequence'}, $seqC;
					}					
				}
			}
		}
	}
	return undef;
	
} # End get_extended_peptide_sequence

1;
