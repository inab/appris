function APPRIS(){}


/* 
 * CONSTANTS: Feature for web site 
 */

APPRIS.UCSC_URL = "http://genome.ucsc.edu/cgi-bin/";
//APPRIS.UCSC_URL = "http://ucsc.cnio.es/cgi-bin/";

APPRIS.RELEASE_URL = "http://appris.bioinfo.cnio.es/archives/gencode3c/"
 
APPRIS.RELEASE =
"\
<span class='release'>APPRIS/Gencode3c - release 28 - Aug 2011\
&copy;\
 <a title='CNIO' href='http://www.cnio.es' target='_blank'>CNIO</a> /\
 <a title='INB' href='http://www.inab.org' target='_blank'>INB</a>\
</span>\
";

APPRIS.DOC_MENU = 
"\
<h2><a href='docs.html' class='linkPage'>Help & Documentations</a></h2>\
<ul>\
	<h3>Data Production:</h3>\
	<li>\
		<ul>\
			<li><a href='gene_and_transcript_types.html' class='linkPage'>Gene and Transcript types</a></li>\
			<li><a href='appris.html' class='linkPage'>APPRIS Pipeline</a></li>\
		</ul>\
	</li>\
	<p />\
	<h3>Data Access:</h3>\
	<li>\
		<ul>\
			<li><a href='api.html' class='linkPage'>Perl API Documentation</a></li>\
			<li><a href='apprislib/index.html' target='_blank' class='linkPage'>Pdoc Perl documentation</a></li>\
			<li><a href='aws.html' class='linkPage'>Web Services</a></li>\
			<li><a href='biomart.html' class='linkPage'>BioMart</a></li>\
		</ul>\
	</li>\
	<p />\
	<h3>About APPRIS:</h3>\
	<li>\
		<ul>\
			<li><a href='publications.html' class='linkPage'>Publications</a></li>\
			<li><a href='contact.html' class='linkPage'>Contact</a></li>\
		</ul>\
	</li>\
</ul>\
\
";

/* 
 * CONSTANTS: Feature labels 
 */
APPRIS.NO_LABEL				= "NO";
APPRIS.UNKNOWN_LABEL		= "UNKNOWN";
APPRIS.OK_LABEL				= "YES";
APPRIS.OK_PROB_LABEL		= "YES_Probably";


/* 
 * CONSTANTS: Method labels 
 */
APPRIS.METHOD_LABELS = new Array();

//APPRIS.APPRIS_TYPE = 'principal_isoform';
//APPRIS.METHOD_LABELS[APPRIS.APPRIS_TYPE] = "Principal Isoform";

APPRIS.FIRESTAR_TYPE = 'functional_residue';
APPRIS.METHOD_LABELS[APPRIS.FIRESTAR_TYPE] = "No. Functional Residues";

APPRIS.MATADOR3D_TYPE = 'homologous_structure';
APPRIS.METHOD_LABELS[APPRIS.MATADOR3D_TYPE] = "Score of Homologous Structure";

APPRIS.SPADE_TYPE = 'functional_domain';
APPRIS.METHOD_LABELS[APPRIS.SPADE_TYPE] = "Whole Domains";

APPRIS.INERTIA_TYPE = 'neutral_evolution';
APPRIS.METHOD_LABELS[APPRIS.INERTIA_TYPE] = "Neutral Evolution of Exons";

APPRIS.CRASH_SP_TYPE = 'signal_peptide';
APPRIS.METHOD_LABELS[APPRIS.CRASH_SP_TYPE] = "Signal Peptide Sequences";

APPRIS.CRASH_TP_TYPE = 'mitochondrial_signal';
APPRIS.METHOD_LABELS[APPRIS.CRASH_TP_TYPE] = "Mitochondrial Signal Sequence";

APPRIS.THUMP_TYPE = 'transmembrane_signal';
APPRIS.METHOD_LABELS[APPRIS.THUMP_TYPE] = "No. Transmembrane Helices";

APPRIS.CEXONIC_TYPE = 'conservation_exon';
APPRIS.METHOD_LABELS[APPRIS.CEXONIC_TYPE] = "Exonic Structures Conserved in Mouse";

APPRIS.CORSAIR_TYPE = 'vertebrate_conservation';
APPRIS.METHOD_LABELS[APPRIS.CORSAIR_TYPE] = "Conservation score (vertebrates)";

/* 
 * CONSTANTS: Description of every panel of report page 
 */
