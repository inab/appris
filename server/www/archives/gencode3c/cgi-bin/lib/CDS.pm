# _________________________________________________________________
# $Id$
# $Revision$
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________
package CDS;

use strict;
use LWP::Simple;
use XML::LibXML;

use Data::Dumper;

###################
# Global variable #
###################
use vars qw($CDSVIEW_CGI $HUMAN_SPECIE_NAME);
$CDSVIEW_CGI='http://compbio1.csail.mit.edu/fcgi-bin/cdsview?alnset=hg18';
$HUMAN_SPECIE_NAME='hg19';

##############
# Prototypes #
##############
sub get_protein_cds_sequence($;$);
sub get_contained_cds($$);
sub get_block_from_transcript($$);
sub get_coordinate_from_peptide($$);
sub filter_cds_alignment($);
sub sort_cds($$);
sub get_coordinates($$$);
sub get_exons_alignment($$$);
sub get_num_gaps($);
sub print_cds_filter_aligment($$);
sub get_cdsview_alignment($$);
sub get_cds_alignment($);
sub get_cds_alignment_from_file($);

sub get_protein_cds_sequence($;$)
{
	my ($cds_list, $sequence) = @_;

	my ($protein_cds_list);
	
	my ($pro_cds_start) = 0;
	my ($pro_cds_end) = 0;
	my ($start_phase) = 0;
	my ($end_phase) = 0;

	foreach my $cds (@{$cds_list}) {

		my ($accumulate) = 0;
		$start_phase = $end_phase;
		if($start_phase == 1) {
			$accumulate = 2;
		}
		elsif($start_phase == 2) {
			$accumulate = 1;
		}
		else {
			$accumulate = 0;
		}
		my ($cds_start) = $cds->{'start'};
		my ($cds_end) = $cds->{'end'};
				
		$pro_cds_start = $pro_cds_end + 1;
		my ($pro_cds_end_div) = (abs($cds_end - $cds_start) + 1 - $accumulate) / 3;
		if ($pro_cds_end_div == 0) {
			$pro_cds_end = $pro_cds_start + $pro_cds_end_div;
			$end_phase = 0;
		}
		elsif ($pro_cds_end_div =~ /(\d+)\.(\d{2})/) {
			my ($pro_cds_end_int) = $1;
			$pro_cds_end = $pro_cds_start + $pro_cds_end_int;			
			my ($pro_cds_end_mod) = '0.'.$2;
			if ($pro_cds_end_mod == '0.33') {
				$end_phase = 1;
			}
			elsif ($pro_cds_end_mod == '0.66') {
				$end_phase = 2;
			}
		}
		else {
			$pro_cds_end = $pro_cds_start + $pro_cds_end_div - 1;
			$end_phase = 0;
		}
		my ($protein_cds) = {
				'start'	=> $pro_cds_start,
				'end'	=> $pro_cds_end,
			
		};

		if (defined $sequence) {
			my ($pro_cds_length) = ($pro_cds_end - $pro_cds_start) + 1;
			my ($pro_seq) = substr($sequence, ($pro_cds_start - 1), $pro_cds_length);
			$protein_cds->{'sequence'} = $pro_seq if (defined $pro_seq);
		}
		push(@{$protein_cds_list}, $protein_cds);
	}
	
	return $protein_cds_list;
} # End get_protein_cds_sequence

