#!/usr/bin/perl -W

use strict;
use warnings;
use threads;

use Getopt::Long;
use FindBin;
use Config::IniFiles;
use File::Temp qw( cleanup );
use Data::Dumper;

use lib "$FindBin::Bin/lib";
use appris qw( get_gene_list create_ensembl_input create_gencode_input create_gencode_data );
use APPRIS::Parser qw( parse_gencode );
use APPRIS::Utils::File qw( prepare_workspace printStringIntoFile getTotalStringFromFile );
use APPRIS::Utils::Logger;
use APPRIS::Utils::Exception qw( info throw );
use APPRIS::Utils::Clusters;

###################
# Global variable #
###################
use vars qw(
	$LOCAL_PWD
	$CONFIG_INI_ENSEMBL_DB_FILE
	$CONFIG_INI_APPRIS_DB_FILE
	$LOGLEVEL
	$LOGAPPEND
);

$LOCAL_PWD					= $FindBin::Bin; $LOCAL_PWD =~ s/bin//;
$CONFIG_INI_ENSEMBL_DB_FILE	= $LOCAL_PWD.'/conf/ensembldb.ini';
$CONFIG_INI_APPRIS_DB_FILE	= $LOCAL_PWD.'/conf/apprisdb.ini';
$LOGLEVEL					= 'INFO';
$LOGAPPEND					= '';

# Input parameters
my ($id) = undef;
my ($position) = undef;
my ($data_file) = undef;
my ($transcripts_file) = undef;
my ($translations_file) = undef;
my ($gene_list_file) = undef;
my ($species) = undef;
my ($e_version) = undef;
my ($outpath) = undef;
my ($methods) = undef;
my ($type_of_input) = undef;
my ($type_of_align) = undef;
my ($c_conf_file) = undef;
my ($ensembldb_conf_file) = undef;
my ($apprisdb_conf_file) = undef;
my ($cached_path) = undef;
my ($logfile) = undef;
my ($logpath) = undef;
my ($logappend) = undef;
my ($loglevel) = undef;

&GetOptions(
	'id=s'				=> \$id,
	'position=s'		=> \$position,	
	'gene-list=s'		=> \$gene_list_file,
	'data=s'			=> \$data_file,
	'transcripts=s'		=> \$transcripts_file,
	'translations=s'	=> \$translations_file,
	'species=s'			=> \$species,
	'e-version=s'		=> \$e_version,
	'outpath=s'			=> \$outpath,
	'methods=s'			=> \$methods,
	't-align=s'			=> \$type_of_align,
	'cluster-conf=s'	=> \$c_conf_file,	
	'ensembldb-conf=s'	=> \$ensembldb_conf_file,
	'apprisdb-conf=s'	=> \$apprisdb_conf_file,
	'cached-path=s'		=> \$cached_path,	
	'loglevel=s'		=> \$loglevel,
	'logfile=s'			=> \$logfile,
	'logpath=s'			=> \$logpath,
	'logappend'			=> \$logappend,
);

# Required arguments
unless (
(
	# gencode-position choice
	(
		defined  $position and
		defined  $data_file and
		defined  $transcripts_file and
		defined  $translations_file
	) or 
	# gencode-list choice
	(
		defined  $gene_list_file and
		defined  $data_file
		#defined  $gene_list_file and
		#defined  $data_file and
		#defined  $transcripts_file and
		#defined  $translations_file
	) or
	# gencode choice
	(
		defined $data_file and
		defined  $transcripts_file and
		defined  $translations_file
	) or 
	# sequence choice
	(
		defined $id and
		defined $translations_file
	) or
	# ensembl-position choice
	defined $position or
	# ensembl-list choice
	defined $gene_list_file or
	# ensembl choice
	defined $id
) and 
	# required
	defined  $species and
	defined  $e_version and
	defined  $outpath
){
	print `perldoc $0`;
	exit 1;
}

# Get the type of input (the order of conditions is important)
if ( defined $position and defined $data_file and defined $transcripts_file and defined $translations_file ) {
	$type_of_input = 'gencode-position';
}
#elsif ( defined $gene_list_file and defined $data_file and defined $transcripts_file and defined $translations_file ) {
elsif ( defined $gene_list_file and defined $data_file ) {	
	$type_of_input = 'gencode-list';
}
elsif ( defined $data_file and defined $transcripts_file and defined $translations_file ) {
	$type_of_input = 'gencode';
}
elsif ( defined $id and defined $translations_file ) {
	$type_of_input = 'sequence';
}
elsif ( defined $position ) {
	$type_of_input = 'ensembl-position';
}
elsif ( defined $gene_list_file ) {
	$type_of_input = 'ensembl-list';
}
elsif ( defined $id ) {
	$type_of_input = 'ensembl';
}

