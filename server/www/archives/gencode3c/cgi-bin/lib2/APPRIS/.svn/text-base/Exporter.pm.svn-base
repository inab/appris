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

# TODO: EXPORT AS GTF AND BED FORMAT
#use APPRIS::Export::GTF qw(get_annotations);
#use APPRIS::Export::BED qw(get_annotations);
use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);

my ($API_VERSION) = 'rel3c';
my ($VERSION) = 'rel3c_3.0';
my ($DATE) = '13-Jul-2010';

my ($CONSTANT_TAB_ANNOTATTIONS) = {
	'identifier' => undef,
	'class' => undef,
	'status' => undef,
	'level' => undef,
	'external_name' => undef,
	'length_na' => undef,
	'length_aa' => undef,
	'principal_isoform' => undef,
	'principal_isoform_source' => undef	
};

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
  Arg [2]    : String $position
               genome position (chr22:20116979-20137016)
  Arg [3]    : (optional) String $head
               flag of head title ('yes','no','only')
  Example    : $annot = $exporter->get_bed_annotations($feature,'chr22:20116979-20137016');
  Description: Retrieves text as BED format with the annotations.
  Returntype : String or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub get_bed_annotations {
    my ($self,$feature,$position,$head) = @_;
    
	my($head_tracks)='';
	my($content_tracks)='';
	
    if (defined $head and $head eq 'only')
    {
    	
		if($position=~/^chr([^\:]*):([^\-]*)-([^\$]*)$/)
		{
			my($chromosome)=$1;
			my($start)=$2;
			my($end)=$3;
			if (defined $chromosome and defined $start and defined $end)
			{
		        $head_tracks .=	"browser pack ensGene ccdsGene\n".
		        				"track name=Empty description='' visibility=0 color='255,255,255'\n".
		        				"chr$chromosome\t$start\t$end\n";
			}
		}
    }
    else # We add the content track (head=> yes | no, position)
    {
		if (defined $head and $head eq 'yes')
		{
			$head_tracks .= "browser pack ensGene ccdsGene\n";
	    }
	    my($report_tracks); 
	    $report_tracks=APPRIS::Export::BED::get_annotations('appris',$feature);
		$report_tracks=APPRIS::Export::BED::get_annotations('firestar',$feature);
	    $report_tracks=APPRIS::Export::BED::get_annotations('matador3d',$feature);
		$report_tracks=APPRIS::Export::BED::get_annotations('pfamscan',$feature);
		$report_tracks=APPRIS::Export::BED::get_annotations('inertia',$feature);
		$report_tracks=APPRIS::Export::BED::get_annotations('crash',$feature);   
		$report_tracks=APPRIS::Export::BED::get_annotations('thump',$feature);   
		$report_tracks=APPRIS::Export::BED::get_annotations('cexonic',$feature); 
		$report_tracks=APPRIS::Export::BED::get_annotations('corsair',$feature); 
	    
		$content_tracks .= APPRIS::Export::BED::print_annotations($report_tracks);			
    }

    my($output_content)=
            "# --------------------------------------------------------------------------------------#\n".
            "# Date: $DATE                                                                     #\n".
            "# Version: $VERSION                                                                    #\n".
            "# Description: Annotations for determining principal splice isoforms (APPRIS)           #\n".
            "# note: the start values of tracks are -1 due the UCSC Genome Growser does not so good. #\n".          
            "# --------------------------------------------------------------------------------------#\n".
            "browser position $position"."\n".
            "browser pix 800"."\n".
            "browser hide all"."\n".

			$head_tracks .
			
            $content_tracks ;

    return $output_content;
    
}