APPRIS.REPORT_INFO_SUMMARY_PANEL =
"\
<div id='content_panel'>\
\
<div class='content_title'>\
	<span class='content_highlighting'>Annotated Isoforms</span>\
</div> <!-- div.content_title -->\
<p>The table shows all splice variants and defines the principal functional variant. \
It shows all splice variants for a gene and includes noncoding transcripts. \
Each transcript ID (ENST) is unique and stable for a specific transcript.</p>\
\
\
<div class='content_subtitle2'>Transcript IDs and Names:</div> <!-- Transcript IDs and Names -->\
<p>ENST IDs are human transcripts. \
Transcript names beginning with 0 (for example FOXP2-001) are from the VEGA/Havana (manual curation) project. \
Transcript names beginning with 2 (eg. FOXP2-201) come solely from the Ensembl annotation pipeline.\
\
\
<div class='content_subtitle2'>Transcript Status:</div> <!-- Transcript Status -->\
<ul>\
	<li>A <span class='content_highlighting'>known</span> transcript is 100% Identical to RefSeq NP or Swiss-Prot entry.</li>\
	<li>A <span class='content_highlighting'>novel</span> transcript shares >60% length with known coding sequence \
	from RefSeq or Swiss-Prot or has cross-species/family support or domain evidence.</li>\
	<li>A <span class='content_highlighting'>putative</span> shares <60% length with known coding sequence from RefSeq \
	or Swiss-Prot, or has an alternative first or last coding exon.</li>\
	<li>A <span class='content_highlighting'>unknown</span> transcript comes from the Ensembl automatic annotation pipeline.</li>\
</ul>\
\
\
<div class='content_subtitle2'>Transcript Class:</div> <!-- Transcript Class -->\
<ul>\
	<li>A <span class='content_highlighting'>protein coding</span> transcript is a spliced mRNA that leads to a protein product.</li>\
	<li>A <span class='content_highlighting'>processed transcript</span> is a noncoding transcript that does not \
	contain an open reading frame (ORF). \
	This type of transcript is annotated by the VEGA/Havana manual curation project.</li>\
	<li><span class='content_highlighting'>Nonsense-mediated decay</span> indicates that the transcript undergoes \
	nonsense mediated decay, a process which detects nonsense mutations and prevents the expression of truncated or \
	erroneous proteins.</li>\
	<li><span class='content_highlighting'>Transcribed pseudogenes and other non-coding transcripts</span> do not result in a protein product.</li>\
</ul>\
\
\
<div class='content_subtitle2'>Confidence Level:</div> <!-- Confidence Level -->\
<p>We supply genome-wide features on three different confidence levels:</p>\
<ul>\
	<li><span class='content_highlighting'>Level 1</span>: Validated. Pseudogene loci, that were predicted \
	by the analysis-pipelines from YALE, UCSC as well as by HAVANA manual annotation from WTSI \
	(Wellcome Trust Sanger Institute).\
	Other transcripts, that were verified experimentally by RT-PCR and sequencing.</li>\
	<li><span class='content_highlighting'>Level 2</span>: Manual Annotation. HAVANA manual annotation from WTSI.</li>\
	<li><span class='content_highlighting'>Level 3</span>: Automated Annotation. ENSEMBL loci where they are different \
	from the HAVANA annotation or where no annotation can be found.</li>\
</ul>\
\
\
<br/>\
<br/>\
<br/>\
<p>For more information, see descriptions of these transcripts \
<a href='docs/gene_and_transcript_types.html' target='_blank'>here</a>.\
\
\
\
</div> <!-- div.main_content -->\
";

