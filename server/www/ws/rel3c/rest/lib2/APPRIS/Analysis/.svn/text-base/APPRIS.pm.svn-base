=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Analysis::APPRIS - Object representing an analysis run

=head1 SYNOPSIS

  my $analysis = APPRIS::Analysis::APPRIS->new(
    -functional_residue       => <Annotation analysed>,
    -conservation_structure   => <Annotation analysed>,
    -domain_signal            => <Annotation analysed>,
    -unusual_evolution        => <Annotation analysed>,
    -peptide_signal           => <Annotation analysed>,
    -mitochondrial_signal     => <Annotation analysed>,
    -transmembrane_signal     => <Annotation analysed>,
    -conservation_exon        => <Annotation analysed>,
    -vertebrate_signal        => <Annotation analysed>,
    -principal_isoform        => <Annotation analysed>,
    -source                   => <Source of Annotation analysed>,
  );

=head1 DESCRIPTION

A representation of analysis of APPRIS within the APPRIS system.
Object to store details of an analysis run.

=head1 METHODS

=cut

package APPRIS::Analysis::APPRIS;

use strict;
use warnings;

use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);

=head2 new

  Arg [-vertebrate_signal]:
        string - the appris annotation for this analysis
  Arg [-score]: (optional)
        string - the score of the analysis
  Example    : $analysis = APPRIS::Analysis::APPRIS->new(...);
  Description: Creates a new analysis object
  Returntype : APPRIS::Analysis::APPRIS
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
		$functional_residue,		$conservation_structure,
		$domain_signal,		$unusual_evolution,
		$peptide_signal,		$mitochondrial_signal,
		$transmembrane_signal,		$conservation_exon,
		$vertebrate_signal,		$principal_isoform,
		$source
	)
	= rearrange( [
		'functional_residue',	'conservation_structure',
		'domain_signal',		'unusual_evolution',
		'peptide_signal',		'mitochondrial_signal',
		'transmembrane_signal',	'conservation_exon',
		'vertebrate_signal',	'principal_isoform',
		'source'
	],
	@_
	);

 	$self->functional_residue($functional_residue);
 	$self->conservation_structure($conservation_structure);
 	$self->domain_signal($domain_signal);
 	$self->unusual_evolution($unusual_evolution);
 	$self->peptide_signal($peptide_signal);
 	$self->mitochondrial_signal($mitochondrial_signal);
 	$self->transmembrane_signal($transmembrane_signal);
 	$self->conservation_exon($conservation_exon);
 	$self->vertebrate_signal($vertebrate_signal);
 	$self->principal_isoform($principal_isoform);
 	$self->source($source);
		
	return $self;
}

=head2 functional_residue

  Arg [1]    : (optional) String - the analysed functional_residue to set
  Example    : $analysis->functional_residue($method);
  Description: Getter/setter for the analysed functional_residue
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub functional_residue {
	my ($self) = shift;
	$self->{'functional_residue'} = shift if(@_);
	return $self->{'functional_residue'};
}

=head2 conservation_structure

  Arg [1]    : (optional) String - the analysed conservation_structure to set
  Example    : $analysis->conservation_structure($method);
  Description: Getter/setter for the analysed conservation_structure
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub conservation_structure {
	my ($self) = shift;
	$self->{'conservation_structure'} = shift if(@_);
	return $self->{'conservation_structure'};
}

=head2 domain_signal

  Arg [1]    : (optional) String - the analysed domain_signal to set
  Example    : $analysis->domain_signal($method);
  Description: Getter/setter for the analysed domain_signal
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub domain_signal {
	my ($self) = shift;
	$self->{'domain_signal'} = shift if(@_);
	return $self->{'domain_signal'};
}

=head2 unusual_evolution

  Arg [1]    : (optional) String - the analysed unusual_evolution to set
  Example    : $analysis->unusual_evolution($method);
  Description: Getter/setter for the analysed unusual_evolution
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub unusual_evolution {
	my ($self) = shift;
	$self->{'unusual_evolution'} = shift if(@_);
	return $self->{'unusual_evolution'};
}

=head2 peptide_signal

  Arg [1]    : (optional) String - the analysed peptide_signal to set
  Example    : $analysis->peptide_signal($method);
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
  Example    : $analysis->mitochondrial_signal($method);
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

=head2 transmembrane_signal

  Arg [1]    : (optional) String - the analysed transmembrane_signal to set
  Example    : $analysis->transmembrane_signal($method);
  Description: Getter/setter for the analysed transmembrane_signal
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub transmembrane_signal {
	my ($self) = shift;
	$self->{'transmembrane_signal'} = shift if(@_);
	return $self->{'transmembrane_signal'};
}

=head2 conservation_exon

  Arg [1]    : (optional) String - the analysed conservation_exon to set
  Example    : $analysis->conservation_exon($method);
  Description: Getter/setter for the analysed conservation_exon
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub conservation_exon {
	my ($self) = shift;
	$self->{'conservation_exon'} = shift if(@_);
	return $self->{'conservation_exon'};
}

=head2 vertebrate_signal

  Arg [1]    : (optional) String - the analysed vertebrate_signal to set
  Example    : $analysis->vertebrate_signal($method);
  Description: Getter/setter for the analysed vertebrate_signal
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub vertebrate_signal {
	my ($self) = shift;
	$self->{'vertebrate_signal'} = shift if(@_);
	return $self->{'vertebrate_signal'};
}

=head2 principal_isoform

  Arg [1]    : (optional) String - the analysed principal_isoform to set
  Example    : $analysis->principal_isoform($method);
  Description: Getter/setter for the analysed principal_isoform
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub principal_isoform {
	my ($self) = shift;
	$self->{'principal_isoform'} = shift if(@_);
	return $self->{'principal_isoform'};
}

=head2 source

  Arg [1]    : (optional) String - the source of the analysis
  Example    : $analysis->source('vertebrate_signal');
  Description: Getter/setter for the source of analysis 
               that for this analysis
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub source {
	my ($self) = shift;
	$self->{'source'} = shift if(@_);
	return $self->{'source'};
}

sub DESTROY {}

1;
