=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Utils::WSpace - Object representing a gene

=head1 SYNOPSIS

  my $gene = APPRIS::Utils::WSpace->new(
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

package APPRIS::Utils::WSpace;

use strict;
use warnings;
use Digest::MD5;
use Bio::SeqIO;

use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);
use APPRIS::Utils::File qw( prepare_workspace getStringFromFile updateStringIntoLockFile );


use Data::Dumper;

{
    # Encapsulated class data
    #___________________________________________________________
    my %_attr_data =
		(
			id				=>  undef,
			file			=>  undef,
			path			=>  undef,
			base			=>  $ENV{APPRIS_PROGRAMS_TMP_DIR},
			index			=>  $ENV{APPRIS_PROGRAMS_TMP_DIR}."/.index",			
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
	
	sub id {
		my ($self, $arg) = @_;
		$self->{id} = $arg if defined $arg;
		return $self->{id};
	}

	sub file {
		my ($self, $arg) = @_;
		$self->{file} = $arg if defined $arg;
		return $self->{file};
	}
	
	sub path {
		my ($self, $arg) = @_;
		$self->{path} = $arg if defined $arg;
		return $self->{path};
	}
	
	sub base {
		my ($self, $arg) = @_;
		$self->{base} = $arg if defined $arg;
		return $self->{base};
	}
	
	sub index {
		my ($self, $arg) = @_;
		$self->{index} = $arg if defined $arg;
		return $self->{index};
	}
}


=head2 new

  Arg [-file]: (optional) 
       string - fasta file
  Arg [-ticket_id]: (optional) 
       string - ticket id in md5
  Example    : $gene = APPRIS::Utils::WSpace->new(...);
  Description: Creates a new ticket object
  Returntype : APPRIS::Utils::WSpace
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
	
	if ( $self->{id} ) {
		$self->{path} = $self->{base}.'/'.$self->{id}.'/';
	}
	elsif ( $self->{file} ) {
		$self->{id} = $self->create_id($self->{file});
		$self->{path} = $self->{base}.'/'.$self->{id}.'/';
	}
	return $self;
}

=head2 create_id

  Arg [1]    : (optional) string $file
               override the default level
  Example    : use APPRIS::Utils::WSpace;
               $id = $ticket->create_id();
  Description: Get the ticket id from fasta input.
  Returntype : string
  Exceptions : thrown every time

=cut

sub create_id
{
	my ($self) = shift;
	$self->{file} = shift if(@_);
	my ($id) = undef;
	my ($data) = '';
	
	# get message to md5	
	eval {		
		my ($in) = Bio::SeqIO->new(
					-file => $self->{file},
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
		$id = $ctx->hexdigest;		
	};
	throw('Creating md5') if ($@);
	
	$self->{id} = $id;
	return $id;
}

=head2 create

  Arg [1]    : (optional) List of string $dirs
               override the default value
  Arg [2]    : (optional) string $path
               base of dire where we create the workspace
  Example    : use APPRIS::Utils::WSpace;
               $id = $ticket->create();
  Description: Create workspace from ticketid and paths.
  Returntype : base path or undef 
  Exceptions : thrown every time

=cut

sub create
{
	my ($self, $dirs, $path) = @_;
	
	# override default base dir
	unless ( defined $path ) {
		if ( defined $self->{path} ) {
			$path = $self->{path};
		}
		else {
			throw('Main path not defined') if ($@);
			return undef;
		}		
	}	

	eval {
		if ( UNIVERSAL::isa($dirs,'ARRAY') ) {
			foreach my $dir (@{$dirs}) {
				my ($p) = APPRIS::Utils::File::prepare_workspace($path.'/'.$dir);
				throw('Creating directory') unless ( defined $p );
			}		
		}
		elsif ( UNIVERSAL::isa($dirs,'SCALAR') || UNIVERSAL::isa($dirs,'REF') ) {
			my ($p) = APPRIS::Utils::File::prepare_workspace($path.'/'.$dirs);
			throw('Creating directory') unless ( defined $p );
		}
		else {
			my ($p) = APPRIS::Utils::File::prepare_workspace($path);
			throw('Creating directory') unless ( defined $p );			
		}		
	};
	throw('Argument must be a correct') if ($@);
	return $path;		
}

=head2 exists

  Arg [1]    : string $cont
               Content that will insert into index file
  Example    : use APPRIS::Utils::WSpace;
               $id = $ticket->exists();
  Description: Says if ticket exists
  Returntype : boolean 
  Exceptions : thrown every time

=cut

sub exists
{
	my ($self, $cont) = @_;
	my ($exist) = 0;
	
	if ( defined $cont ) {
		my ($i) = APPRIS::Utils::File::getStringFromFile($self->{index});
		if ( defined $i and ($i =~ /$cont/) ) {
			$exist = 1;
		}
	}
	return $exist;
}

=head2 add_index

  Arg [1]    : string $cont
               Content that will insert into index file
  Example    : use APPRIS::Utils::WSpace;
               $id = $ticket->add_index();
  Description: Insert the filename and ticket_id into index file.
  Returntype : boolean 
  Exceptions : thrown every time

=cut

sub add_index
{
	my ($self, $cont) = @_;
	my $ok = 1;
	
	if ( defined $cont ) {
		my ($p) = APPRIS::Utils::File::updateStringIntoLockFile($cont,$self->{index});
		throw('Updating index file') unless ( defined $p );
	}
	return $ok;
}

sub DESTROY {}

1;