=head2 get_das_annotations

  Arg [1]    : Listref of APPRIS::Gene or undef
  Arg [2]    : String $position
               genome position (chr22:20116979-20137016)
  Arg [3]    : (optional) String $head
               flag of head title ('yes','no','only')
  Example    : $annot = $exporter->get_bed_annotations($feature,'chr22:20116979-20137016');
  Description: Retrieves text as BED format with the annotations.
  Returntype : String or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub get_das_annotations {
    my ($chromosome_features)=@_;
    
    my($output_content)='';
    
    # Scan all genes
    while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
    {
        my($chromosome)='chr'.$gene_features->{'chr'};

        # Variable to GTF output file
        my($csv_transcript_content)='';     
        my($exist_signal_peptide)=0; # Flag that controls if exist signal peptide for one transcript of a gene
        my($exist_mitochondrial_signal)=0; # Flag that controls if exist mitochondrial signal for one transcript of a gene

                
        # Scan all transcripts
        while(my($transcript_id, $transcript_features)=each(%{$gene_features->{'transcripts'}}))
        {
            my($trans_coordinate)={
                'chr'=>$chromosome,
                'start'=>0,
                'end'=>0,
                'strand'=>'.'
            };
            $trans_coordinate->{'start'}=$transcript_features->{'start'} if(exists $transcript_features->{'start'} and defined $transcript_features->{'start'});
            $trans_coordinate->{'end'}=$transcript_features->{'end'} if(exists $transcript_features->{'end'} and defined $transcript_features->{'end'});
            $trans_coordinate->{'strand'}=$transcript_features->{'strand'} if(exists $transcript_features->{'strand'} and defined $transcript_features->{'strand'});
                        
            # Get Principal Isoform Annotations     
            my($principal_isoform_annotation)=DB::get_principal_isoform_annotations($transcript_id);

            # Check transcript class
            if(defined $principal_isoform_annotation)
            {
                my($identifiers)={
                    'gene_id'=>$gene_id,
                    'transcript_id'=>$transcript_id
                };
                $identifiers->{'external_id'}=$transcript_features->{'external_id'} if(exists $transcript_features->{'external_id'} and defined $transcript_features->{'external_id'});
                
                # Scan peptide
                if(defined $transcript_id and exists $transcript_features->{'peptide'} and defined $transcript_features->{'peptide'})
                {
                    while(my($peptide_id, $peptide_features)=each(%{$transcript_features->{'peptide'}}))
                    {
                        if(exists $peptide_features->{'sequence'} and defined $peptide_features->{'sequence'})
                        {
                            # Get APPRIS Annotations
                            if(exists $principal_isoform_annotation->{'principal_isoform'} and defined $principal_isoform_annotation->{'principal_isoform'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'principal_isoform'};
                                my($appris_source_annotation)='';
                                $appris_source_annotation=$principal_isoform_annotation->{'source'} if(exists $principal_isoform_annotation->{'source'} and defined $principal_isoform_annotation->{'source'});                             
                                $output_content.=APPRIS::Export::GTF::getAPPRISAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$appris_source_annotation,$VERSION);
                            }
                            # Get firestar Annotations
                            if(exists $principal_isoform_annotation->{'functional_residue'} and defined $principal_isoform_annotation->{'functional_residue'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'functional_residue'};
                                $output_content.=APPRIS::Export::GTF::getFirestarAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$VERSION);
                            } 
                            # Get Matador3D Annotations                         
                            if(exists $principal_isoform_annotation->{'conservation_structure'} and defined $principal_isoform_annotation->{'conservation_structure'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'conservation_structure'};
                                $output_content.=APPRIS::Export::GTF::getMatador3DAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$VERSION);
                            }
                            # Get PfamScan Annotations
                            if(exists $principal_isoform_annotation->{'domain_signal'} and defined $principal_isoform_annotation->{'domain_signal'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'domain_signal'};
                                $output_content.=APPRIS::Export::GTF::getPfamScanAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$VERSION);
                            }
                            # Get INERTIA Annotations
                            if(exists $principal_isoform_annotation->{'unusual_evolution'} and defined $principal_isoform_annotation->{'unusual_evolution'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'unusual_evolution'};
                                $output_content.=APPRIS::Export::GTF::getInertiaAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$VERSION);
                            }
                            # Get CRASH Annotations
                            if(exists $principal_isoform_annotation->{'peptide_signal'} and defined $principal_isoform_annotation->{'peptide_signal'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'peptide_signal'};
                                $output_content.=APPRIS::Export::GTF::getSignalPAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$VERSION);
                            }
                            if(exists $principal_isoform_annotation->{'mitochondrial_signal'} and defined $principal_isoform_annotation->{'mitochondrial_signal'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'mitochondrial_signal'};
                                $output_content.=APPRIS::Export::GTF::getTargetPAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$VERSION);
                            }
                            # Get THUMP Annotations
                            if(exists $principal_isoform_annotation->{'transmembrane_signal'} and defined $principal_isoform_annotation->{'transmembrane_signal'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'transmembrane_signal'};
                                $output_content.=APPRIS::Export::GTF::getTHUMPAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$VERSION);
                            }
                            # Get CExonic Annotations
                            if(exists $principal_isoform_annotation->{'conservation_exon'} and defined $principal_isoform_annotation->{'conservation_exon'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'conservation_exon'};
                                $output_content.=APPRIS::Export::GTF::getCExonicAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$VERSION);
                            }
                            # Get CORSAIR Annotations
                            if(exists $principal_isoform_annotation->{'vertebrate_signal'} and defined $principal_isoform_annotation->{'vertebrate_signal'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'vertebrate_signal'};
                                $output_content.=APPRIS::Export::GTF::getCORSAIRAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$VERSION);
                            }                           
                        }               
                    }
                }
            }               
        } # end transcript loop
    } # end gene loop
    
    return $output_content;    
}

