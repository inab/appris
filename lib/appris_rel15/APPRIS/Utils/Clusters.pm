=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Utils::Clusters - Object to run a job into queue system

=head1 SYNOPSIS

  my $cluster = APPRIS::Utils::Clusters->new( -conf => <Config ini file> );

=head1 DESCRIPTION

Object to run jobs within queue system.

=head1 METHODS

=cut

package APPRIS::Utils::Clusters;

use strict;
use warnings;
use Config::IniFiles;
use File::Basename;

use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);

use vars qw(
	$NUM_TIMES
);

$NUM_TIMES	= 4;

{
    # Encapsulated class data
    #___________________________________________________________
    my %_attr_data = # DEFAULT
		(
			host				=>  undef,
			user				=>  undef,
			wspace				=>  '/tmp',
			clusters			=>  undef,
			num_clusters		=>  undef,
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
}

=head2 new

  Arg [-conf]: String - file path of config ini
  Example    : $analysis = APPRIS::Utils::Clusters->new(...);
  Description: Creates a new analysis object
  Returntype : APPRIS::Utils::Clusters
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub new {
	my ($caller) = shift;
	
	# class
	my ($caller_is_obj) = ref($caller);
	return $caller if $caller_is_obj;
	my ($class) = $caller_is_obj || $caller;
	my ($self) = bless {}, $class;
	
	foreach my $attrname ($self->_standard_keys) {
		$self->{$attrname} = $self->_default_for($attrname);
	}	
	
	# config parameter
	my ($conf) = rearrange( ['conf'], @_ );
	return undef unless ( defined $conf );	
	my ($cfg) = new Config::IniFiles(-file => $conf);
	
	# create local configuration
	my ($l_host) = $cfg->val('LOCAL_SERVER', 'host');
	return undef unless ( defined $l_host and ($l_host ne '') );
	$self->host($l_host);
	my ($l_user) = $cfg->val('LOCAL_SERVER', 'user');
	return undef unless ( defined $l_user and ($l_user ne '') );
	$self->user($l_user);

	# create cluster configuration
	my ($clusters);
	my ($num_clusters) = $cfg->val('CLUSTER_SERVER', 'num_clusters');
	return undef unless ( defined $num_clusters and ($num_clusters ne '') );
	for ( my $i=1; $i <= $num_clusters; $i++ ) {
		my ($cluster_id)	= 'CLUSTER_SERVER'.'_'.$i;
		my ($c_host)		= $cfg->val($cluster_id, 'host') || return undef; # required		
		my ($c_user)		= $cfg->val($cluster_id, 'user') || return undef; # required
		my ($c_wspace)		= $cfg->val($cluster_id, 'wspace') || return undef; # required
		my ($q_system)		= $cfg->val($cluster_id, 'q_system') || return undef; # required
		my ($q_settings)	= $cfg->val($cluster_id, 'q_settings') || return undef; # required
		my ($q_bin_dir)		= $cfg->val($cluster_id, 'q_bin_dir') || return undef; # required
		my ($q_name)		= $cfg->val($cluster_id, 'q_name') || return undef; # required		
		my ($q_submit)		= $cfg->val($cluster_id, 'q_submit') || 'qsub';
		my ($q_status)		= $cfg->val($cluster_id, 'q_status') || 'qstat';
		my ($q_select)		= $cfg->val($cluster_id, 'q_select') || 'qselect';
		my ($q_delete)		= $cfg->val($cluster_id, 'q_delete') || 'qdel';
		my ($j_num)			= $cfg->val($cluster_id, 'j_num') || 20;
		my ($j_name)		= $cfg->val($cluster_id, 'j_name') || undef;
		my ($j_home)		= $cfg->val($cluster_id, 'j_home') || undef;
		my ($p_name)		= $cfg->val($cluster_id, 'p_name') || undef;
		
		my ($cluster) = new Cluster(
							-host			=> $c_host,
							-user			=> $c_user,
							-wspace			=> $c_wspace,
							-q_system		=> $q_system,
							-q_settings		=> $q_settings,
							-q_bin_dir		=> $q_bin_dir,
							-q_submit		=> $q_submit,
							-q_status		=> $q_status,
							-q_select		=> $q_select,
							-q_delete		=> $q_delete,
							-q_name			=> $q_name,
							-j_num			=> $j_num
		);
		$cluster->j_name($j_name) if (defined $j_name);
		$cluster->j_home($j_home) if (defined $j_home);
		$cluster->p_name($p_name) if (defined $p_name);		
		$clusters->{$c_host} = $cluster;
	}	
	if ( defined $clusters ) {
		$self->clusters($clusters);
		$self->num_clusters( scalar(keys %{$clusters}) );
	}
	else {
		return undef;
	}
		
	return $self;
}

=head2 host

  Arg [1]    : (optional) String - host name of local server
  Example    : $analysis->host($name);
  Description: Getter/setter for the host name of local server
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

  Arg [1]    : (optional) String - user name of local server
  Example    : $analysis->user($name);
  Description: Getter/setter for the user name of local server
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

=head2 clusters

  Arg [1]    : (optional) List - the list of defined cluster
  Example    : $analysis->clusters($list);
  Description: Getter/setter for the list of defined cluster
  Returntype : List of hash that describes several cluster
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub clusters {
	my ($self) = shift;
	$self->{'clusters'} = shift if(@_);
	return $self->{'clusters'};
}

=head2 cluster

  Arg [1]    : String - host name of cluster
  Example    : $analysis->cluster($list);
  Description: Getter for the cluster
  Returntype : Cluster object
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub cluster {
	my ($self) = shift;
	my ($host) = shift if(@_);
	my ($cluster) = undef;
	if ( defined $host and 
		exists $self->{'clusters'}->{$host} and 
		defined $self->{'clusters'}->{$host}
	) {
		$cluster = $self->{'clusters'}->{$host};
	}
	return $cluster;
}

=head2 num_clusters

  Arg [1]    : (optional) String - the num of clusters
  Example    : $analysis->num_clusters($num);
  Description: Getter/setter for the num of clusters
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub num_clusters {
	my ($self) = shift;
	$self->{'num_clusters'} = shift if(@_);
	return $self->{'num_clusters'};
}

=head2 get_num_jobs

  Arg [1]    : String - host name
  Arg [2]    : (optional) String - job name
  Example    : $analysis->get_num_jobs($host);
  Description: Get the number of processes that are runnning 
               in a cluster(host). 
               If job name is given, reports the number of jobs.
               Unless, reports the number of jobs running by cluster user.
  Returntype : String number, -1 if something wrong 
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub get_num_jobs {
	my ($self) = shift;
	my ($host) = shift if(@_);
	my ($j_name) = shift if(@_);
	my ($num) = -1;
	
	if ( defined $host and 
		exists $self->{'clusters'}->{$host} and 
		defined $self->{'clusters'}->{$host}
	) {
		my ($cluster) = $self->{'clusters'}->{$host};
		my ($user) = $cluster->user;
		my ($q_system) = $cluster->q_system;
		my ($q_settings) = $cluster->q_settings;		
		my ($q_status) = $cluster->q_status;
		my ($q_select) = $cluster->q_select;
		$j_name = $user unless ( defined $j_name ); # for cluster user
		my ($cmd) = undef;
	 	if ( $q_system eq 'sge' ) {	 		
			$cmd = "ssh $user\@$host '. $q_settings && $q_status | grep -c $j_name'";
		}
		elsif ( $q_system eq 'pbs' ) {
			$cmd = "ssh $user\@$host '$q_select -N $j_name | grep -c .vader'";
		}
		if ( defined $cmd ) {
			eval {
				my (@num_stdout_list) = `$cmd`;
				if ( scalar(@num_stdout_list) > 0 ) {
					my ($num_stdout) = $num_stdout_list[0];
					if ( $num_stdout =~ /(\d*)/ ) {
						$num = $1;
					}
				}
			};
			return undef if ($@);			
		}	
	}
	return $num;
}

=head2 free

  Example    : $analysis->free();
  Description: Get the cluster that is free
  Returntype : String 
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub free {
	my ($self) = shift;
	my ($host) = undef;
		
	while ( my ($c_host,$cluster) = each(%{$self->{'clusters'}}) ) {
		my ($j_num) = $cluster->j_num;
		my ($j_name) = $cluster->j_name;
		my ($num) = $self->get_num_jobs($c_host,$j_name);
		if ( $num < $j_num ) {
			$host = $c_host;
			last;	
		}
	}
	return $host;
}

=head2 wspace

  Arg [1]    : String - host name of cluster
  Arg [2]    : (optional) String - the workspace of cluster
  Example    : $analysis->wspace($path);
  Description: Getter/setter for the workspace of cluster 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub wspace {
	my ($self) = shift;
	my ($host) = shift if(@_);
	my ($ws) = shift if(@_);
	
	if ( defined $host and
		exists $self->{'clusters'}->{$host} and 
		defined $self->{'clusters'}->{$host}
	) {
		my ($cluster) = $self->{'clusters'}->{$host};
		if ( defined $ws ) {
			$ws = $cluster->wspace($ws);
		}
		else {
			$ws = $cluster->wspace;
		}
	}
	return $ws;
}

=head2 script

  Arg [1]    : String - host name of cluster
  Arg [2]    : Hash   - configuration of job script
  Example    : $analysis->script($file);
  Description: Getter/setter for the job script of cluster 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub script {
	my ($self) = shift;
	my ($host) = shift if(@_);
	my ($q_script) = shift if(@_);
	my ($script) = undef;
	
	if ( defined $host and
		exists $self->{'clusters'}->{$host} and 
		defined $self->{'clusters'}->{$host}
	) {
		my ($cluster) = $self->{'clusters'}->{$host};
		if ( defined $q_script ) {
			$cluster->p_name($q_script->{'p_name'}) if (exists $q_script->{'p_name'});
			$cluster->j_name($q_script->{'name'}) if (exists $q_script->{'name'});
			$cluster->j_wdir($q_script->{'wdir'}) if (exists $q_script->{'wdir'});
			$cluster->j_stdout($q_script->{'stdout'}) if (exists $q_script->{'stdout'});
			$cluster->j_stderr($q_script->{'stderr'}) if (exists $q_script->{'stderr'});
			$cluster->j_script($q_script->{'script'}) if (exists $q_script->{'script'});
		}
		$script = $cluster->q_script;
	}
	return $script;
}

=head2 smkdir

  Arg [1]    : String - host name of cluster
  Arg [2]    : String - dir name  
  Example    : $analysis->submit($host,$dir);
  Description: Create a directory into cluster 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub smkdir {
	my ($self, $host, $dir) = @_;
	my ($wsdir) = undef;
	
	if ( defined $host and
		defined $dir and
		exists $self->{'clusters'}->{$host} and 
		defined $self->{'clusters'}->{$host}
	) {
		my ($cluster) = $self->{'clusters'}->{$host};
		my ($user) = $cluster->user;
		$wsdir = $dir;
		my ($cmd) = "ssh $user\@$host 'mkdir -p $wsdir'";
#print STDERR "CMD: $cmd\n";
		eval {
			system($cmd);
		};
		return undef if ($@);		
	}
	return $wsdir;
}

=head2 dscopy

  Arg [1]    : String - host name of cluster
  Arg [2]    : String - dir name of cluster
  Arg [3]    : String - dir name of host
  Example    : $analysis->dscopy($host,$dest,$orig);
  Description: Submit the bash script into queue system 
  Returntype : String, new cluster dir
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub dscopy {
	my ($self, $host, $dest, $orig) = @_;
	my ($wsdir) = undef;
	
	if ( defined $host and
		defined $orig and
		exists $self->{'clusters'}->{$host} and 
		defined $self->{'clusters'}->{$host}
	) {
		my ($cluster) = $self->{'clusters'}->{$host};
		my ($user) = $cluster->user;
		my ($wspace) = $cluster->wspace;		
		my ($cmd) = "scp $orig $user\@$host:$dest";
#print STDERR "CMD: $cmd\n";
		eval {
			system($cmd);
		};
		return undef if ($@);
		my (@inpath_n) = split('/', $orig);		
		if ( scalar(@inpath_n) > 0 ) {
			my ($num) = scalar(@inpath_n);
			$wsdir = $wspace.'/'.$inpath_n[$num-1];
		}
	}
	return $wsdir;
}

=head2 scopy

  Arg [1]    : String - host name of cluster
  Arg [2]    : String - dir name of cluster
  Arg [3]    : String - file of host
  Example    : $analysis->submit($host);
  Description: Submit the bash script into queue system 
  Returntype : String, new cluster file
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub scopy {
	my ($self, $host, $dest, $orig) = @_;
	my ($wsfile) = undef;
	
	if ( defined $host and
		defined $orig and
		exists $self->{'clusters'}->{$host} and 
		defined $self->{'clusters'}->{$host}
	) {
		my ($cluster) = $self->{'clusters'}->{$host};
		my ($user) = $cluster->user;
		my ($wspace) = $cluster->wspace;		
		my ($cmd) = "scp $orig $user\@$host:$dest";
#print STDERR "CMD: $cmd\n";
		eval {
			system($cmd);
		};
		return undef if ($@);		
		my ($name, $path, $suffix) = fileparse($orig);
		$wsfile = $wspace.'/'.$name;		
	}
	return $wsfile;
}

=head2 submit

  Arg [1]    : String - host name of cluster
  Arg [2]    : (optional) String - workspace of cluster  
  Example    : $analysis->submit($host);
  Description: Submit the bash script into queue system 
  Returntype : String, the Job ID
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub submit {
	my ($self, $host, $file) = @_;
	my ($j_id) = -1;
	my ($num) = 1;	
	
	if ( defined $host and
		defined $file and
		exists $self->{'clusters'}->{$host} and 
		defined $self->{'clusters'}->{$host}
	) {
		my ($cluster) = $self->{'clusters'}->{$host};
		my ($user) = $cluster->user;
		my ($wspace) = $cluster->wspace;		
		my ($c_mkdir) = $self->smkdir($host, $wspace);
		my ($j_file) = $self->scopy($host, $wspace, $file);
		my ($q_settings) = $cluster->q_settings;		
		my ($q_submit) = $cluster->q_submit;
		do {
			my ($cmd) = "ssh $user\@$host '. $q_settings && $q_submit < $j_file'";
			eval {
				my (@num_stdout_list) = `$cmd`;
				my ($num_stdout) = $num_stdout_list[0];
				if ( $num_stdout =~ /Your job (\d*) \("[^\"]*"\) has been submitted/ ) {
					$j_id = $1;
				}
			};
			$j_id = -1 if ($@);
			$num++;
		} while ( ($num <= $NUM_TIMES) and ($j_id == -1) );
	}
	return $j_id;
}

=head2 local_submit

  Arg [1]    : String - host name of cluster
  Arg [2]    : (optional) String - workspace of cluster  
  Example    : $analysis->submit($host);
  Description: Submit the bash script into queue system 
  Returntype : String, the Job ID
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub local_submit {
	my ($self, $host, $file) = @_;
	my ($j_id) = -1;
	my ($num) = 1;	
	
	if ( defined $host and
		defined $file and
		exists $self->{'clusters'}->{$host} and 
		defined $self->{'clusters'}->{$host}
	) {
		my ($cluster) = $self->{'clusters'}->{$host};
		my ($q_settings) = $cluster->q_settings;		
		my ($q_submit) = $cluster->q_submit;
		do {
			my ($cmd) = ". $q_settings && $q_submit < $file";
			eval {
				my (@num_stdout_list) = `$cmd`;
				my ($num_stdout) = $num_stdout_list[0];
				if ( $num_stdout =~ /Your job (\d*) \("[^\"]*"\) has been submitted/ ) {
					$j_id = $1;
				}
			};
			$j_id = -1 if ($@);
			$num++;
		} while ( ($num <= $NUM_TIMES) and ($j_id == -1) );
	}
	return $j_id;
}

sub DESTROY {}

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

package Cluster;

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
		$p_name,			$j_name,			$j_home,
		$j_script,			$j_stdout,			$j_stderr,
	)
	= rearrange( [
		'host',				'user',				'wspace',
		'q_system',			'q_bin_dir',		'q_settings',
		'q_name',			'q_script',
		'j_num',
		'p_name',			'j_name',			'j_home',
		'j_script',			'j_stdout',			'j_stderr',
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
	$self->j_home($j_home) if (defined $j_home);
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

=head2 j_home

  Arg [1]    : (optional) String - the name of job to set
  Example    : $analysis->j_home($name);
  Description: Getter/setter for the name of job 
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : Stable

=cut

sub j_home {
	my ($self) = shift;
	$self->{'j_home'} = shift if(@_);
	return $self->{'j_home'};
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