# Get the type of input
if ( defined $type_of_align ) {
	if ( lc($type_of_align) eq 'compara' ) {
		$type_of_align = 'compara';		
	}
}

# Optional arguments
# get vars of ensembl db
unless ( defined $ensembldb_conf_file ) {
	$ensembldb_conf_file = $CONFIG_INI_ENSEMBL_DB_FILE;
}
# get vars of appris db
unless ( defined $apprisdb_conf_file ) {
	$apprisdb_conf_file = $CONFIG_INI_APPRIS_DB_FILE;
}

# Get log filehandle and print heading and parameters to logfile
my ($logger) = new APPRIS::Utils::Logger(
	-LOGFILE      => $logfile,
	-LOGPATH      => $logpath,
	-LOGAPPEND    => $logappend,
	-LOGLEVEL     => $loglevel,
);
$logger->init_log();
$LOGLEVEL	= $loglevel if ( defined $loglevel );
$LOGAPPEND	= "--logappend" if ( defined $logappend );

#################
# Method bodies #
#################
sub run_gencode($$$);
sub run_sequence($$$);
sub run_ensembl($$);
sub run_pipeline($$;$;$);
sub prepare_appris_params($$);
sub create_appris_input($$);
sub run_cluster_appris($$$);
sub run_appris($$$);
sub check_appris($$$);
sub insert_appris($$$);

# Main subroutine
sub main()
{
	# using gene list
	my ($gene_list);
	if ( defined $gene_list_file ) {
		$logger->info("-- using gene list\n");
	}

	# run appris pipeline for each gene depending on input
	$logger->info("-- from given input...");
	if ( ($type_of_input eq 'gencode') or ($type_of_input eq 'gencode-position') or ($type_of_input eq 'gencode-list') ) {		
		$logger->info(" $type_of_input type\n");
		
		# get gene list
		my ($gene_list);
		my ($data_fh);
		if ( defined $id ) {
			$logger->info("-- using gene id\n");
			$gene_list->{$id} = 1;
		}
		elsif ( defined $position ) {
			$logger->info("-- using genome position\n");
			$data_fh = appris::create_gencode_input($data_file, $position);
			if ( UNIVERSAL::isa($data_fh,'File::Temp') ) {
				$data_file = $data_fh->filename;
			}
		}		
		elsif ( defined $gene_list_file ) {
			$logger->info("-- using gene list\n");
			$gene_list = get_gene_list($gene_list_file);
			$data_fh = appris::create_gencode_input($data_file, undef, $gene_list);
			if ( UNIVERSAL::isa($data_fh,'File::Temp') ) {
				$data_file = $data_fh->filename;
			}
		}
		
		$logger->info("-- create gencode data files\n");
		my ($gencode_data) = appris::create_gencode_data($data_file, $transcripts_file, $translations_file);
		
		# delete tmp file
		if ( defined $data_fh and UNIVERSAL::isa($data_fh,'File::Temp') ) {
			$data_fh->unlink_on_destroy(1);
		}

		$logger->info("-- run gencode data files\n");
		my ($runtimes) = run_gencode($gencode_data, $outpath, $gene_list);
				
		#$logger->info("-- print times\n");
		#foreach my $runtime (@{$runtimes}) {
		#	$logger->info($runtime->{'gene_id'}."\t".$runtime->{'run'});
		#}
	}
	elsif ( ($type_of_input eq 'sequence') ) {
		$logger->info(" $type_of_input type\n");
		
		# get gene list
		my ($gene_list);
		if ( defined $id ) {
			$logger->info("-- using gene id\n");
			$gene_list->{$id} = 1;
		}
		
		$logger->info("-- run sequence\n");
		my ($runtimes) = run_sequence($translations_file, $outpath, $gene_list);
				
	}	
	elsif ( ($type_of_input eq 'ensembl') or ($type_of_input eq 'ensembl-position') or ($type_of_input eq 'ensembl-list') ) {
		$logger->info(" $type_of_input type\n");	

		# get gene list
		my ($gene_list);
		if ( defined $id ) {
			$logger->info("-- using gene id\n");
			$gene_list->{$id} = 1;
		}
		elsif ( defined $position ) {
			$logger->info("-- using genome position\n");
			$gene_list = appris::create_ensembl_input($position, $ensembldb_conf_file, $e_version, $species);			
		}
		elsif ( defined $gene_list_file ) {
			$logger->info("-- using gene list\n");
			$gene_list = appris::get_gene_list($gene_list_file);
		}
		
		$logger->info("-- run ensembl ids\n");
		my ($runtimes) = run_ensembl($outpath, $gene_list);
		
	}
	else {
		$logger->error("analying input parameters");
	}	
	
	File::Temp::cleanup();
	
	$logger->finish_log();
	
	exit 0;	
}