sub get_contained_cds($$)
{
	my($residue,$transcript_features)=@_;
	
	my($contained_cds);

	# Sort the exons depending orientation from transcript
	my($transcript_orientation)=$transcript_features->{'strand'};
	my($sort_cds_list)=sort_cds($transcript_orientation,$transcript_features);

	my($residue_start)=$residue->{'start'};
	my($residue_end)=$residue->{'end'};
		
	for(my $i=0;$i<scalar(@{$sort_cds_list});$i++)
	{
		my($cds_start)=$sort_cds_list->[$i]->{'start'};
		my($cds_end)=$sort_cds_list->[$i]->{'end'};
		my($cds_strand)=$sort_cds_list->[$i]->{'strand'};

		if($residue_start >= $cds_start and $residue_end <= $cds_end) # Within one CDS
		{
			push(@{$contained_cds},{'start'=>$cds_start,'end'=>$cds_end,'strand'=>$cds_strand});
			last;			
		}
		elsif($cds_strand eq '+' and $residue_start <= $cds_end and $residue_end > $cds_end) # Within several CDS's (strand +)
		{
			push(@{$contained_cds},{'start'=>$cds_start,'end'=>$cds_end,'strand'=>$cds_strand});
			for(my $j=$i+1;$j<scalar(@{$sort_cds_list});$j++)
			{
				my($next_cds_start)=$sort_cds_list->[$j]->{'start'};
				my($next_cds_end)=$sort_cds_list->[$j]->{'end'};
				my($next_cds_strand)=$sort_cds_list->[$j]->{'strand'};

				if($residue_end >= $next_cds_start and $residue_end >= $next_cds_end)
				{
					push(@{$contained_cds},{'start'=>$next_cds_start,'end'=>$next_cds_end,'strand'=>$next_cds_strand});
				}
				elsif($residue_end >= $next_cds_start and $residue_end <= $next_cds_end)
				{
					push(@{$contained_cds},{'start'=>$next_cds_start,'end'=>$next_cds_end,'strand'=>$next_cds_strand});
					last;
				}
			}
			last;			
		}
		elsif($cds_strand eq '-' and $residue_start <= $cds_start and $residue_end >= $cds_start) # Within several CDS's (strand -)
		{
			push(@{$contained_cds},{'start'=>$cds_start,'end'=>$cds_end,'strand'=>$cds_strand});
			for(my $j=$i+1;$j<scalar(@{$sort_cds_list});$j++)
			{
				my($next_cds_start)=$sort_cds_list->[$j]->{'start'};
				my($next_cds_end)=$sort_cds_list->[$j]->{'end'};
				my($next_cds_strand)=$sort_cds_list->[$j]->{'strand'};

				if($residue_start <= $next_cds_end)
				{
					push(@{$contained_cds},{'start'=>$next_cds_start,'end'=>$next_cds_end,'strand'=>$next_cds_strand});
				}
			}
			last;			
		}
	}	
	
	return $contained_cds;
		
} # End get_contained_cds

# get peptide position from peptide position
sub get_block_from_transcript($$)
{
	my($position,$transcript_features) = @_;
	my($residue_report);
	
	my($residue_start);
	my($residue_end);
	my($residue_size);

	my($position_start)=$position->{'start'};
	my($position_end)=$position->{'end'};

	my($transcript_start)=$transcript_features->{'start'};
	my($transcript_end)=$transcript_features->{'end'};

	$residue_start=abs($position_start-$transcript_start);	
	$residue_size=$position_end-$position_start+1;	
	$residue_end=$residue_start+$residue_size-1;

	if(defined $residue_start and defined $residue_end and defined $residue_size)
	{
		$residue_report->{'size'}=$residue_size;
		$residue_report->{'start'}=$residue_start;
		$residue_report->{'end'}=$residue_end;
	}
	return $residue_report;

}

