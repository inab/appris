#!/usr/bin/perl -W
# _________________________________________________________________
# $Id$
# $Revision$
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________

use CGI qw(:standard);
use strict;
use FindBin;
use lib "$FindBin::Bin/lib";
use DB;
use Export;

use Data::Dumper;

###################
# Global variable #
###################
use vars qw($VERSION $DATE);

$VERSION='v28_rel3c';
$DATE='Aug-2011';

#################
# Method bodies #
#################
# Main subroutine
sub main()
{
	my($query_cgi)=new CGI;
	my($format)=lc($query_cgi->param('format'));
	Export::print_content('') unless(defined $format and $format ne '');

	my($position)=$query_cgi->param('position');
	Export::print_content('') unless(defined $position and $position ne '');

	my($head)=lc($query_cgi->param('head')); # Optional ('yes','no','only')

	# Get position info
	my($chromosome);
	my($chromosome_features);
	if($position=~/^chr(\w*)$/)
	{
		$chromosome=$1;
		$chromosome_features=DB::get_chromosome_report($chromosome);
		Export::print_content('') unless(ref($chromosome_features) eq 'HASH');
	}
	elsif($position=~/^chr(\w*):(\d*)-(\d*)$/)
	{
		$chromosome=$1;
		$chromosome_features=DB::get_chromosome_report_region($position);		
		Export::print_content('') unless(ref($chromosome_features) eq 'HASH');
	}
	else
	{
		Export::print_content('');
	}

	# Print data
	if($format eq 'bed')
	{
		my($output_content)=Export::get_bed_annotations($head,$position,$chromosome_features,$DATE,$VERSION);
		Export::print_content($output_content);		
	}
    elsif($format eq 'gtf')
    {
        my($output_content)=Export::get_das_annotations($chromosome_features,$VERSION);
        Export::print_content($output_content);
    }	
	else
	{
		Export::print_content('');
	}	
}



main();


1;


__END__

=head1 NAME

export_data

=head1 DESCRIPTION

CGI-BIN script that exports data from genomic position. The output data
is a text file whose format is 'gtf','gff3', or 'bed' 

=head1 VERSION

0.1

=head1 SYNOPSIS

export_data

	position= <Genome position> (chr22:20100000-20140000)
	
	format= <Output format> ('gtf','gff3','bed','havana_gtf')

	head= <Genome Borwser Head> ('yes','no','only')	

=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
