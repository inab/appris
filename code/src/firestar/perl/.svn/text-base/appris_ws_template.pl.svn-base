#!/usr/bin/perl -W

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
my $conf_file=$ARGV[4];
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


# Blastpgp
unless ( -e "$target_dir/$psifile.psi" and (-s "$target_dir/$psifile.psi" > 0) ) {
	my $psi_cmd1="blastpgp -C $dir/$tmpfile.chk -d $DB/$nrdb -e0.01 -F F -h0.01 -j3 -b0 -v50 -a12 -i $dir/$tmpfile.faa";
	print STDERR "PSI_CMD_1: $psi_cmd1\n";
	system($psi_cmd1);
	my $psi_cmd2="blastpgp -R $dir/$tmpfile.chk -a12 -d $DB/fdbTptDB_$release -F F -e$evalue -v0 -i $dir/$tmpfile.faa -o $dir/$psifile.psi";
	print STDERR "PSI_CMD_2: $psi_cmd2\n";
	system($psi_cmd2);
	open(PN,">$dir/$tmpfile.pn");
	open(SN,">$dir/$tmpfile.sn");
	print PN "$tmpfile.chk";
	print SN "$tmpfile.faa";
	close PN; close SN;
	my $psi_cmd3="makemat -P $dir/$tmpfile";
	print STDERR "PSI_CMD_3: $psi_cmd3\n";
	system($psi_cmd3);
	
	if (-e "$dir/$psifile.psi" and (-s "$dir/$psifile.psi") > 0 ) {
		system("cp $dir/$psifile.psi $target_dir");
	}
}

# HHSearch
unless ( -e "$target_dir/$tmpfile.hhr" and (-s "$target_dir/$tmpfile.hhr" > 0) ) {
	my $hhb_cmd1="hhblits -cpu 4 -i $dir/$tmpfile.faa -d $hh_prof_db -oa3m $dir/$tmpfile.a3m -o /dev/null";
	print STDERR "HHB_CMD_1: $hhb_cmd1\n";
	system($hhb_cmd1);
	my $hhb_cmd2="perl $ENV{'HHLIB'}/scripts/addss.pl -i $dir/$tmpfile.a3m";
	print STDERR "HHB_CMD_2: $hhb_cmd2\n";
	system($hhb_cmd2);
	my $hhb_cmd3="hhmake -i $dir/$tmpfile.a3m";
	print STDERR "HHB_CMD_3: $hhb_cmd3\n";
	system($hhb_cmd3);
	my $hhb_cmd4="hhsearch -cpu 4 -d $hhblits_DB -i $dir/$tmpfile.hhm";
	print STDERR "HHB_CMD_4: $hhb_cmd4\n";
	system($hhb_cmd4);
		
	if (-e "$dir/$tmpfile.hhr" and (-s "$dir/$tmpfile.hhr") > 0 ) {
		system("cp $dir/$tmpfile.hhr $target_dir");
	}
}

exit 0;

