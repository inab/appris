=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

Parser - Module to handle firestar results

=head1 SYNOPSIS

  use APPRIS::Parser
    qw(
       parse_firestar
     );

  or to get all methods just

  use APPRIS::Parser;

  eval { parse_firestar($result) };
  if ($@) {
    print "Caught exception:\n$@";
  }

=head1 DESCRIPTION

Module to handle firestar results.

=head1 METHODS

=cut
package APPRIS::Parser;

use strict;
use warnings;
use APPRIS::Transcript;
use APPRIS::Analysis;
use APPRIS::Analysis::Firestar;
use APPRIS::Analysis::INERTIA;

use Exporter;

use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(
	parse_firestar
	parse_inertia
	parse_firestar_gopher
);

sub parse_firestar($$);
sub parse_inertia($$$$$);
sub _parse_inertia_file($$\$);
sub _parse_omega_file($$\$);
sub _parse_omega_file($$\$);
sub parse_firestar_gopher($);

=head2 parse_firestar

  Arg [1]    : String $id 
               The stable ID of the gene to retrieve
  Arg [2]    : string $result
               Parse firestar result
  Example    : use APPRIS::Parser qw(parse_firestar);
               parse_firestar($result);
  Description: Parse output of firestar.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_firestar($$)
{
	my ($stable_id, $result) = @_;

	my ($transcript_result) = '';
	my ($init_trans_result) = 0;
	my ($transcripts);
	my ($cutoffs);
	
	my (@results) = split( '\n', $result);
	foreach my $line (@results)
	{
		if ( $line eq '######') {
			# Init trans result
			$transcript_result = '';
			$init_trans_result = 1;
		}
		if ( $init_trans_result ) {
			$transcript_result .= $line."\n";		
		}

		#>>>     OTTHUMT00000171822      29      46,47,48,49,67,68,69,70,98,99,100,101,166,170,171,394,411,412,413,448,452,480,481,492,495,497,498,499,504
		if ( $line=~/^>>>\t+([^\t]+)\t+([^\t]+)\t+([^\$]+)$/ )
		{
			my ($id) = $1;
			my (@residue_list) = split(',', $3);

			# Get the peptide position and scores
			my ($residue_list_report);
			foreach my $residue_position (@residue_list)
			{
				if ( defined $residue_position and $residue_position ne '' )
				{
					#76	6	VETATTVGYGDLY	 2h8pC  1k4cC  2r9rH
					if ( $transcript_result =~ /$residue_position\t+(\d+)\t+([^\t]*)\t+([^\n]*)[^\>]*>>>\t+$id/ )
					{
						my ($score) = $1;
						my ($domain) = $2;
						my ($pdb_list) = $3; $pdb_list =~ s/^\s*//; $pdb_list =~ s/\s*$//;
						push(@{$residue_list_report},{
								'residue'	=> $residue_position,
								'score'		=> $score,
								'domain'	=> $domain,
								'pdb_list'	=> $pdb_list,
						});
					}
				}			
			}

			if(defined $residue_list_report and scalar(@{$residue_list_report})>0)
			{
				$cutoffs->{$id}->{'residues'} = $residue_list_report;
			}
			
			# Save result for each transcript
			$cutoffs->{$id}->{'result'} = $transcript_result;
			
			# Init trans result
			$transcript_result = ''; 
		}
		#C>>     OTTHUMT00000171822      3      46,47,48
		if ( $line=~/^C>>\t+([^\t]+)\t+([^\t]+)\t+([^\$]+)$/ )
		{
			my ($id) = $1;
			my (@residue_list) = split(',', $3);

			# Get the peptide position and scores
			my ($residue_list_report);
			foreach my $residue_position (@residue_list)
			{
				if ( defined $residue_position and $residue_position ne '' )
				{
					#76	6	VETATTVGYGDLY	 2h8pC  1k4cC  2r9rH
					if ( $transcript_result =~ /$residue_position\t+(\d+)\t+([^\t]*)\t+([^\n]*)[^\>]*>>\t+$id/ )
					{
						my ($score) = $1;
						my ($domain) = $2;
						my ($pdb_list) = $3; $pdb_list =~ s/^\s*//; $pdb_list =~ s/\s*$//;
						push(@{$residue_list_report},{
								'residue'	=> $residue_position,
								'score'		=> $score,
								'domain'	=> $domain,
								'pdb_list'	=> $pdb_list,				
						});		
					}
				}
			}
			
			# Sort residues
			my (@res_list) = @{$cutoffs->{$id}->{'residues'}};
			my (@sort_res_list) = sort { $a->{'peptide_position'} <=> $b->{'peptide_position'} } @res_list;
			$cutoffs->{$id}->{'residues'} = \@sort_res_list; 

			# Save result for each transcript
			my ($trans_result) = '';
			if ( exists $cutoffs->{$id}->{'result'} and defined $cutoffs->{$id}->{'result'} )
			{
					$cutoffs->{$id}->{'result'} = $cutoffs->{$id}->{'result'} . $transcript_result;
			}
			
			# Init result variable for the next
			$transcript_result = '';
		}
		
		#ACCEPT: ID\tTOTAL_SCORE\tTOTAL_MOTIFS\tNUM_SCORE_6\tNUM_SCORE_5\tNUM_SCORE_4\n		
		if ( $line =~ /^ACCEPT:\s*([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]+)\t([^\t]+)\t([^\n]+)\n*/ )
		{
			my ($id) = $1;
			my ($total_score) = $2;
			my ($total_residues) = $3;
			my ($num_residues_6) = $4;
			my ($num_residues_5) = $5;
			my ($num_residues_4) = $6;

			if ( defined $id and ($id ne '') )
			{
				unless ( defined $total_residues and $total_residues ne '' )
					{ $total_residues = 0; }
					
				$cutoffs->{$id}->{'num_residues'} = $total_residues;
				$cutoffs->{$id}->{'functional_residue'} = 'ACCEPT';
			}
		}
		#REJECT: ID\tTOTAL_SCORE\tTOTAL_MOTIFS\tNUM_SCORE_6\tNUM_SCORE_5\tNUM_SCORE_4\n
		if ( $line =~ /^REJECT:\s*([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]+)\t([^\t]+)\t([^\n]+)\n*/ )
		{
			my ($id) = $1;
			my ($total_score) = $2;
			my ($total_residues) = $3;
			my ($num_residues_6) = $4;
			my ($num_residues_5) = $5;
			my ($num_residues_4) = $6;

			if ( defined $id and ($id ne '') )
			{
				unless ( defined $total_residues and $total_residues ne '' )
					{ $total_residues = 0; }
					
				$cutoffs->{$id}->{'num_residues'} = $total_residues;
				$cutoffs->{$id}->{'functional_residue'} = 'REJECT';
			}
		}
	}

	# Create APPRIS object
	while ( my ($id, $report) = each(%{$cutoffs}) )
	{
		# create Firestar object
		my ($regions);		
		foreach my $residue (@{$report->{'residues'}})
		{
			push(@{$regions},
				APPRIS::Analysis::FirestarRegion->new
				(
					-residue	=> $residue->{'residue'},
					-score		=> $residue->{'score'},
					-domain		=> $residue->{'domain'},
				)				
			);			
		}
		my ($firestar) = APPRIS::Analysis::Firestar->new (
						-result					=> $report->{'result'},
						-functional_residue		=> $report->{'functional_residue'},
						-num_residues			=> $report->{'num_residues'}
		);
		$firestar->residues($regions) if (defined $regions);

		# create Analysis object
		my ($analysis) = APPRIS::Analysis->new();
		if (defined $firestar) {
			$analysis->firestar($firestar);
			$analysis->number($analysis->number+1);
		}
				
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $id,
		);
		$transcript->analysis($analysis) if (defined $analysis);

		push(@{$transcripts}, $transcript) if ( defined $transcript );
	}
	my ($entity) = APPRIS::Gene->new( -stable_id => $stable_id );
	$entity->transcripts($transcripts);

	return $entity;
}