sub run_gencode($$$)
{
	my ($data, $outpath, $gene_list) = @_;
	my ($runtimes) = undef;
		
	foreach my $gene (@{$data}) {
		my ($gene_id) = $gene->stable_id;
		my ($gene_eid) = $gene_id;
		if ( $gene->version ) {
			my ($gene_ver) = $gene->version;
			$gene_eid = $gene_id.'.'.$gene_ver;
		}
		if ( defined $gene_list ) { # if there is a gene list, we run appris for the list
			if ( exists $gene_list->{$gene_id} ) {
				my ($runtime) = run_pipeline($gene_eid, $outpath, $gene);
				push(@{$runtimes}, $runtime);				
			}
		}
		else { # if there is not gene list, we run appris for all of them
			my ($runtime) = run_pipeline($gene_eid, $outpath, $gene);
			push(@{$runtimes}, $runtime);			
		}
	}
	return $runtimes;
} # end run_gencode

sub run_sequence($$$)
{
	my ($transl_file, $outpath, $gene_list) = @_;
	my ($runtimes) = undef;
			
	foreach my $gene_id (keys(%{$gene_list})) {
		my ($runtime) = run_pipeline($gene_id, $outpath, undef, $transl_file);
		push(@{$runtimes}, $runtime);		
	}
	return $runtimes;
} # end run_sequence

sub run_ensembl($$)
{
	my ($outpath, $gene_list) = @_;
	my ($runtimes) = undef;
			
	foreach my $gene_id (keys(%{$gene_list})) {
		my ($runtime) = run_pipeline($gene_id, $outpath);
		push(@{$runtimes}, $runtime);		
	}
	return $runtimes;
} # end run_ensembl

sub run_pipeline($$;$;$)
{
	my ($gene_id, $outpath, $gene, $transl_file) = @_;
	my ($runtime) = undef;
	my ($workspace) = $outpath.'/';

	$logger->info("-- $gene_id\n");	
	
	# create parameters
	$logger->info("\t-- create parameters ");
	my ($params) = {
		'species'		=> "'$species'",
		'e-version'		=> $e_version,				
		'outpath'		=> $workspace,
	};	
	# data from gencode type
	if ( $type_of_input =~ /^gencode/ and defined $gene ) {
		$logger->info("from $type_of_input\n");

		$logger->info("\t-- prepare workspace\n");
		if ( $type_of_input eq 'gencode-list' ) {
			my ($chr) = $gene->chromosome;
			$workspace .= "chr$chr".'/'.$gene_id;
		}
		else {
			$workspace .= $gene_id;			
		}
		$workspace = prepare_workspace($workspace);
				
		$logger->info("\t-- prepare params\n");
		$params = prepare_appris_params($gene, $workspace);
	}
	# data from sequence type
	elsif ( $type_of_input =~ /^sequence/ and defined $transl_file ) {
		$logger->info("from $type_of_input\n");

		$logger->info("\t-- prepare workspace\n");
		$workspace = prepare_workspace($workspace);
				
		$logger->info("\t-- prepare params\n");
		$params->{'id'} = $gene_id;
		$params->{'transl'} = $transl_file;
	}
	# data from ensembl type
	elsif ( ($type_of_input =~ /^ensembl/) and defined $gene_id ) {
		$logger->info("from $type_of_input\n");

		$logger->info("\t-- prepare workspace\n");
		$workspace .= $gene_id;
		$workspace = prepare_workspace($workspace);
		
		$logger->info("\t-- prepare params\n");
		$params->{'id'} = $gene_id;
	}
	else {
		$logger->info("\t-- do not run appris\n");
		return $runtime;
	}
	$params->{'methods'} = $methods if ( defined $methods );	
	$params->{'t-align'} = $type_of_align if ( defined $type_of_align );
	$params->{'cached-path'} = $cached_path if ( defined $cached_path );	
	$params->{'cluster-conf'} = $c_conf_file if ( defined $c_conf_file );
		
	# create parameters for script that checks results
	#my ($cparams) = {
	#		'id'				=> $gene_id,
	#		'inpath'			=> $workspace,
	#		'outfile'			=> $workspace.'/'.$gene_id.'.log',
	#};

	# create parameters for script that insert results into db
	#my ($iparams) = {
	#		'id'				=> $gene_id,
	#		'species'			=> "'$species'",
	#		'e-version'			=> $e_version,
	#		'inpath'			=> $workspace,
	#		'ensembldb-conf'	=> $ensembldb_conf_file,	
	#		'apprisdb-conf'		=> $apprisdb_conf_file,
	#};
	#$iparams->{'methods'} = $methods if ( defined $methods );
	
	# run appris pipeline
	if ( defined $c_conf_file ) {
		$logger->info("\t-- run cluster appris\n");
		run_cluster_appris($gene_id, $workspace, $params);			
	}
	else {
		$logger->info("\t-- run local appris\n");
		run_appris($gene_id, $workspace, $params);
		
		# check appris results
		#$logger->info("\t-- check results\n");
		#my ($pipetime) = check_appris($gene_id, $workspace, $cparams);
		#throw("checking results") unless ( defined $pipetime );
		
		# insert results of pipeline
		#$logger->info("\t-- insert results\n");
		#my ($inserttime) = insert_appris($gene_id, $workspace, $iparams);
		#throw("inserting results") unless ( defined $inserttime );
		
		# create output
		#$runtime = {
		#	'gene_id'	=> $gene_id,			
		#	'run'		=> $pipetime,
		#	'insert'	=> $inserttime,
		#};			
	}

	return $runtime;
	
} # end run_pipeline

