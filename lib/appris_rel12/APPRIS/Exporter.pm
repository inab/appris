=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Exporter

=head1 SYNOPSIS

  $registry = APPRIS::Exporter->new(
    -dbhost  => 'localhost',
    -dbname  => 'homo_sapiens_encode_3c',
    -dbuser  => 'jmrodriguez'
    );

  $gene = $registry->fetch_by_stable_id($stable_id);

  @genes = @{ $registry->fetch_by_chr_start_end('X', 1, 10000) };

=head1 DESCRIPTION

All Adaptors are stored/registered using this module.
This module should then be used to get the adaptors needed.

The registry can be loaded from a configuration file or from database info.

=head1 METHODS

=cut

package APPRIS::Exporter;

use strict;
use warnings;
use Data::Dumper;
use Bio::Seq;
use Bio::SeqIO;

use APPRIS::Export::GTF;
use APPRIS::Export::SEQ;
use APPRIS::Export::BED;
use APPRIS::Export::JSON;
use APPRIS::Export::SVG;

use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);
use APPRIS::Utils::Constant qw(
        $API_VERSION
        $VERSION
        $DATE
);

my ($API_VERSION) = $APPRIS::Utils::Constant::API_VERSION;
my ($VERSION) = $APPRIS::Utils::Constant::VERSION;
my ($DATE) = $APPRIS::Utils::Constant::DATE;

{
    # Encapsulated class data
    #___________________________________________________________
    my %_attr_data = # DEFAULT
		(
		);
    #_____________________________________________________________

	# Classwide default value for a specified object attribute
	sub _default_for {
		my ($self, $attr) = @_;
		$_attr_data{$attr};
	}

	# List of names of all specified object attributes
	sub _standard_keys {
		keys %_attr_data;
	}	
}
=head2 new

  Example :

    APPRIS::Exporter->new()

  Description: Will load the correct versions of the appris
               databases for the software release it can find on a
               database instance into the registry.

  Exceptions : None.
  Status     : Stable

=cut

sub new {
	my ($caller, %args) = @_;
	
	my ($caller_is_obj) = ref($caller);
	return $caller if $caller_is_obj;
	my ($class) = $caller_is_obj || $caller;
	my ($self) = bless {}, $class;

	foreach my $attrname ($self->_standard_keys) {
		my ($attr) = "-".$attrname;
		if (exists $args{$attr} && defined $args{$attr}) {
			$self->{$attrname} = $args{$attr};
		} else {
			$self->{$attrname} = $self->_default_for($attrname);
		}
	}

	return $self;
}

=head2 software_version
  
  get the software version.
  
  Args       : none
  ReturnType : int
  Status     : At Risk
  
=cut
  
sub software_version {
	my ($self) = @_;
	return $API_VERSION;
}

=head2 date
  
  get the date of exported data.
  
  Args       : none
  ReturnType : string
  Status     : At Risk
  
=cut
  
sub date {
	my ($self) = @_;
	return $DATE;
}

=head2 version
  
  get the version of exported data.
  
  Args       : none
  ReturnType : string
  Status     : At Risk
  
=cut
  
sub version {
	my ($self) = @_;
	return $VERSION;
}

