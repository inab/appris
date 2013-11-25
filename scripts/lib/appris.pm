=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

appris - common process

=head1 SYNOPSIS

=head1 DESCRIPTION


=head1 METHODS

=cut

package appris;

use strict;
use warnings;
use File::Temp;

use APPRIS::Parser qw( parse_gencode );
use APPRIS::Utils::File qw( getTotalStringFromFile );
use APPRIS::Utils::Exception qw( info throw warning deprecate );

use Exporter;

use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(
	get_gene_list
	create_ensembl_input
	create_gencode_input
	create_gencode_data
);

=head2 get_gene_list

  Arg[1]      : (optional) String $text - notification text to present to user
  Example     : # run a code snipped conditionally
                if ($support->user_proceed("Run the next code snipped?")) {
                    # run some code
                }

                # exit if requested by user
                exit unless ($support->user_proceed("Want to continue?"));
  Description : If running interactively, the user is asked if he wants to
                perform a script action. If he doesn't, this section is skipped
                and the script proceeds with the code. When running
                non-interactively, the section is run by default.
  Return type : TRUE to proceed, FALSE to skip.
  Exceptions  : none
  Caller      : general

=cut

sub get_gene_list($)
{
	my ($file) = @_;
	my ($list);
	
	my ($genes) = getTotalStringFromFile($file);
	foreach my $gene_id (@{$genes}) {
		$gene_id =~ s/\s*//mg;			
		$list->{$gene_id} = 1;
	}
	return $list;
} # end get_gene_list

=head2 create_ensembl_input

  Arg[1]      : (optional) String $text - notification text to present to user
  Example     : # run a code snipped conditionally
                if ($support->user_proceed("Run the next code snipped?")) {
                    # run some code
                }

                # exit if requested by user
                exit unless ($support->user_proceed("Want to continue?"));
  Description : If running interactively, the user is asked if he wants to
                perform a script action. If he doesn't, this section is skipped
                and the script proceeds with the code. When running
                non-interactively, the section is run by default.
  Return type : TRUE to proceed, FALSE to skip.
  Exceptions  : none
  Caller      : general

=cut

sub create_ensembl_input($$$$)
{
	my ($position, $conf_file, $e_version, $species) = @_;
	my ($gene_list);
	
	# create ensembl registry from default config file
	my ($cfg) = new Config::IniFiles( -file => $conf_file );
	my ($e_core_param) = {
			'-host'       => $cfg->val( 'ENSEMBL_CORE_REGISTRY', 'host'),
			'-user'       => $cfg->val( 'ENSEMBL_CORE_REGISTRY', 'user'),
			'-pass'       => $cfg->val( 'ENSEMBL_CORE_REGISTRY', 'pass'),
			'-verbose'    => $cfg->val( 'ENSEMBL_CORE_REGISTRY', 'verbose'),
			'-db_version' => $e_version,
			'-species'    => $species,
	};
	info(
		"\t-host        => ".$cfg->val( 'ENSEMBL_CORE_REGISTRY', 'host')."\n".
		"\t-user        => ".$cfg->val( 'ENSEMBL_CORE_REGISTRY', 'user')."\n".
		"\t-pass        => ".$cfg->val( 'ENSEMBL_CORE_REGISTRY', 'pass')."\n".
		"\t-verbose     => ".$cfg->val( 'ENSEMBL_CORE_REGISTRY', 'verbose')."\n".
		"\t-db_version  => ".$e_version."\n".										
		"\t-species     => ".$species."\n"
	);
	my ($registry) = 'Bio::EnsEMBL::Registry';
	eval {
		$registry->load_registry_from_db(%{$e_core_param});
	};
	throw("can not load ensembl registry: $!\n") if $@;
		
	# create ensembl input for each position
	foreach my $pos ( split(',', $position) ) {
		if ( defined $pos ) {
			info("-- create input for $pos\n");
			$pos =~ s/^chr//;			
			my ($slice_adaptor) = $registry->get_adaptor( $species, 'Core', 'Slice' );
			my ($slice) = $slice_adaptor->fetch_by_region( 'chromosome', $pos );
			if ( defined $slice ) {
				my ($genes) = $slice->get_all_Genes();
				if ( defined $genes ) {
					while ( my $gene = shift @{$genes} ) {
						my ($gene_id) = $gene->stable_id().'.'.$gene->version();
						#$gene_list->{$gene_id} = $gene->chr_name();
						$gene_list->{$gene_id} = $gene->biotype();
					}					
				}
			}
		}		
	}
	
	return $gene_list;
	
} # end create_ensembl_input

