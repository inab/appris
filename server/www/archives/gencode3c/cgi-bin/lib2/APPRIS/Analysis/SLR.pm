=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Analysis::SLR - Object representing an analysis run

=head1 SYNOPSIS

  my $analysis = APPRIS::Analysis::SLR->new(
    -result      => <Analysis result>,
    -functional_residue  => <Annotation analysed>,
  );

=head1 DESCRIPTION

A representation of analysis of SLR within the APPRIS system.
Object to store details of an analysis run.

=head1 METHODS

=cut

package APPRIS::Analysis::SLR;

use strict;
use warnings;

use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);

=head2 new

  Arg [-result]  : 
       string - the anlysis result of the transcript
  Arg [-alignment]  : 
       string - the input alignment to get the analysed result
  Arg [-tree]  : 
       string - the input tree to get the analydsed result
  Example    : $analysis = APPRIS::Analysis::SLR->new(...);
  Description: Creates a new analysis object
  Returntype : APPRIS::Analysis::SLR
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
		$result,			$alignment,
		$tree
	)
	= rearrange( [
		'result',			'alignment',
		'tree'
	],
	@_
	);

 	$self->result($result);
 	$self->alignment($alignment);
	$self->tree($tree);
		
	return $self;
}

=head2 result

  Arg [1]    : (optional) String - the result to set
  Example    : $analysis->result(123);
  Description: Getter/setter for the results for this analysis
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub result {
	my ($self) = shift;
	$self->{'result'} = shift if(@_);
	return $self->{'result'};
}

=head2 alignment

  Arg [1]    : (optional) String - the input alignment to set
  Example    : $analysis->alignment(123);
  Description: Getter/setter for the input alignment
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub alignment {
	my ($self) = shift;
	$self->{'alignment'} = shift if(@_);
	return $self->{'alignment'};
}

=head2 tree

  Arg [1]    : (optional) String - the input tree to set 
               the analysis
  Example    : $analysis->tree(5);
  Description: Getter/setter for the input tree 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub tree {
	my ($self) = shift;
	$self->{'tree'} = shift if(@_);
	return $self->{'tree'};
}

sub DESTROY {}

1;
