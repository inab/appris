#!/usr/bin/perl -W
# _________________________________________________________________
# $Id$
# $Revision$
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________

use strict;
use warnings;
use FindBin;
use Getopt::Long;
use Config::IniFiles;
use File::Basename;
use Data::Dumper;

use APPRIS::Utils::Logger;
use APPRIS::Utils::WSpace;
use APPRIS::Utils::File qw( prepare_workspace printStringIntoFile getStringFromFile );

###################
# Global variable #
###################
use vars qw(
	$LOCAL_PWD
	$SRC_DIR
	$DEFAULT_CONFIG_FILE
	$DEFAULT_CFG
	$CFG
	$LOGGER_CONF
	$WORKSPACE
	$METHOD_STRUCT
);

$LOCAL_PWD				= $FindBin::Bin;
$SRC_DIR				= $LOCAL_PWD.'/src/';
$DEFAULT_CONFIG_FILE	= $LOCAL_PWD.'/conf/pipeline.ini';
$DEFAULT_CFG			= new Config::IniFiles( -file => $DEFAULT_CONFIG_FILE );
$CFG					= undef;
$METHOD_STRUCT			= [ split( ',', $DEFAULT_CFG->val('APPRIS_PIPELINE', 'structure') ) ];
$LOGGER_CONF			= '';
$WORKSPACE				= undef;

# Input parameters
my ($id) = undef;
my ($data_file) = undef;
my ($pdata_file) = undef;
my ($transc_file) = undef;
my ($transl_file) = undef;
my ($inpath) = undef;
my ($species) = undef;
my ($e_version) = undef;
my ($outpath) = undef;
my ($methods) = undef;
my ($type_of_input) = undef;
my ($type_of_align) = undef;
my ($cached_path) = undef;
my ($logfile) = undef;
my ($logpath) = undef;
my ($logappend) = undef;
my ($loglevel) = undef;

&GetOptions(
	'id=s'					=> \$id,
	'data=s'				=> \$data_file,
	'pdata=s'				=> \$pdata_file,
	'transcripts=s'			=> \$transc_file,
	'translations=s'		=> \$transl_file,
	'inpath=s'				=> \$inpath,
	'species=s'				=> \$species,
	'e-version=s'			=> \$e_version,		
	'outpath=s'				=> \$outpath,		
	'methods=s'				=> \$methods,
	't-align=s'				=> \$type_of_align,
	'cached-path=s'			=> \$cached_path,
	'loglevel=s'			=> \$loglevel,
	'logfile=s'				=> \$logfile,
	'logpath=s'				=> \$logpath,
	'logappend'				=> \$logappend,
);

# Required arguments
unless (
	(
		# first choice
		defined $inpath
		or
		# second choice
		defined $id
		or
		# third choice
		(defined $data_file and
		defined  $pdata_file and
		defined  $transc_file and
		defined  $transl_file)
		or
		# fourth choice
		defined  $transl_file
	)
	and 	
	defined  $species and
	defined  $e_version and
	defined  $outpath
){
	print `perldoc $0`;
	exit 1;
}

# Get method's pipeline
unless ( defined $methods ) {
	$methods = $DEFAULT_CFG->val('APPRIS_PIPELINE', 'structure');
}

# Get the type of input (the order of conditions is important)
if ( defined $inpath ) {
	$type_of_input = 'inpath';
}
elsif ( defined $data_file and defined $pdata_file and defined $transc_file and defined $transl_file ) {
	$type_of_input = 'gencode';
}
elsif ( defined $id and defined $transl_file ) {
	$type_of_input = 'sequence';
}
elsif ( defined $id ) {
	$type_of_input = 'ensembl';
}

# Get the type of input
if ( defined $type_of_align ) {
	if ( lc($type_of_align) eq 'ucsc' ) {
		$type_of_align = 'ucsc';		
	}
	elsif ( lc($type_of_align) eq 'compara' ) {
		$type_of_align = 'compara';		
	}
}