=head2 create_gencode_input

  Arg[1]      : (optional) String $text - notification text to present to user
  Example     : # run a code snipped conditionally
                if ($support->user_proceed("Run the next code snipped?")) {
                    # run some code
                }

                # exit if requested by user
                exit unless ($support->user_proceed("Want to continue?"));
  Description : If running interactively, the user is asked if he wants to
                perform a script action. If he doesn't, this section is skipped
                and the script proceeds with the code. When running
                non-interactively, the section is run by default.
  Return type : TRUE to proceed, FALSE to skip.
  Exceptions  : none
  Caller      : general

=cut

sub create_gencode_input($;$;$)
{
	my ($data_file, $position, $gene_list) = @_;
	my ($data_tmpfile) = File::Temp->new( UNLINK => 0, SUFFIX => '.appris.dat' );
	my ($data_tmpfilename) = $data_tmpfile->filename;
		
	# customize data for a position
	if ( defined $position ) {
		foreach my $pos ( split(',', $position) ) {
			if ( defined $pos ) {
				eval {
					my ($cmd) =	"awk '{if(\$1==\"$pos\") {print \$0}}' $data_file >> $data_tmpfilename";
					info("** script: $cmd\n");
					my (@cmd_out) = `$cmd`;
				};
				throw("creating input for $pos") if($@);
			}		
		}		
	}
	# get customized data for a gene list
	elsif ( defined $gene_list ) {
		my ($g_cond) = '';	
		foreach my $g ( keys(%{$gene_list}) ) {
			$g_cond .= ' $10 ~ /'.$g.'/ ||'; # for rel7 version		
		}
		if ( $g_cond ne '' ) {
	    	$g_cond =~ s/\|\|$//;
	    	$g_cond = '('.$g_cond.')';			
			eval {
				my ($cmd) = "awk '{if(\$9==\"gene_id\" && $g_cond) {print \$0}}' $data_file >> $data_tmpfilename";
				info("** script: $cmd\n");
				my (@cmd_out) = `$cmd`;
			};
			throw("creating gencode data for genelist") if($@);			
		}		
	}	
	
	return $data_tmpfile;
	
} # end create_gencode_input

=head2 create_gencode_data

  Arg[1]      : (optional) String $text - notification text to present to user
  Example     : # run a code snipped conditionally
                if ($support->user_proceed("Run the next code snipped?")) {
                    # run some code
                }

                # exit if requested by user
                exit unless ($support->user_proceed("Want to continue?"));
  Description : If running interactively, the user is asked if he wants to
                perform a script action. If he doesn't, this section is skipped
                and the script proceeds with the code. When running
                non-interactively, the section is run by default.
  Return type : TRUE to proceed, FALSE to skip.
  Exceptions  : none
  Caller      : general

=cut