# get genomic coordinate from peptide position
sub get_coordinate_from_peptide($$)
{
	my($residue_position,$transcript_features) = @_;
	my($residue_report);
	
	my($residue_start);
	my($residue_end);
	my($transcript_orientation)=$transcript_features->{'strand'};

	# Sort the exons depending orientation from transcript
	my($sort_exon_list)=sort_cds($transcript_orientation,$transcript_features);
	
	# Start transcript residue
	my($j)=1; # First residue
	while($j<=3)
	{
		my($transcript_nucleotide_relative_position)=($residue_position-1)*3+$j;

		my($exon_length_accumulate)=0;
		foreach my $exon (@{$sort_exon_list})
		{
			my($exon_start)=$exon->{'start'};
			my($exon_end)=$exon->{'end'};

			my($exon_init,$exon_length)=get_coordinates($transcript_orientation,$exon,$transcript_features);
			$exon_length_accumulate+=$exon_length;
			if($exon_length_accumulate/$transcript_nucleotide_relative_position >= 1)
			{
				my($relative_position_from_exon)=$exon_length_accumulate-$exon_length;
				if($j==1)
				{
					if($transcript_orientation eq '-')
					{
						$residue_start=$exon_end-($transcript_nucleotide_relative_position-$relative_position_from_exon)+1;
					} else {
						$residue_start=$exon_start+($transcript_nucleotide_relative_position-$relative_position_from_exon)-1;						
					}	
					last;				
				}
				elsif($j==3)
				{
					if($transcript_orientation eq '-')
					{
						$residue_end=$exon_end-($transcript_nucleotide_relative_position-$relative_position_from_exon)+1;
					} else {
						$residue_end=$exon_start+($transcript_nucleotide_relative_position-$relative_position_from_exon)-1;						
					}			
					last;
				}
			}
		}
		$j=$j+2; # Third transcrip residue for aminoacid
	}

	if(defined $residue_start and defined $residue_end)
	{
		$residue_report->{'peptide_position'}=$residue_position;
		$residue_report->{'strand'}=$transcript_orientation;
		$residue_report->{'start'}=$residue_start;
		$residue_report->{'end'}=$residue_end;
	}
	return $residue_report;
}

# Filter CDS alignment. We get the sequence alignment bigger than 50% exons
sub filter_cds_alignment($)
{
	my ($cds_alignment) = @_;
	my($cds_filter_alignment);
	
	my($human_length)=$cds_alignment->{$HUMAN_SPECIE_NAME}->{'length'};
	while(my($specie_name,$specie_cds)=each(%{$cds_alignment}))
	{
		if($specie_name eq $HUMAN_SPECIE_NAME)
		{
			$cds_filter_alignment->{$specie_name}=$specie_cds;
		}
		elsif($specie_cds->{'num_gaps'}<($human_length/2))
		{
			$cds_filter_alignment->{$specie_name}=$specie_cds; 
		}
	}
	return $cds_filter_alignment;
}

# Sort list of cds depending orientation
sub sort_cds($$)
{
	my ($orientation,$transcript_report) = @_;
	my($sort_exon_list);

	# Sort the exons depending orientation from transcript
	if(	exists $transcript_report->{'cds'} and
		defined $transcript_report->{'cds'} and
		(scalar(@{$transcript_report->{'cds'}})>0)
	){
		if($orientation eq '-')
		{
			@{$sort_exon_list}= sort { $b->{'start'} <=> $a->{'start'} } @{$transcript_report->{'cds'}};			
		}
		else
		{
			@{$sort_exon_list}= sort { $a->{'start'} <=> $b->{'start'} } @{$transcript_report->{'cds'}};				
		}		
	}
	return $sort_exon_list;
}

# Sort list of exons depending orientation
sub sort_exons($$)
{
	my ($orientation,$transcript_report) = @_;
	my($sort_exon_list);

	# Sort the exons depending orientation from transcript
	if(	exists $transcript_report->{'exons'} and
		defined $transcript_report->{'exons'} and
		(scalar(@{$transcript_report->{'exons'}})>0)
	){
		if($orientation eq '-')
		{
			@{$sort_exon_list}= sort { $b->{'start'} <=> $a->{'start'} } @{$transcript_report->{'exons'}};			
		}
		else
		{
			@{$sort_exon_list}= sort { $a->{'start'} <=> $b->{'start'} } @{$transcript_report->{'exons'}};				
		}		
	}
	return $sort_exon_list;
}

