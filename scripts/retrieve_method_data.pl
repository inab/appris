#!/usr/bin/perl -W

use strict;
use warnings;
use Getopt::Long;
use FindBin;

use APPRIS::Registry;
use APPRIS::Exporter;
use APPRIS::Utils::File qw( updateStringIntoFile );
use APPRIS::Utils::Logger;

use Data::Dumper;

###################
# Global variable #
###################
use vars qw(
	$LOCAL_PWD
	$CONFIG_INI_APPRIS_DB_FILE
);

$LOCAL_PWD					= $FindBin::Bin; $LOCAL_PWD =~ s/bin//;
$CONFIG_INI_APPRIS_DB_FILE	= $LOCAL_PWD.'/conf/apprisdb.ini';
#$METHODS = ['appris','firestar','matador3d','spade','corsair','inertia','crash','thump','cexonic','proteo'];
# TEMPORAL SOLUTION!!!!
$ENV{APPRIS_METHODS}="firestar,matador3d,spade,corsair,thump,crash,appris";
# TEMPORAL SOLUTION!!!!

# Input parameters
my ($chr) = undef;
my ($format) = undef;
my ($output_file) = undef;
my ($apprisdb_conf_file) = undef;
my ($logfile) = undef;
my ($logpath) = undef;
my ($logappend) = undef;
my ($loglevel) = undef;
&GetOptions(
	'chr=s'				=> \$chr,
	'format=s'			=> \$format,
	'output=s'			=> \$output_file,
	'apprisdb-conf=s'	=> \$apprisdb_conf_file,
	'loglevel=s'		=> \$loglevel,
	'logfile=s'			=> \$logfile,
	'logpath=s'			=> \$logpath,
	'logappend'			=> \$logappend,
);
unless(defined $format and defined $output_file)
{
	print `perldoc $0`;
	exit 1;
}

# Optional arguments
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


#####################
# Method prototypes #
#####################
sub get_data_by_chr($$);
sub get_data_by_method($$);


#################
# Method bodies #
#################
# Main subroutine
sub main()
{
	# Check inputs
	if (defined $format and ($format ne '')) {
		$format = lc($format);
		unless (($format ne '') and ( ($format eq 'gtf') or ($format eq 'gff3') or ($format eq 'bed') or ($format eq 'json') ) ) {
			print `perldoc $0`;
			exit 1;
		}
	}	
	
	# APPRIS Registry
	# The Registry system allows to tell your programs where to find the APPRIS databases and how to connect to them.
	my ($registry) = APPRIS::Registry->new();
	$registry->load_registry_from_ini(-file	=> $apprisdb_conf_file);	
	
	# Get annotations from given chr
	my ($output_report) = get_data_by_chr($registry, $chr);
	if ( defined $output_report ) {
		while ( my ($met,$met_out) = each(%{$output_report}) ) {
			if ( $met_out ne '' ) {
				my ($met_file) = $output_file.'.'.$met.'.'.$format;
				my ($printing_file_log) = updateStringIntoFile($met_out,$met_file);
				die ("ERROR: printing $chr:$met ") unless(defined $printing_file_log);						
			}				
		}
	}	

	$logger->finish_log();
	
	exit 0;	
	
}
sub get_data_by_chr($$)
{
	my ($registry, $chr) = @_;
	my ($output_report);
	my ($chromosome) = $registry->fetch_by_region($chr);

	foreach my $method ( split(',',$ENV{APPRIS_METHODS}) ) {
		$logger->debug("#method $method -------\n");
		$output_report->{$method} = get_data_by_method($chromosome,$method);
	}
	return $output_report;
}
sub get_data_by_method($$)
{
	my ($chromosome, $method) = @_;
	my ($output) = '';

	foreach my $gene (@{$chromosome}) {
		my ($gene_id) = $gene->stable_id;
		$logger->debug("#gene $gene_id -------\n");
		
		# Print data
		my ($out) = '';
		if ($gene and $format eq 'bed') {
			my ($position); # get position param
			my ($exporter) = APPRIS::Exporter->new();
			my ($head) = 'no';
			$output .= $exporter->get_bed_annotations($gene, $position, $head, $method);
		}
		elsif ($gene and $format eq 'gtf') {
			my ($exporter) = APPRIS::Exporter->new();
			$output .= $exporter->get_gtf_annotations($gene, $method);
	    }
		elsif ($gene and $format eq 'gff3') {
			my ($exporter) = APPRIS::Exporter->new();
			$output .= $exporter->get_gff3_annotations($gene, $method);
	    }
		elsif ($gene and $format eq 'json') {
			my ($exporter) = APPRIS::Exporter->new();
			$output .= $exporter->get_json_annotations($gene, $method);
    	}
    	$output .= $out;    	
    	$logger->debug("empty response\n") unless ( $out eq '' ); 
		$logger->debug("\n");
	}
	return $output;
}

main();


1;

__END__

=head1 NAME

retrieve_method_data

=head1 DESCRIPTION

Get the annotations of methods in several formats

=head1 SYNOPSIS

retrieve_method_data

=head2 Required arguments:

	--format <Output format: 'gtf', 'bed', or 'json'>
	
	--output <Output file that has method's annotations>
	
=head2 Optional arguments:

	--chr  <Genomic region>
	
	--apprisdb-conf <Config file of APPRIS database>
				
=head2 Optional arguments (log arguments):

	--loglevel=LEVEL <define log level (default: NONE)>	

	--logfile=FILE <Log to FILE (default: *STDOUT)>
	
	--logpath=PATH <Write logfile to PATH (default: .)>
	
	--logappend <Append to logfile (default: truncate)>


=head1 EXAMPLE

	perl retrieve_method_data.pl

		--chr=chr21
		
		--format=gtf
		
		--output=../features/data/appris.results.rel7.v1.chr21
	

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
