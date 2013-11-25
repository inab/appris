=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Analysis::FirestarRegion - Object representing a region

=head1 SYNOPSIS

  my $region = APPRIS::Analysis::FirestarRegion->new(
    -start  => 123,
    -end    => 1045,
    -strand => '+',
  );

  # print region information
  print("region start:end:strand is "
      . join( ":", map { $region->$_ } qw(start end strand) )
      . "\n" );

=head1 DESCRIPTION

A representation of a FirestarRegion within the APPRIS system.
A FirestarRegion object represents a region of a genome from analysis
method.

=head1 METHODS

=cut

package APPRIS::Analysis::FirestarRegion;

use strict;
use warnings;
use vars qw(@ISA);

use APPRIS::Analysis::Region;
use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);

@ISA = qw(APPRIS::Analysis::Region);

=head2 new

  Arg [-residue]  : 
       int - postion of the peptide residue
  Arg [-score] : 
       string - the score of the region
  Arg [-domain] : (optional)
       string - the domain of the region
  Arg [-start]  : (optional)
       int - start postion of the slice 
  Arg [-end]    : (optional)
       int - end position of the slice
  Arg [-strand] : (optional)
       char - '+','-' the strand the slice is on
  Example    : $region = APPRIS::Analysis::FirestarRegion->new(...);
  Description: Creates a new region object
  Returntype : APPRIS::Analysis::FirestarRegion
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
		$residue,	$score,		$domain,
		$start,		$end,		$strand,
	)
	= rearrange( [
		'residue',	'score',	'domain',
		'start',	'end',		'strand',	
	],
	@_
	);

 	$self->residue($residue);
 	$self->score($score);
 	$self->domain($domain) if(defined $domain);
 	$self->start($start) if(defined $start);
 	$self->end($end) if(defined $end);
 	$self->strand($strand) if(defined $strand);
  
	return $self;
}

=head2 residue

  Arg [1]    : (optional) Int - the position of peptide location to set
  Example    : $region->residue(123);
  Description: Getter/setter for position of peptide location
  Returntype : Int
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub residue {
	my ($self) = shift;
	$self->{'residue'} = shift if(@_);
	return $self->{'residue'};
}

=head2 score

  Arg [1]    : (optional) String - the score of the region is on
  Example    : $region->score('-');
  Description: Getter/setter for the score that for this region
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub score {
	my ($self) = shift;
	$self->{'score'} = shift if(@_);
	return $self->{'score'};
}

=head2 domain

  Arg [1]    : (optional) String - the domain of the region is on
  Example    : $region->domain('-');
  Description: Getter/setter for the domain that for this region
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub domain {
	my ($self) = shift;
	$self->{'domain'} = shift if(@_);
	return $self->{'domain'};
}

sub DESTROY {}

1;
