# _________________________________________________________________
# $Id: MOBY.pm 65 2009-06-08 11:39:06Z jmrodriguez $
# $Revision: 65 $
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________
package MOBY;

use SOAP::Lite;# + 'trace';
use MOBY::Client::Central;
use MOBY::Client::Service;
use MOBY::Async::Service;
use XML::LibXML;

#####################
# Method prototypes #
#####################
sub get_SignalP_annotations($$$$$$);
sub get_TargetP_annotations($$);
sub get_Firestar_annotations($$);
sub get_CExonic_annotations($);
sub get_Matador3D_annotations($$);
sub get_Prank_annotations($$);
sub get_PSLR_annotations($$$);
sub get_SLR_annotations($$$);


#################
# Method bodies #
#################
sub get_SignalP_annotations($$$$$$)
{
	my($id,$fasta,$type,$format,$method,$truncate)=@_;
	
	my($Central)=MOBY::Client::Central->new(
			Registries => {
					mobycentral => {URL => $Constant::MOBY_CENTRAL_URL,URI => $Constant::MOBY_CENTRAL_URI }
			});
	
	my ($ServiceInstances, $RegObject) = $Central->findService(
                serviceName=> 'runSignalP',
                authURI => 'cnio.es'
               );

	my($fastaMulti)= <<FASTA_MULTI_MOBYDATA;
<moby:FASTA_AA_multi moby:namespace="VEGA" moby:id="$id" moby:articleName="">
	<moby:String moby:namespace="" moby:id="" moby:articleName="content"><![CDATA[$fasta]]></moby:String>
</moby:FASTA_AA_multi>
FASTA_MULTI_MOBYDATA

	my($WSDL)=$Central->retrieveService($ServiceInstances->[0]);
	my($Service)=MOBY::Async::Service->new(service => $WSDL);
	my($EPR,@queryIDs)=$Service->submit(XMLinputlist => [
		[
			'sequences', $fastaMulti,
		 	'type',"<Value>$type</Value>",
		 	'format',"<Value>$format</Value>",
		 	'method',"<Value>$method</Value>",
		 	'truncate',"<Value>$truncate</Value>"		 	
		],
	]);
	my($moby_response);
	my($finished)=scalar(@queryIDs);
	do {
		sleep(1);
		my(@status)=$Service->poll($EPR,@queryIDs);
		foreach my $stat (@status)
		{
			if($stat->new_state() ne 'created' && $stat->new_state() ne 'running')
			{
				my(@response)=$Service->result($EPR,($stat->id()));
				$moby_response=$response[0];
				$Service->destroy($EPR,($stat->id()));
				$finished--;
			}
		}
	} while($finished>0);

	# Parser moby response
	my($result);
	if(defined $moby_response)
	{
		my($parser)=XML::LibXML->new();
		my($doc)=$parser->parse_string($moby_response);
	
		if(scalar(@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'mobyData')})>0)
		{
			my($first_mobyData)=($doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'mobyData'))[0];
			foreach my $string_node (@{$first_mobyData->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')})
			{
				if(UNIVERSAL::isa($string_node,'XML::LibXML::Node'))
				{
					$result=$string_node->textContent();
				}
			}
		}
	}
	return $result;
	
} # End get_SignalP_annotations

sub get_TargetP_annotations($$)
{
	my($id,$fasta)=@_;
	
	my($Central)=MOBY::Client::Central->new(
			Registries => {
					mobycentral => {URL => $Constant::MOBY_CENTRAL_URL,URI => $Constant::MOBY_CENTRAL_URI }
			});
	
	my ($ServiceInstances, $RegObject) = $Central->findService(
                serviceName=> 'runTargetP',
                authURI => 'cnio.es'
               );

	my($fastaMulti)= <<FASTA_MULTI_MOBYDATA;
<moby:FASTA_AA_multi moby:namespace="VEGA" moby:id="$id" moby:articleName="">
	<moby:String moby:namespace="" moby:id="" moby:articleName="content"><![CDATA[$fasta]]></moby:String>
</moby:FASTA_AA_multi>
FASTA_MULTI_MOBYDATA

	my($WSDL)=$Central->retrieveService($ServiceInstances->[0]);
	my($Service)=MOBY::Async::Service->new(service => $WSDL);
	my($EPR,@queryIDs)=$Service->submit(XMLinputlist => [
		['sequences', $fastaMulti],
	]);
	my($moby_response);
	my($finished)=scalar(@queryIDs);
	do {
		sleep(1);
		my(@status)=$Service->poll($EPR,@queryIDs);
		foreach my $stat (@status)
		{
			if($stat->new_state() ne 'created' && $stat->new_state() ne 'running')
			{
				my(@response)=$Service->result($EPR,($stat->id()));
				$moby_response=$response[0];
				$Service->destroy($EPR,($stat->id()));
				$finished--;
			}
		}
	} while($finished>0);

	# Parser moby response
	my($result);
	if(defined $moby_response)
	{
		my($parser)=XML::LibXML->new();
		my($doc)=$parser->parse_string($moby_response);
	
		if(scalar(@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'mobyData')})>0)
		{
			my($first_mobyData)=($doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'mobyData'))[0];
			foreach my $string_node (@{$first_mobyData->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')})
			{
				if(UNIVERSAL::isa($string_node,'XML::LibXML::Node'))
				{
					$result=$string_node->textContent();
				}
			}
		}
	}
	return $result;
	
} # End get_TargetP_annotations

