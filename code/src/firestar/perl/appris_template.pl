#!/usr/bin/perl

use strict;
use FindBin;
use Config::IniFiles;

my $cwd=$FindBin::Bin;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#		VALORES DE ENTRADA		#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
my $tmpfile=$ARGV[0];
my $evalue=$ARGV[1];
my $target_dir=$ARGV[2];
my $server=$ARGV[3];
my $id=$ARGV[4];
my $conf_file=$ARGV[5];
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my $variables=Config::IniFiles->new(-file => $conf_file);

my $dir=$variables->val('CLUSTER_PATHS','root');
my $DB=$variables->val('CLUSTER_PATHS','DB');
my $release=$variables->val('DATABASES','release');
my $nrdb=$variables->val('DATABASES','nrdb');
my $user=$variables->val('SERVER','user');
$server=$user.'@'.$variables->val('SERVER','srv');
my $hhbdb=$variables->val('DATABASES','hhbdb');
my $queue=$variables->val('CLUSTER_PATHS','ahsoka_queue');
my $hh_nr_db=$variables->val('DATABASES','hhprof');

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
my $psifile="$tmpfile";
my $dir_perl="$dir/Perl";
my $dir_sh="$dir/QSUB_files";
my $hhblits_DB="$DB/$hhbdb".$release."_hhm_db";
my $hh_prof_db="$DB/$hh_nr_db";

file_generator();

system("qsub $dir_sh/$tmpfile\_hhb.sh");
system("qsub $dir_sh/$tmpfile\_psi.sh");
sleep(15);

my $flag="RED";
my $magic_bulletHH="OPEN";
my $magic_bulletPS="OPEN";
my $command='ssh '.$user.'@'.$server.' "';

while ($flag eq "RED"){
	my @var=`qstat -u $user | grep $id`;
	if (scalar@var == 3){
		foreach (@var){
			chomp($_);
			my $number_process=substr($_,0,7);$number_process=~s/\s+//;
			my $string=substr($_,8);
			my @types=split(/\s+/,$string);
			if ($types[3] eq "Eqw"){
				print STDERR "Queue error found with $tmpfile\n";
				`$command qmod -c $number_process"`;
			}
		}		
	}
	elsif (scalar@var == 2){
		foreach (@var){
                	chomp($_);
			my $number_process=substr($_,0,7);$number_process=~s/\s+//;
			my $string=substr($_,8);
			my @process=split(/\s+/,$string);
			if ($process[1] eq "p$id"){
				if (!-e "$dir/$tmpfile.hhr"){
print STDOUT "COND_1: !-e $dir/$tmpfile.hhr\n";
print STDOUT "qsub $dir_sh/$tmpfile\_hhb.sh\n";
					system("qsub $dir_sh/$tmpfile\_hhb.sh");
				}
				elsif(-e "$dir/$tmpfile.hhr" && $magic_bulletHH eq "OPEN"){
print STDOUT "COND_2: -e $dir/$tmpfile.hhr && $magic_bulletHH eq OPEN\n";
print STDOUT "cp $dir/$tmpfile.hhr $target_dir\n";
					#system("scp $dir/$tmpfile.hhr $server:$target_dir");
					system("cp $dir/$tmpfile.hhr $target_dir");
					$magic_bulletHH="CLOSE";
				}
                	}
			elsif ($process[1] eq "h$id"){
				if ( (!-e "$dir/$tmpfile.mtx") or
					(!-e "$dir/$psifile.psi") or
					(!-e "$dir/$tmpfile.chk") ) {
print STDOUT "COND_3: !-e $dir/$tmpfile.mtx\n";
print STDOUT "qsub $dir_sh/$tmpfile\_psi.sh\n";
					system("qsub $dir_sh/$tmpfile\_psi.sh");
				}
				elsif (-e "$dir/$psifile.psi" && $magic_bulletPS eq "OPEN"){
print STDOUT "COND_4: -e $dir/$psifile.psi && $magic_bulletPS eq OPEN\n";
print STDOUT "cp $dir/$psifile.psi $target_dir\n";
					#system("scp $dir/$psifile.psi $server:$target_dir");
					system("cp $dir/$psifile.psi $target_dir");
					$magic_bulletPS="CLOSE";
				}
			}
			if ($process[3] eq "Eqw") {
				print STDERR "Queue error found with $tmpfile\n";
				`$command qmod -c $number_process"`;
			}
		}
	}
	elsif (scalar@var == 1) {
		if (-e "$dir/$tmpfile.mtx" && -e "$dir/$psifile.psi" && -e "$dir/$tmpfile.chk" && -e "$dir/$tmpfile.hhr") {
print STDOUT "COND_5:\n";
print STDOUT "cp $dir/$psifile.psi $dir/$tmpfile.mtx $dir/$tmpfile.chk $dir/$tmpfile.hhr $target_dir\n";
			#system("scp $dir/$psifile.psi $dir/$tmpfile.mtx $dir/$tmpfile.chk $dir/$tmpfile.hhr $server:$target_dir");
			system("cp $dir/$psifile.psi $dir/$tmpfile.mtx $dir/$tmpfile.chk $dir/$tmpfile.hhr $target_dir");
			$flag="GREEN";
		}
		elsif(!-e "$dir/$tmpfile.hhr") {
print STDOUT "COND_6:\n";
print STDOUT "qsub $dir_sh/$tmpfile\_hhb.sh\n";
			system("qsub $dir_sh/$tmpfile\_hhb.sh");
		}
		elsif (!-e "$dir/$tmpfile.mtx" && !-e "$dir/$psifile.psi") {
print STDOUT "COND_7:\n";
print STDOUT "qsub $dir_sh/$tmpfile\_psi.sh\n";
                	system("qsub $dir_sh/$tmpfile\_psi.sh");
		}
	}
	sleep(3);
}