sub prepare_appris_params($$)
{
	my ($gene, $workspace) = @_;
	my ($gene_id) = $gene->stable_id;
	my ($gene_eid) = $gene_id;
	if ( $gene->version ) {
		my ($gene_ver) = $gene->version;
		$gene_eid = $gene_id.'.'.$gene_ver;
	}
	
	# require parameter
	my ($params) = {
		'species'		=> "'$species'",
		'e-version'		=> $e_version,				
		'outpath'		=> $workspace,
	};
	
	# input files
	my ($in_files) = {
			'data'			=> $workspace.'/'.$gene_eid.'.annot.gtf',
			'pdata'			=> $workspace.'/'.$gene_eid.'.pannot.gtf',
			'transc'		=> $workspace.'/'.$gene_eid.'.transc.fa',
			'transl'		=> $workspace.'/'.$gene_eid.'.transl.fa',
			'cdsseq'		=> $workspace.'/'.$gene_eid.'.cdsseq.fa',			
			'firestar'		=> $workspace.'/'.$gene_eid.'.firestar',
			'matador3d'		=> $workspace.'/'.$gene_eid.'.matador3d',
			'spade'			=> $workspace.'/'.$gene_eid.'.spade',
			'corsair'		=> $workspace.'/'.$gene_eid.'.corsair',
			'thump'			=> $workspace.'/'.$gene_eid.'.thump',
			'crash'			=> $workspace.'/'.$gene_eid.'.crash',
			'appris'		=> $workspace.'/'.$gene_eid.'.appris',
			'appris-det'	=> $workspace.'/'.$gene_eid.'.appris.det',
			'logfile'		=> $workspace.'/'.$gene_eid.'.log',
			'errfile'		=> $workspace.'/'.$gene_eid.'.err',
	};
	
	# delete any log file for the new execution
	if ( -e $in_files->{'logfile'} and -e $in_files->{'errfile'} ) {
		eval {
			my ($cmd) = "rm -rf ".$in_files->{'logfile'}." ".$in_files->{'errfile'}." ";
			$logger->info("\n** script: $cmd\n");
			system ($cmd);
		};
		throw("deleting log files of appris") if($@);
	}
		
	# check if files exists
	if (
		-e $in_files->{'data'} and (-s $in_files->{'data'} > 0) and
		-e $in_files->{'pdata'} and (-s $in_files->{'pdata'} > 0) and
		-e $in_files->{'transc'} and (-s $in_files->{'transc'} > 0) and
		-e $in_files->{'transl'} and (-s $in_files->{'transl'} > 0) 
	) {
		$logger->info("\t-- use input path\n");
		$params->{'inpath'} = $workspace;
	}
	else {
		$logger->info("\t-- create gencode input\n");
		my ($create) = create_appris_input($gene, $in_files);
		if ( defined $create ) {
			if ( exists $in_files->{'data'} and -e ($in_files->{'data'}) ) {
				$params->{'data'} = $in_files->{'data'};	
			}			
			if ( exists $in_files->{'pdata'} and -e ($in_files->{'pdata'}) ) {
				$params->{'pdata'} = $in_files->{'pdata'};
			}
			if ( exists $in_files->{'transc'} and -e ($in_files->{'transc'}) ) {
				$params->{'transc'} = $in_files->{'transc'};
			}
			if ( exists $in_files->{'transl'} and -e ($in_files->{'transl'}) ) {
				$params->{'transl'} = $in_files->{'transl'};
			}			
		}
	}	

	return $params;
	
} # end prepare_appris_params