sub get_Firestar_annotations($$)
{
	my ($id,$fasta) = @_;
	
	my($Central)=MOBY::Client::Central->new(
			Registries => {
					mobycentral => {URL => $Constant::MOBY_CENTRAL_URL,URI => $Constant::MOBY_CENTRAL_URI }
			});
	
	my ($ServiceInstances, $RegObject) = $Central->findService(
                serviceName=> 'runFirestar',
                authURI => 'cnio.es'
               );

	my($fastaNAmulti)= <<FASTA_MULTI_MOBYDATA;
<moby:FASTA_AA_multi moby:namespace="VEGA" moby:id="$id" moby:articleName="">
	<moby:String moby:namespace="" moby:id="" moby:articleName="content"><![CDATA[$fasta]]></moby:String>
</moby:FASTA_AA_multi>
FASTA_MULTI_MOBYDATA

	my($WSDL)=$Central->retrieveService($ServiceInstances->[0]);
	my($Service)=MOBY::Async::Service->new(service => $WSDL);
	my($EPR,@queryIDs)=$Service->submit(XMLinputlist => [
		['sequences', $fastaNAmulti],
	]);
	my($moby_response);
	my($finished)=scalar(@queryIDs);
	do
	{
		sleep(1);
		my(@status)=$Service->poll($EPR,@queryIDs);
		foreach my $stat (@status)
		{
			if($stat->new_state() ne 'created' && $stat->new_state() ne 'running')
			{
				my(@response)=$Service->result($EPR,($stat->id()));
				$moby_response=$response[0];
				$Service->destroy($EPR,($stat->id()));
				$finished--;
			}
		}
	} while($finished>0);

	# Parser moby response
	my($result);
	if(defined $moby_response)
	{
		my($parser)=XML::LibXML->new();
		my($doc)=$parser->parse_string($moby_response);
	
		if(scalar(@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'mobyData')})>0)
		{
			my($first_mobyData)=($doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'mobyData'))[0];
			foreach my $string_node (@{$first_mobyData->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')})
			{
				if(UNIVERSAL::isa($string_node,'XML::LibXML::Node'))
				{
					$result=$string_node->textContent();
				}
			}
		}
	}
	return $result;
	
} # End get_Firestar_annotations

