					EXTRACTING DATA WITH WEB SERVICES (RESTful services)

APPRIS has been designed to be portable, modular and flexible. It is possible to integrate it to other 
bioinformatics systems and it can be accessed in distributed systems in the form of web service 
(RESTful web services, and BioMOBY web services).


RESTful WEB SERVICES

The APPRIS allows manipulation of the database data through various RESTful web services.
For example, there are services that retrieves useful information about Gene, Transcript and Translation.
Other services retrieve the output results of APPRIS method that executed from a given Gene or Transcript.


* Retrieve gene information:

- search_identifiers,
	It retrieves useful information of gene/trancript that is stored into APPRIS database.
	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/search_identifiers.cgi?queryId=ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/search_identifiers.cgi?queryId=ENST00000366621
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/search_identifiers.cgi?queryId=OTTHUMG00000014823		
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/search_identifiers.cgi?queryId=RNF215
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/search_identifiers.cgi?queryId=CCDS1599
	
	Parameters:
	
		- queryId (string), is a query input that could be:
			- Ensembl gene/transcript identifier,
			- VEGA gene/transcript identifier, 
			- gene/transcript name,
			- CCDS identifier.
	
	Response:
		The output format is a XML Document.
		
		<?xml version="1.0" encoding="UTF-8"?>
		<query xmlns:appris="http://appris.bioinfo.cnio.es" id="ENST00000366621">
		  <match label="ENST00000366621" namespace="Ensembl_Transcript_Id" chr="1" start="233749750" end="233808258">
		    <class><![CDATA[protein_coding]]></class>
		    <status><![CDATA[UNKNOWN]]></status>
		    <dblink namespace="External_Id" id="KCNK1-001"/>
		    <dblink namespace="Vega_Transcript_Id" id="OTTHUMT00000092565"/>
		    <dblink namespace="Ensembl_Gene_Id" id="ENSG00000135750"/>
		    <dblink namespace="CCDS" id="CCDS1599"/>
		  </match>
		</query>
		 

- export_data,
	It retrieves the APPRIS data from a given genomic region. The output format could be as GFF or as BED. 
	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/export_data.cgi?position=chr22:20116979-20137016&format=BED&head=no		
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/export_data.cgi?position=chr22:20116979-20137016&format=GTF

	Parameters:
	
		- position (string), correspond to genomic region whose format is like this (chrN:start_region-end_region).
		
		- format (string), indicates the type of output format (GTF or BED).
			For more information on GTF (Gene Transfer Format), see http://genome.ucsc.edu/FAQ/FAQformat.html#format4
			For more information on BED, see http://genome.ucsc.edu/FAQ/FAQformat.html#format1 
		
		- head (string), optional variable in the case of BED output.
			It retrieves (or does not) the overall display of the UCSC Genome browser, 'yes','no', or 'only'.

	Response:
		The output is a text/plain format.
		
		GTF response:
			22	FIRESTAR	functional_residue	20127090	20127092	6	+	.	gene_id "ENSG00000099904"; version "v28_rel3c"; transcript_name "ZDHHC8-002"; transcript_id "ENST00000405930"; note "peptide_position:106"; annotation "Functional residue"
			22	FIRESTAR	functional_residue	20127099	20127101	6	+	.	gene_id "ENSG00000099904"; version "v28_rel3c"; transcript_name "ZDHHC8-002"; transcript_id "ENST00000405930"; note "peptide_position:109"; annotation "Functional residue"
			22	APPRIS	functional_residue	20119471	20135529	5	+	.	gene_id "ENSG00000099904"; version "v28_rel3c"; transcript_name "ZDHHC8-002"; transcript_id "ENST00000405930"; annotation "UNKNOWN"
			22	MATADOR3D	homologous_structure	20119471	20119574	0	+	.	gene_id "ENSG00000099904"; version "v28_rel3c"; transcript_name "ZDHHC8-002"; transcript_id "ENST00000405930"; annotation "Homologous structure"
			22	MATADOR3D	homologous_structure	20126717	20126838	0	+	.	gene_id "ENSG00000099904"; version "v28_rel3c"; transcript_name "ZDHHC8-002"; transcript_id "ENST00000405930"; annotation "Homologous structure"
			22	MATADOR3D	homologous_structure	20127001	20127158	0	+	.	gene_id "ENSG00000099904"; version "v28_rel3c"; transcript_name "ZDHHC8-002"; transcript_id "ENST00000405930"; annotation "Homologous structure"

		BED response:

			# Description: Annotations for determining principal splice isoforms (APPRIS)
			browser position chr22:20116979-20137016
			browser pix 800
			browser hide all
			track name=Principal_Isoform description='Principal isoform' visibility=2 color='0,0,0' group='0'
			chr22	20119329	20135530	ENST00000334554	0	+	20119470	20132920	0	11	245,122,158,173,103,92,142,121,110,1001,2779	0,7387,7671,7913,8308,8810,9064,9410,9614,10949,13422
			track name=Functional_Residue description='Functional residues' visibility=2 color='210,145,35' group='0'
			chr22	20127089	20127257	ENST00000405930	0	+	20127089	20127257	0	5	3,3,3,3,3	0,9,39,42,165
			chr22	20127089	20127257	ENST00000436518	0	+	20127089	20127257	0	5	3,3,3,3,3	0,9,39,42,165
			chr22	20127089	20127134	ENST00000320602	0	+	20127089	20127134	0	4	3,3,3,3	0,9,39,42
			chr22	20127089	20127257	ENST00000334554	0	+	20127089	20127257	0	5	3,3,3,3,3	0,9,39,42,165
			track name=Whole_Domain description='Whole domains' visibility=2 color='118,156,2' group='0'
			chr22	20127086	20127329	ENST00000405930	0	+	20127086	20127329	0	2	72,87	0,156
			chr22	20127086	20127329	ENST00000436518	0	+	20127086	20127329	0	2	72,87	0,156
			chr22	20127086	20127329	ENST00000334554	0	+	20127086	20127329
			
	