# Get the init exon and its length depending orientation
sub get_coordinates($$$)
{
	my($orientation,$exons,$transcript_report) = @_;
	my($init,$length);

	if($orientation eq '-')
	{
		my($transcript_end)=$transcript_report->{'end'};
		$init=abs($exons->{'end'}-$transcript_end);
		$length=$exons->{'end'}-$exons->{'start'}+1;
	}
	else
	{
		my($transcript_start)=$transcript_report->{'start'};
		$init=$exons->{'start'}-$transcript_start;
		$length=$exons->{'end'}-$exons->{'start'}+1;
	}	
	return ($init,$length);
}
# Get only exons sequences
# And delete both "anc_aa" and "ancestor" alignment
sub get_exons_alignment($$$)
{
	my ($orientation,$cds_alignment,$transcript_features) = @_;
	my($cds_exons_alignment);

	# Sort the exons depending orientation from transcript
	my($sort_exon_list)=sort_cds($orientation,$transcript_features);
	
	my($num_species)=0;
	my($length_sequences)=0;
	my($sequences)='';

	# Scan every alignment for each specie
	while(my($specie_name,$specie_cds)=each(%{$cds_alignment}))
	{
		unless(($specie_name eq 'anc_aa') or ($specie_name eq 'ancestor')) # Don't pay attention to these alignments
		{
			my($exon_sequences)='';
			foreach my $exon (@{$sort_exon_list})
			{
				# Get the cds depending orientation
				my($init_exon,$length_exon)=get_coordinates($orientation,$exon,$transcript_features);

				# Subtraction the CDS sequences and concatenate each other
				$exon_sequences.=substr($specie_cds->{'sequence'},$init_exon,$length_exon);
			}
			$cds_exons_alignment->{$specie_name}->{'sequence'}=$exon_sequences;
			$cds_exons_alignment->{$specie_name}->{'length'}=length($exon_sequences);
			$cds_exons_alignment->{$specie_name}->{'num_gaps'}=get_num_gaps($exon_sequences);			
		}
	}
	return $cds_exons_alignment;
}
# Get the number of gaps
sub get_num_gaps($)
{
	my($sequence)=@_;
	my($num_gaps)=($sequence=~tr/\-/\-/);
	return $num_gaps;
}