sub get_CExonic_annotations($)
{
	my ($gene_id) = @_;
	
	my($Central)=MOBY::Client::Central->new(
			Registries => {
					mobycentral => {URL => $Constant::MOBY_CENTRAL_URL,URI => $Constant::MOBY_CENTRAL_URI }
			});
	
	my ($ServiceInstances, $RegObject) = $Central->findService(
                serviceName=> 'runCExonic',
                authURI => 'cnio.es'
               );

	my($WSDL)=$Central->retrieveService($ServiceInstances->[0]);
	my($Service)=MOBY::Async::Service->new(service => $WSDL);
	my $mobyData = qq{<Genomic_Location namespace="VEGA" id="$gene_id">
		<String namespace="" id="" articleName="specie"></String>
		<Integer namespace="" id="" articleName="chromosome"></Integer>
		<Integer namespace="" id="" articleName="start"></Integer>
		<Integer namespace="" id="" articleName="end"></Integer>
	</Genomic_Location>};
	
	my($EPR,@queryIDs)=$Service->submit(XMLinputlist => [
	 	['genomic_location', $mobyData],
	]);
	my($moby_response);
	my($finished)=scalar(@queryIDs);
	do {
		sleep(1);
		my(@status)=$Service->poll($EPR,@queryIDs);
		foreach my $stat (@status)
		{
			if($stat->new_state() ne 'created' && $stat->new_state() ne 'running')
			{
				my(@response)=$Service->result($EPR,($stat->id()));
				$moby_response=$response[0];
				$Service->destroy($EPR,($stat->id()));
				$finished--;
			}
		}
	} while($finished>0);

#open(MOBY_REPONSE,">moby-cexonic-result.xml");
#print MOBY_REPONSE $moby_response;
#close(MOBY_REPONSE);
#$/=undef;	
#open(MOBY_REPONSE,"moby-cexonic-result.xml");
#my($moby_response)=<MOBY_REPONSE>;
#close(MOBY_REPONSE);
#$/='\n';


	# Parser moby response
	my($result);
	if(defined $moby_response)
	{
		my($parser)=XML::LibXML->new();
		my($doc)=$parser->parse_string($moby_response);
	
		if(scalar(@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'Simple')})>0)
		{
			my(@reports)=@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'Simple')};
			foreach my $report (@reports)
			{
				my($article_name)=$report->getAttributeNS($Constant::MOBY_NAMESPACE,'articleName');
				$article_name = $report->getAttribute('articleName') unless defined $article_name;
	
				if(scalar(@{$report->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')})>0)
				{					
					my(@contents)=@{$report->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')};
					foreach my $content (@contents)
					{
						my($response)=$content->textContent()."\n";
						my($article_name2)=$content->getAttributeNS($Constant::MOBY_NAMESPACE,'articleName');
						$article_name2 = $content->getAttribute('articleName') unless defined $article_name2;
						if($article_name2 eq 'content')
						{
							$result->{'result'}=$response;						
						}
						elsif($article_name2 eq 'rawdata')
						{
							$result->{$article_name}=$response;#decode_base64($result);
						}
					}						
				}
			}
		}
	}
	return $result;

} # End get_CExonic_annotations

sub get_Matador3D_annotations($$)
{
	my ($id,$fasta) = @_;
	
	my($Central)=MOBY::Client::Central->new(
			Registries => {
					mobycentral => {URL => $Constant::MOBY_CENTRAL_URL,URI => $Constant::MOBY_CENTRAL_URI }
			});
	
	my ($ServiceInstances, $RegObject) = $Central->findService(
                serviceName=> 'runAS3D',
                authURI => 'cnio.es'
               );

	my($fastaNAmulti)= <<FASTA_MULTI_MOBYDATA;
<moby:FASTA_AA_multi moby:namespace="VEGA" moby:id="$id" moby:articleName="">
	<moby:String moby:namespace="" moby:id="" moby:articleName="content"><![CDATA[$fasta]]></moby:String>
</moby:FASTA_AA_multi>
FASTA_MULTI_MOBYDATA

	my($WSDL)=$Central->retrieveService($ServiceInstances->[0]);
	my($Service)=MOBY::Async::Service->new(service => $WSDL);
	my($EPR,@queryIDs)=$Service->submit(XMLinputlist => [
		['sequences', $fastaNAmulti],
	]);
	my($moby_response);
	my($finished)=scalar(@queryIDs);
	do
	{
		sleep(1);
		my(@status)=$Service->poll($EPR,@queryIDs);
		foreach my $stat (@status)
		{
			if($stat->new_state() ne 'created' && $stat->new_state() ne 'running')
			{
				my(@response)=$Service->result($EPR,($stat->id()));
				$moby_response=$response[0];
				$Service->destroy($EPR,($stat->id()));
				$finished--;
			}
		}
	} while($finished>0);

	# Parser moby response
	my($result);
	if(defined $moby_response)
	{
		my($parser)=XML::LibXML->new();
		my($doc)=$parser->parse_string($moby_response);
	
		if(scalar(@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'mobyData')})>0)
		{
			my($first_mobyData)=($doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'mobyData'))[0];
			foreach my $string_node (@{$first_mobyData->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')})
			{
				if(UNIVERSAL::isa($string_node,'XML::LibXML::Node'))
				{
					$result=$string_node->textContent();
				}
			}
		}
	}
	return $result;
	
} # End get_Matador3D_annotations