# Get log filehandle and print heading and parameters to logfile
my ($logger) = new APPRIS::Utils::Logger(
	-LOGFILE      => $logfile,
	-LOGPATH      => $logpath,
	-LOGAPPEND    => $logappend,
	-LOGLEVEL     => $loglevel,
);
$logger->init_log();
$LOGGER_CONF .= " --loglevel=$loglevel " if ( defined $loglevel );
$LOGGER_CONF .= " --logpath=$logpath " if ( defined $logpath );
$LOGGER_CONF .= " --logfile=$logfile " if ( defined $logfile );
$LOGGER_CONF .= " --logappend " if ( defined $logappend );


#####################
# Method prototypes #
#####################
sub create_workspace($$);
sub run_getgtf($$$$);
sub create_ini($$);
sub create_inputs($);
sub run_getmafucsc($$$);
sub run_getecompara($$$$);
sub run_pipeline($$$);

sub _subs_template($$$);
sub _rm_files($);
sub _cp_files($$);

#################
# Method bodies #
#################

# Main subroutine
sub main()
{
	# prepare workspace
	$logger->info("-- prepare workspace\n");              
	$outpath = prepare_workspace($outpath);
	if ( ($type_of_input eq 'gencode') or ($type_of_input eq 'sequence') ) {
		my ($name, $inpath, $suffix) = fileparse($transl_file, qr/\.[^.]+/);
		unless ( defined $id ) {
			if ( defined $name and $name =~ /^([^\.]+\.[\d]+)/ ) {
				$id = $1;
			}
			elsif ( defined $name and $name =~ /^([^\.]+)/ ) {
				$id = $1;
			}
			else { $logger->error("id not defined"); }
		}
	}
	elsif ( $type_of_input eq 'inpath' ) {
		my (@inpath_n) = split('/', $inpath);		
		if ( scalar(@inpath_n) > 0 ) {
			my ($num) = scalar(@inpath_n);
			$id = $inpath_n[$num-1];
		}
		else {
			$logger->error("id not defined");
		}
	}
	
	# Get ticket for pipeline
	$logger->info("-- get ticket id and prepare workspace\n");
	my ($wspace_id, $cached) = create_workspace($id, $methods);
	$logger->error("getting id and preparing workspace") unless ( defined $wspace_id );
		
	# If results are cached, we get the results
	if ( defined $wspace_id ) {
		if ( defined $cached )
		{		
			$logger->info("-- CACHED!!!: TODO: copy results into output directory\n");
			# $wspace_id
			# TODO: THINK HOW THE CACHE WILL WORK using the tickey id and the possible results
		}
		elsif ( defined $WORKSPACE )
		{		
			# Create ini file
			$logger->info("-- create ini files for appris pipeline\n");
			my ($config_file) = create_ini($wspace_id, $methods);
			unless ( defined $config_file ) {
				$logger->error("create ini files for appris pipeline");
			}
			$CFG = new Config::IniFiles( -file =>  $config_file );			

			# Create inputs for pipeline
			$logger->info("-- create input files for appris pipeline\n");
			my ($input_files) = create_inputs($id);
			unless ( defined $input_files ) {
				$logger->error("creating input files for appris pipeline");
			}
			
			# Run methods
			$logger->info("-- run pipeline\n");
			my ($output) = run_pipeline($config_file, $id, $input_files);
						
		}
	}
	else
	{
		$logger->error("obtain inputs for pipeline: ".$!) if($@);
	}
		
	$logger->finish_log();
	
	exit 0;
}

sub _subs_template($$$)
{
	my ($conf_file, $old, $new) = @_;	
	$conf_file =~ s/$old/$new/g;		
	return $conf_file;		
}

sub _rm_files($)
{
	my ($files) = @_;
	my ($ok);
	my ($list) = '';
	foreach my $file ( @{$files} ) {
		if ( UNIVERSAL::isa($file,'SCALAR') ) {
			$list .= " $file ";	
		}
		elsif ( UNIVERSAL::isa($file,'HASH') ) {
			while ( my ($k,$v) = each(%{$file}) ) {
				$list .= " $v ";
			}		
		}
	}
	if ( defined $list and $list ne '' ) {
		eval {
			my ($cmd) = "rm $list";
			$logger->info("-- $cmd\n");
			system ($cmd);		
		};
		$logger->error("deleting files: ".$!) if($@);
		$ok = 1;		
	}	
	return $ok;
}

