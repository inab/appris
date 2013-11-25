=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Analysis::CRASH - Object representing an analysis run

=head1 SYNOPSIS

  my $analysis = APPRIS::Analysis::CRASH->new(
    -result      => <Analysis result>,
    -peptide_signal  => <Annotation analysed>,
  );

=head1 DESCRIPTION

A representation of analysis of CRASH within the APPRIS system.
Object to store details of an analysis run.

=head1 METHODS

=cut

package APPRIS::Analysis::CRASH;

use strict;
use warnings;

use APPRIS::Analysis::CRASHRegion;
use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);

=head2 new

  Arg [-result]  : 
       string - the anlysis result of the transcript
  Arg [-peptide_signal]:
        string - the appris annotation for this analysis
  Arg [-mitochondrial_signal]:
        string - the appris annotation for this analysis
  Arg [-num_regions] : (optional)
        int - the number of analysed residues
  Arg [-peptide]: (optional)
        Listref of APPRIS::Analysis::CRASHRegion - the 
        set of regions that was analysed
  Example    : $analysis = APPRIS::Analysis::CRASH->new(...);
  Description: Creates a new analysis object
  Returntype : APPRIS::Analysis::CRASH
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub new {
	my ($caller) = shift;

	my ($caller_is_obj) = ref($caller);
	return $caller if $caller_is_obj;
	my ($class) = $caller_is_obj || $caller;
	my ($self) = bless {}, $class;

	my (
		$peptide_result,		$mitochondrial_result,
		$peptide_signal,		$mitochondrial_signal,
		$peptide_score,			$mitochondrial_score,
		$peptide_regions,		$mitochondrial_regions
	)
	= rearrange( [
		'peptide_result',		'mitochondrial_result',
		'peptide_signal',		'mitochondrial_signal',
		'peptide_score',		'mitochondrial_score',
		'peptide_regions',		'mitochondrial_regions'
	],
	@_
	);

 	$self->peptide_result($peptide_result);
 	$self->mitochondrial_result($mitochondrial_result);
 	$self->peptide_signal($peptide_signal);
 	$self->mitochondrial_signal($mitochondrial_signal);
 	$self->peptide_score($peptide_score);
 	$self->mitochondrial_score($mitochondrial_score);
	$self->peptide_regions($peptide_regions) if(defined $peptide_regions);
	$self->mitochondrial_regions($mitochondrial_regions) if(defined $mitochondrial_regions);
		
	return $self;
}

=head2 peptide_result

  Arg [1]    : (optional) String - the peptide_result to set
  Example    : $analysis->peptide_result(123);
  Description: Getter/setter for the peptide_result for this analysis
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub peptide_result {
	my ($self) = shift;
	$self->{'peptide_result'} = shift if(@_);
	return $self->{'peptide_result'};
}

=head2 mitochondrial_result

  Arg [1]    : (optional) String - the mitochondrial_result to set
  Example    : $analysis->mitochondrial_result(123);
  Description: Getter/setter for the mitochondrial_result for this analysis
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub mitochondrial_result {
	my ($self) = shift;
	$self->{'mitochondrial_result'} = shift if(@_);
	return $self->{'mitochondrial_result'};
}

=head2 peptide_signal

  Arg [1]    : (optional) String - the analysed peptide_signal to set
  Example    : $analysis->peptide_signal(123);
  Description: Getter/setter for the analysed peptide_signal
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub peptide_signal {
	my ($self) = shift;
	$self->{'peptide_signal'} = shift if(@_);
	return $self->{'peptide_signal'};
}

=head2 mitochondrial_signal

  Arg [1]    : (optional) String - the analysed mitochondrial_signal to set
  Example    : $analysis->mitochondrial_signal(123);
  Description: Getter/setter for the analysed mitochondrial_signal
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub mitochondrial_signal {
	my ($self) = shift;
	$self->{'mitochondrial_signal'} = shift if(@_);
	return $self->{'mitochondrial_signal'};
}

=head2 peptide_score

  Arg [1]    : (optional) String - the analysed peptide_score to set
  Example    : $analysis->peptide_score(123);
  Description: Getter/setter for the analysed peptide_score
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub peptide_score {
	my ($self) = shift;
	$self->{'peptide_score'} = shift if(@_);
	return $self->{'peptide_score'};
}

=head2 mitochondrial_score

  Arg [1]    : (optional) String - the analysed mitochondrial_score to set
  Example    : $analysis->mitochondrial_score(123);
  Description: Getter/setter for the analysed mitochondrial_score
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub mitochondrial_score {
	my ($self) = shift;
	$self->{'mitochondrial_score'} = shift if(@_);
	return $self->{'mitochondrial_score'};
}

=head2 peptide_regions

  Arg [1]    : (optional) Listref of APPRIS::Analysis::CRASHRegion - 
               the set of peptide regions that for this analysis 
  Example    : $analysis->peptide_regions($regions);
  Description: Getter/setter for the set of analysed regions 
  Returntype : Listref of APPRIS::Analysis::CRASHRegion or undef
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub peptide_regions {
	my ($self) = shift;
	$self->{'peptide_regions'} = shift if(@_);
	return $self->{'peptide_regions'};
}

=head2 mitochondrial_regions

  Arg [1]    : (optional) Listref of APPRIS::Analysis::CRASHRegion - 
               the set of mitochondrial regions that for this analysis 
  Example    : $analysis->mitochondrial_regions($regions);
  Description: Getter/setter for the set of analysed regions 
  Returntype : Listref of APPRIS::Analysis::CRASHRegion or undef
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub mitochondrial_regions {
	my ($self) = shift;
	$self->{'mitochondrial_regions'} = shift if(@_);
	return $self->{'mitochondrial_regions'};
}

sub DESTROY {}

1;