sub create_appris_input($$)
{
	my ($gene, $in_files) = @_;
	my ($create) = undef;
	
	# gene vars
	my ($chr) = $gene->chromosome;
	my ($gene_id) = $gene->stable_id;
	my ($gene_eid) = $gene_id;
	if ( $gene->version ) {
		my ($gene_ver) = $gene->version;
		$gene_eid = $gene_id.'.'.$gene_ver;
	}	
	my ($data_cont) = '';
	my ($pdata_cont) = '';
	my ($transc_cont) = '';
	my ($transl_cont) = '';
	my ($cdsseq_cont) = '';
	my ($gencode_file);
	
	# get gene annots
	my ($cmd) = "grep 'gene_id \"$gene_eid\"' $data_file";
	my (@global_data_cont);
	eval { @global_data_cont = `$cmd`; };
	throw("getting gene annots\n") if($@);
	if ( scalar(@global_data_cont) == 0 ) {
    	throw("empty gene annots\n");			
	}		
	
	# scan transctipt/translation/cds seq/cds info
	foreach my $transcript (@{$gene->transcripts}) {		
		my ($transcript_id) = $transcript->stable_id;
		my ($transcript_eid) = $transcript_id;
		if ( $transcript->version ) {
			my ($transcript_ver) = $transcript->version;
			$transcript_eid = $transcript_id.'.'.$transcript_ver;
		}
		my ($transcript_name) = $transcript_id;
		if ( $transcript->external_name ) {
			$transcript_name = $transcript->external_name;
		}
				
		# get transcript sequence				
		if ( $transcript->sequence ) {
			my ($seq) = $transcript->sequence;
			my ($len) = length($transcript->sequence);
			$transc_cont .= ">$transcript_eid|$gene_eid|$transcript_name|$len\n";
			$transc_cont .= $seq."\n";
		}
		
		if ( $transcript->translate ) {
			my ($translate) = $transcript->translate;
						
			# get translation sequence
			if ( $translate->sequence ) {
				my ($seq) = $translate->sequence;
				my ($len) = length($translate->sequence);
				# mask short sequences
				#if ( $len <= 2 ) { $seq .= 'X'; }
				$transl_cont .= ">$transcript_eid|$gene_eid|$transcript_name|$len\n";
				$transl_cont .= $seq."\n";					
			}
								
			if ( $transcript->exons and $translate->cds_sequence ) {
				my ($exons) = $transcript->exons;
				
				for (my $icds = 0; $icds < scalar(@{$translate->cds_sequence}); $icds++) {
					my ($cds) = $translate->cds->[$icds];
					my ($exon) = $exons->[$icds];
					my ($exon_id) = $exon->stable_id; $exon_id = '-' unless (defined $exon_id);
					my ($pro_cds) = $translate->cds_sequence->[$icds];

					my ($cds_start) = $cds->start;
					my ($cds_end) = $cds->end;
					my ($cds_strand) = $cds->strand;
					my ($cds_phase) = $cds->phase;
					
					my ($pro_cds_start) = $pro_cds->start;
					my ($pro_cds_end) = $pro_cds->end;
					my ($pro_cds_end_phase) = $pro_cds->end_phase;
					my ($pro_cds_seq) = $pro_cds->sequence;
						
					# delete the residue that is shared by two CDS						
					#if (defined $pro_cds_end_phase and $pro_cds_end_phase != 0) { $pro_cds_seq =~ s/\w{1}$//; }
						
					# retrieve cds sequence
					if (defined $pro_cds_seq and $pro_cds_seq ne '') {
						my ($len) = length($pro_cds_seq);
						$cdsseq_cont .= ">$transcript_eid|$gene_eid|$transcript_name|$len|$exon_id|$chr|$cds_start|$cds_end|$cds_strand|$cds_phase\n";
						$cdsseq_cont .= $pro_cds_seq."\n";							
					}
												
					# acquire protein coordinates
					if (defined $pro_cds_start and defined $pro_cds_end) {
						$pdata_cont .=	'SEQ'."\t".
													'Ensembl'."\t".
													'Protein'."\t".
													$pro_cds_start."\t".
													$pro_cds_end."\t".
													'.'."\t".
													'.'."\t".
													$pro_cds_end_phase."\t".
													"ID=$exon_id;Parent=$transcript_eid;Gene=$gene_eid\n";					
					}
				}
			}
		}			
	}

	# create files
	if ( scalar(@global_data_cont) > 0 ) {
		$data_cont = join('',@global_data_cont);
		my ($output_file) = $in_files->{'data'};		
		my ($printing_file_log) = printStringIntoFile($data_cont, $output_file);
		throw("creating $output_file file") unless ( defined $printing_file_log );
	}
	if ( $pdata_cont ne '' ) {
		my ($output_file) = $in_files->{'pdata'};
		my ($printing_file_log) = printStringIntoFile($pdata_cont, $output_file);
		throw("creating $output_file file") unless ( defined $printing_file_log );
	}
	if ( $transc_cont ne '' ) {
		my ($output_file) = $in_files->{'transc'};
		my ($printing_file_log) = printStringIntoFile($transc_cont, $output_file);
		throw("creating $output_file file") unless ( defined $printing_file_log );
	}
	if ( $transl_cont ne '' ) {
		my ($output_file) = $in_files->{'transl'};
		my ($printing_file_log) = printStringIntoFile($transl_cont, $output_file);
		throw("creating $output_file file") unless ( defined $printing_file_log );
	}
	if ( $cdsseq_cont ne '' ) {
		my ($output_file) = $in_files->{'cdsseq'};
		my ($printing_file_log) = printStringIntoFile($cdsseq_cont, $output_file);
		throw("creating $output_file file") unless ( defined $printing_file_log );
	}
	
	# determine if appris has to run
	if ( (scalar(@global_data_cont) > 0) and ($pdata_cont ne '') and ($transl_cont ne '') and ($cdsseq_cont ne '') ) {
		$create = 1;
	}
	
	return $create;
	
} # end create_appris_input