=head2 parse_inertia

  Arg [1]    : String $id 
               The stable ID of the gene to retrieve
  Arg [2]    : string $inertia
               INERTIA result
  Arg [3]    : string $mafft
               MAFFT Omega result
  Arg [4]    : string $prank
               Prank Omega result
  Arg [5]    : string $kalign
               Kalign Omega result
  Example    : use APPRIS::Parser qw(parse_inertia);
               parse_inertia($id, $mafft, $prank, $kalign);
  Description: Parse the output of inertia.
  Returntype : APPRIS::Gene or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_inertia($$$$$)
{
	my ($stable_id, $inertia_i, $mafft_i, $prank_i, $kalign_i) = @_;
	my ($transcripts);
	my ($cutoffs);
	
	_parse_inertia_file('inertia', $inertia_i, $cutoffs);
	_parse_omega_file('mafft', $mafft_i, $cutoffs);
	_parse_omega_file('prank', $prank_i, $cutoffs);
	_parse_omega_file('kalign', $kalign_i, $cutoffs);

	# Create APPRIS objects
	while ( my ($id, $report) = each(%{$cutoffs}) )
	{
		# create INERTIA object
		my ($inertia);
		my ($regions);
		my ($report2) = $report->{'inertia'};
		foreach my $residue (@{$report2->{'residues'}})
		{
			push(@{$regions},
				APPRIS::Analysis::INERTIARegion->new
				(
					-start				=> $residue->{'start'},
					-end				=> $residue->{'end'},
					-strand				=> $residue->{'strand'},
					-unusual_evolution	=> $residue->{'unusual_evolution'}
				)
			);
		}
		if ( exists $report2->{'unusual_evolution'} and defined $report2->{'unusual_evolution'} ) {
			$inertia = APPRIS::Analysis::INERTIA->new
			(
				-unusual_evolution		=> $report2->{'unusual_evolution'}
			);
			$inertia->regions($regions) if (defined $regions);				
		}

		while ( my ($type, $report2) = each(%{$report}) )
		{
			if ( ($type eq 'mafft') or ($type eq 'prank') or ($type eq 'kalign') )
			{
				# create Omega object
				my ($omega);
				my ($regions);
				
				foreach my $residue (@{$report2->{'residues'}})
				{
					push(@{$regions},
						APPRIS::Analysis::OmegaRegion->new
						(
							-start				=> $residue->{'start'},
							-end				=> $residue->{'end'},
							-omega_mean			=> $residue->{'omega_mean'},
							-st_deviation		=> $residue->{'st_deviation'},
							-p_value			=> $residue->{'p_value'},
							-difference_value	=> $residue->{'difference_value'},
							-unusual_evolution	=> $residue->{'unusual_evolution'}
						)
					);			
				}
				$omega = APPRIS::Analysis::Omega->new
				(
					-average			=> $report2->{'omega_average'},
					-st_desviation		=> $report2->{'omega_st_desviation'},
					-result				=> $report2->{'result'},
					-unusual_evolution	=> $report2->{'unusual_evolution'}
				);
				$omega->regions($regions) if (defined $regions);
				
				$inertia->mafft_alignment($omega) if ($inertia and $omega and ($type eq 'mafft') );
				$inertia->prank_alignment($omega) if ($inertia and $omega and ($type eq 'prank') );
				$inertia->kalign_alignment($omega) if ($inertia and $omega and ($type eq 'kalign') );
			}			
		}
		
		# create Analysis object			
		my ($analysis);
		if (defined $inertia) {
			$analysis = APPRIS::Analysis->new();
			$analysis->inertia($inertia);
			$analysis->number($analysis->number+1);
		}
					
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new ( -stable_id	=> $id );
		$transcript->analysis($analysis) if (defined $analysis);
		push(@{$transcripts}, $transcript) if ( defined $transcript );		
	}
	
	# create Gene object
	my ($entity) = APPRIS::Gene->new ( -stable_id => $stable_id );
	$entity->transcripts($transcripts);

	return $entity;
}