=head2 get_bed_annotations

  Arg [1]    : Listref of APPRIS::Gene or undef
  Arg [2]    : String - $position (optional)
               genome position (chr22:20116979-20137016)
  Arg [3]    : String - $head (optional)
               flag of head title ('yes','no','only')
  Arg [4]    : String - $source
               List of sources ('all', ... )           
  Example    : $annot = $exporter->get_bed_annotations($feature,'chr22:20116979-20137016','no','appris');
  Description: Retrieves text as BED format with the annotations.
  Returntype : String or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub get_bed_annotations {
    my ($self, $feature, $position, $head, $source) = @_;
    my ($output) = '';

	# IMPORTANT:
	# If we have a list of objects, BED annotations only for the first transcript.
	if ($feature and (ref($feature) eq 'ARRAY') ) { 
		$feature = $feature->[0];
	}
	
	# Get position if its not defined
	unless (defined $position) {
		my ($chr);
		my ($start);
		my ($end);
		if ($feature and (ref($feature) ne 'ARRAY')) {			
	    	if ($feature->isa("APPRIS::Gene") or $feature->isa("APPRIS::Transcript")) {
				$chr = $feature->chromosome;
				$start = $feature->start;
				$end = $feature->end;	    		
	    	}
		}
		#elsif ($feature and (ref($feature) eq 'ARRAY') ) { # in the case that we have a list of objects
    	#	foreach my $feat (@{$feature}) {
	    #		if ($feat->isa("APPRIS::Gene") or $feat->isa("APPRIS::Transcript")) {	    			
		#			$chr = $feat->chromosome unless (defined $chr);
		#			$start = $feat->start unless (defined $start);
		#			$end = $feat->end unless (defined $end);
	    #			
	    #			$start = $feat->start if ($feat->start < $start);
	    #			$end = $feat->end if ($feat->end > $end);
	    #		}
    	#	}
		#}
	    if ( defined $chr and defined $start and defined $end ) {
	    	$position = "chr$chr:$start\-$end";
	    }		
	}
	if (defined $position and ($position ne '')) {
		$output .= APPRIS::Export::BED::get_annotations($feature, $position, $source, $head, $self->version, $self->date);		
	}
    else {
		throw('Argument must be define');
    }
	return $output;
}

=head2 get_gtf_annotations

  Arg [1]    : Listref of APPRIS::Gene or APPRIS::Transcript or undef
  Arg [2]    : List of sources
  Example    : $annot = $exporter->get_gtf_annotations($feature,$source);
  Description: Retrieves text as GFF format with the annotations.
  Returntype : String or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub get_gtf_annotations {
    my ($self, $feature, $source) = @_;
    my ($output) = '';

	if ($feature and (ref($feature) ne 'ARRAY')) {
    	if ($feature->isa("APPRIS::Gene")) {
			foreach my $transcript (@{$feature->transcripts}) {
				$output .= APPRIS::Export::GTF::get_trans_annotations($transcript, $source, $self->version);
			}
    	}
    	elsif ($feature->isa("APPRIS::Transcript")) {
    		$output .= APPRIS::Export::GTF::get_trans_annotations($feature, $source, $self->version);
    	}
    	else {
			throw('Argument must be an APPRIS::Gene or APPRIS::Transcript');
    	}
    }
	elsif ($feature and (ref($feature) eq 'ARRAY') ) { # in the case that we have a list of objects
    	foreach my $feat (@{$feature}) {
	    	if ($feat->isa("APPRIS::Gene")) {
				foreach my $transcript (@{$feat->transcripts}) {
					$output .= APPRIS::Export::GTF::get_trans_annotations($transcript, $source, $self->version);
				}
	    	}
	    	elsif ($feat->isa("APPRIS::Transcript")) {
	    		$output .= APPRIS::Export::GTF::get_trans_annotations($feat, $source, $self->version);
	    	}
	    	else {
				throw('Argument must be an APPRIS::Gene or APPRIS::Transcript');
	    	}    		
    	}
	}
    else {
		throw('Argument must be define');
   	}
	return $output;
}

=head2 get_json_annotations

  Arg [1]    : Listref of APPRIS::Gene or APPRIS::Transcript or undef
  Arg [2]    : List of sources
  Example    : $annot = $exporter->get_json_annotations($feature,$source);
  Description: Retrieves text as JSON format with the annotations.
  Returntype : String or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub get_json_annotations {
    my ($self, $feature, $source) = @_;
    my ($output) = '';

	my ($gtf_output) = $self->get_gtf_annotations($feature, $source);
	$output .= APPRIS::Export::JSON::get_annotations($gtf_output);
	
	return $output;
}

=head2 get_seq_annotations

  Arg [1]    : Listref of APPRIS::Gene or APPRIS::Transcript or undef
  Arg [2]    : String $type
               type of sequence ('na' or 'aa')
  Arg [3]    : (optional) String $format
               format of output (by default 'fasta')
  Example    : $annot = $exporter->get_seq_annotations($feature,'aa');
  Description: Retrieves nucleotide o aminoacid sequence.
  Returntype : String or undef