sub create_gencode_data($;$;$;$;$;$)
{
	my ($data_file, $transcripts_file, $translations_file, $conf_file, $e_version, $species) = @_;	
	my ($data_tmpfile) = File::Temp->new( UNLINK => 0, SUFFIX => '.appris.dat' );
	my ($data_tmpfilename) = $data_tmpfile->filename;
	
	# create ensembl registry from default config file
	my ($registry);
	if ( defined $conf_file and defined $e_version and defined $species ) {
		my ($cfg) = new Config::IniFiles( -file => $conf_file );
		my ($e_core_param) = {
				'-host'       => $cfg->val( 'ENSEMBL_CORE_REGISTRY', 'host'),
				'-user'       => $cfg->val( 'ENSEMBL_CORE_REGISTRY', 'user'),
				'-pass'       => $cfg->val( 'ENSEMBL_CORE_REGISTRY', 'pass'),
				'-verbose'    => $cfg->val( 'ENSEMBL_CORE_REGISTRY', 'verbose'),
				'-db_version' => $e_version,
				'-species'    => $species,
		};
		info(
			"\t-host        => ".$cfg->val( 'ENSEMBL_CORE_REGISTRY', 'host')."\n".
			"\t-user        => ".$cfg->val( 'ENSEMBL_CORE_REGISTRY', 'user')."\n".
			"\t-pass        => ".$cfg->val( 'ENSEMBL_CORE_REGISTRY', 'pass')."\n".
			"\t-verbose     => ".$cfg->val( 'ENSEMBL_CORE_REGISTRY', 'verbose')."\n".
			"\t-db_version  => ".$e_version."\n".										
			"\t-species     => ".$species."\n"
		);
		$registry = 'Bio::EnsEMBL::Registry';
		eval {
			$registry->load_registry_from_db(%{$e_core_param});
		};
		throw("can not load ensembl registry: $!\n") if $@;		
	}
	
	# create gencode object
	my ($gencode_data) = parse_gencode($data_file, $transcripts_file, $translations_file, $registry);
	unless ( defined $gencode_data ) {
		throw("can not create gencode object\n");
	}
	
	return $gencode_data;
	
} # end create_gencode_data

=head2 run_in_clusters

  Arg[1]      : (optional) String $text - notification text to present to user
  Example     : # run a code snipped conditionally
                if ($support->user_proceed("Run the next code snipped?")) {
                    # run some code
                }

                # exit if requested by user
                exit unless ($support->user_proceed("Want to continue?"));
  Description : If running interactively, the user is asked if he wants to
                perform a script action. If he doesn't, this section is skipped
                and the script proceeds with the code. When running
                non-interactively, the section is run by default.
  Return type : TRUE to proceed, FALSE to skip.
  Exceptions  : none
  Caller      : general

=cut