sub run_cluster_appris($$$)
{
	my ($c_id, $workspace, $params) = @_;
	
	# prepare clusters	
	$logger->info("-- prepare clusters\n");
	my ($clusters) = new APPRIS::Utils::Clusters( -conf => $c_conf_file );
	$logger->error("preparing clusters") unless (defined $clusters);
	
	# get free cluster
	$logger->info("-- get free cluster\n");
	my ($c_free) = $clusters->free();
	while ( !$c_free ) {
		$logger->info(".");
		sleep(2);
		$c_free = $clusters->free();
	}
	$logger->info("\n");
	$logger->info("-- free cluster: $c_free\n");

	# create workspace in cluster
	$logger->info("-- create workspace within cluster\n");
	my ($c_wsbase) = $clusters->wspace($c_free).'/'.$c_id;	
	my ($c_wspace) = $clusters->smkdir($c_free, $c_wsbase);
	sleep(1);
	$c_wspace = $clusters->wspace($c_free, $c_wsbase);
	$logger->error("preparing cluster workspace") unless (defined $c_wspace);
	sleep(1);
	
	# create inputs within cluster
	$logger->info("-- create inputs within cluster\n");
	my ($orig_files) = $workspace; $orig_files =~ s/\/*$//; $orig_files .= '/*';
	my ($c_file) = $clusters->dscopy($c_free, $c_wspace, $orig_files);
	$logger->error("copying $orig_files into cluster") unless (defined $c_file);
	$c_file =~ s/\/\*$//;
	sleep(2);
	
	# create job script for cluster
	$logger->info("-- create job script for cluster\n");	
	my ($parameters) = '';
	if ( defined $params ) {
		while ( my ($k,$v) = each(%{$params}) ) {
			if ( ($k eq 'outpath') or ($k eq 'inpath') ) { # modify the outpath/inpath because in a cluster is different
				$parameters .= " --$k=$c_wspace ";
			}
			elsif ( $k eq 'cluster-conf' ) { # delete cluster-conf
			}
			else { $parameters .= " --$k=$v "; }
		}
	}	
	my ($c_logpath) = $c_wspace;
	my ($c_logfile) = $c_id.'.log';
	my ($c_jobhome) = $clusters->cluster($c_free)->j_home;
	my ($cmd) =	"perl $c_jobhome/code/appris.pl ".
				" $parameters ".
				" --loglevel=$LOGLEVEL --logpath=$c_logpath --logfile=$c_logfile $LOGAPPEND ";
	# copy results to host
	my ($l_host) = $clusters->host;
	my ($l_user) = $clusters->user;
	#my ($cmd2) = '';
	my ($cmd2) = "cd $c_wspace && tar -cf - * | ssh $l_user\@$l_host 'cd $workspace; tar -xf - ' ";
	# rm results of cluster
	my ($cmd3) = '';
	#my ($cmd3) = "rm -rf $c_wspace ";
	my ($c_script) = "source $c_jobhome/code/conf/apprisrc && source $c_jobhome/code/conf/apprisrc.wserver && ".
						$cmd."\n\n".
						$cmd2."\n\n".
						$cmd3."\n\n";						
	my ($c_stderr) = $c_id.'.err';
	my ($script) = $clusters->script($c_free, { 
												'wdir'		=> $c_wspace,
												'stdout'	=> $c_stderr,
												'stderr'	=> $c_stderr,
												'script'	=> $c_script,
	});
	$logger->error("creating job script for cluster") unless (defined $script);
	$logger->debug("\n** script:\n $script\n");	
	
	# create local script that will execute into cluster
	my ($l_script) = $workspace.'/'.$c_id.'.sh';
	$l_script = printStringIntoFile($script, $l_script);
	$logger->error("creating job script into local server") unless (defined $l_script);
	sleep(1);

	# submit job
	$logger->info("-- submit job: ");
	my ($job_id) = $clusters->submit($c_free, $l_script);
	$logger->error("can not submit the job for $c_id: $!\n") unless (defined $job_id);
	$logger->info("JOB_ID: $job_id\n");
		
} # end run_cluster_appris

sub run_appris($$$)
{
	my ($id, $workspace, $params) = @_;
	
	# get inputs
	my ($parameters) = '';
	if ( defined $params ) {
		while ( my ($k,$v) = each(%{$params}) ) {
			$parameters .= " --$k=$v ";
		}
	}
	
	# create appris job script for cluster
	my ($c_wspace) = $workspace;
	my ($c_id) = $id;
	my ($c_logpath) = $c_wspace;
	my ($c_logfile) = $c_id.'.log';

	# run
	eval {
		my ($cmd) =	" perl $ENV{APPRIS_CODE_DIR}/appris.pl ".
					" $parameters ".
					" --loglevel=$LOGLEVEL --logpath=$c_logpath --logfile=$c_logfile $LOGAPPEND ";			
		$logger->info("\n** script: $cmd\n");
		my (@cmd_out) = `$cmd`;
	};
	throw("running appris") if($@);

} # end run_appris

sub check_appris($$$)
{
	my ($id, $workspace, $params) = @_;
	
	# get inputs
	my ($parameters) = '';
	if ( defined $params ) {
		while ( my ($k,$v) = each(%{$params}) ) {
			$parameters .= " --$k=$v ";
		}
	}
	
	# create appris job script for cluster
	my ($c_wspace) = $workspace;
	my ($c_id) = $id;
	my ($c_logpath) = $c_wspace;
	my ($c_logfile) = $c_id.'.log';

	# run
	eval {
		my ($cmd) =	" perl $ENV{APPRIS_HOME}/scripts/cappris.pl ".
					" --id=$id ".
					" $parameters ".
					" --loglevel=$LOGLEVEL --logpath=$c_logpath --logfile=$c_logfile $LOGAPPEND ";			
		$logger->info("\n** script: $cmd\n");
		my (@cmd_out) = `$cmd`;
	};
	throw("cheking appris") if($@);

} # end check_appris

sub insert_appris($$$)
{
	my ($id, $workspace, $params) = @_;
	
	# get inputs
	my ($parameters) = '';
	if ( defined $params ) {
		while ( my ($k,$v) = each(%{$params}) ) {
			$parameters .= " --$k=$v ";
		}
	}
	
	# create appris job script for cluster
	my ($c_wspace) = $workspace;
	my ($c_id) = $id;
	my ($c_logpath) = $c_wspace;
	my ($c_logfile) = $c_id.'.log';

	# run
	eval {
		my ($cmd) =	" perl $ENV{APPRIS_HOME}/scripts/iappris.pl ".
					" --id=$id ".
					" $parameters ".
					" --loglevel=$LOGLEVEL --logpath=$c_logpath --logfile=$c_logfile $LOGAPPEND ";			
		$logger->info("\n** script: $cmd\n");
		my (@cmd_out) = `$cmd`;
	};
	throw("inserting appris") if($@);

} # end insert_appris


main();


1;

__END__

=head1 NAME

apprisall

=head1 DESCRIPTION

global script that runs APPRIS for GENCODE and ENSEMBL 

=head1 SYNOPSIS

apprisall

=head2 Input arguments:

	* Gencode choice: executes appris for one or more genes (using data from Gencode -cds, exons, seqs, etc.- )

		--data=  <Gene annotation file>
	
		--transcripts=  <Transcript sequences file>
	
		--translations=  <Translation sequences file>

		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>	
	
	* Gencode-position choice: executes appris for a genome region (using data from Gencode -cds, exons, seqs, etc.- )

		--position= <Genome position> (21 or 21,22)
	
		--data=  <Gene annotation file>
		
		--transcripts=  <Transcript sequences file>
	
		--translations=  <Translation sequences file>

		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>	

	* Gencode-list choice: executes appris for list of genes (using data from Gencode -cds, exons, seqs, etc.- )

		--gene-list=  <File with a list of genes>
	
		--data=  <Gene annotation file>
		
		--transcripts=  <Transcript sequences file>
	
		--translations=  <Translation sequences file>

		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>	

	* Ensembl choice: executes appris for one gene (using data from Ensembl -api version- )

		--id= <Ensembl gene identifier>
	
		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>	

	* Ensembl-position choice: executes appris for a genome region (using data from Ensembl -api version- )

		--position= <Genome position> (21 or 21,22)
	
		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>
		
	* Ensembl-list choice: executes appris for list of genes (using data from Ensembl -api version- )

		--gene-list=  <File with a list of genes>

		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>
	
=head2 Output arguments:
	
		--outpath= <Output directory>
		
=head2 Optional arguments (methods):
		
		--methods= <List of APPRIS's methods ('firestar,matador3d,spade,corsair,thump,crash,appris'. Default: ALL)>
		
=head2 Optional arguments (type of inputs):

		--t-align= <Type of alignment (['compara'] default: NONE)>
	
=head2 Optional arguments (config files):

		--cluster-conf= <Config file of cluster execution (default: none)>

		--ensembldb-conf= <Config file of Ensembl database (default: 'conf/ensembldb.ini' file)>
		
		--apprisdb-conf= <Config file of APPRIS database (default: 'conf/apprisdb.ini' file)>

=head2 Optional arguments: # TODO: !!!!

		--operation=[appris|cappris|iappris] <List of appris operations (Default: ALL)>
		
=head2 Optional arguments (log arguments):
	
		--loglevel=LEVEL <define log level (default: NONE)>	
	
		--logfile=FILE <Log to FILE (default: *STDOUT)>
		
		--logpath=PATH <Write logfile to PATH (default: .)>
		
		--logappend= <Append to logfile (default: truncate)>



=head1 EXAMPLE of ENSEMBL's type of 'input

apprisall

	--species='Mus musculus'
	
	--e-version=69
	
	--outpath=../features/ENSMUSG00000017167_e69/

	--id=ENSMUSG00000017167

	--methods=firestar,matador3d
	
	--t-align=compara
	

=head1 EXAMPLE of GENCODE's type of input

apprisall

	--species='Homo sapiens'
	
	--e-version=70
	
	--outpath=/home/jmrodriguez/projects/Encode/gencode15/annotations/
	
	--data=/home/jmrodriguez/projects/Encode/gencode15/features/gencode.v15.annotation.gtf
	
	--transcripts=/home/jmrodriguez/projects/Encode/gencode15/features/gencode.v15.pc_transcripts.fa
	
	--translations=/home/jmrodriguez/projects/Encode/gencode15/features/gencode.v15.pc_translations.fa
	
	--methods=appris
	
	--loglevel=INFO
	
	--logappend
	
	--logpath=/home/jmrodriguez/projects/Encode/gencode15/logs/
			
	--logfile=apprisall.log


=head1 EXAMPLE of GENCODE's type of input (with given position)

apprisall

	--species='Homo sapiens'
	
	--e-version=70
	
	--outpath=/home/jmrodriguez/projects/Encode/gencode15/annotations/
	
	--position=chr22,chrM
	
	--data=/home/jmrodriguez/projects/Encode/gencode15/features/gencode.v15.annotation.gtf
	
	--transcripts=/home/jmrodriguez/projects/Encode/gencode15/features/gencode.v15.pc_transcripts.fa
	
	--translations=/home/jmrodriguez/projects/Encode/gencode15/features/gencode.v15.pc_translations.fa
	
	--loglevel=INFO
	
	--logappend
	
	--logpath=/home/jmrodriguez/projects/Encode/gencode15/logs/
			
	--logfile=apprisall.log


=head1 EXAMPLE of GENCODE's type of input (with given gene list)

apprisall

	--species='Homo sapiens'
	
	--e-version=70
	
	--outpath=/home/jmrodriguez/projects/Encode/gencode15/annotations/
	
	--gene-list=/home/jmrodriguez/projects/Encode/gencode15/features/gene_list.txt
	
	--data=/home/jmrodriguez/projects/Encode/gencode15/features/gencode.v15.annotation.gtf
	
	--transcripts=/home/jmrodriguez/projects/Encode/gencode15/features/gencode.v15.pc_transcripts.fa
	
	--translations=/home/jmrodriguez/projects/Encode/gencode15/features/gencode.v15.pc_translations.fa
	
	--loglevel=INFO
	
	--logappend
	
	--logpath=/home/jmrodriguez/projects/Encode/gencode15/logs/
			
	--logfile=apprisall.log


=head1 EXAMPLE of SEQUENCE's type of input

apprisall

	--species='Homo sapiens'
	
	--e-version=74

	--outpath=/home/jmrodriguez/projects/Encode/appris/code/examples/ENSG00000160404.13/
	
	--id=WSERVER_ENSG00000160404_XXXX
	
	--transl=/home/jmrodriguez/projects/Encode/appris/code/examples/ENSG00000160404.13/ENSG00000160404.13.transl.fa
	
	--loglevel=debug
	
	--logappend
	
	--logfile=/home/jmrodriguez/projects/Encode/appris/code/examples/ENSG00000160404.13/ENSG00000160404.13.log
	
	

=head1 EXAMPLE of CACHED results

apprisall

	--species='Homo sapiens'
	
	--e-version=74

	--outpath=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/
	
	--transl=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/ENSG00000168556.5.transl.fa
	
	--transc=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/ENSG00000168556.5.transc.fa
	
	--pdata=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/ENSG00000168556.5.pannot.gtf
	
	--data=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/ENSG00000168556.5.annot.gtf
	
	--methods=firestar
	
	--t-align=compara
	
	--cached-path=/local/jmrodriguez/appris/code/cached/homo_sapiens/e_70
	
	--loglevel=debug
	
	--logappend
	
	--logfile=/local/jmrodriguez/gencode19/annotations/chr4/ENSG00000168556.5/ENSG00000168556.5.log
	


=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