APPRIS.REPORT_INFO_APPRIS_PANEL = 
"\
<div id='content_panel'>\
\
<div class='content_title'>\
	<span class='content_highlighting'>Annotations in detail</span>\
</div> <!-- div.content_title -->\
\
\
<p><b>APPRIS</b> detects principal isoforms based on a range of methods that use \
protein structural information, functionally important residues, \
conservation of exonic structure and evidence of non-neutral evolution.</p>\
\
\
<div class='content_subtitle2'>Num. Functional Residues:</div> <!-- FIRESTAR -->\
<p><b>Firestar</b> method predicts functionally important residues. Variants that have <i><b>lost</b></i> \
conserved functional residues are <i><b>eliminated</b></i> as potential principal isoforms.</p>\
\
\
<div class='content_subtitle2'>Num. Exons with Conservation Structure:</div> <!-- MATADOR-3D -->\
<p><b>MATADOR-3D</b> method analyses the protein structural information for each variant. \
Variants with large inserts or deletions relative to their crystal structures are also not \
likely to be the principal isoform. So they are <i><b>eliminated</b></i> as potential principal isoforms.</p>\
\
\
<div class='content_subtitle2'>Whole Domains:</div> <!-- PfamScan -->\
<p><b>PfamScan</b> method identifies the domains present in a transcript. \
Variants that have <i><b>lost</b></i> \
conserved protein domains are <i><b>eliminated</b></i> as potential principal isoforms.</p>\
\
\
<div class='content_subtitle2'>Neutral Evolution of Exons:</div> <!-- INERTIA -->\
<p>The principal isoform is not likely to contain exons that are evolving abnormally \
quickly or unusual selective pressures. \
Variants with differently evolving exons are <i><b>eliminated</b></i> as potential principal isoforms. \
<b>INERTIA</b> is the method that this functinality.</p>\
\
\
<div class='content_subtitle2'>Signal Peptide Sequences and Mitochondrial Signal Sequences:</div> <!-- CRASH -->\
<p>The presence and location of signal peptides and cleavage sites in amino acid sequences are \
analysed with <b>SignalP</b> program. \
And <b>TargetP</b> service that \
predicts the sub-cellular location of eukaryotic proteins. \
<b>CRASH</b> method is make upt by these methods.</p>\
\
\
<div class='content_subtitle2'>Num. Transmembrane Helices:</div> <!-- THUMP -->\
<p><b>THUMP</b> makes unanimous predictions of trans-membrane helices. \
Transcripts that have <i><b>lost</b></i> trans-membrane helices \
relative to other transcripts from the same gene are <i><b>eliminated</b></i> as the principal isoform.</p>\
\
\
<div class='content_subtitle2'>Exonic Structures Conserved in Mouse:</div> <!-- CExonic -->\
<p><b>CExonic</b> analyses the conservation of exonic structure  between orthologous splicing isoforms \
of two species (human-mouse). \
If one transcript does not have conserved exonic structure, while all the rest have, \
this not likely to be the principal isoform, so will be <i><b>eliminated</b></i>.</p>\
\
\
<div class='content_subtitle2'>Conservation score (vertebrates):</div> <!-- CORSAIR -->\
<p><b>CORSAIR</b> makes BLAST searches against vertebrates to determine the most likely principal isoform. \
Transcripts conserved over greater evolutionary distances are more likely to be the principal variant.</p>\
\
\
<br/>\
<br/>\
<br/>\
<p>For more information about these methods, \
click <a href='docs/appris.html' target='_blank'>here</a>.</p>\
\
\
\
</div> <!-- div.main_content -->\
";



APPRIS.REPORT_INFO_UCSC_PANEL = 
"\
<div id='content_panel'>\
\
<div class='content_title'>\
	<span class='content_highlighting'>UCSC Genome Browser on Human Feb. 2009 (GRCh37/hg19) Assembly</span>\
</div> <!-- div.content_title -->\
\
\
<p>The <a href='http://genome.ucsc.edu/cgi-bin/hgGateway' target='_blank'>Genome Browser</a> stacks annotation tracks \
beneath genome coordinate positions, allowing rapid visual correlation of different types of information. \
It zooms and scrolls over chromosomes, showing the work of annotators worldwide.<br/>\
For more information go to <a href='http://genome.ucsc.edu/goldenPath/help/hgTracksHelp.html' target='_blank'>user guide</a> of \
UCSC Genome Browser.</p>\
<p align='center'><img src='img/UCSC_human.jpg'/></p>\
<p>The UCSC Genome Browser was created by the Genome Bioinformatics Group of UC Santa Cruz. \
Software Copyright (c) The Regents of the University of California. All rights reserved.\
</p>\
\
\
\
</div> <!-- div.main_content -->\
";


APPRIS.REPORT_INFO_SEQUENCE_PANEL = 
"\
<div id='content_panel'>\
\
<div class='content_title'>\
	<span class='content_highlighting'>Sequences</span>\
</div> <!-- div.content_title -->\
\
\
<p>This section displays by default the canonical protein sequence and upon request all isoforms.</p>\
</p>\
\
\
\
</div> <!-- div.main_content -->\
";


APPRIS.EXPORT_DATA_SUMMARY_PANEL = new Array();
APPRIS.EXPORT_DATA_SUMMARY_PANEL['table'] = "";
APPRIS.EXPORT_DATA_SUMMARY_PANEL['url'] = "";

APPRIS.EXPORT_DATA_APPRIS_PANEL = new Array();
APPRIS.EXPORT_DATA_APPRIS_PANEL['table'] = "";
APPRIS.EXPORT_DATA_APPRIS_PANEL['url'] = "";

APPRIS.EXPORT_DATA_SEQUENCE_PANEL = "";

APPRIS.EXPORT_DATA_UCSC_PANEL = ""; 