- export_sequence,
	It retrieves both transcript sequence and protein sequence.
	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/export_sequence.cgi?id=ENSG00000099904&type=na&format=fasta
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/export_sequence.cgi?id=ENSG00000099904&type=aa

	Parameters:
	
		- id (string), Ensembl gene/transcript identifier. E.g. ENSG00000099904, or ENST00000382363.
		
		- type (string), indicates the type of sequence.
			'na' for Nucleotide sequence, and 'aa' for Aminoacid sequence.

		- format (string), optional variable.
			It indicates the type of output format. At the moment, the unique format output is 'fasta'.
			For more information on FASTA, see http://www.ncbi.nlm.nih.gov/BLAST/blastcgihelp.shtml

	Respose:
		The output is a text/plain format.

		FASTA response:
			>ENST00000436518|ENSG00000099904|ZDHHC8-004|180
			MVLREGSCAGRQNASACWPHGTTGCPWLTRAVSPAVPVYNGIIFLFVLANFSMATFMDPGVFPRADEDED
			KEDDFRAPLYKNVDVRGIQVRMKWCATCHFYRPPRCSHCSVCDNCVEDFDHHCPWVNNCIGRRNYRYFFL
			FLLSLSAHMVGVVAFGLVYVLNHAEGLGAAHTTITYPWFL


* Retrieve method information:

APPRIS automates a range of computational methods used to define principal functional variants based on 
the Principal Variant Pipeline (protein functional, structural and evolutionary information).

All these RESTful services has a site-specific prefix, followed by method name, type of query and query string.
E.g.
	http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/name/CRISP3
	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^ ^^^^ ^^^^^^
			site-specific prefix           method  type  query
	

- firestar,
	Firestar (Lopez et al., 2007) is a method that predicts functionally important residues in protein sequences.  

	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
			- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
			- CCDS identifier (e.g. CCDS4929).
		
	Response:
		The output is a text/plain format. For more information on output, 
		see http://appris.bioinfo.cnio.es/docs/rest/README.firestar.txt

		
- matador3d,
	Matador3D is a locally-installed method that checks for structural homologues for each transcript in the PDB. 

	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/matador3d/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/matador3d/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/matador3d/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/matador3d/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/matador3d/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
			- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
			- CCDS identifier (e.g. CCDS4929).
		
	Response:
		The output is a text/plain format. For more information on output, 
		see http://appris.bioinfo.cnio.es/docs/rest/README.matador3d.txt

- spade,
	SPADE uses a locally installed version of the program Pfamscan (http://pfam.sanger.ac.uk/) to identify the 
	effect of alternative splicing on the conservation of protein functional domains.  

	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/spade/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/spade/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/spade/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/spade/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/spade/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
			- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
			- CCDS identifier (e.g. CCDS4929).
		
	Response:
		The output is a text/plain format. For more information on output, 
		see http://appris.bioinfo.cnio.es/docs/rest/README.spade.txt

- inertia,
	From a transcript, INERTIA detects exons with non-neutral evolutionary rates. Transcripts are aligned 
	against related species using three different alignment methods, and evolutionary rates of exons for 
	each of the three alignments are contrasted using SLR software.  

	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/inertia/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/inertia/name/CRISP3-203
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/inertia/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/inertia/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl transcript identifier (e.g. ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA transcript identifier (e.g. OTTHUMT00000040871), 
			- transcript name (e.g. CRISP3-203),
			- CCDS identifier (e.g. CCDS4929).
		
	Response:
		The output is a text/plain format. For more information on output, 
		see http://appris.bioinfo.cnio.es/docs/rest/README.inertia.txt

- crash,
	From a transcript, CRASH makes conservative predictions of signal peptides and mitochondrial signal sequences 
	by analyzing the output of the SignalP and TargetP programs. 

	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/crash/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/crash/name/CRISP3-203
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/crash/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/crash/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl transcript identifier (e.g. ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA transcript identifier (e.g. OTTHUMT00000040871), 
			- transcript name (e.g. CRISP3-203),
			- CCDS identifier (e.g. CCDS4929).
		
	Response:
		The output is a text/plain format. For more information on output, 
		see http://appris.bioinfo.cnio.es/docs/rest/README.crash.txt

- thump,
	THUMP makes conservative predictions of trans-membrane helices by analyzing the 
	output of three locally installed trans-membrane prediction methods.
	
	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/thump/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/thump/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/thump/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/thump/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/thump/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
			- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
			- CCDS identifier (e.g. CCDS4929).
		
	Response:
		The output is a text/plain format. For more information on output, 
		see http://appris.bioinfo.cnio.es/docs/rest/README.thump.txt

- cexonic,
	CExonic is a method for the determination of conservation of exonic structure. The conservation of 
	exonic structure between orthologous splice isoforms of two species (human and mouse) would suggest 
	that their biological function may be conserved.

	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/cexonic/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/cexonic/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/cexonic/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/cexonic/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/cexonic/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
			- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
			- CCDS identifier (e.g. CCDS4929).
		
	Response:
		The output is a text/plain format. For more information on output, 
		see http://appris.bioinfo.cnio.es/docs/rest/README.cexonic.txt
