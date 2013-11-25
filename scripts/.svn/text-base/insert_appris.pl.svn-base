#!/usr/bin/perl -W

use strict;
use warnings;
use threads;

use Getopt::Long;
use FindBin;
use Config::IniFiles;
use Data::Dumper;

use lib "$FindBin::Bin/lib";
use appris qw( get_gene_list create_ensembl_input create_gencode_input );
use APPRIS::Parser qw( parse_gencode );
use APPRIS::Utils::File qw( prepare_workspace printStringIntoFile getTotalStringFromFile );
use APPRIS::Utils::Logger;
use APPRIS::Utils::Exception qw( info throw );

###################
# Global variable #
###################
use vars qw(
	$LOCAL_PWD
	$CONFIG_INI_ENSEMBL_DB_FILE
	$CONFIG_INI_APPRIS_DB_FILE
	$LOGLEVEL
	$APPRIS_METHODS
);

$LOCAL_PWD					= $FindBin::Bin;
$CONFIG_INI_ENSEMBL_DB_FILE	= $FindBin::Bin.'/conf/ensembldb.ini';
$CONFIG_INI_APPRIS_DB_FILE	= $FindBin::Bin.'/conf/apprisdb.ini';
$LOGLEVEL					= 'INFO';
# TEMPORAL SOLUTION!!!!
$ENV{APPRIS_METHODS}="firestar,matador3d,spade,corsair,thump,crash,appris";
# TEMPORAL SOLUTION!!!!
foreach my $method ( split(',',$ENV{APPRIS_METHODS}) ) {
	$APPRIS_METHODS->{$method} = 1;
}

# Input parameters
my ($id) = undef;
my ($position) = undef;
my ($gene_list_file) = undef;
my ($data_file) = undef;
my ($species) = undef;
my ($e_version) = undef;
my ($inpath) = undef;
my ($methods) = undef;
my ($type_of_input) = undef;
my ($ensembldb_conf_file) = undef;
my ($apprisdb_conf_file) = undef;
my ($logfile) = undef;
my ($logpath) = undef;
my ($logappend) = undef;
my ($loglevel) = undef;

&GetOptions(
	'id=s'				=> \$id,
	'position=s'		=> \$position,
	'gene-list=s'		=> \$gene_list_file,
	'data=s'			=> \$data_file,
	'species=s'			=> \$species,
	'e-version=s'		=> \$e_version,
	'inpath=s'			=> \$inpath,
	'methods=s'			=> \$methods,
	'ensembldb-conf=s'	=> \$ensembldb_conf_file,	
	'apprisdb-conf=s'	=> \$apprisdb_conf_file,
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
		defined  $data_file
	) or 
	# gencode-list choice
	(
		defined  $gene_list_file and
		defined  $data_file
	) or
	# gencode choice
	(
		defined $data_file
	) or 
	# sequence choice
	(
		defined $id
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
	defined  $inpath
){
	print `perldoc $0`;
	exit 1;
}

# Get method's pipeline
unless ( defined $methods ) {
	$methods = join( ',',keys(%{$APPRIS_METHODS}) );
}