=cut

sub get_seq_annotations {
    my ($self,$feature,$type,$format) = @_;
    my ($output) = '';

    if ($feature and ref($feature)) {
    	if ($feature->isa("APPRIS::Gene")) {
			foreach my $transcript (@{$feature->transcripts}) {
				$output .= APPRIS::Export::SEQ::get_trans_annotations($transcript,$type,$format);
			}
    	}
    	elsif ($feature->isa("APPRIS::Transcript")) {
    		$output .= APPRIS::Export::SEQ::get_trans_annotations($feature,$type,$format);
    	}
    	else {
			throw('Argument must be an APPRIS::Gene or APPRIS::Transcript');
    	}
    }
    else {
		throw('Argument must be define');
   	}
	return $output;
}

=head2 get_tab_annotations

  Arg [1]    : Listref of APPRIS::Gene or APPRIS::Transcript or undef
  Arg [2]    : Listred of String $params
  Example    : $annot = $exporter->get_tab_annotations($feature,$params);
  Description: Retrieves nucleotide o aminoacid sequence.
  Returntype : String or undef

=cut

# TODO: IMPLEMENT TAB LIBRARY
sub get_tab_annotations {
    my ($self,$feature,$params) = @_;
    my ($output) = '';

    if ($feature and ref($feature)) {
    	if ($feature->isa("APPRIS::Gene")) {
			foreach my $transcript (@{$feature->transcripts}) {
				$output .= APPRIS::Export::TAB::get_trans_annotations($transcript,$params);
			}
    	}
    	elsif ($feature->isa("APPRIS::Transcript")) {
    		$output .= APPRIS::Export::TAB::get_trans_annotations($feature,$params);
    	}
    	else {
			throw('Argument must be an APPRIS::Gene or APPRIS::Transcript');
    	}
    }
    else {
		throw('Argument must be define');
   	}
	return $output;
}

=head2 get_img_seq_annotations

  Arg [1]    : Listref of APPRIS::Gene or APPRIS::Transcript or undef
  Example    : $annot = $exporter->get_img_seq_annotations($feature);
  Description: Retrieves image of sequences.
  Returntype : String or undef

=cut

sub get_img_seq_annotations {
    my ($self,$feature) = @_;
    my ($output) = '';

    if ($feature and ref($feature)) {
    	if ($feature->isa("APPRIS::Gene")) {
			foreach my $transcript (@{$feature->transcripts}) {
				$output .= APPRIS::Export::SVG::get_trans_annotations($transcript);
			}
    	}
    	elsif ($feature->isa("APPRIS::Transcript")) {
    		$output .= APPRIS::Export::SVG::get_trans_annotations($feature);
    	}
    	else {
			throw('Argument must be an APPRIS::Gene or APPRIS::Transcript');
    	}
    }
    else {
		throw('Argument must be define');
   	}
	return $output;
}

=head2 get_res_annotations

  Arg [1]    : Listref of APPRIS::Gene or APPRIS::Transcript or undef
  Example    : $annot = $exporter->get_res_annotations($feature,'aa');
  Description: Retrieves residues of methods.
  Returntype : String or undef

=cut

sub get_res_annotations {
    my ($self,$feature) = @_;
    my ($output) = '';
    my ($report);

    if ($feature and ref($feature)) {
    	if ($feature->isa("APPRIS::Gene")) {
			foreach my $transcript (@{$feature->transcripts}) {
				$report = APPRIS::Export::RES::get_trans_residues($transcript);
			}
    	}
    	elsif ($feature->isa("APPRIS::Transcript")) {
    		$report = APPRIS::Export::RES::get_trans_residues($feature);
    	}
    	else {
			throw('Argument must be an APPRIS::Gene or APPRIS::Transcript');
    	}
    	if ( defined $report ) {
			$output .= APPRIS::Export::JSON::get_residues($report);
    	}
    }
    else {
		throw('Argument must be define');
   	}
	return $output;
}

sub DESTROY {}

1;
