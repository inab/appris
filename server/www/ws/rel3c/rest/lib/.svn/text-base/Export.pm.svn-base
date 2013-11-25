# _________________________________________________________________
# $Id$
# $Revision$
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________
package Export;

use strict;
use warnings;
require Export::BED;
require Export::GFF;
#use Export::BED;
#use Export::GFF;


#####################
# Method prototypes #
#####################
sub print_content($);
sub get_bed_annotations($$$$$);
sub get_das_annotations($$);


#################
# Method bodies #
#################
sub print_content($)
{
	my($output_report)=@_;
	
	print STDOUT "Content-type: text/plain\n\n";
	print STDOUT $output_report;
	
	exit 0;		
}
sub get_bed_annotations($$$$$)
{
    my ($head,$position,$chromosome_features,$date,$version)=@_;
    
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
		        $head_tracks .=	"browser full ensGene ccdsGene\n".
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
	    $report_tracks=Export::BED::getAnnotations('appris',$chromosome_features);
		$report_tracks=Export::BED::getAnnotations('firestar',$chromosome_features);
	    $report_tracks=Export::BED::getAnnotations('matador3d',$chromosome_features);
		$report_tracks=Export::BED::getAnnotations('spade',$chromosome_features);
		$report_tracks=Export::BED::getAnnotations('inertia',$chromosome_features);
		$report_tracks=Export::BED::getAnnotations('crash',$chromosome_features);   
		$report_tracks=Export::BED::getAnnotations('thump',$chromosome_features);   
		$report_tracks=Export::BED::getAnnotations('cexonic',$chromosome_features); 
		$report_tracks=Export::BED::getAnnotations('corsair',$chromosome_features); 
	    
		$content_tracks .= Export::BED::printAnnotations($report_tracks);			
    }

    my($output_content)=
            "# --------------------------------------------------------------------------------------#\n".
            "# Date: $date                                                                        #\n".
            "# Version: $version                                                                    #\n".
            "# Description: Annotations for determining principal splice isoforms (APPRIS)           #\n".
            "# note: the start values of tracks are -1 due the UCSC Genome Growser does not so good. #\n".          
            "# --------------------------------------------------------------------------------------#\n".
            "browser position $position"."\n".
            "browser pix 800"."\n".
            "browser hide all"."\n".

			$head_tracks .
			
            $content_tracks ;

    return $output_content;
    
} # End get_bed_annotations

sub get_das_annotations($$)
{
    my ($chromosome_features,$version)=@_;
    
    my($output_content)='';
    
    # Scan all genes
    while(my($gene_id, $gene_features)=each(%{$chromosome_features}))
    {
        my($chromosome)='chr'.$gene_features->{'chr'};

        # Variable to GFF output file
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
            my($principal_isoform_annotation)=DB::get_appris_annotations($transcript_id);

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
                                $output_content.=Export::GFF::getAPPRISAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$appris_source_annotation,$version);
                            }
                            # Get firestar Annotations
                            if(exists $principal_isoform_annotation->{'functional_residue'} and defined $principal_isoform_annotation->{'functional_residue'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'functional_residue'};
                                $output_content.=Export::GFF::getFirestarAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version);
                            } 
                            # Get Matador3D Annotations                         
                            if(exists $principal_isoform_annotation->{'conservation_structure'} and defined $principal_isoform_annotation->{'conservation_structure'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'conservation_structure'};
                                $output_content.=Export::GFF::getMatador3DAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version);
                            }
                            # Get SPADE Annotations
                            if(exists $principal_isoform_annotation->{'domain_signal'} and defined $principal_isoform_annotation->{'domain_signal'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'domain_signal'};
                                $output_content.=Export::GFF::getSPADEAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version);
                            }
                            # Get INERTIA Annotations
                            if(exists $principal_isoform_annotation->{'unusual_evolution'} and defined $principal_isoform_annotation->{'unusual_evolution'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'unusual_evolution'};
                                $output_content.=Export::GFF::getInertiaAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version);
                            }
                            # Get CRASH Annotations
                            if(exists $principal_isoform_annotation->{'peptide_signal'} and defined $principal_isoform_annotation->{'peptide_signal'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'peptide_signal'};
                                $output_content.=Export::GFF::getSignalPAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version);
                            }
                            if(exists $principal_isoform_annotation->{'mitochondrial_signal'} and defined $principal_isoform_annotation->{'mitochondrial_signal'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'mitochondrial_signal'};
                                $output_content.=Export::GFF::getTargetPAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version);
                            }
                            # Get THUMP Annotations
                            if(exists $principal_isoform_annotation->{'transmembrane_signal'} and defined $principal_isoform_annotation->{'transmembrane_signal'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'transmembrane_signal'};
                                $output_content.=Export::GFF::getTHUMPAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version);
                            }
                            # Get CExonic Annotations
                            if(exists $principal_isoform_annotation->{'conservation_exon'} and defined $principal_isoform_annotation->{'conservation_exon'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'conservation_exon'};
                                $output_content.=Export::GFF::getCExonicAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version);
                            }
                            # Get CORSAIR Annotations
                            if(exists $principal_isoform_annotation->{'vertebrate_signal'} and defined $principal_isoform_annotation->{'vertebrate_signal'})
                            {
                                my($appris_annotation)=$principal_isoform_annotation->{'vertebrate_signal'};
                                $output_content.=Export::GFF::getCORSAIRAnnotations($gene_id,$transcript_id,$transcript_features,$appris_annotation,$version);
                            }                           
                        }               
                    }
                }
            }               
        } # end transcript loop
    } # end gene loop
    
    return $output_content;
    
} # End get_das_annotations

1;