sub _parse_inertia_file($$\$)
{
	my ($type, $result, $ref_cutoffs) = @_;

	my ($transcript_id);	
	my (@results) = split( '\n', $result);
	
	foreach my $line (@results)
	{
		next if( $line =~ /^#/ ); # Skip comment line
		$line.="\n"; # Due we are spliting by '\n'
		
		if ( $line =~ /^>([^\t]+)\t+([^\n]+)\n+$/ )
		{
			$transcript_id = $1;
			my ($unusual_evolution) = $2;

			${$ref_cutoffs}->{$transcript_id}->{$type}->{'unusual_evolution'} = $unusual_evolution;			
			unless ( exists ${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} ) {
				${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} = $line;
			} else {
				${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} .= $line;
			}			
		}		
		elsif ( defined $transcript_id and ($line =~ /^\t+([^\:]+)\:([^\_]+)\:([^\t]+)\t([^\n]+)\n+$/) )
		{
			my ($start) = $1;
			my ($end) = $2;
			my ($strand) = $3;
			my ($exon_annotation) = $4;
		
			my ($exon_report) = {
							'start'					=> $start,
							'end'					=> $end,
							'strand'				=> $strand,
							'unusual_evolution'		=> $exon_annotation						
			};
			push( @{${$ref_cutoffs}->{$transcript_id}->{$type}->{'residues'}}, $exon_report );
			${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} .= $line;
		}		
	}	
}

sub _parse_omega_file($$\$)
{
	my ($type, $result, $ref_cutoffs) = @_;

	my (@results) = split( '\n', $result);
	
	foreach my $line (@results)
	{
		next if( $line =~/^#/ ); # Skip comment line
		$line.="\n"; # Due we are spliting by '\n'
				
		# omega_average omega_exon_id   start_exon      end_exon        strand_exon     difference_value        p_value st_desviation   exon_annotation transcript_list
		if ( $line =~ /^([^\t]+)\t+([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+([^\n]+)\n+$/ )
		{
			my ($omega_mean) = $1;
			my ($omega_exon_id) = $2;
			my ($start) = $3;
			my ($end) = $4;
			my ($strand) = $5;
			my ($d_value) = $6;
			my ($p_value) = $7;
			my ($st_desviation) = $8;
			my ($exon_annotation) = $9;
			my ($exon_transcrits_list) = $10;
		
			# Get the trasncipt with omega exons
			my (@exon_transcrits);
			if ( $exon_transcrits_list ne 'NULL' ) {
				@exon_transcrits = split(';',$exon_transcrits_list);			
			}
			
			foreach my $transcript_id (@exon_transcrits)
			{
				my ($omega_exon_report) = {
							'omega_exon_id'			=> $omega_exon_id,
							'start'					=> $start,
							'end'					=> $end,
							'strand'				=> $strand,
							'omega_mean'			=> $omega_mean,
							'st_deviation'			=> $st_desviation,
							'difference_value'		=> $d_value,
							'p_value'				=> $p_value,
							'unusual_evolution'		=> $exon_annotation						
				};
				push( @{${$ref_cutoffs}->{$transcript_id}->{$type}->{'residues'}}, $omega_exon_report );
				unless ( exists ${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} ) {
					${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} = $line;
				} else {
					${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} .= $line;
				}
			}
		}

		# # omega_average omega_exon_id   start_exon      end_exon        difference_value        p_value st_desviation   exon_annotation transcript_list
		if ( $line =~ /^>([^\t]+)\t+([^\n]+)\n+$/ )
		{
			my ($transcript_id) = $1;
			my ($unusual_evolution) = $2;

			${$ref_cutoffs}->{$transcript_id}->{$type}->{'unusual_evolution'} = $unusual_evolution;			
			${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} .= "----------------------------------------------------------------------\n";
			${$ref_cutoffs}->{$transcript_id}->{$type}->{'result'} .= $line;

			${$ref_cutoffs}->{$transcript_id}->{$type}->{'omega_average'} = 0; # DEPRECATED
			${$ref_cutoffs}->{$transcript_id}->{$type}->{'omega_st_desviation'} = 0; # DEPRECATED			
		}		
	}
}

=head2 parse_firestar_gopher

  Arg [1]    : string $result
               Parse firestar result
  Example    : use APPRIS::Parser qw(parse_firestar);
               parse_firestar($result);
  Description: Execute MOBY web services of firestar.
  Returntype : Listref of APPRIS::Transcript or undef
  Exceptions : return undef
  Caller     : generally on error

=cut

sub parse_firestar_gopher($)
{
	my ($result) = @_;

	my ($transcript_result) = '';
	my ($init_trans_result) = 0;
	my ($transcripts);
	my ($cutoffs);
	
	my (@results) = split( '\n', $result);
	foreach my $line (@results)
	{
		if ( $line eq '######') {
			# Init trans result
			$transcript_result = '';
			$init_trans_result = 1;
		}
		if ( $init_trans_result ) {
			$transcript_result .= $line."\n";		
		}

		#>>>     OTTHUMT00000171822      29      46,47,48,49,67,68,69,70,98,99,100,101,166,170,171,394,411,412,413,448,452,480,481,492,495,497,498,499,504
		if ( $line=~/^>>>\t+([^\t]+)\t+([^\t]+)\t+([^\$]+)$/ )
		{
			my ($id) = $1;
			my (@residue_list) = split(',', $3);

			# Get the peptide position and scores
			my ($residue_list_report);
			foreach my $residue_position (@residue_list)
			{
				if ( defined $residue_position and $residue_position ne '' )
				{
					#76	6	VETATTVGYGDLY	 2h8pC  1k4cC  2r9rH
					if ( $transcript_result =~ /$residue_position\t+(\d+)\t+([^\t]*)\t+([^\n]*)[^\>]*>>>\t+$id/ )
					{
						my ($score) = $1;
						my ($domain) = $2;
						my ($pdb_list) = $3; $pdb_list =~ s/^\s*//; $pdb_list =~ s/\s*$//;
						push(@{$residue_list_report},{
								'residue'	=> $residue_position,
								'score'		=> $score,
								'domain'	=> $domain,
								'pdb_list'	=> $pdb_list,
						});
					}
				}			
			}

			if(defined $residue_list_report and scalar(@{$residue_list_report})>0)
			{
				$cutoffs->{$id}->{'residues'} = $residue_list_report;
			}
			
			# Save result for each transcript
			$cutoffs->{$id}->{'result'} = $transcript_result;
			
			# Init trans result
			$transcript_result = ''; 
		}
		#C>>     OTTHUMT00000171822      3      46,47,48
		if ( $line=~/^C>>\t+([^\t]+)\t+([^\t]+)\t+([^\$]+)$/ )
		{
			my ($id) = $1;
			my (@residue_list) = split(',', $3);

			# Get the peptide position and scores
			my ($residue_list_report);
			foreach my $residue_position (@residue_list)
			{
				if ( defined $residue_position and $residue_position ne '' )
				{
					#76	6	VETATTVGYGDLY	 2h8pC  1k4cC  2r9rH
					if ( $transcript_result =~ /$residue_position\t+(\d+)\t+([^\t]*)\t+([^\n]*)[^\>]*>>\t+$id/ )
					{
						my ($score) = $1;
						my ($domain) = $2;
						my ($pdb_list) = $3; $pdb_list =~ s/^\s*//; $pdb_list =~ s/\s*$//;
						push(@{$residue_list_report},{
								'residue'	=> $residue_position,
								'score'		=> $score,
								'domain'	=> $domain,
								'pdb_list'	=> $pdb_list,				
						});		
					}
				}
			}
			
			# Sort residues
			my (@res_list) = @{$cutoffs->{$id}->{'residues'}};
			my (@sort_res_list) = sort { $a->{'peptide_position'} <=> $b->{'peptide_position'} } @res_list;
			$cutoffs->{$id}->{'residues'} = \@sort_res_list; 

			# Save result for each transcript
			my ($trans_result) = '';
			if ( exists $cutoffs->{$id}->{'result'} and defined $cutoffs->{$id}->{'result'} )
			{
					$cutoffs->{$id}->{'result'} = $cutoffs->{$id}->{'result'} . $transcript_result;
			}
			
			# Init result variable for the next
			$transcript_result = '';
		}
		
		#ACCEPT: ID\tTOTAL_SCORE\tTOTAL_MOTIFS\tNUM_SCORE_6\tNUM_SCORE_5\tNUM_SCORE_4\n		
		if ( $line =~ /^ACCEPT:\s*([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]+)\t([^\t]+)\t([^\n]+)\n*/ )
		{
			my ($id) = $1;
			my ($total_score) = $2;
			my ($total_residues) = $3;
			my ($num_residues_6) = $4;
			my ($num_residues_5) = $5;
			my ($num_residues_4) = $6;

			if ( defined $id and ($id ne '') )
			{
				unless ( defined $total_residues and $total_residues ne '' )
					{ $total_residues = 0; }
					
				$cutoffs->{$id}->{'num_residues'} = $total_residues;
				$cutoffs->{$id}->{'functional_residue'} = 'ACCEPT';
			}
		}
		#REJECT: ID\tTOTAL_SCORE\tTOTAL_MOTIFS\tNUM_SCORE_6\tNUM_SCORE_5\tNUM_SCORE_4\n
		if ( $line =~ /^REJECT:\s*([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]+)\t([^\t]+)\t([^\n]+)\n*/ )
		{
			my ($id) = $1;
			my ($total_score) = $2;
			my ($total_residues) = $3;
			my ($num_residues_6) = $4;
			my ($num_residues_5) = $5;
			my ($num_residues_4) = $6;

			if ( defined $id and ($id ne '') )
			{
				unless ( defined $total_residues and $total_residues ne '' )
					{ $total_residues = 0; }
					
				$cutoffs->{$id}->{'num_residues'} = $total_residues;
				$cutoffs->{$id}->{'functional_residue'} = 'REJECT';
			}
		}
	}

	# Create APPRIS object
	while ( my ($id, $report) = each(%{$cutoffs}) )
	{
		# create Firestar object
		my ($regions);		
		foreach my $residue (@{$report->{'residues'}})
		{
			push(@{$regions},
				APPRIS::Analysis::FirestarRegion->new
				(
					-residue	=> $residue->{'residue'},
					-score		=> $residue->{'score'},
					-domain		=> $residue->{'domain'},
				)				
			);			
		}
		my ($firestar) = APPRIS::Analysis::Firestar->new (
						-result					=> $report->{'result'},
						-functional_residue		=> $report->{'functional_residue'},
						-num_residues			=> $report->{'num_residues'}
		);
		$firestar->residues($regions) if (defined $regions);

		# create Analysis object
		my ($analysis) = APPRIS::Analysis->new();
		if (defined $firestar) {
			$analysis->firestar($firestar);
			$analysis->number($analysis->number+1);
		}
				
		# create Transcript object
		my ($transcript) = APPRIS::Transcript->new
		(
			-stable_id	=> $id,
		);
		$transcript->analysis($analysis) if (defined $analysis);

		push(@{$transcripts}, $transcript) if ( defined $transcript );
	}

	return $transcripts;
}
1;