sub get_Prank_annotations($$)
{
	my ($id,$fasta) = @_;
	
	my($Central)=MOBY::Client::Central->new(
			Registries => {
					mobycentral => {URL => $Constant::MOBY_CENTRAL_URL,URI => $Constant::MOBY_CENTRAL_URI }
			});
	
	my ($ServiceInstances, $RegObject) = $Central->findService(
                serviceName=> 'runPrank',
                authURI => 'cnio.es'
               );

	my($fastaMulti)= <<SEQ_ALIGNMENT_MOBYDATA;
<moby:Sequence_alignment_report moby:namespace="VEGA" moby:id="$id" moby:articleName="">
	<moby:String moby:namespace="" moby:id="" moby:articleName="content"><![CDATA[$fasta]]></moby:String>
</moby:Sequence_alignment_report>
SEQ_ALIGNMENT_MOBYDATA

	my($WSDL)=$Central->retrieveService($ServiceInstances->[0]);
	my($Service)=MOBY::Async::Service->new(service => $WSDL);
	my($EPR,@queryIDs)=$Service->submit(XMLinputlist => [
		['alignment', $fastaMulti],
	]);
	my($moby_response);
	my($finished)=scalar(@queryIDs);
	do {
		sleep(1);
		my(@status)=$Service->poll($EPR,@queryIDs);
		foreach my $stat (@status) {
			if($stat->new_state() ne 'created' && $stat->new_state() ne 'running') {
				my(@response)=$Service->result($EPR,($stat->id()));
				$moby_response=$response[0];
				$Service->destroy($EPR,($stat->id()));
				$finished--;
			}
		}
	} while($finished>0);

#open(MOBY_REPONSE,">moby-prank-result.xml");
#print MOBY_REPONSE $moby_response;
#close(MOBY_REPONSE);

#$/=undef;
#open(MOBY_REPONSE,"moby-prank-result.xml");
#my($moby_response)=<MOBY_REPONSE>;
#close(MOBY_REPONSE);
#$/='\n';

	# Parser moby response
	my($result);
	if(defined $moby_response)
	{
		my($parser)=XML::LibXML->new();
		my($doc)=$parser->parse_string($moby_response);
	
		if(scalar(@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'Simple')})>0)
		{
			my(@reports)=@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'Simple')};
			foreach my $report (@reports)
			{
				my($article_name)=$report->getAttributeNS($Constant::MOBY_NAMESPACE,'articleName');
				$article_name = $report->getAttribute('articleName') unless defined $article_name;
	
				if(scalar(@{$report->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')})>0)
				{					
					my(@contents)=@{$report->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')};
					next unless(scalar(@contents)>0);
					my($content)=$contents[0];
					if(	$article_name eq 'prank_sequence_alignment_1' or
						$article_name eq 'prank_tree_1' or
						$article_name eq 'prank_sequence_alignment_2' or
						$article_name eq 'prank_tree_2'
					)
					{
						$result->{$article_name}=$content->textContent();				
					}
				}
			}
		}
	}
	return $result;
	
} # End get_Prank_annotations

sub get_PSLR_annotations($$$)
{
	my ($id,$seqAligReport,$prankTree) = @_;

	my($Central)=MOBY::Client::Central->new(
			Registries => {
					mobycentral => {URL => $Constant::MOBY_CENTRAL_URL,URI => $Constant::MOBY_CENTRAL_URI }
			});
	my ($ServiceInstances, $RegObject) = $Central->findService(
                serviceName=> 'fromPrankToSLR',
                authURI => 'cnio.es'
               );

	my($seqAligReport_mobyObject)= <<SEQ_ALIGNMENT_MOBYDATA;
<moby:Sequence_alignment_report moby:namespace="" moby:id="$id" moby:articleName="">
	<moby:String moby:namespace="" moby:id="" moby:articleName="content"><![CDATA[$seqAligReport]]></moby:String>
</moby:Sequence_alignment_report>
SEQ_ALIGNMENT_MOBYDATA

	my($prankTree_mobyData)= <<TREE_ALIGNMENT_MOBYDATA;
<moby:Prank_Tree_Text moby:namespace="" moby:id="$id" moby:articleName="">
	<moby:String moby:namespace="" moby:id="" moby:articleName="content"><![CDATA[$prankTree]]></moby:String>
</moby:Prank_Tree_Text>
TREE_ALIGNMENT_MOBYDATA

	my($WSDL)=$Central->retrieveService($ServiceInstances->[0]);
	my($Service)=MOBY::Client::Service->new(service => $WSDL);

	my($moby_response)=$Service->execute(XMLinputlist => [
	 	['sequence_alignment', $seqAligReport_mobyObject, 'prank_tree', $prankTree_mobyData],
	]);

#open(MOBY_REPONSE,">moby-pslr-result.xml");
#print MOBY_REPONSE $moby_response;
#close(MOBY_REPONSE);

	# Parser moby response
	my($result);
	if(defined $moby_response)
	{
		my($parser)=XML::LibXML->new();
		my($doc)=$parser->parse_string($moby_response);
	
		if(scalar(@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'Simple')})>0)
		{
			my(@reports)=@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'Simple')};
			foreach my $report (@reports)
			{
				my($article_name)=$report->getAttributeNS($Constant::MOBY_NAMESPACE,'articleName');
				$article_name = $report->getAttribute('articleName') unless defined $article_name;
	
				if(scalar(@{$report->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')})>0)
				{					
					my(@contents)=@{$report->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')};
					next unless(scalar(@contents)>0);
					my($content)=$contents[0];
					if(	$article_name eq 'sequence_alignment' or
						$article_name eq 'prank_tree'
					)
					{
						$result->{$article_name}=$content->textContent();				
					}
				}
			}
		}
	}
	return $result;
	
} # End get_PSLR_annotations

sub get_SLR_annotations($$$)
{
	my ($id,$seqAligReport,$prankTree) = @_;

	my($Central)=MOBY::Client::Central->new(
			Registries => {
					mobycentral => {URL => $Constant::MOBY_CENTRAL_URL,URI => $Constant::MOBY_CENTRAL_URI }
			});
	my ($ServiceInstances, $RegObject) = $Central->findService(
                serviceName=> 'runSLR',
                authURI => 'cnio.es'
               );

	my($seqAligReport_mobyObject)= <<SEQ_ALIGNMENT_MOBYDATA;
<moby:Sequence_alignment_report moby:namespace="" moby:id="$id" moby:articleName="">
	<moby:String moby:namespace="" moby:id="" moby:articleName="content"><![CDATA[$seqAligReport]]></moby:String>
</moby:Sequence_alignment_report>
SEQ_ALIGNMENT_MOBYDATA

	my($prankTree_mobyData)= <<TREE_ALIGNMENT_MOBYDATA;
<moby:Prank_Tree_Text moby:namespace="" moby:id="$id" moby:articleName="">
	<moby:String moby:namespace="" moby:id="" moby:articleName="content"><![CDATA[$prankTree]]></moby:String>
</moby:Prank_Tree_Text>
TREE_ALIGNMENT_MOBYDATA

	my($WSDL)=$Central->retrieveService($ServiceInstances->[0]);
	my($Service)=MOBY::Async::Service->new(service => $WSDL);
	my($EPR,@queryIDs)=$Service->submit(XMLinputlist => [
	 	['sequence_alignment', $seqAligReport_mobyObject, 'prank_tree', $prankTree_mobyData],
	]);
	my($moby_response);
	my($finished)=scalar(@queryIDs);
	do {
		sleep(1);
		my(@status)=$Service->poll($EPR,@queryIDs);
		foreach my $stat (@status)
		{
			if($stat->new_state() ne 'created' && $stat->new_state() ne 'running')
			{
				my(@response)=$Service->result($EPR,($stat->id()));
				$moby_response=$response[0];
				$Service->destroy($EPR,($stat->id()));
				$finished--;
			}
		}
	} while($finished>0);

#open(MOBY_REPONSE,">moby-slr-result.xml");
#print MOBY_REPONSE $moby_response;
#close(MOBY_REPONSE);

#$/=undef;
#open(MOBY_REPONSE,"moby-slr-result.xml");
#my($moby_response)=<MOBY_REPONSE>;
#close(MOBY_REPONSE);
#$/='\n';

	# Parser moby response
	my($result);
	if(defined $moby_response)
	{
		my($parser)=XML::LibXML->new();
		my($doc)=$parser->parse_string($moby_response);
	
		if(scalar(@{$doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'mobyData')})>0)
		{
			my($first_mobyData)=($doc->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'mobyData'))[0];
			foreach my $string_node (@{$first_mobyData->getElementsByTagNameNS($Constant::MOBY_NAMESPACE,'String')})
			{
				if(UNIVERSAL::isa($string_node,'XML::LibXML::Node'))
				{
					$result=$string_node->textContent();
				}
			}
		}
	}
	return $result;

} # End get_SLR_annotations


1;