=head2 get_sequences

  Arg [1]    : Listref of APPRIS::Gene or APPRIS::Transcript or undef
  Arg [2]    : String $type
               type of sequence ('na' or 'aa')
  Arg [3]    : (optional) String $format
               format of output (by default 'fasta')
  Example    : $annot = $exporter->get_sequences($feature,'aa');
  Description: Retrieves nucleotide o aminoacid sequence.
  Returntype : String or undef

=cut

sub get_sequences {
    my ($self,$feature,$type,$format) = @_;
    my ($output) = '';

    if ($feature and ref($feature)) {
    	if ($feature->isa("APPRIS::Gene")) {
			foreach my $transcript (@{$feature->transcripts}) {
				$output .= $self->get_trans_sequences($transcript,$type,$format);
			}
    	}
    	elsif ($feature->isa("APPRIS::Transcript")) {
    		$output .= $self->get_trans_sequences($feature,$type,$format);
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

=head2 get_trans_sequences

  Arg [1]    : Listref of APPRIS::Gene or APPRIS::Transcript or undef
  Arg [2]    : String $type
               type of sequence ('na' or 'aa')
  Arg [3]    : (optional) String $format
               format of output (by default 'fasta')
  Example    : $annot = $exporter->get_trans_sequences($feature,'aa');
  Description: Retrieves nucleotide o aminoacid sequence.
  Returntype : String or undef

=cut

sub get_trans_sequences {
    my ($self,$feature,$type,$format) = @_;
    my ($output) = '';
	my ($num_residues) = 70;
	
    if (ref($feature) and $feature->isa("APPRIS::Transcript")) {
		my ($id);
		my ($sequence);
		if ($feature->stable_id) {
			$id = $feature->stable_id;
			if ($type eq 'na') {
				if ($feature->sequence) {
					$sequence = $feature->sequence;
				}						
			} elsif ($type eq 'aa') {
				if ($feature->translate and $feature->translate->sequence) {
					$sequence = $feature->translate->sequence;
				}
			}
			my ($main_id) = ''; 
			foreach my $xref_identify (@{$feature->xref_identify}) {
				if (($xref_identify->dbname eq 'Ensembl_Gene_Id') and $xref_identify->id) {
					$main_id = $xref_identify->id;
				}
			}
			my ($ext_name) = '';
			$ext_name = $feature->external_name if ($feature->external_name);
			
			if (defined $id and defined $sequence) {
				my($seqobj)=Bio::Seq->new(
					-display_id => $id,
					-seq => $sequence
				);
				my ($slength) = $seqobj->length;
				$output .= ">".$id."|".$main_id."|".$ext_name."|".$slength."\n";
				my ($index) = 1;
				while($index < $slength) {
					my ($send) = $num_residues+$index-1;
					$send = $slength if ($send >= $slength);
					$output .= $seqobj->subseq($index,$send)."\n";
					$index = $send+1;	
				}
			}
		}		
    }
    else {
		throw('Argument must be an APPRIS::Transcript');
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

sub get_tab_annotations {
    my ($self,$feature,$params) = @_;
    my ($output) = '';

    if ($feature and ref($feature)) {
    	if ($feature->isa("APPRIS::Gene")) {
			foreach my $transcript (@{$feature->transcripts}) {
				$output .= $self->get_trans_tab_annotations($transcript,$params);
			}
    	}
    	elsif ($feature->isa("APPRIS::Transcript")) {
    		$output .= $self->get_trans_tab_annotations($feature,$params);
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

=head2 get_trans_tab_annotations

  Arg [1]    : Listref of APPRIS::Transcript or undef
  Arg [2]    : Listred of String $params
  Example    : $annot = $exporter->get_trans_tab_annotations($feature,$params);
  Description: Retrieves nucleotide o aminoacid sequence.
  Returntype : String or undef

=cut

sub get_trans_tab_annotations {
    my ($self,$feature,$params) = @_;
    my ($output) = '';
	
    if (ref($feature) and $feature->isa("APPRIS::Transcript")) {
    	
    	# Init tab annotations
    	my ($constant_tab_annots);
    	while ( my($key,$value) = each(%{$CONSTANT_TAB_ANNOTATTIONS}) ) {
    		$constant_tab_annots->{$key} = $value;
    	}
		
		if ($feature->stable_id) {
			$constant_tab_annots->{'identifier'} = $feature->stable_id;

			if ($feature->chromosome) {
				$constant_tab_annots->{'chr'} = $feature->chromosome;
			}	
			if ($feature->start) {
				$constant_tab_annots->{'start'} = $feature->start;
			}	
			if ($feature->end) {
				$constant_tab_annots->{'end'} = $feature->end;
			}	
			if ($feature->strand) {
				$constant_tab_annots->{'strand'} = $feature->strand;
			}	
			if ($feature->biotype) {
				$constant_tab_annots->{'class'} = $feature->biotype;
			}	
			if ($feature->status) {
				$constant_tab_annots->{'status'} = $feature->status;
			}	
			if ($feature->level) {
				$constant_tab_annots->{'level'} = $feature->level;
			}	
			if ($feature->external_name) {
				$constant_tab_annots->{'external_name'} = $feature->external_name;
			}	
			if ($feature->sequence) {
				$constant_tab_annots->{'length_na'} = length($feature->sequence);
			}						
			if ($feature->translate and $feature->translate->sequence) {
				$constant_tab_annots->{'length_aa'} = length($feature->translate->sequence);
			}
			if ($feature->analysis->appris and $feature->analysis->appris->principal_isoform) {
				$constant_tab_annots->{'principal_isoform'} = $feature->analysis->appris->principal_isoform;			
			}
			if ($feature->analysis->appris and $feature->analysis->appris->source) {
				$constant_tab_annots->{'principal_isoform_source'} = $feature->analysis->appris->source;			
			}
			
			# Xref identity
			foreach my $xref_identify (@{$feature->xref_identify}) {
				if (($xref_identify->dbname eq 'Ensembl_Gene_Id') and $xref_identify->id) {
					$constant_tab_annots->{'gene'} = $xref_identify->id;
				}
				elsif (($xref_identify->dbname eq 'CCDS') and $xref_identify->id) {
					$constant_tab_annots->{'ccds_id'} = $xref_identify->id;
				}
			}
			
			# Tags: CDS start not found, CDS end not found
			if ($feature->translate and $feature->translate->codons) {
				my ($start_codon);
				my ($stop_codon);
				foreach my $codon (@{$feature->translate->codons}) {
					if ($codon->type and $codon->type eq 'start') {
						$start_codon = 1;
					}
					elsif ($codon->type and $codon->type eq 'stop') {
						$stop_codon = 1;
					}
				}
				if ( !(defined $start_codon) and !(defined $stop_codon) ) {
					$constant_tab_annots->{'codons_not_found'} = 'start_stop' 
				}				
				elsif ( !(defined $start_codon) and defined $stop_codon ) {
					$constant_tab_annots->{'codons_not_found'} = 'start' 
				}
				elsif ( defined $start_codon and !(defined $stop_codon) ) {
					$constant_tab_annots->{'codons_not_found'} = 'stop' 
				}
			}
			
			# Print output
			foreach my $param (@{$params}) {
				if (exists $constant_tab_annots->{$param} and defined $constant_tab_annots->{$param}) {
					$output .= $constant_tab_annots->{$param}."\t";
				} else {
					$output .= '-'."\t";
				}
			}
			if (defined $output and $output ne '') {
				$output =~ s/\t$/\n/;
			}
		}		
    }
    else {
		throw('Argument must be an APPRIS::Transcript');
   	}
	return $output;
}


sub DESTROY {}

1;
