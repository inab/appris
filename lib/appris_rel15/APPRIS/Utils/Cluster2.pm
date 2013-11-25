=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

Cluster - Object to run a job into queue system

=head1 SYNOPSIS

  # Encapsulated class data
  #___________________________________________________________
  my %_attr_data = # DEFAULT
		(
			q_system			=>  undef,
			q_bin_dir			=>  undef,
			q_script			=>  undef,
			q_submit			=>  'qsub',
			q_status			=>  'qstatus',
			q_select			=>  'qselect',
			q_delete			=>  'qdel',
		);
  #_____________________________________________________________
    
  my $cluster = Cluster->new(
			-q_system	=>  <Queue System>,
			-q_name		=>  <Name of queue>,
			-p_name		=>  <Name of project>,
			-j_name		=>  <Name of job to run>,
			-j_stdout	=>  <The stdout file of job>,
			-j_stderr	=>  <The stderr file of job>,
			-j_script	=>  <The scripts of job>
  );


=head1 DESCRIPTION

Object to run jobs within queue system.

=head1 METHODS

=cut

package APPRIS::Utils::Cluster2;

use strict;
use warnings;

use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);

# see at the end of file
use vars qw(
	$SGE_TEMPLATE
	$PBS_TEMPLATE
);

{
    # Encapsulated class data
    #___________________________________________________________
    my %_attr_data = # DEFAULT
		(
			host				=>  undef,
			user				=>  undef,
			wspace				=>  '/tmp',
			q_system			=>  undef,
			q_settings			=>  undef,
			q_bin_dir			=>  undef,
			q_submit			=>  'qsub',
			q_status			=>  'qstat',
			q_select			=>  'qselect',
			q_delete			=>  'qdel',			
			q_script			=>  undef,
			q_name				=>  'normal',
			p_name				=>  'inb_project',			
			j_num				=>  undef,
			j_name				=>  'test',
			j_script			=>  undef,
			j_stdout			=>  '/dev/null',
			j_stderr			=>  '/dev/null',
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
	
	# Substitute values within template
	sub _subs_template {
		my ($self, $old, $new) = @_;
		my ($q_script) = $self->{'q_script'};
		$q_script =~ s/$old/$new/g;		
		$self->{'q_script'} = $q_script;		
	}
}

=head2 new

  Arg [-q_system]:
        string - the queue system
  Arg [-q_name]: (optional)
        string - the name of queue
  Arg [-p_name]: (optional)
        string - the name of project
  Arg [-j_name]: (optional)
        string - the name of job to run
  Arg [-j_stdout]: (optional)
        string - the stdout file of job
  Arg [-j_stderr]: (optional)
        string - the stderr file of job
  Arg [-j_script]: (optional)
        string - the scripts of job
  Example    : $analysis = APPRIS::Utils::Cluster->new(...);
  Description: Creates a new analysis object
  Returntype : APPRIS::Utils::Cluster
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

	foreach my $attrname ($self->_standard_keys) {
		$self->{$attrname} = $self->_default_for($attrname);
	}

	my (
		$host,				$user,				$wspace,
		$q_system,			$q_bin_dir,			$q_settings,					
		$q_name,			$q_script,
		$j_num,
		$p_name,			$j_name,			$j_script,
		$j_stdout,			$j_stderr,
	)
	= rearrange( [
		'host',				'user',				'wspace',
		'q_system',			'q_bin_dir',		'q_settings',
		'q_name',			'q_script',
		'j_num',
		'p_name',			'j_name',			'j_script',
		'j_stdout',			'j_stderr',
	],
	@_
	);
	return undef unless (
		defined $host and
		defined $user and
		defined $wspace and
		defined $q_system and
		defined $q_bin_dir and
		defined $q_settings 
	);
	$self->host($host);
	$self->user($user);
	$self->wspace($wspace);
	
	$self->q_system($q_system);
	$self->q_settings($q_settings);
	$self->q_bin_dir($q_bin_dir);
	
	if ( defined $q_script ) {
		$self->q_script($q_script)
	}
	else {
		if ( $q_system eq 'sge') { $self->q_script($SGE_TEMPLATE); }
		elsif ( $q_system eq 'pbs' ) { $self->q_script($PBS_TEMPLATE); }
		else { return undef; }		
	}
	
	$self->q_name($q_name) if (defined $q_name);
	$self->p_name($p_name) if (defined $p_name);
	$self->j_num($j_num) if (defined $j_num);
	$self->j_name($j_name) if (defined $j_name);
	$self->j_script($j_script) if (defined $j_script);
	$self->j_stdout($j_stdout) if (defined $j_stdout);
	$self->j_stderr($j_stderr) if (defined $j_stderr);
	
	# if we need the absolute path to execute queue commands
	if ( defined $self->q_bin_dir and ($self->q_bin_dir ne '') ) {
		$self->q_submit($self->q_bin_dir.'/'.$self->q_submit);
		$self->q_status($self->q_bin_dir.'/'.$self->q_status);
		$self->q_select($self->q_bin_dir.'/'.$self->q_select);
		$self->q_delete($self->q_bin_dir.'/'.$self->q_delete);
	}
	
	return $self;
}

=head2 host

  Arg [1]    : (optional) String - the host name of the cluster
  Example    : $analysis->host($name);
  Description: Getter/setter for the host name of the cluster
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub host {
	my ($self) = shift;
	$self->{'host'} = shift if(@_);
	return $self->{'host'};
}

=head2 user

  Arg [1]    : (optional) String - the user name of the cluster
  Example    : $analysis->user($user);
  Description: Getter/setter for the user name of the cluster
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub user {
	my ($self) = shift;
	$self->{'user'} = shift if(@_);
	return $self->{'user'};
}

=head2 wspace

  Arg [1]    : (optional) String - the num of allowed jobs
  Example    : $analysis->wspace($num);
  Description: Getter/setter for the num of allowed jobs 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub wspace {
	my ($self) = shift;
	$self->{'wspace'} = shift if(@_);
	return $self->{'wspace'};
}

=head2 q_system

  Arg [1]    : (optional) String - the queue system to set
  Example    : $analysis->q_system($system);
  Description: Getter/setter for the system of queue
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub q_system {
	my ($self) = shift;
	$self->{'q_system'} = shift if(@_);
	return $self->{'q_system'};
}

=head2 q_settings

  Arg [1]    : (optional) String - the file settings of queue system
  Example    : $analysis->q_settings($system);
  Description: Getter/setter for the file setting of queue system
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub q_settings {
	my ($self) = shift;
	$self->{'q_settings'} = shift if(@_);
	return $self->{'q_settings'};
}

=head2 q_bin_dir

  Arg [1]    : (optional) String - the dir of queue binaries to set
  Example    : $analysis->q_bin_dir($dir);
  Description: Getter/setter for the dir of queue binaries
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub q_bin_dir {
	my ($self) = shift;
	$self->{'q_bin_dir'} = shift if(@_);
	return $self->{'q_bin_dir'};
}

=head2 q_script

  Arg [1]    : (optional) String - the bash script of queue to set
  Example    : $analysis->q_script($script);
  Description: Getter/setter for the bash script of queue
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub q_script {
	my ($self) = shift;
	$self->{'q_script'} = shift if(@_);
	return $self->{'q_script'};
}

=head2 q_submit

  Arg [1]    : (optional) String - the command of queue to set
  Example    : $analysis->q_submit($command);
  Description: Getter/setter for the command of queue 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub q_submit {
	my ($self) = shift;
	$self->{'q_submit'} = shift if(@_);
	return $self->{'q_submit'};
}

=head2 q_status

  Arg [1]    : (optional) String - the command of queue to set
  Example    : $analysis->q_status($command);
  Description: Getter/setter for the command of queue 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub q_status {
	my ($self) = shift;
	$self->{'q_status'} = shift if(@_);
	return $self->{'q_status'};
}

=head2 q_select

  Arg [1]    : (optional) String - the command of queue to set
  Example    : $analysis->q_select($command);
  Description: Getter/setter for the command of queue 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub q_select {
	my ($self) = shift;
	$self->{'q_select'} = shift if(@_);
	return $self->{'q_select'};
}

=head2 q_delete

  Arg [1]    : (optional) String - the command of queue to set
  Example    : $analysis->q_delete($command);
  Description: Getter/setter for the command of queue 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub q_delete {
	my ($self) = shift;
	$self->{'q_delete'} = shift if(@_);
	return $self->{'q_delete'};
}