# Get CDS alignment as FASTA format
sub get_cds_alignment($)
{
	my ($cds_alignment_string_xml) = @_;
	my($cds_alignment);

	my($parser);
	my($cdsview_doc);
	eval{
		$parser=XML::LibXML->new();
		$cdsview_doc=$parser->parse_string($cds_alignment_string_xml);		
	};
	return $cds_alignment if($@);

	my(@row_nodes)=$cdsview_doc->getElementsByTagName('row');
	return $cds_alignment unless(scalar(@row_nodes)>0);

	foreach my $node (@row_nodes)
	{
		if(UNIVERSAL::isa($node,'XML::LibXML::Element'))
		{
			my($specie_name)=$node->getAttribute('name');
			
			if(defined($specie_name) && $specie_name ne '')
			{

				my(@codon_nodes)=$node->getElementsByTagName('codon');
				return $cds_alignment unless(scalar(@codon_nodes)>0);
	
				my($cds_sequence)='';
				my($cds_length)=0;
				my($cds_num_gaps)=0;
				foreach my $n (@codon_nodes)
				{
					if(UNIVERSAL::isa($n,'XML::LibXML::Element'))
					{
						my($frame)=$n->textContent();
						$cds_length+=length($frame); # Length
						$cds_sequence.=$frame if($frame=~/[a-z|A-Z|\-]/); # Sequence
						my($num_gaps)=($frame=~tr/\-/\-/);
						$cds_num_gaps+=$num_gaps; # Num gaps
					}
				}
				my(@epilogue_nodes)=$node->getElementsByTagName('epilogue');
				foreach my $n (@epilogue_nodes)
				{
					if(UNIVERSAL::isa($n,'XML::LibXML::Element'))
					{
						my($frame)=$n->textContent();
						$cds_length+=length($frame); # Length
						$cds_sequence.=$frame if($frame=~/[a-z|A-Z|\-]/); # Sequence
						my($num_gaps)=($frame=~tr/\-/\-/);
						$cds_num_gaps+=$num_gaps; # Num gaps
					}
				}
				
				$cds_alignment->{$specie_name}->{'sequence'}=$cds_sequence;
				$cds_alignment->{$specie_name}->{'num_gaps'}=$cds_num_gaps;
				$cds_alignment->{$specie_name}->{'length'}=$cds_length;
			}
		}
	}
	return $cds_alignment;
}
# Get CDS alignment from file
sub get_cds_alignment_from_file($)
{
	my($alignment_file) = @_;
	my($cds_alignment);

	$/=undef;
	local(*ALIGNMENT_FILE);
	open(ALIGNMENT_FILE,$alignment_file) or return undef;
	my($alignmet_content)=<ALIGNMENT_FILE>;
	close(ALIGNMENT_FILE);
	$/='\n';
	
	if(defined $alignmet_content)
	{
		while($alignmet_content=~/>([^\n]+)\n+([a-zA-Z\-]+)/g)
		{
			my($specie_name)=$1;
			my($cds_sequence)=$2;
			my($test_gaps)=$cds_sequence;
			my($num_gaps)=($test_gaps=~tr/\-/\-/);
			$cds_alignment->{$specie_name}->{'sequence'}=$cds_sequence;
			$cds_alignment->{$specie_name}->{'num_gaps'}=$num_gaps;
			$cds_alignment->{$specie_name}->{'length'}=length($cds_sequence);
		}
	}
	return $cds_alignment;	
}
# Get CDS alignment from CGI as xml document but in string format
sub get_cdsview_alignment($$)
{
	my ($chromosome,$orientation) = @_;
	my($cds_alignment_string_xml);

	$chromosome=~tr/\,/\-/;
	my($cdsview_uri)=$CDSVIEW_CGI.'&interval='.'chr'.$chromosome;
	$cdsview_uri.='&rc' if($orientation eq '-');
	my($cdsview_content)=get($cdsview_uri);

	my($parser);
	my($cdsview_doc);
	eval{
		$parser=XML::LibXML->new();
		$cdsview_doc=$parser->parse_string($cdsview_content);		
	};
	return $cds_alignment_string_xml if($@);

	my(@cdsview_nodes)=$cdsview_doc->getElementsByTagName('cdsview');
	return $cds_alignment_string_xml unless(scalar(@cdsview_nodes)>0);

	foreach my $node (@cdsview_nodes)
	{
		$cds_alignment_string_xml.=$node->toString() if(UNIVERSAL::isa($node,'XML::LibXML::Element'));
	}
	
	return $cds_alignment_string_xml;
}

# Print CDS aligments as phylip or fasta format
sub print_cds_filter_aligment($$)
{
	my ($cds_filter_alignment,$format) = @_;
	my($cds_alignment)='';

	if($format eq 'phylip')
	{
		my($num_species)=0;
		my($length_sequences)=length($cds_filter_alignment->{$HUMAN_SPECIE_NAME}->{'sequence'});
		my($sequences)='';
		while(my($specie_name,$specie_cds)=each(%{$cds_filter_alignment}))
		{
			$sequences.=$specie_name."\n".$specie_cds->{'sequence'}."\n";
			$num_species++;
		}
		$cds_alignment=$num_species.' '.$length_sequences."\n".$sequences;
	}
	elsif($format eq 'fasta')
	{
		my($cds_alignment_fasta)='';
		while(my($specie_name,$specie_cds)=each(%{$cds_filter_alignment}))
		{
			$cds_alignment_fasta.=">$specie_name\n".$specie_cds->{'sequence'}."\n";				
		}
		$cds_alignment=$cds_alignment_fasta;
	}
	return $cds_alignment;
	
} # End print_cds_filter_aligment


1;
