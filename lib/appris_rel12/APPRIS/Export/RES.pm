=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Export::RES - Utility functions for info exporting

=head1 SYNOPSIS

  use APPRIS::Export::RES
    qw(
       get_trans_residues
     );

  or to get all methods just

  use APPRIS::Export::RES;

  eval { get_trans_residues($feature,$params) };
  if ($@) {
    print "Caught exception:\n$@";
  }

=head1 DESCRIPTION

Retrieves sequences of transcript as fasta format.

=head1 METHODS

=cut

package APPRIS::Export::RES;

use strict;
use warnings;
use Data::Dumper;
use Bio::Seq;
use Bio::SeqIO;

use APPRIS::Utils::Exception qw(throw warning deprecate);

use APPRIS::Utils::Constant qw(
	$OK_LABEL
	$METHOD_DESC
);

my ($OK_LABEL) = $APPRIS::Utils::Constant::OK_LABEL;
my ($METHOD_DESC) = $APPRIS::Utils::Constant::METHOD_DESC;

=head2 get_trans_residues

  Arg [1]    : Listref of APPRIS::Gene or APPRIS::Transcript or undef
  Example    : $annot = $exporter->get_trans_residues($feature,'aa');
  Description: Retrieves nucleotide o aminoacid sequence.
  Returntype : String or undef

=cut

sub get_trans_residues {
    my ($feature) = @_;
    my ($report);
	
    if (ref($feature) and $feature->isa("APPRIS::Transcript")) {    	
		my ($id);
		if ($feature->stable_id) {
			$id = $feature->stable_id;
			
		 	if ( $feature->analysis ) {
		 		my ($analysis) = $feature->analysis;
		 		if ( $analysis->firestar and $analysis->firestar->result ) {		 			
					my ($method) = $analysis->firestar;	 			
			 		my ($residues) = parser_firestar_residues($method);
					if ( defined $residues and scalar($residues) > 0 ) {
						$report->{$id}->{$METHOD_DESC->{'firestar'}} = $residues;
					}
		 		}
		 		if ( $analysis->matador3d and $analysis->matador3d->result ) {		 			
					my ($method) = $analysis->matador3d;	 			
			 		my ($residues) = parser_matador3d_residues($method);
					if ( defined $residues and scalar($residues) > 0 ) {
						$report->{$id}->{$METHOD_DESC->{'matador3d'}} = $residues;
					}
		 		}		 		
		 		if ( $analysis->spade and $analysis->spade->result ) {		 			
					my ($method) = $analysis->spade;	 			
			 		my ($residues) = parser_spade_residues($method);
					if ( defined $residues and scalar($residues) > 0 ) {
						$report->{$id}->{$METHOD_DESC->{'spade'}} = $residues;
					}
		 		}
		 		if ( $analysis->crash and $analysis->crash->result ) {		 			
					my ($method) = $analysis->crash;	 			
			 		my ($label,$residues) = parser_crash_residues($method);
					if ( defined $residues and scalar($residues) > 0 ) {
						$report->{$id}->{$METHOD_DESC->{$label}} = $residues;
					}
		 		}
		 		if ( $analysis->thump and $analysis->thump->result ) {
		 			my ($method) = $analysis->thump;		 			
			 		my ($residues) = parser_thump_residues($method);
					if ( defined $residues and scalar($residues) > 0 ) {
						$report->{$id}->{$METHOD_DESC->{'thump'}} = $residues;
					}
		 		}
		 	}
		}		
    }
    else {
		throw('Argument must be an APPRIS::Transcript');
   	}
	return $report;
}

sub parser_firestar_residues {
	my ($method) = @_;
	my ($residues);
	if ( defined $method->residues and defined $method->result ) {

		foreach my $region (@{$method->residues}) {
			if ( defined $region->residue ) {
				my ($res) = {
					'start'	=> $region->residue,
					'end'	=> $region->residue,	
				};
				push(@{$residues},$res);
			}
		}
	}
	return $residues;	
}

sub parser_matador3d_residues {
	my ($method) = @_;
	my ($residues);
	
	if ( defined $method->conservation_structure and defined $method->result ) {
		if ( defined $method->alignments ) {
			foreach my $region (@{$method->alignments}) {	
				if ( defined $region->pstart and defined $region->pend and defined $region->score and ($region->type eq 'mini-exon') ) {
					my ($res) = {
						'start'	=> $region->pstart,
						'end'	=> $region->pend,
					};
					push(@{$residues},$res);						
				}
			}
		}
	}
	
	return $residues;
}


sub parser_spade_residues {
	my ($method) = @_;
	my ($residues);
	
	if ( defined $method->domain_signal and defined $method->result ) {
		if ( defined $method->regions ) {
			foreach my $region (@{$method->regions}) {	
				if ( defined $region->alignment_start and defined $region->alignment_end and
					 defined $region->hmm_name and defined $region->evalue ) {
						my ($res) = {
							'start'	=> $region->alignment_start,
							'end'	=> $region->alignment_end,
						};
						push(@{$residues},$res);
				}
			}
		}
	}
	
	return $residues;
}

sub parser_crash_residues {
	my ($method) = @_;
	my ($label,$residues);
	
	if ( defined $method->result and defined $method->peptide_signal and defined $method->mitochondrial_signal ) {
		if ( ($method->peptide_signal eq $OK_LABEL) or ($method->mitochondrial_signal eq $OK_LABEL) ) {
			if ( defined $method->regions ) {
				if ( ($method->peptide_signal eq $OK_LABEL) and ($method->mitochondrial_signal eq $OK_LABEL) ) {
					$label = 'crash';
				}
				elsif ( $method->peptide_signal eq $OK_LABEL ) {
					$label = 'crash_sp';
				}					
				elsif ( $method->mitochondrial_signal eq $OK_LABEL ) {
					$label = 'crash_tp';
				}					
				
				foreach my $region (@{$method->regions}) {
					if ( defined $region->pstart and defined $region->pend ) {
						my ($res) = {
							'start'	=> $region->pstart,
							'end'	=> $region->pend,
						};
						push(@{$residues},$res);
					}
				}
			}						
		}
	}
	
	return ($label,$residues);
}

sub parser_thump_residues {
	my ($method) = @_;
	my ($residues);
	
	if ( defined $method->transmembrane_signal and defined $method->result ) {
		if ( defined $method->regions ) {
			foreach my $region (@{$method->regions}) {
				if ( defined $region->pstart and defined $region->pend ) {					
					unless ( defined $region->damaged ) {
						my ($res) = {
							'start'	=> $region->pstart,
							'end'	=> $region->pend,
						};
						push(@{$residues},$res);						
					}					
				}
			}
		}
	}
		
	return $residues;
}

1;