####### Limpieza scripts ###########
#unlink("$dir_sh/$tmpfile\_psi.sh","$dir_sh/$tmpfile\_hhb.sh");
#unlink("$dir_perl/$tmpfile.psi.pl","$dir_perl/$tmpfile.hhb.pl");
#unlink("$dir_perl/$tmpfile.main.pl","$dir_sh/$tmpfile.main.sh");
####################################

####### Limpieza ficheros generados ###########
#unlink("$dir/$tmpfile.hhr","$dir/$tmpfile.mtx","$dir/$tmpfile.chk","$dir/$psifile.psi","$dir/$tmpfile.hhm","$dir/$tmpfile.a3m");
#unlink("$dir/$tmpfile.aux","$dir/$tmpfile.sn","$dir/$tmpfile.pn","$dir/$tmpfile.mn","$dir/$tmpfile.faa");
#################### end ######################


sub file_generator{
	
	open(SH,">$dir_sh/$tmpfile\_psi.sh");
	print SH "#!/bin/bash\n";
	print SH "# Load Environmental variables for 'ahsoka' cluster\n";
	print SH "source /etc/bash.bashrc\n";
	print SH "source /etc/profile\n";
	print SH "source \${HOME}/.bashrc\n";
	print SH "#\$ -e $dir/LOG/$tmpfile.stderr\n";
	print SH "#\$ -o $dir/LOG/$tmpfile.stdout\n";
	print SH "#\$ -cwd\n";
	print SH "#\$ -q $queue\n";
	print SH "#\$ -N p$id\n";
	print SH "\n";
	print SH "\n";
	print SH "perl $dir/Perl/$tmpfile.psi.pl\n";
	print SH "\n";	
	close(SH);
	
	open(SH2,">$dir_sh/$tmpfile\_hhb.sh");
	print SH2 "#!/bin/bash\n";
	print SH2 "# Load Environmental variables for 'ahsoka' Linux_x86_64 cluster\n";
	print SH2 "source /etc/bash.bashrc\n";
	print SH2 "source /etc/profile\n";
	print SH2 "source \${HOME}/.bashrc\n";
	print SH2 "#\$ -e $dir/LOG/$tmpfile.stderr\n";
	print SH2 "#\$ -o $dir/LOG/$tmpfile.stdout\n";
	print SH2 "";
	print SH2 "#\$ -cwd\n";
	print SH2 "#\$ -q $queue\n";
	print SH2 "#\$ -N h$id\n";
	print SH2 "\n";
	print SH2 "\n";
	print SH2 "perl $dir/Perl/$tmpfile.hhb.pl\n";
	print SH2 "\n";
	close(SH2);
	
	open (PERL1,">$dir_perl/$tmpfile.psi.pl");
	print PERL1 "#!/usr/bin/perl\n";
	print PERL1 "\n";
	print PERL1 "use strict;\n";
	print PERL1 "\n";
	print PERL1 "my \$tmpfile=\"$tmpfile\";\n";
	print PERL1 "my \$dir=\"$dir\";\n";
	print PERL1 "my \$DB=\"$DB\";\n";
	print PERL1 "my \$evalue=\"$evalue\";\n";
	print PERL1 "my \$release_date=\"$release\";\n";
	print PERL1 "my \$nrdb=\"$nrdb\";\n";
	print PERL1 "my \$psifile=\"$psifile\";\n";
	print PERL1 "\n";
	print PERL1 "my \$cmd1=\"blastpgp -C \$dir/\$tmpfile.chk -d \$DB/\$nrdb -e0.01 -F F -h0.01 -j3 -b0 -v50 -a12 -i \$dir/\$tmpfile.faa\";\n";
	print PERL1 "print STDOUT \"PSI_CMD_1: \$cmd1\n\";\n";
	print PERL1 "`\$cmd1`;\n";
	print PERL1 "\n";
	print PERL1 "my \$cmd2=\"blastpgp -R \$dir/\$tmpfile.chk -a12 -d \$DB/fdbTptDB_\$release_date -F F -e\$evalue -v0 -i \$dir/\$tmpfile.faa -o \$dir/\$psifile.psi\";\n";
	print PERL1 "print STDOUT \"PSI_CMD_2: \$cmd2\n\";\n";
	print PERL1 "`\$cmd2`;\n";
	print PERL1 "\n";
	print PERL1 "open(PN,\">\$dir/\$tmpfile.pn\");\n";
	print PERL1 "open(SN,\">\$dir/\$tmpfile.sn\");\n";
	print PERL1 "print PN \"\$tmpfile.chk\";\n";
	print PERL1 "print SN \"\$tmpfile.faa\";\n";
	print PERL1 "close PN;close SN;\n";
	print PERL1 "\n";
	print PERL1 "`makemat -P \$dir/\$tmpfile`;\n";
	print PERL1 "\n";
	close(PERL1);
	
	open (PERL2,">$dir_perl/$tmpfile.hhb.pl");
	print PERL2 "#!/usr/bin/perl\n";
	print PERL2 "\n";
	print PERL2 "use strict;\n";
	print PERL2 "\n";
	print PERL2 "my \$tmpfile=\"$tmpfile\";\n";
	print PERL2 "my \$dir=\"$dir\";\n";
	print PERL2 "my \$DB=\"$DB\";\n";
	print PERL2 "\n";
	print PERL2 "my \$cmd1=\"hhblits -cpu 4 -i \$dir/\$tmpfile.faa -d $hh_prof_db -oa3m \$dir/\$tmpfile.a3m -o /dev/null\";\n";
	print PERL2 "print STDOUT \"HHB_CMD_1: \$cmd1\n\";\n";
	print PERL2 "`\$cmd1`;\n";
	print PERL2 "\n";
	print PERL2 "my \$cmd2=\"perl \$ENV{'HHLIB'}/scripts/addss.pl -i \$dir/\$tmpfile.a3m\";\n";
	print PERL2 "print STDOUT \"HHB_CMD_2: \$cmd2\n\";\n";
	print PERL2 "`\$cmd2`;\n";
	print PERL2 "\n";
	print PERL2 "my \$cmd3=\"hhmake -i \$dir/\$tmpfile.a3m\";\n";
	print PERL2 "print STDOUT \"HHB_CMD_3: \$cmd3\n\";\n";
	print PERL2 "`\$cmd3`;\n";
	print PERL2 "\n";
	print PERL2 "my \$cmd4=\"hhsearch -cpu 4 -d $hhblits_DB -i \$dir/\$tmpfile.hhm\";\n";
	print PERL2 "print STDOUT \"HHB_CMD_4: \$cmd4\n\";\n";
	print PERL2 "`\$cmd4`;\n";
	print PERL2 "\n";
	close(PERL2);
}	