sub _cp_files($$)
{
	my ($org, $dst) = @_;
	my ($ok);
	my ($list) = '';
	foreach my $file ( @{$org} ) {
		$list .= " $file ";
	}
	if ( defined $list and $list ne '' ) {
		eval {
			my ($cmd) = "cp -rp $list $dst/.";
			$logger->info("-- $cmd\n");
			system ($cmd);		
		};
		$logger->error("copying results: ".$!) if($@);
		$ok = 1;		
	}	
	return $ok;
}

sub create_workspace($$)
{
	my ($id, $methods) = @_;
	my ($wspace_id, $cached);
	
	# create identifier path
	my ($ws_sp) = lc($species); $ws_sp =~ s/\s/\_/g;
	my ($ws_name) = $ws_sp.'/'."e_$e_version";
	if ( defined $ENV{APPRIS_WS_NAME} ) {
		$ws_name = $ENV{APPRIS_WS_NAME};
	}
	my ($ws_id) = $ws_name.'/'.$id;
	
	
	# create workspace
	my ($wspace) = new APPRIS::Utils::WSpace(
											-id		=> $ws_id,											
											-base	=> $ENV{APPRIS_PROGRAMS_TMP_DIR},
	);
	$wspace_id = $wspace->id;
	$WORKSPACE = $wspace->create();
	unless ( defined $WORKSPACE ) {
		$logger->error("creating workspace: $wspace_id");
		return (undef,undef);
	}		

	# BEGIN: TODO: THINK HOW THE CACHE WILL WORK using the tickey id and the possible results	
	# $wspace_id
	# indexing the execution
	my ($cont) = $id."\t".$wspace->id."\t".$methods."\n";
	unless ( $wspace->exists($cont) ) {		
		my ($b) = $wspace->add_index($cont);
		unless ( defined $b ) {
			$logger->error("indexing execution");
			return (undef,undef);
		}		
	}
	else {
		#$cached = 1;
	}
	# check cached path
	if ( defined $cached_path ) {
		eval {
			my ($cached_dir) = $cached_path.'/'.$id;
			if ( -d $cached_dir ) {
				my ($dst_dir) = $ENV{APPRIS_PROGRAMS_TMP_DIR}.'/'.$ws_name.'/';
				my ($cmd) = "cd $cached_path && tar -cf - $id | (cd $dst_dir && tar -xf - )";
				$logger->info("\n** script: $cmd\n");
				system($cmd);
			}
		};
		if($@) {
			$logger->error("checking cached path");
			return (undef,undef);			
		}
	}
	# END: TODO: THINK HOW THE CACHE WILL WORK using the tickey id and the possible results	
	

	# input workspace
	my ($i_name) = $DEFAULT_CFG->val('INPUT_VARS', 'name');
	my ($a) = $wspace->create([$i_name]);
	unless ( defined $a ) {
		$logger->error("creating workspace: $i_name");
		return (undef,undef);
	}
	
	# cache workspace
	my ($c_name) = $DEFAULT_CFG->val('CACHE_VARS', 'name');
	my ($b) = $wspace->create([$c_name]);
	unless ( defined $b ) {
		$logger->error("creating workspace: $c_name");
		return (undef,undef);
	}
			
	# method workspaces
	foreach my $method ( split(',',$methods) ) {
		
		next if ( $method eq 'none' );
		
		# create the workspace for each method
		my ($a) = $wspace->create([$method]);
		unless ( defined $a ) {
			$logger->error("creating workspace: $method");
			return (undef,undef);
		}
		my ($wspace_method) = $WORKSPACE.'/'.$method.'/';
		
		# create dirs for individual methods
		my ($ws_list);
		if ( $method eq 'firestar') {
			$ws_list = $DEFAULT_CFG->val('FIRESTAR_VARS', 'workspaces');
		}
		elsif ( $method eq 'matador3d') {
			$ws_list = $DEFAULT_CFG->val('MATADOR3D_VARS', 'workspaces');
		}
		elsif ( $method eq 'spade') {
			$ws_list = $DEFAULT_CFG->val('SPADE_VARS', 'workspaces');
		}
		elsif ( $method eq 'corsair') {
			$ws_list = $DEFAULT_CFG->val('CORSAIR_VARS', 'workspaces');
		}
		elsif ( $method eq 'thump') {
			$ws_list = $DEFAULT_CFG->val('THUMP_VARS', 'workspaces');
		}
		elsif ( $method eq 'crash') {
			$ws_list = $DEFAULT_CFG->val('CRASH_VARS', 'workspaces');
		}
		elsif ( $method eq 'inertia') {
			$ws_list = $DEFAULT_CFG->val('INERTIA_VARS', 'workspaces');
		}
		elsif ( $method eq 'cexonic') {
			$ws_list = $DEFAULT_CFG->val('CEXONIC_VARS', 'workspaces');
		}
		elsif ( $method eq 'appris') {
			$ws_list = $DEFAULT_CFG->val('APPRIS_VARS', 'workspaces');
		}
		else {
			$logger->error("methods parameter is wrong: $method");
			return (undef,undef);
		}
		if ( defined $ws_list and $ws_list ne '' ) {
			my (@ws) = split(',',$ws_list);
			my ($b) = $wspace->create(\@ws, $wspace_method);
			unless ( defined $b ) {
				$logger->error("creating workspace: $wspace_method");
				return (undef,undef);
			}
		}		
	}
			
	return ($wspace_id, $cached);		
}

