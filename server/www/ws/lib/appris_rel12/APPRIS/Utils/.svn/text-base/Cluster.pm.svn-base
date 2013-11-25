=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Utils::Cluster - Object to run a job into queue system

=head1 SYNOPSIS

  # Encapsulated class data
  #___________________________________________________________
  my %_attr_data = # DEFAULT
		(
			q_system			=>  undef,
			q_bin_dir			=>  undef,
			q_script			=>  undef,
			q_prefix			=>  'sh',
			q_submit			=>  'qsub',
			q_status			=>  'qstatus',
			q_select			=>  'qselect',
			q_delete			=>  'qdel',
		);
  #_____________________________________________________________
    
  my $cluster = APPRIS::Utils::Cluster->new(
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

package APPRIS::Utils::Cluster;

use strict;
use warnings;

use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);

# see at the end of file
use vars qw(
	$QUEUE_BIN_DIR_SGE
	$QUEUE_BIN_DIR_PBS

	$SGE_TEMPLATE
	$PBS_TEMPLATE
);

{
    # Encapsulated class data
    #___________________________________________________________
    my %_attr_data = # DEFAULT
		(
			q_system			=>  undef,
			q_bin_dir			=>  '',
			q_script			=>  undef,
			q_prefix			=>  'sh',
			q_submit			=>  'qsub',
			q_status			=>  'qstat',
			q_select			=>  'qselect',
			q_delete			=>  'qdel',			
			q_name				=>  'normal',
			p_name				=>  'inb_project',			
			j_name				=>  'test',
			j_stdout			=>  '/dev/null',
			j_stderr			=>  '/dev/null',
			j_script			=>  undef
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
		$q_system,			$q_name,
		$p_name,
		$j_name,			$j_stdout,
		$j_stderr,			$j_script
	)
	= rearrange( [
		'q_system',			'q_name',				
		'p_name',
		'j_name',			'j_stdout',
		'j_stderr',			'j_script'
	],
	@_
	);

	if ( $q_system eq 'sge') {
		$self->q_system($q_system);
		#$self->q_bin_dir($QUEUE_BIN_DIR_SGE);
		$self->q_script($SGE_TEMPLATE);
	}
	elsif ( $q_system eq 'pbs' ) {
		$self->q_system($q_system);
		#$self->q_bin_dir($QUEUE_BIN_DIR_PBS);
		$self->q_script($PBS_TEMPLATE);		
	}
	else {
		return undef;
	}
	if (defined $q_name) { $self->q_name($q_name); }
	else { $self->q_name($self->{'q_name'}); }
	if (defined $p_name) { $self->p_name($p_name); }
	else { $self->p_name($self->{'p_name'}); }
	if (defined $j_name) { $self->j_name($j_name); }
	else { $self->j_name($self->{'j_name'}); }

	$self->j_stdout($j_stdout) if (defined $j_stdout);
	$self->j_stderr($j_stderr) if (defined $j_stderr);
	$self->j_script($j_script) if (defined $j_script);
	
	# if we need the absolute path to execute queue commands
	if ( defined $self->q_bin_dir and ($self->q_bin_dir ne '') ) {
		$self->q_submit($self->q_bin_dir.'/'.$self->q_submit);
		$self->q_status($self->q_bin_dir.'/'.$self->q_status);
		$self->q_select($self->q_bin_dir.'/'.$self->q_select);
		$self->q_select($self->q_bin_dir.'/'.$self->q_select);
	}
	
	return $self;
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

=head2 q_prefix

  Arg [1]    : (optional) String - the prefix of bash script to set
  Example    : $analysis->q_prefix($prefix);
  Description: Getter/setter for the prefix of bash script 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub q_prefix {
	my ($self) = shift;
	$self->{'q_prefix'} = shift if(@_);
	return $self->{'q_prefix'};
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


=head2 get_num_jobs

  Arg [1]    : (optional) String - job name
  Example    : $analysis->get_num_jobs($j_name);
  Description: Get the number of processes that are runnning 
               from a given jobname
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub get_num_jobs {
	my ($self) = shift;
	my ($j_name) = shift if(@_);
	my ($q_system) = $self->{'q_system'};
	my ($q_status) = $self->{'q_status'};
	my ($q_select) = $self->{'q_select'};
	my ($num) = -1;
	
	if ( $q_system eq 'sge') {
		my (@num_stdout_list) = `$q_status | grep -c $j_name`;
		if ( scalar(@num_stdout_list) > 0 ) {
			my ($num_stdout) = $num_stdout_list[0];
			if ( $num_stdout =~ /(\d*)/ ){
				$num = $1;
			}
		}	
	}
	elsif ( $q_system eq 'pbs' ) {
		my (@num_stdout_list) = `$q_select -N $j_name | grep -c .vader`;
		if ( scalar(@num_stdout_list) > 0 ) {
			my ($num_stdout) = $num_stdout_list[0];
			if ( $num_stdout =~ /(\d*)/ ) {
				$num = $1;
			}
		}
	}
	return $num;
}

=head2 submit

  Arg [1]    : (optional) String - file of bash script of job to submit
  Example    : $analysis->submit($q_script);
  Description: Submit the bash script into queue system 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub submit {
	my ($self) = shift;
	my ($j_id) = undef;
	if (@_) {
		my ($q_file) = shift;
		my ($q_submit) = $self->{'q_submit'};
		eval {
			sleep(1);
			my ($cmd) = "$q_submit < $q_file";
			my (@num_stdout_list) = `$cmd`;
			my ($num_stdout) = $num_stdout_list[0];
			if ( $num_stdout =~ /Your job (\d*) \("[^\"]*"\) has been submitted/ ) {
				$j_id = $1;
			}
		};
		return undef if($@);
	}
	return $j_id;
}

sub DESTROY {}

$QUEUE_BIN_DIR_SGE='/opt/gridengine/bin/lx24-amd64/';
$QUEUE_BIN_DIR_PBS='/opt/pbs/default/bin/';

$SGE_TEMPLATE=<<SGE_TEMPLATE;
#!/bin/bash

# Job name
#\$ \-N  __JOB__NAME__

# Project name
#\$ \-P __PROJ__NAME__

# Type of queue
#\$ \-q __QUEUE__NAME__

# Stdout file
#\$ \-o  __STDOUT__FILE__

# Stderr file
#\$ \-e  __STDERR__FILE__

# The job is located in the current
# working directory.
#\$ \-cwd

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