# Get the type of input (the order of conditions is important)
if ( defined $position and defined $data_file ) {
	$type_of_input = 'gencode-position';
}
elsif ( defined $gene_list_file and defined $data_file ) {	
	$type_of_input = 'gencode-list';
}
elsif ( defined $data_file ) {
	$type_of_input = 'gencode';
}
elsif ( defined $id ) {
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

#################
# Method bodies #
#################
sub insert_ensembl($$);
sub insert_gencode($$;$);
sub insert_pipeline($$;$);
sub insert_appris($$$);

# Main subroutine
sub main()
{
	# using gene list
	my ($gene_list);
	if ( defined $gene_list_file ) {
		$logger->info("-- using gene list\n");
		my ($genes) = getTotalStringFromFile($gene_list_file);
		foreach my $gene_id (@{$genes}) {
			$gene_id =~ s/\s*//mg;			
			$gene_list->{$gene_id} = 1;
		}		
	}
	
	# run appris pipeline for each gene depending on input
	$logger->info("-- from given input...");
	if ( ($type_of_input eq 'ensembl') or ($type_of_input eq 'ensembl-position') or ($type_of_input eq 'ensembl-list') ) {
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
		
		$logger->info("-- insert ensembl ids\n");
		my ($runtimes) = insert_ensembl($gene_list, $inpath);

	}
	elsif ( ($type_of_input eq 'gencode') or ($type_of_input eq 'gencode-position') or ($type_of_input eq 'gencode-list') ) {
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
			$gene_list = appris::get_gene_list($gene_list_file);
		}
		
		$logger->info("-- create gencode data files\n");
		my ($gencode_data) = appris::create_gencode_data($data_file);		
		
		# delete tmp file
		if ( defined $data_fh and UNIVERSAL::isa($data_fh,'File::Temp') ) {
			$data_fh->unlink_on_destroy(1);
		}

		$logger->info("-- run gencode data files\n");
		my ($runtimes) = insert_gencode($gencode_data, $inpath, $gene_list);
				
		$logger->info("-- print times\n");
		foreach my $runtime (@{$runtimes}) {
			#$logger->info($runtime->{'gene_id'}."\t".$runtime->{'run'});
		}
	}
	else {
		$logger->error("analying input parameters");
	}	
	
	$logger->finish_log();
	
	exit 0;	
}

sub insert_ensembl($$)
{
	my ($data, $inpath) = @_;
	my ($runtimes) = undef;
			
	foreach my $gene_id (keys(%{$data})) {
		my ($runtime) = insert_pipeline($gene_id, $inpath);
		push(@{$runtimes}, $runtime);		
	}
	return $runtimes;
} # end insert_ensembl

sub insert_gencode($$;$)
{
	my ($data, $inpath, $gene_list) = @_;
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
				my ($runtime) = insert_pipeline($gene_eid, $inpath, $gene);
				push(@{$runtimes}, $runtime);				
			}
		}
		else { # if there is not gene list, we run appris for all of them
			my ($runtime) = insert_pipeline($gene_eid, $inpath, $gene);
			push(@{$runtimes}, $runtime);			
		}
	}
	return $runtimes;
} # end insert_gencode

sub insert_pipeline($$;$)
{
	my ($gene_id, $inpath, $gene) = @_;
	my ($runtime) = undef;
	my ($workspace) = $inpath.'/';

	$logger->info("-- $gene_id\n");	
	
	# create parameters
	$logger->info("\t-- create parameters ");
	my ($params);
	# data from gencode type
	if ( defined $gene and defined $gene->chromosome ) {
		$logger->info("from gencode data\n");
		#my ($chr) = $gene->chromosome;
		#$workspace .= "chr$chr". '/'.$gene_id;
		$workspace .= $gene_id;
				
		$logger->info("\t-- prepare params\n");
		$params = {
			'id'				=> $gene_id,
			'species'			=> "'$species'",
			'e-version'			=> $e_version,
			'inpath'			=> $workspace,
			'methods'			=> $methods,
			'ensembldb-conf'	=> $ensembldb_conf_file,	
			'apprisdb-conf'		=> $apprisdb_conf_file,
		};
	}
	# data from ensembl type
	elsif ( defined $gene_id ) {
		$logger->info("from ensembl data\n");
		$workspace .= $gene_id;

		$logger->info("\t-- prepare params\n");		
		$params = {
			'id'				=> $gene_id,
			'species'			=> "'$species'",
			'e-version'			=> $e_version,
			'inpath'			=> $workspace,
			'methods'			=> $methods,
			'ensembldb-conf'	=> $ensembldb_conf_file,	
			'apprisdb-conf'		=> $apprisdb_conf_file,
		};
	}
	else {
		return $runtime;
	}
		
	# run appris pipeline
	if ( defined $params ) {
		
		# insert results of pipeline
		$logger->info("\t-- insert results\n");
		my ($inserttime) = insert_appris($gene_id, $workspace, $params);
		throw("inserting results") unless ( defined $inserttime );
				
		# create output
		#$runtime = {
		#	'gene_id'	=> $gene_id,			
		#	'insert'	=> $inserttime,
		#};
		return $runtime;		
		
	}
	else {
		$logger->info("\t-- do not run appris\n");
	}

	return $runtime;
	
} # end insert_pipeline

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
		my ($cmd) =	" perl $ENV{APPRIS_SCRIPTS_DIR}/iappris.pl ".
					" $parameters ".
					" --loglevel=$LOGLEVEL --logpath=$c_logpath --logfile=$c_logfile --logappend ";			
		$logger->info("\n** script: $cmd\n");
		my (@cmd_out) = `$cmd`;
	};
	throw("running appris") if($@);

} # end insert_appris


