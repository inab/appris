package Ubio::Utils::SSH;
require Exporter;

sub new{
	use Net::SCP;
	my ($class,%args)=@_;
	my $this={};
	bless($this);
	return($this);
}

sub SSHCopy($)
{
	use File::Basename;
	
	my ($class,%args)=@_;
	my $source=$args{"source"};
	my $destination=$args{"destination"};
	my $hostname=$args{"host"} || "caton";
	
	$username="firedb";
	$destination=$username . "@" . $hostname . ":$destination" ;
	$scp = Net::SCP->new( { "host"=>$hostname, "user"=>$username } );
#	print "$source -> $destination\n";
	$scp->scp( $source, $destination);
	return();
	
return undef if ($scp->{errstr});
}
sub SSHExecute($$)
{
	use Net::SSH qw(sshopen2);
	my ($class,%args)=@_;
	my $user=$args{"user"};
	my $host=$args{"host"};
	my $cmd=$args{"cmd"};
	my $name=$args{"name"};
	my $file_cmd=$args{"file_cmd"};
	my $queue_output=$args{"output"};
	if($file_cmd){

		#$cmd="/opt/gridengine/bin/lx24-amd64/qsub -N $name -M eandres\@cnio.es -m bea $file_cmd && rm $file_cmd";
		#$cmd="source /etc/profile >&/dev/null && source /home/eandres/.bash_profile >& /dev/null && qsub -N $name -M eandres\@cnio.es -m bea $file_cmd && rm $file_cmd";
		$cmd="source /etc/profile >&/dev/null && qsub -N $name $file_cmd && rm $file_cmd";
	#	print "***";
	#	print "$cmd\n";
	}else{
		#$cmd = "source ~/.bashrc && echo \"$cmd\" |/opt/gridengine/bin/lx24-amd64/qsub -q normal -N $name -M eandres\@cnio.es -m bea";
		#$cmd = "source /etc/profile  >&/dev/null && source /home/eandres/.bash_profile >& /dev/null && echo \"$cmd\" |qsub -q normal -N $name -o $queue_output -M eandres\@cnio.es -m bea";
		$cmd = "source /etc/profile  >&/dev/null && echo \"$cmd\" | qsub -q normal -N $name -o $queue_output";
		
	#		print $cmd ."\n";
	}

#	print "$user\@$host\n$cmd\n";
	sshopen2("$user\@$host", *READER, *WRITER, "$cmd") || die "ssh: $!";
	         while (<READER>) {
             chomp();
             print STDERR "$_\n";
         }
	close(READER);
	close(WRITER);
	return();
}
1;
