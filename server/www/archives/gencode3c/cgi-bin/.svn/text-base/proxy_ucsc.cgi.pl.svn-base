#!/usr/bin/perl -W
# _________________________________________________________________
# $Id$
# $Revision$
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________

use CGI qw(:standard);
use strict;
use warnings 'all';
use LWP::UserAgent;
use HTML::TreeBuilder;
#use Image::Size;
use JSON;

use Data::Dumper;

###################
# Global variable #
###################
use vars qw($UCSC_CGI $UCSC_URL $APPRIS_URL);

$UCSC_CGI="http://genome.ucsc.edu/cgi-bin/";
$UCSC_URL="http://genome.ucsc.edu/cgi-bin/hgTracks";
#$UCSC_CGI="http://ucsc.cnio.es/cgi-bin/";
#$UCSC_URL="http://ucsc.cnio.es/cgi-bin/hgTracks";

$APPRIS_URL="http://appris.bioinfo.cnio.es/archives/gencode3c/cgi-bin/export_data.cgi";

#####################
# Method prototypes #
#####################

#################
# Method bodies #
#################
sub print_content($$)
{
	my($report,$num_exit)=@_;
	
	print STDOUT "Content-type: application/json\n\n";
	print STDOUT $report;
	exit $num_exit;
}

# Main subroutine
sub main()
{
	my($query_cgi)=new CGI;
	
	my($position)=$query_cgi->param('position');
	print_content('',1) unless(defined $position and $position ne '' and ($position=~/^chr(\w*)$/ or $position=~/^chr(\w*):(\d*)-(\d*)$/));
	
	my($format)=$query_cgi->param('format');
	print_content('',1) unless(defined $format and $format ne '');

	my($head)=$query_cgi->param('head'); # Optional

	my($appris_export_data_url)=$APPRIS_URL.'?';
	$appris_export_data_url.='position='.$position.'%26';
	$appris_export_data_url.='format='.$format;
	$appris_export_data_url.='%26'.'head='.$head if(defined $head);

	my($request);
	eval{
		$request = HTTP::Request->new("GET",$UCSC_URL,HTTP::Headers->new(),
											'db=hg19'.'&'.
											'position='.$position.'&'.
											'hgt.customText='.$appris_export_data_url
		);
	};
	print_content('',1) if($@);

	my($ua)=LWP::UserAgent->new;
	my($req)=$ua->request($request);
	if ($req->is_error())
	{
		my $status = $req->status_line;
		print_content('',1);
	}
	else
	{
		my($http_response)=$req->content();
		# Check if there were some error
		if($http_response=~/warnList.innerHTML/)
		{
			print_content('',1);
		}
		
		my($parser);
		eval {
			$parser=HTML::TreeBuilder->new_from_content($http_response);
		};
		print_content('',1) if($@);

		# Find UCSC url of images: side and hgt
		my($img_table)=$parser->find_by_attribute('id','imgTbl');
		my($row_data_ruler)=$img_table->find_by_attribute('id','td_data_ruler');
		my($img_data_ruler)=$row_data_ruler->find_by_attribute('id','img_data_ruler');
		my($img_data_ruler_src)=$img_data_ruler->attr('src');
		my($img_data_ruler_url)=$UCSC_CGI.$img_data_ruler_src;
		
		my($row_side_ruler)=$img_table->find_by_attribute('id','td_side_ruler');
		my($img_side_ruler)=$row_side_ruler->find_by_attribute('id','img_side_ruler');
		my($img_side_ruler_src)=$img_side_ruler->attr('src');
		my($img_side_ruler_url)=$UCSC_CGI.$img_side_ruler_src;
		

		my ($json) = '';
		if ( ($img_side_ruler_url ne '') and ($img_side_ruler_url ne '') ) {
			$json = qq{{"side" : "$img_side_ruler_url", "hgt" : "$img_data_ruler_url"}};	
		} else {
			$json = qq{{"error" : "ucsc problems"}};
		}
		 
		print_content($json,0);
	}
}

main();


1;


__END__

=head1 NAME



=head1 DESCRIPTION

CGI-BIN script that retrieves report from given gene calling BioMart database.

=head1 VERSION

0.1

=head1 SYNOPSIS


=head1 AUTHOR

Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es- (INB-GN2,CNIO)

=cut