main();


1;

__END__

=head1 NAME

insert_appris

=head1 DESCRIPTION

global script that insert results of APPRIS into database 

=head1 SYNOPSIS

insert_appris

=head2 Input arguments:

	* Gencode choice: executes appris for one or more genes (using data from Gencode -cds, exons, seqs, etc.- )

		--data=  <Gene annotation file>
		
		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>

		--inpath= <Acquire input files from PATH>
			
	* Gencode-position choice: executes appris for a genome region (using data from Gencode -cds, exons, seqs, etc.- )

		--position= <Genome position> (21 or 21,22)
	
		--data=  <Gene annotation file>
		
		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>

		--inpath= <Acquire input files from PATH>
		
	* Gencode-list choice: executes appris for list of genes (using data from Gencode -cds, exons, seqs, etc.- )

		--gene-list=  <File with a list of genes>
	
		--data=  <Gene annotation file>
		
		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>

		--inpath= <Acquire input files from PATH>
		
	* Ensembl choice: executes appris for one gene (using data from Ensembl -api version- )

		--id= <Ensembl gene identifier>
		
		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>

		--inpath= <Acquire input files from PATH>
		
	* Ensembl-position choice: executes appris for a genome region (using data from Ensembl -api version- )

		--position= <Genome position> (21 or 21,22)
		
		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>

		--inpath= <Acquire input files from PATH>
		
	* Ensembl-list choice: executes appris for list of genes (using data from Ensembl -api version- )

		--gene-list=  <File with a list of genes>
	
		--species= <Name of species: Homo sapiens, Mus musculus, etc>
	
		--e-version= <Number of Ensembl version of identifier>

		--inpath= <Acquire input files from PATH>
						
=head2 Optional arguments:

		--methods= <List of APPRIS's methods ('ensembl,firestar,matador3d,spade,corsair,thump,crash,appris'. Default: ALL)>
		
		--ensembldb-conf <Config file of Ensembl database>
		
		--apprisdb-conf <Config file of APPRIS database>
				
=head2 Optional arguments (log arguments):
	
		--loglevel=LEVEL <define log level (default: NONE)>	
	
		--logfile=FILE <Log to FILE (default: *STDOUT)>
		
		--logpath=PATH <Write logfile to PATH (default: .)>
		
		--logappend= <Append to logfile (default: truncate)>


=head1 EXAMPLE

perl insert_appris.pl

	--id=ENSMUSG00000017167	

	--species='Mus musculus'
	
	--e-version=69
	
	--methods=firestar,matador3d
	
	--inpath=../features/ENSMUSG00000017167_e69/
	
	--apprisdb-conf=/home/jmrodriguez/projects/Encode/appris/scripts/conf/apprisdb.mus70.ini
	

=head1 EXAMPLE

perl insert_appris.pl

	--data=/home/jmrodriguez/projects/Encode/gencode15/features/chr21.gencode.v15.annotation.gtf
	
	--species='Homo sapiens'
	
	--e-version=70
	
	--methods=appris
	
	--inpath=/home/jmrodriguez/projects/Encode/gencode15/annotations/
	
	--loglevel=INFO
	
	--logappend
	
	--logpath=/home/jmrodriguez/projects/Encode/gencode15/logs/
			
	--logfile=insert_appris.log
	
=head1 EXAMPLE

perl insert_appris.pl

	--position=21
	
	--data=/home/jmrodriguez/projects/Encode/gencode15/features/gencode.v15.annotation.gtf
	
	--species='Homo sapiens'
	
	--e-version=70
	
	--methods=appris
	
	--inpath=/home/jmrodriguez/projects/Encode/gencode15/annotations/
	
	--loglevel=INFO
	
	--logappend
	
	--logpath=/home/jmrodriguez/projects/Encode/gencode15/logs/
			
	--logfile=insert_appris.log


=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