sub run_getgtf($$$$)
{
	my ($id, $species, $e_version, $datadir) = @_;	
	my ($input_files) = {
		'annot'			=> $datadir.'/'.$id.'.annot.gtf',
		'pannot'		=> $datadir.'/'.$id.'.pannot.gtf',
		'transc'		=> $datadir.'/'.$id.'.transc.fa',
		'transl'		=> $datadir.'/'.$id.'.transl.fa'
	};
	my ($data_file, $pdata_file, $transc_file, $transl_file) = ( 
		$input_files->{'annot'},
		$input_files->{'pannot'},
		$input_files->{'transc'},
		$input_files->{'transl'},
	);
	
	# check if input exists	
	unless (
		-e $data_file and (-s $data_file > 0) and 
		-e $pdata_file and (-s $pdata_file > 0) and 
		-e $transc_file and (-s $transc_file > 0) and 
		-e $transl_file and (-s $transl_file > 0)
	) {	
		eval {
			my ($cmd) = "perl $SRC_DIR/ensembl/getGTF.pl ".
							"--id=$id ".
							"--species='$species' ".
							"--e-version=$e_version ".
							"--out-data=$data_file ".
							"--out-pdata=$pdata_file ".
							"--out-transcripts=$transc_file ".
							"--out-translations=$transl_file ".
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		if($@) {
			my ($a) = _rm_files($input_files);
			$logger->error("deleting files") unless ( defined $a );
			return undef;		
		}
		unless (
			-e $data_file and (-s $data_file > 0) and 
			-e $pdata_file and (-s $pdata_file > 0) and 
			-e $transc_file and (-s $transc_file > 0) and 
			-e $transl_file and (-s $transl_file > 0)
		) {
			my ($a) = _rm_files($input_files);
			$logger->error("deleting files") unless ( defined $a );
			return undef;				
		}
	}
	
	return $input_files;
}

sub run_getmafucsc($$$)
{
	my ($species, $input_files, $datadir) = @_;
	my ($t_align) = 'ucsc';
	my ($outpath) = $datadir;
	my ($data_file) = $input_files->{'annot'};
	my ($transc_file) = $input_files->{'transc'};
	my ($transl_file) = $input_files->{'transl'};
	
	# check if input exists
	if ( (`grep -c '>' $transl_file` ne `ls -1 $datadir/*.$t_align.faa | wc -l`) or (`grep -c '>' $transl_file` ne `ls -1 $datadir/*.$t_align.nh | wc -l`) ) {
		eval {
			my ($cmd) = "perl $SRC_DIR/ucsc/getUCSCAlign.pl ".
							"--species='$species' ".
							"--data=$data_file ".
							"--translations=$transl_file ".
							"--outpath=$datadir ".
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		if($@) {
			my ($a) = _rm_files("$datadir/*.$t_align.faa");
			$logger->error("deleting files") unless ( defined $a );
			my ($b) = _rm_files("$datadir/*.$t_align.nh");
			$logger->error("deleting files") unless ( defined $b );
			return undef;		
		}
		my (@ls_out) = `ls -1 $datadir/*.$t_align.faa`;
		if ( scalar(@ls_out) == 0 ) {
			my ($a) = _rm_files("$datadir/*.$t_align.faa");
			$logger->error("deleting files") unless ( defined $a );
			my ($b) = _rm_files("$datadir/*.$t_align.nh");
			$logger->error("deleting files") unless ( defined $b );
			return undef;		
		}	
	}
		
	return $outpath;
}

sub run_getecompara($$$$)
{
	my ($species, $e_version, $input_files, $datadir) = @_;
	my ($t_align) = 'compara';
	my ($outpath) = $datadir;
	my ($data_file) = $input_files->{'annot'};
	my ($transc_file) = $input_files->{'transc'};
	my ($transl_file) = $input_files->{'transl'};
	
	# check if input exists
	if ( (`grep -c '>' $transl_file` ne `ls -1 $datadir/*.$t_align.faa | wc -l`) or (`grep -c '>' $transl_file` ne `ls -1 $datadir/*.$t_align.nh | wc -l`) ) {
		eval {
			my ($cmd) = "perl $SRC_DIR/ensembl/getEComparaAlign.pl ".
							"--species='$species' ".
							"--e-version=$e_version ".
							"--data=$data_file ".
							"--transcripts=$transc_file ".
							"--translations=$transl_file ".
							"--outpath=$datadir ".
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		if($@) {
			my ($a) = _rm_files("$datadir/*.$t_align.faa");
			$logger->error("deleting files") unless ( defined $a );
			my ($b) = _rm_files("$datadir/*.$t_align.nh");
			$logger->error("deleting files") unless ( defined $b );
			return undef;		
		}
		my (@ls_out) = `ls -1 $datadir/*.$t_align.faa`;
		if ( scalar(@ls_out) == 0 ) {
			my ($a) = _rm_files("$datadir/*.$t_align.faa");
			$logger->error("deleting files") unless ( defined $a );
			my ($b) = _rm_files("$datadir/*.$t_align.nh");
			$logger->error("deleting files") unless ( defined $b );
			return undef;		
		}	
	}
	# BEGIN: TEMPORAL!!!!
	#else {
	#	foreach my $align (`cd $datadir && ls -1 *.align.faa`) {
	#		$align =~ s/\s*//mg;
	#		if ( $align =~ /^(.*)\.align\.faa/ ) {
	#			eval {
	#				system("mv $datadir/$1.align.faa $datadir/$1.compara.faa");
	#				system("mv $datadir/$1.align.tree.nh $datadir/$1.compara.tree.nh");
	#			};
	#			if($@) {				
	#				$logger->error("moving files");
	#				return undef;		
	#			}				
	#		}
	#	}
	#}
	# END: TEMPORAL!!!!	
	
	return $outpath;
}

sub create_ini($$)
{
	my ($wspace_id, $methods) = @_;
	
	my ($config_cont) = getStringFromFile($DEFAULT_CONFIG_FILE);
	$config_cont = _subs_template($config_cont, 'APPRIS__PIPELINE__WORKSPACE', $wspace_id);
	$config_cont = _subs_template($config_cont, 'APPRIS__PIPELINE__METHODS', $methods);
	$config_cont = _subs_template($config_cont, 'APPRIS__SPECIES', $species);
	
	my ($config_file) = $WORKSPACE.'/pipeline.ini';
	my ($a) = printStringIntoFile($config_cont, $config_file);
	$logger->error("-- printing config annot") unless ( defined $a );
	
	return ($config_file);
}

sub create_inputs($)
{
	my ($id) = @_;
	my ($input_files);
	my ($datadir) =  $WORKSPACE.'/'.$CFG->val( 'INPUT_VARS', 'name');
		
	# Obtain inputs for pipeline
	$logger->info("-- obtain gene annotations, transcript seq, and translate seq...");
	if ( $type_of_input eq 'inpath' ) {
		$logger->info("from $type_of_input\n");
		$input_files = {
			'id'			=> $id,
			'species'		=> "'$species'",
			'e-version'		=> $e_version,			
			'annot'			=> $inpath.'/'.$id.'.annot.gtf',
			'pannot'		=> $inpath.'/'.$id.'.pannot.gtf',
			'transc'		=> $inpath.'/'.$id.'.transc.fa',
			'transl'		=> $inpath.'/'.$id.'.transl.fa',
		};
	}
	elsif ( $type_of_input eq 'gencode' ) {
		$logger->info("from $type_of_input\n");
		$input_files = {
			'id'			=> $id,
			'species'		=> "'$species'",
			'e-version'		=> $e_version,			
			'annot'			=> $data_file,
			'pannot'		=> $pdata_file,
			'transc'		=> $transc_file,
			'transl'		=> $transl_file,
		};
		
		# copy inputs into cache for pipeline
		$logger->info("-- copy inputs for pipeline\n");
			my ($a) = _cp_files([$data_file,$pdata_file,$transc_file,$transl_file], $datadir);
			unless ( defined $a ) {
			$logger->error("copying input files for appris pipeline");
		}
	}	
	elsif ( $type_of_input eq 'sequence' ) {
		$logger->info("from $type_of_input\n");
		$input_files = {
			'id'			=> $id,
			'species'		=> "'$species'",
			'e-version'		=> $e_version,			
			'transl'		=> $transl_file,
		};
		
		# copy inputs into cache for pipeline
		$logger->info("-- copy inputs for pipeline\n");
			my ($a) = _cp_files([$transl_file], $datadir);
			unless ( defined $a ) {
			$logger->error("copying input files for appris pipeline");
		}
	}	
	elsif ( $type_of_input eq 'ensembl' ) {
		$logger->info("from $type_of_input\n");
		$input_files = run_getgtf($id, $species, $e_version, $datadir);
		if ( defined $input_files ) {
			# copy inputs into outpath
			$logger->info("-- copy inputs for pipeline\n");
			my ($a) = _cp_files(["$datadir/*.gtf","$datadir/*.fa"], $outpath);
			unless ( defined $a ) {
				$logger->error("copying input files for appris pipeline");
			}
		}
		else {			
			$logger->error("creating input files for appris pipeline");
		}		
	}
	else {
		$logger->error("analying input parameter");
	}
	
	# create alignments for pipeline
	if ( defined $type_of_align ) {	
		if ( $type_of_align eq 'ucsc' ) {
			$logger->info("-- create alignments...from $type_of_align\n");
			#my ($alignpath) = run_getmafucsc($species, $input_files, $datadir);
			#if ( defined $alignpath ) {				
				# copy inputs into outpath
				$logger->info("-- copy inputs for pipeline\n");
				my ($a) = _cp_files(["$datadir/*.$type_of_align.faa","$datadir/*.$type_of_align.nh"], $outpath);
				unless ( defined $a ) {
					$logger->error("copying input files for appris pipeline");
				}
			#}
			#else {
			#	$logger->error("creating alignments for appris pipeline");
			#}
		}
		if ( $type_of_align eq 'compara' ) {
			$logger->info("-- create alignments...from $type_of_align\n");
			my ($alignpath) = run_getecompara($species, $e_version, $input_files, $datadir);
			if ( defined $alignpath ) {				
				# copy inputs into outpath
				$logger->info("-- copy inputs for pipeline\n");
				my ($a) = _cp_files(["$datadir/*.$type_of_align.faa","$datadir/*.$type_of_align.nh"], $outpath);
				unless ( defined $a ) {
					$logger->error("copying input files for appris pipeline");
				}
			}
			else {
				$logger->error("creating alignments for appris pipeline");
			}
		}
		$input_files->{'alignpath'} = $datadir;
	}
	# TEMPORAL: For the moment we include always the alignpath
	$input_files->{'alignpath'} = $datadir;
	# TEMPORAL: For the moment we include always the alignpath
		
	return $input_files;
}

sub run_pipeline($$$)
{
	my ($config_file, $id, $files) = @_;
	
	# acquire the outputs for each method
	my ($methods_list) = $CFG->val('APPRIS_PIPELINE', 'methods');
	foreach my $method ( split(',',$methods_list) ) {		
		if ( $method eq 'appris' ) {
			foreach my $met ( @{$METHOD_STRUCT} ) {
				$files->{$method}->{$met} = $outpath.'/'.$id.'.'.$met;				
			}
		}
		else {
			$files->{$method} = $outpath.'/'.$id.'.'.$method;				
		}
	}
	
	# execute sequentially
	if ( exists $files->{'firestar'} ) {
		my ($m) = 'firestar';
		eval {
			my ($cmd) = "perl $SRC_DIR/firestar/firestar.pl ".
							"--appris ".
							"--conf=".$config_file." ".
							"--input=".$files->{'transl'}." ".
							"--output=".$files->{$m}." ".
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		$logger->error("runing $m: ".$!) if($@);
	}
	if ( exists $files->{'matador3d'} ) {
		my ($m) = 'matador3d';
		eval {
			my ($cmd) = "perl $SRC_DIR/matador3d/matador3d.pl ".
							"--appris ".
							"--conf=".$config_file." ".
							"--gff=".$files->{'annot'}." ".
							"--input=".$files->{'transl'}." ".
							"--output=".$files->{$m}." ".
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		$logger->error("runing $m: ".$!) if($@);
	}
	if ( exists $files->{'spade'} ) {
		my ($m) = 'spade';
		eval {
			my ($cmd) = "perl $SRC_DIR/spade/spade.pl ".
							"--appris ".
							"--conf=".$config_file." ".
							"--input=".$files->{'transl'}." ".
							"--output=".$files->{$m}." ".
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		$logger->error("runing $m: ".$!) if($@);
	}
	if ( exists $files->{'corsair'} ) {
		my ($m) = 'corsair';
		eval {
			my ($cmd) = "perl $SRC_DIR/corsair/corsair.pl ".
							"--appris ".
							"--conf=".$config_file." ".								
							"--gff=".$files->{'pannot'}." ".
							"--input=".$files->{'transl'}." ".
							"--output=".$files->{$m}." ".							
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		$logger->error("runing $m: ".$!) if($@);
	}
	if ( exists $files->{'thump'} ) {
		my ($m) = 'thump';
		eval {
			my ($cmd) = "perl $SRC_DIR/thump/thump.pl ".
							"--appris ".
							"--conf=".$config_file." ".
							"--input=".$files->{'transl'}." ".
							"--output=".$files->{$m}." ".
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		$logger->error("runing $m: ".$!) if($@);
	}
	if ( exists $files->{'crash'} ) {
		my ($m) = 'crash';
		eval {
			my ($cmd) = "perl $SRC_DIR/crash/crash.pl ".
							"--appris ".
							"--conf=".$config_file." ".
							"--input=".$files->{'transl'}." ".
							"--output=".$files->{$m}." ".
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		$logger->error("runing $m: ".$!) if($@);
	}
	if ( exists $files->{'inertia'} ) {	
		my ($m) = 'inertia';
		eval {
			my ($cmd) = "perl $SRC_DIR/inertia/inertia.pl ".
							"--appris ".
							"--conf=".$config_file." ".
							"--gff=".$files->{'annot'}." ".
							"--inpath=".$files->{'alignpath'}." ".
							"--output=".$files->{$m}." ".
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		$logger->error("runing $m: ".$!) if($@);	
	}
	if ( exists $files->{'appris'} ) {
		my ($m) = 'appris';
		eval {
			my ($cmd) = "perl $SRC_DIR/appris/appris.pl ".
							"--conf=".$config_file." ".
							"--data=".$files->{'annot'}." ".
							"--transcripts=".$files->{'transc'}." ".
							"--translations=".$files->{'transl'}." ".
							
							"--firestar=".$files->{$m}->{'firestar'}." ".
							"--matador3d=".$files->{$m}->{'matador3d'}." ".
							"--spade=".$files->{$m}->{'spade'}." ".
							"--corsair=".$files->{$m}->{'corsair'}." ".
							"--thump=".$files->{$m}->{'thump'}." ".
							"--crash=".$files->{$m}->{'crash'}." ".
															
							"--output=".$files->{$m}->{'appris'}." ".
							"--output_label=".$files->{$m}->{'appris'}.".label ".
							"--output_score=".$files->{$m}->{'appris'}.".score ".
							"$LOGGER_CONF ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		$logger->error("runing $m: ".$!) if($@);
	}
}


main();


__END__

=head1 NAME

appris

=head1 DESCRIPTION

Script that execute APPRIS

=head1 ARGUMENTS

=head2 Required arguments:
	
	--species= <Name of species -mammals->
	
	--e-version= <Number of Ensembl version of identifier>
	
	--outpath= <Output directory>

=head2 Optional input arguments (first choice - cached):
		
	--inpath= <Acquire input files from PATH>
	
=head2 Optional input arguments (second choice):

	--id= <Ensembl gene identifier>

=head2 Optional input arguments (third choice):
	
	--data=  <Gene annotation file>
	
	--pdata=  <Gene/Peptide annotation file>
	
	--transcripts=  <Transcript sequences file>
	
	--translations=  <Translation sequences file>
	
=head2 Optional input arguments (fourth choice):
	
	--translations=  <Translation sequences file>

=head2 Optional arguments (type of inputs):

	--t-align= <Type of alignment (['compara'] default: NONE)>

=head2 Optional arguments (methods):

	--methods= <List of APPRIS's methods (default: ALL)>

=head2 Optional arguments (methods):

	--cached-path= <Cached path>
		
=head2 Optional arguments (log arguments):
	
	--loglevel=LEVEL <define log level (default: NONE)>	

	--logfile=FILE <Log to FILE (default: *STDOUT)>
	
	--logpath=PATH <Write logfile to PATH (default: .)>
	
	--logappend <Append to logfile (default: truncate)>
    

=head1 EXAMPLE

perl appris.pl

	--id=ENSMUSG00000017167	

	--species='Mus musculus'
	
	--e-version=70
	
	--outpath=examples/ENSMUSG00000017167
	
	--loglevel=INFO
	
	--logappend
	
	--logpath=examples/ENSMUSG00000017167
	
	--logfile=ENSMUSG00000017167.log
	
=head1 EXAMPLE

perl run_appris.pl

	--id=ENSG00000099999	

	--species='Homo sapiens'
	
	--e-version=70
		
	--outpath=examples/ENSG00000099999
	
	--t-align=compara
	
	--loglevel=DEBUG
	
	--logappend
	
	--logpath=examples/ENSG00000099999/
	
	--logfile=ENSG00000099999.log
	
=head1 EXAMPLE

perl appris.pl

	--species='Homo sapiens'
	
	--e-version=69

	--data=examples/ENSG00000140416/ENSG00000140416.annot.gtf
	
	--pdata=examples/ENSG00000140416/ENSG00000140416.pannot.gtf
	
	--transcripts=examples/ENSG00000140416/ENSG00000140416.transc.fa
	
	--translations=examples/ENSG00000140416/ENSG00000140416.transl.fa
	
	--outpath=examples/ENSG00000140416/
	
	--loglevel=DEBUG
	
	--logappend
	
	--logpath=examples/ENSG00000140416/
	
	--logfile=ENSG00000140416.log
	
=head1 EXAMPLE

perl appris.pl

	--species='Homo sapiens'
	
	--e-version=74

	--transl=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/ENSG00000168556.5.transl.fa
	
	--transc=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/ENSG00000168556.5.transc.fa
	
	--pdata=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/ENSG00000168556.5.pannot.gtf
	
	--data=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/ENSG00000168556.5.annot.gtf
	
	--outpath=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/
	
	--methods=firestar
	
	--t-align=compara
	
	--cached-path=/local/jmrodriguez/appris/code/cached/homo_sapiens/e_70
	
	--loglevel=debug
	
	--logappend
	
	--logpath=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/
	
	--logfile=ENSG00000168556.5.log		
	

=head1 AUTHOR

Created and Developed by

	Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut