=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Export::PROTEO - Utility functions for info exporting

=head1 SYNOPSIS

  use APPRIS::Export::PROTEO
    qw(
       get_trans_annotations
     );

  or to get all methods just

  use APPRIS::Export::PROTEO;

  eval { get_trans_annotations($feature,$version) };
  if ($@) {
    print "Caught exception:\n$@";
  }

=head1 DESCRIPTION

Retrieves information of transcript as GTF format.

=head1 METHODS

=cut

package APPRIS::Export::PROTEO;

use strict;
use warnings;
use Data::Dumper;
use Bio::Seq;
use Bio::SeqIO;
use FindBin;
use Exporter;

use APPRIS::Utils::Exception qw(throw warning deprecate);
use APPRIS::Utils::Constant qw(
	$OK_LABEL
	$NO_LABEL
	$UNKNOWN_LABEL
);
use APPRIS::Utils::File qw( getTotalStringFromFile );


use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(
	$RST_FILE
	get_proteo_report
);


###################
# Global variable #
###################
use vars qw(
	$GTF_CONSTANTS
	$RST_FILE
);

$GTF_CONSTANTS = {
	'appris'=>{
		'source'=>'APPRIS',
		'type'=>'principal_isoform',
		'annotation'=>['Principal Isoform','Possible Principal Isoform','No Principal Isoform']		
	},	
	'proteo'=>{
		'source'=>'PROTEO',
		'type'=>'peptide_evidence',
		#'annot'=>['exon_conservation','non-aligned_introns'],
	},
};
$RST_FILE = "$FindBin::Bin/PROTEO/gencode7.paper.tsv";


=head2 print_annotations

  Arg [1]    : String - common attributes
  Arg [2]    : String - optional attributes
  Example    : $annot = print_annotations($feature,$version);
  Description: Print the (common and optional) annotations.
  Returntype : String or undef

=cut

sub print_annotations {
	my ($common, $optional) = @_;
	
	my ($output)='';

	# <seqname> <source> <feature> <start> <end>  <score> <strand> <frame> [attributes] [comments]
	#  Print feature: Common feature
	$output .= 	$common->{'seqname'}."\t".
				$common->{'source'}."\t".
				$common->{'type'}."\t".
				$common->{'start'}."\t".
				$common->{'end'}."\t".
				$common->{'score'}."\t".
				$common->{'strand'}."\t".
				$common->{'phase'}."\t";

	#  Print feature
	while ( my ($key,$value) = each(%{$optional}) )
	{
		$output .= $key.' "'.$value.'"; ';
	}
	$output=~s/\; $/\n/;
	
	return $output;
}

sub get_appris_annotations2 {
	my ($transcript_id, $gene_id, $external_id, $feature, $method_type, $method_score, $appris_annot, $version) = @_;
	
	my ($output) = '';
	my ($method_phase) = '.';
	my ($method_source) = $GTF_CONSTANTS->{'appris'}->{'source'};

	# Common attributes
	my ($common) = {
			'seqname'	=> $feature->chromosome,
			'source'	=> $method_source,
			'type'		=> $method_type,
			'start'		=> $feature->start,
			'end'		=> $feature->end,
			'score'		=> $method_score,
			'strand'	=> $feature->strand,
			'phase'		=> $method_phase
	};
	
	# Optinal attributes
	my($optional);
	#$optional->{'annotation'}		= $appris_annot;
	$optional->{'gene_id'}			= $gene_id;
	$optional->{'transcript_id'}	= $transcript_id;
	$optional->{'transcript_name'}	= $external_id;
	$optional->{'version'}			= $version;		
	if (defined $common and defined $optional) {
		$output .= print_annotations($common,$optional);			
	}
	
	return $output;
	
} # End get_appris_annotations2

=head2 get_proteo_annotations

  Arg [1]    : String - the stable identifier of transcript
  Arg [2]    : String - the stable identifier of gene
  Arg [3]    : String - the external database name associated with transcript
  Arg [4]    : APPRIS::Transcript
  Arg [5]    : String - $version
  Example    : $annot = get_proteo_annotations($trans_id, $gen_id, $ext_id, $feat, $v);
  Description: Retrieves specific annotation.
  Returntype : String or undef

=cut

sub get_proteo_annotations {
	my ($transcript_id, $gene_id, $external_id, $feature, $version) = @_;

    my ($output) = '';
	my ($method_score) = 0;
	my ($method_phase) = '.';
	my ($method_source) = $GTF_CONSTANTS->{'proteo'}->{'source'};
	my ($method_type) = $GTF_CONSTANTS->{'proteo'}->{'type'};

	# Get annotations from file
	if ( -e $RST_FILE and (-s $RST_FILE > 0) ) {
		
		# get cont report
		my ($rst_report) = get_proteo_report($transcript_id);
		
		if ( defined $rst_report and exists $rst_report->{$transcript_id} ) {
							
			$method_score = $rst_report->{$transcript_id}->{'uniq_pep_num'};
			
			# common attributes
			my ($common) = {
					'seqname'	=> $feature->chromosome,
					'source'	=> $method_source,
					'type'		=> $method_type,
					'start'		=> $feature->start,
					'end'		=> $feature->end,
					'score'		=> $method_score,
					'strand'	=> $feature->strand,
					'phase'		=> $method_phase
			};
			# optinal attributes
			my($optional);
			$optional->{'gene_id'}			= $gene_id;
			$optional->{'transcript_id'}	= $transcript_id;
			$optional->{'transcript_name'}	= $external_id;
			$optional->{'version'}			= $version;
			if (defined $common and defined $optional) {
				$output .= print_annotations($common,$optional);			
			}				
			# get appris annotation
			$output .= get_appris_annotations2(	$transcript_id,
												$gene_id,
												$external_id,
												$feature,
												$method_type,
												$method_score,
												'',
												$version);				
		}
	}
	
	return $output;
	
} # End get_proteo_annotations

sub get_proteo_report($) {
	my ($transcript_id) = @_;
	my ($rst_report);		
	
	# get cont report
	#my ($rst_content) = APPRIS::Utils::File::getTotalStringFromFile($RST_FILE);
	my(@rst_content);
	eval {
		@rst_content=`grep "^$transcript_id" $RST_FILE`;
	};
	return $rst_report if($@);		
	
	#foreach my $rst_cont ( @{$rst_content} ) {
	foreach my $rst_cont ( @rst_content ) {			
		if ( $rst_cont =~ /([^\t]*)\t+([^\t]*)\t+([^\t]*)\t+([^\t]*)\t+([^\t]*)\t+([^\t]*)\t+([^\t]*)\t+([^\t]*)\t+([^\t]*)\t+([^\t]*)\t+([^\$]*)$/ ) {
			
			my ($rst_trans_id) = $1;
			my ($rst_gene_id) = $2;
			my ($rst_num_trans) = $3;
			my ($rst_appris_pred) = $4;
			my ($rst_trans_length) = $5;
			my ($rst_uniq_pep_num) = $6;
			my ($rst_uniq_coverage) = $7;
			my ($rst_shared_pep_num) = $8;
			my ($rst_shared_coverage) = $9;
			my ($rst_uniq_pep_names) = $10;
			my ($rst_shared_pep_names) = $11;
			
			$rst_report->{$rst_trans_id} = {
				'gene_id'			=> $rst_gene_id,
				'uniq_pep_num'		=> $rst_uniq_pep_num,
				'uniq_coverage'		=> $rst_uniq_coverage,
				'shared_pep_num'	=> $rst_shared_pep_num,
				'shared_coverage'	=> $rst_shared_coverage,
				'uniq_pep_names'	=> $rst_uniq_pep_names,
				'shared_pep_names'	=> $rst_shared_pep_names,
			}
		}			
	}
	return $rst_report;
	
} # End get_proteo_report

1;