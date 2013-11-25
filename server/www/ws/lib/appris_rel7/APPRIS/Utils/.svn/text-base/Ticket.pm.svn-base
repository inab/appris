=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Utils::Ticket - Object representing a gene

=head1 SYNOPSIS

  my $gene = APPRIS::Utils::Ticket->new(
    -chr	=> 1,
    -start  => 123,
    -end    => 1045,
    -strand => '+',
  );

  # print gene information
  print("gene start:end:strand is "
      . join( ":", map { $gene->$_ } qw(start end strand) )
      . "\n" );

  # set some additional attributes
  $gene->stable_id('ENSG000001');
  $gene->description('This is the gene description');

=head1 DESCRIPTION

A representation of a Gene within the APPRIS system.
A gene is a set of one or more alternative transcripts.

=head1 METHODS

=cut

package APPRIS::Utils::Ticket;

use strict;
use warnings;
use Digest::MD5;
use Bio::SeqIO;

use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);
use APPRIS::Utils::File qw( prepare_workspace );


use Data::Dumper;

{
    # Encapsulated class data
    #___________________________________________________________
    my %_attr_data =
		(
			file			=>  undef,
			ticket			=>  undef,
			base			=>  undef, # $ENV{APPRIS_PROGRAMS_TMP_DIR},
			paths			=> 	undef, # ['firestar','matador3d','corsair','spade','inertia','cexonic','thump','crash'],
			cache			=>  undef, # $ENV{APPRIS_PROGRAMS_TMP_DIR}."/cache.txt",			
		);
    #_____________________________________________________________

	# Classwide default value for a specified object attribute
	sub _default_for {
		my ($self, $attr) = @_;
		$_attr_data{$attr};
	}

	# List of names of all specified object attributes
	sub _standard_keys {
		keys %_attr_data;
	}
	
	sub file {
		my ($self, $arg) = @_;
		$self->{file} = $arg if defined $arg;
		return $self->{file};
	}
	
	sub ticket {
		my ($self, $arg) = @_;
		$self->{ticket} = $arg if defined $arg;
		return $self->{ticket};
	}
	
	sub base {
		my ($self, $arg) = @_;
		$self->{base} = $arg if defined $arg;
		return $self->{base};
	}

	sub paths {
		my ($self, $arg) = @_;
		$self->{paths} = $arg if defined $arg;
		return $self->{paths};
	}

	sub cache {
		my ($self, $arg) = @_;
		$self->{cache} = $arg if defined $arg;
		return $self->{cache};
	}
}


=head2 new

  Arg [-file]: (optional) 
       string - fasta file
  Arg [-ticket_id]: (optional) 
       string - ticket id in md5
  Example    : $gene = APPRIS::Utils::Ticket->new(...);
  Description: Creates a new ticket object
  Returntype : APPRIS::Utils::Ticket
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut
sub new {
	my ($caller, %args) = @_;
	
	my ($caller_is_obj) = ref($caller);
	return $caller if $caller_is_obj;
	my ($class) = $caller_is_obj || $caller;
	my ($self) = bless {}, $class;

	foreach my $attrname ($self->_standard_keys) {
		my ($attr) = "-".$attrname;
		if (exists $args{$attr} && defined $args{$attr}) {
			$self->{$attrname} = $args{$attr};
		} else {
			$self->{$attrname} = $self->_default_for($attrname);
		}
	}

	return $self;
}

=head2 get_ticket_id

  Arg [1]    : (optional) string $file
               override the default level
  Example    : use APPRIS::Utils::Ticket;
               $id = $ticket->get_ticket_id();
  Description: Get the ticket id from fasta input.
  Returntype : string
  Exceptions : thrown every time

=cut

sub get_ticket_id
{
	my ($self) = shift;
	$self->{'file'} = shift if(@_);
	my ($ticket_id) = undef;
	my ($data) = '';
	
	# get message to md5	
	eval {		
		my ($in) = Bio::SeqIO->new(
					-file => $self->{'file'},
					-format => 'Fasta'
		);
		while ( my $seqObj = $in->next_seq() ) {
			my ($seq_id) = $seqObj->id;
			my ($seq) = $seqObj->seq;			
			$data .= $seq_id.':'.$seq.'|';
		}
		$data =~ s/\|$//;
	};
	throw('Argument must be a correct fasta file') if ($@);
	
	# create md5
	eval {
		my ($ctx) = Digest::MD5->new;
		$ctx->add($data);
		$ticket_id = $ctx->hexdigest;		
	};
	throw('Creating md5') if ($@);
	
	$self->{'ticket'} = $ticket_id;
	return $ticket_id;
}

=head2 create_workspace

  Arg [1]    : (optional) List of string $paths
               override the default value
  Arg [2]    : (optional) string $paths
               base of dire where we create the workspace
  Example    : use APPRIS::Utils::Ticket;
               $id = $ticket->create_workspace();
  Description: Create workspace from ticketid and paths.
  Returntype : base path or undef 
  Exceptions : thrown every time

=cut

sub create_workspace
{
	my ($self, $paths, $base) = @_;
	$self->{'paths'} = $paths if (defined $paths);
	
	# override default base dir
	unless ( defined $base ) {
		if ( defined $self->{'base'} and $self->{'ticket'} ) {
			$base = $self->{'base'}.'/'.$self->{'ticket'}.'/';
		}
		else {
			throw('Argument must be a correct') if ($@);
			return undef;
		}		
	}	

	eval {
		if ( UNIVERSAL::isa($self->{'paths'},'ARRAY') ) {
			foreach my $path (@{$self->{'paths'}}) {
				my ($p) = APPRIS::Utils::File::prepare_workspace($base.'/'.$path);
				throw('Creating directory') unless ( defined $p );
			}		
		}
		elsif ( UNIVERSAL::isa($self->{'paths'},'SCALAR') || UNIVERSAL::isa($self->{'paths'},'REF') ) {
			my ($p) = APPRIS::Utils::File::prepare_workspace($base.'/'.$self->{'paths'});
			throw('Creating directory') unless ( defined $p );
		}		
	};
	throw('Argument must be a correct') if ($@);
	return $base;		
}

=head2 mkdir_workspace

  Arg [1]    : string $path
  Example    : use APPRIS::Utils::Ticket;
               $p = $ticket->mkdir_workspace($path);
  Description: Create directory from path.
  Returntype : string or undef
  Exceptions : thrown every time

=cut

sub mkdir_workspace
{
	my ($self, $path) = @_;
	
	my ($p) = APPRIS::Utils::File::prepare_workspace($path);
	throw('Creating directory') unless ( defined $p );
	
	return $p;
}

=head2 exist_ticket_id

  Arg [1]    : (optional) string $ticket
               override the default value
  Example    : use APPRIS::Utils::Ticket;
               $id = $ticket->exist_ticket_id();
  Description: Check if ticket already exists.
  Returntype : boolean
  Exceptions : thrown every time

=cut

sub exist_ticket_id
{
	
}

sub DESTROY {}

1;
