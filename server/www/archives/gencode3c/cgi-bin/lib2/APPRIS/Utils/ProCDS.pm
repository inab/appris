=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Utils::ProCDS - Utility functions for protein handling

=head1 SYNOPSIS

  use APPRIS::Utils::ProCDS
    qw(
       get_protein_cds_sequence
     );

  or to get all methods just

  use APPRIS::Utils::ProCDS;

  eval { get_protein_cds_sequence(cds_list) };
  if ($@) {
    print "Caught exception:\n$@";
  }

=head1 DESCRIPTION

The functions exported by this package provide a set of useful methods 
to handle files.

=head1 METHODS

=cut

package APPRIS::Utils::ProCDS;

use strict;
use warnings;

use APPRIS::ProCDS;

use Exporter;

use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(
	get_protein_cds_sequence
	get_contained_cds
);

=head2 get_protein_cds_sequence

  Arg [1]    : Listref of APPRIS::CDS $cds_list
  Arg [2]    : (optional) String - the aminoacid sequence 
               that for this peptide
  Example    : use APPRIS::Utils::ProCDS qw(get_protein_cds_sequence);
               get_protein_cds_sequence($cds_list);
  Description: Get the peptide coordinates and sequence from CDS list.
  Returntype : Listref of APPRIS::ProCDS or undef
  Exceptions : none

=cut

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
		my ($cds_start) = $cds->start;
		my ($cds_end) = $cds->end;
				
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
		my ($protein_cds) = APPRIS::ProCDS->new(
											-start				=> $pro_cds_start,
											-end				=> $pro_cds_end,
											-start_phase		=> $start_phase,
											-end_phase			=> $end_phase
										);
		if (defined $sequence) {
			my ($pro_cds_length) = ($pro_cds_end - $pro_cds_start) + 1;
			my ($pro_seq) = substr($sequence, ($pro_cds_start - 1), $pro_cds_length);
			$protein_cds->sequence($pro_seq) if (defined $pro_seq);
		}
		push(@{$protein_cds_list}, $protein_cds);
	}
	
	return $protein_cds_list;
}	

=head2 sort_cds

  Arg [1]    : Listref of APPRIS::CDS $cds_list
  Arg [2]    : (optional) String - the aminoacid sequence 
               that for this peptide
  Example    : use APPRIS::Utils::ProCDS qw(get_protein_cds_sequence);
               get_protein_cds_sequence($cds_list);
  Description: Sort list of CDS depending orientation.
  Returntype : Listref of APPRIS::ProCDS or undef
  Exceptions : none

=cut

sub sort_cds($$)
{
	my ($cds_list, $strand) = @_;

	my ($sort_cds_list);

	# Sort the CDS depending orientation from transcript
	if ($cds_list) {
		if ($strand eq '-') {
			@{$sort_cds_list}= sort { $b->start <=> $a->start } @{$cds_list};			
		}
		else {
			@{$sort_cds_list}= sort { $a->start <=> $b->start } @{$cds_list};				
		}		
	}
	return $sort_cds_list;
}

=head2 get_contained_cds

  Arg [1]    : Listref of APPRIS::CDS $cds_list
  Arg [2]    : Int - the start location of looking region
  Arg [3]    : Int - the end location of looking region  
  Example    : use APPRIS::Utils::ProCDS qw(get_contained_cds);
               get_contained_cds($cds_list,$start,$end);
  Description: Get the CDS list that are within given region
  Returntype : Listref of APPRIS::CDS or undef
  Exceptions : none

=cut

sub get_contained_cds($$$)
{
	my ($cds_list, $residue_start, $residue_end) = @_;
	
	my ($contained_cds);

	# Sort the exons depending orientation from transcript
	# For that we take the orientation of the first CDS
	my ($trans_strand) = $cds_list->[0]->strand;
	my ($sort_cds_list) = sort_cds($cds_list, $trans_strand);

	for (my $i = 0; $i < scalar(@{$sort_cds_list}); $i++) {
		my ($cds_start) = $sort_cds_list->[$i]->start;
		my ($cds_end) = $sort_cds_list->[$i]->end;
		my ($cds_strand) = $sort_cds_list->[$i]->strand;
		my ($cds_phase) = $sort_cds_list->[$i]->phase;

		# within one CDS
		if ($residue_start >= $cds_start and $residue_end <= $cds_end) {
			push(@{$contained_cds},
				APPRIS::CDS->new
				(
					-start		=> $cds_start,
					-end		=> $cds_end,
					-strand		=> $cds_strand,
					-phase		=> $cds_phase
				)
			);
			last;			
		}
		# within several CDS's (strand +)
		elsif ($cds_strand eq '+' and $residue_start <= $cds_end and $residue_end > $cds_end) {
			push(@{$contained_cds},
				APPRIS::CDS->new
				(
					-start		=> $cds_start,
					-end		=> $cds_end,
					-strand		=> $cds_strand,
					-phase		=> $cds_phase
				)
			);
			
			for (my $j = $i+1; $j < scalar(@{$sort_cds_list}); $j++) {
				my ($next_cds_start) = $sort_cds_list->[$j]->start;
				my ($next_cds_end) = $sort_cds_list->[$j]->end;
				my ($next_cds_strand) = $sort_cds_list->[$j]->strand;
				my ($next_cds_phase) = $sort_cds_list->[$j]->phase;

				if ($residue_end >= $next_cds_start and $residue_end >= $next_cds_end) {
					push(@{$contained_cds},
						APPRIS::CDS->new
						(
							-start		=> $next_cds_start,
							-end		=> $next_cds_end,
							-strand		=> $next_cds_strand,
							-phase		=> $next_cds_phase
						)
					);
				}
				elsif($residue_end >= $next_cds_start and $residue_end <= $next_cds_end) {
					push(@{$contained_cds},
						APPRIS::CDS->new
						(
							-start		=> $next_cds_start,
							-end		=> $next_cds_end,
							-strand		=> $next_cds_strand,
							-phase		=> $next_cds_phase
						)
					);					
					last;
				}
			}
			last;			
		}
		# within several CDS's (strand -)
		elsif($cds_strand eq '-' and $residue_start <= $cds_start and $residue_end >= $cds_start) {
			push(@{$contained_cds},
				APPRIS::CDS->new
				(
					-start		=> $cds_start,
					-end		=> $cds_end,
					-strand		=> $cds_strand,
					-phase		=> $cds_phase
				)
			);					
			
			for (my $j = $i+1; $j < scalar(@{$sort_cds_list}); $j++) {
				my ($next_cds_start) = $sort_cds_list->[$j]->start;
				my ($next_cds_end) = $sort_cds_list->[$j]->end;
				my ($next_cds_strand) = $sort_cds_list->[$j]->strand;
				my ($next_cds_phase) = $sort_cds_list->[$j]->phase;

				if ($residue_start <= $next_cds_end) {
					push(@{$contained_cds},
						APPRIS::CDS->new
						(
							-start		=> $next_cds_start,
							-end		=> $next_cds_end,
							-strand		=> $next_cds_strand,
							-phase		=> $next_cds_phase
						)
					);					
				}
			}
			last;			
		}
	}	
	
	return $contained_cds;
		
} # End get_contained_cds

1;