=head2 q_name

  Arg [1]    : (optional) String - the name of queue to set
  Example    : $analysis->q_name($type);
  Description: Getter/setter for the name of queue 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub q_name {
	my ($self) = shift;
	if (@_) {
		$self->{'q_name'} = shift;
		$self->_subs_template('__QUEUE__NAME__', $self->{'q_name'});
	}
	return $self->{'q_name'};
}

=head2 p_name

  Arg [1]    : (optional) String - the name of project
  Example    : $analysis->p_name($name);
  Description: Getter/setter for the name of project 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub p_name {
	my ($self) = shift;
	if (@_) {
		$self->{'p_name'} = shift;
		$self->_subs_template('__PROJ__NAME__', $self->{'p_name'});		
	}	
	return $self->{'p_name'};
}

=head2 j_num

  Arg [1]    : (optional) String - the num of allowed jobs
  Example    : $analysis->j_num($num);
  Description: Getter/setter for the num of allowed jobs 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub j_num {
	my ($self) = shift;
	$self->{'j_num'} = shift if(@_);
	return $self->{'j_num'};
}

=head2 j_name

  Arg [1]    : (optional) String - the name of job to set
  Example    : $analysis->j_name($name);
  Description: Getter/setter for the name of job 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub j_name {
	my ($self) = shift;
	if (@_) {
		$self->{'j_name'} = shift;
		$self->_subs_template('__JOB__NAME__', $self->{'j_name'});
	}
	return $self->{'j_name'};
}

=head2 j_script

  Arg [1]    : (optional) String - the scripts of job to set
  Example    : $analysis->j_script($file);
  Description: Getter/setter for the scripts file of job 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub j_script {
	my ($self) = shift;
	if (@_) {
		$self->{'j_script'} = shift;
		$self->_subs_template('__JOB__SCRIPTS__', $self->{'j_script'});
	}
	return $self->{'j_script'};
}

=head2 j_wdir

  Arg [1]    : (optional) String - the working dir of job to set
  Example    : $analysis->j_wdir($file);
  Description: Getter/setter for the working dir of job 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub j_wdir {
	my ($self) = shift;
	if (@_) {
		$self->{'j_wdir'} = shift;
		$self->_subs_template('__WORKING__DIR__', $self->{'j_wdir'});
	}
	return $self->{'j_wdir'};
}

=head2 j_stdout

  Arg [1]    : (optional) String - the stdout file of job to set
  Example    : $analysis->j_stdout($file);
  Description: Getter/setter for the stdout file of job 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub j_stdout {
	my ($self) = shift;
	if (@_) {
		$self->{'j_stdout'} = shift;
		$self->_subs_template('__STDOUT__FILE__', $self->{'j_stdout'});
	}
	return $self->{'j_stdout'};
}

=head2 j_stderr

  Arg [1]    : (optional) String - the stderr file of job to set
  Example    : $analysis->j_stderr($file);
  Description: Getter/setter for the stderr file of job 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub j_stderr {
	my ($self) = shift;
	if (@_) {
		$self->{'j_stderr'} = shift;
		$self->_subs_template('__STDERR__FILE__', $self->{'j_stderr'});
	}
	return $self->{'j_stderr'};
}


sub DESTROY {}

$SGE_TEMPLATE=<<SGE_TEMPLATE;
#!/bin/bash

# Job name
#\$ \-N  __JOB__NAME__

# Project name
#\$ \-P __PROJ__NAME__

# Type of queue
#\$ \-q __QUEUE__NAME__

# Working directory.
#\$ \-wd __WORKING__DIR__ 

# Stdout file
#\$ \-o  __STDOUT__FILE__

# Stderr file
#\$ \-e  __STDERR__FILE__

__JOB__SCRIPTS__

SGE_TEMPLATE

$PBS_TEMPLATE=<<PBS_TEMPLATE;
#!/bin/bash

# Job name
#PBS \-N  __JOB__NAME__

# Project name
#PBS \-P  __PROJ__NAME__

# Type of queue
#PBS \-q __QUEUE__NAME__

# Stdout file
#PBS \-o __STDOUT__FILE__

# Stderr file
#PBS \-e __STDERR__FILE__

__JOB__SCRIPTS__

PBS_TEMPLATE

1;