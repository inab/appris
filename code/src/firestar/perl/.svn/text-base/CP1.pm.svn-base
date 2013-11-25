package CP1;

sub new{
	#use Net::SCP;
	my ($class,%args)=@_;
	my $this={};
	bless($this);
	return($this);
}

sub CPCopy($)
{
	use File::Basename;
	
	my ($class,%args)=@_;
	my $source=$args{"source"};
	my $destination=$args{"destination"};
	
	eval {
		system("cp -rp $source $destination");
	};
	return undef if ($@);
}
sub SSHExecute($$)
{
	#use Net::SSH qw(sshopen2);
	my ($class,%args)=@_;
	my $user=$args{"user"};
	my $host=$args{"host"};
	my $cmd=$args{"cmd"};
	my $name=$args{"name"};
	my $file_cmd=$args{"file_cmd"};
	my $queue_output=$args{"output"};
	if($file_cmd){
		#$cmd="source /etc/profile >&/dev/null && qsub -N $name $file_cmd && rm $file_cmd";
		$cmd="qsub -N $name $file_cmd";
	}else{
		$cmd = "source /etc/profile  >&/dev/null && echo \"$cmd\" | qsub -q normal -N $name -o $queue_output";
	}
	
	eval {
		system("$cmd");
	};
	return undef if ($@);
	
	return ();
}

1;