sub run_in_clusters($)
{
#	my ($params) = @_;
#	
#	my ($c_id) = $params->{'id'};
#	my ($c_e_version) = $params->{'e-version'};	
#
#	# prepare clusters	
#	$logger->info("-- prepare clusters\n");
#	my ($clusters) = new APPRIS::Utils::Clusters( -conf => $c_conf_file );
#	$logger->error("preparing clusters") unless (defined $clusters);
#	
#	# get free cluster
#	$logger->info("-- get free cluster");
#	my ($c_free) = $clusters->free();
#	while ( !$c_free ) {
#		$logger->info(".");
#		sleep(2);
#		$c_free = $clusters->free();
#	}
#	$logger->info("\n");
#	$logger->info("-- free cluster: $c_free\n");
#	
#	# create workspace in cluster
#	$logger->info("-- prepare job script for cluster\n");
#	#my ($ws_sp) = lc($species); $ws_sp =~ s/\s/\_/g;
#	#my ($c_wsbase) = $clusters->wspace($c_free).'/'.$ws_sp.'/'."e_$c_e_version".'/'.$c_id;
#	my ($c_wsbase) = $clusters->wspace($c_free).'/'.$c_id.'_e'.$c_e_version;	
#	my ($c_wspace) = $clusters->smkdir($c_free, $c_wsbase);
#	sleep(1);
#	$c_wspace = $clusters->wspace($c_free, $c_wsbase);
#	$logger->error("preparing cluster workspace") unless (defined $c_wspace);
#	sleep(1);
#	
#	# prepare inputs for cluster
#	my ($parameters) = '';
#	if ( exists $params->{'inpath'} ) {
#		my ($file) = $params->{'inpath'}; $file =~ s/\/*$//; $file .= '/*';
#		my ($c_file) = $clusters->dscopy($c_free, $c_wspace, $file);
#		$logger->error("copying $file into cluster") unless (defined $c_file);
#		$c_file =~ s/\/\*$//;
#		$parameters .= " --inpath=$c_file ";		
#	}
#	else {
#		if ( exists $params->{'data'} ) {
#			my ($file) = $params->{'data'};
#			my ($c_file) = $clusters->scopy($c_free, $c_wspace, $file);
#			$logger->error("copying $file into cluster") unless (defined $c_file);
#			$parameters .= " --annot=$c_file ";
#		}
#		if ( exists $params->{'pdata'} ) {
#			my ($file) = $params->{'pdata'};
#			my ($c_file) = $clusters->scopy($c_free, $c_wspace, $file);
#			$logger->error("copying $file into cluster") unless (defined $c_file);
#			$parameters .= " --pannot=$c_file ";
#		}
#		if ( exists $params->{'transc'} ) {
#			my ($file) = $params->{'transc'};
#			my ($c_file) = $clusters->scopy($c_free, $c_wspace, $file);
#			$logger->error("copying $file into cluster") unless (defined $c_file);
#			$parameters .= " --transc=$c_file ";
#		}
#		if ( exists $params->{'transl'} ) {
#			my ($file) = $params->{'transl'};
#			my ($c_file) = $clusters->scopy($c_free, $c_wspace, $file);
#			$logger->error("copying $file into cluster") unless (defined $c_file);
#			$parameters .= " --transl=$c_file ";
#		}		
#	}
#	sleep(2);
#	
#	# create scripts
#	# run program
#	my ($c_logpath) = $c_wspace;
#	my ($c_logfile) = $c_id.'.log';
#	my ($cmd) = "perl \$APPRIS_PROGRAMS_DIR/runner.pl ".
#					"--id=$c_id ".
#					"--species='$species' ".
#					"--e-version=$c_e_version ".
#					" $parameters ".
#					"--methods=$methods ".
#					"--outpath=$c_wspace ".
#					"--loglevel=$CLUSTER_LOGLEVEL --logpath=$c_logpath --logfile=$c_logfile --logappend ";
#	my ($l_host) = $clusters->host;
#	my ($l_user) = $clusters->user;
#	# copy results to host
#	my ($cmd2) = '';
#	#my ($cmd2) = "cd $c_wspace && tar -cf - $c_id* | ssh $l_user\@$l_host 'mkdir ".$params->{'outpath'}." && cd ".$params->{'outpath'}."; tar -xf - ' ";
#	#my ($cmd2) = "cd $c_wspace && tar -cf - $c_id* | ssh $l_user\@$l_host 'cd ".$params->{'outpath'}."; tar -xf - ' ";
#	# rm results of cluster
#	my ($cmd3) = '';
#	#my ($cmd3) = "rm -rf $c_wspace ";
#					
#	# create job script for cluster	
#	my ($c_script) = "source /home/inb/.bashrc && ".$cmd."\n\n".$cmd2."\n\n".$cmd3."\n\n";
#	my ($c_stderr) = $c_id.'.err';
#	my ($script) = $clusters->script($c_free, { 
#												'wdir'		=> $c_wspace,
#												'stdout'	=> $c_stderr,
#												'stderr'	=> $c_stderr,
#												'script'	=> $c_script,
#	});
#	$logger->error("creating job script for cluster") unless (defined $script);
#	$logger->debug("\n** script:\n $script\n");	
#	
#	# create local script that will execute into cluster
#	my ($l_script) = $outpath.'/'.$c_id.'.sh';
#	$l_script = printStringIntoFile($script, $l_script);
#	$logger->error("creating job script into local server") unless (defined $l_script);
#	sleep(1);
#
#	# submit job
#	$logger->info("-- submit job: ");
#	my ($job_id) = $clusters->submit($c_free, $l_script);
#	$logger->error("can not submit the job for $c_id: $!\n") unless (defined $job_id);
#	$logger->info("JOB_ID: $job_id\n");
	
} # end run_in_clusters

1;