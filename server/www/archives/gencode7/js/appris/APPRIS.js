function APPRIS(){}

/* 
 * CONSTANTS: Feature for web site 
 */

APPRIS.RESTWS = "../../ws/rel7/rest/";
APPRIS.RELEASE_URL = "http://appris.bioinfo.cnio.es/";
APPRIS.RESTWS_URL = "http://appris.bioinfo.cnio.es/"+APPRIS.RESTWS;
//APPRIS.RESTWS_URL = "http://localhost/~jmrodriguez/APPRIS/"+APPRIS.RESTWS;

APPRIS.VERSION = "13Dec2012.v19";
APPRIS.RELEASE_TITLE = "APPRIS/Gencode7 - release 19 - Dec 2012";
APPRIS.PERL_API_FILE = "<a href='../download/api/appris.perl-api.rel7.v19.tar.gz'>http://appris.bioinfo.cnio.es/download/api/appris.perl-api.rel7.v19.tar.gz</a>";

APPRIS.ENSEMBL_URL = "http://apr2011.archive.ensembl.org/Homo_sapiens/Transcript/Summary?db=core";
APPRIS.UCSC_URL = "http://genome.ucsc.edu/cgi-bin/";
APPRIS.UCSC_CNIO_URL = "http://ucsc.cnio.es/cgi-bin/";
APPRIS.PROTEO_RESTWS_URL = "http://proteo.bioinfo.cnio.es/cgi-bin/";
//APPRIS.PROTEO_RESTWS_URL = "http://lobo.cnio.es/~jmrodriguez/PROTEO/cgi-bin/";

APPRIS.RELEASE =
"\
<span class='release'>"+APPRIS.RELEASE_TITLE+" \
&copy;\
 <a title='CNIO' href='http://www.cnio.es' target='_blank'>CNIO</a> /\
 <a title='INB' href='http://www.inab.org' target='_blank'>INB</a>\
</span>\
";


/* 
 * CONSTANTS: Description of MYSQL file 
 */

APPRIS.MYSQL_FILE_E = "appris.entity.homo_sapiens_gencode."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_F = "appris.firestar.homo_sapiens_gencode."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_M = "appris.matador3d.homo_sapiens_gencode."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_C = "appris.corsair.homo_sapiens_gencode."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_S = "appris.spade.homo_sapiens_gencode."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_I = "appris.inertia.homo_sapiens_gencode."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_X = "appris.cexonic.homo_sapiens_gencode."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_T = "appris.thump.homo_sapiens_gencode."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_R = "appris.crash.homo_sapiens_gencode."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_A = "appris.pi.homo_sapiens_gencode."+APPRIS.VERSION+".dump.gz";

APPRIS.MYSQL_FILES = "<pre class='code'>"+
"<a href='"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_E+"'>"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_E+"</a><br/>"+
"<a href='"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_F+"'>"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_F+"</a><br/>"+
"<a href='"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_M+"'>"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_M+"</a><br/>"+
"<a href='"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_C+"'>"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_C+"</a><br/>"+
"<a href='"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_S+"'>"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_S+"</a><br/>"+
"<a href='"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_I+"'>"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_I+"</a><br/>"+
"<a href='"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_X+"'>"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_X+"</a><br/>"+
"<a href='"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_T+"'>"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_T+"</a><br/>"+
"<a href='"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_R+"'>"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_R+"</a><br/>"+
"<a href='"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_A+"'>"+APPRIS.RELEASE_URL+"download/mysql/"+APPRIS.MYSQL_FILE_A+"</a><br/>"+
"</p>";

APPRIS.GZIP_MYSQL_FILES = "<pre class='code'>"+
"gunzip < "+APPRIS.MYSQL_FILE_E+" | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}<br/>"+
"gunzip < "+APPRIS.MYSQL_FILE_F+" | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}<br/>"+
"gunzip < "+APPRIS.MYSQL_FILE_M+" | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}<br/>"+
"gunzip < "+APPRIS.MYSQL_FILE_C+" | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}<br/>"+
"gunzip < "+APPRIS.MYSQL_FILE_S+" | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}<br/>"+
"gunzip < "+APPRIS.MYSQL_FILE_I+" | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}<br/>"+
"gunzip < "+APPRIS.MYSQL_FILE_X+" | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}<br/>"+
"gunzip < "+APPRIS.MYSQL_FILE_T+" | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}<br/>"+
"gunzip < "+APPRIS.MYSQL_FILE_R+" | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}<br/>"+
"gunzip < "+APPRIS.MYSQL_FILE_A+" | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}<br/>"+
"</p>";

/* 
 * CONSTANTS: Description of Main annotations that can download 
 */

APPRIS.MAIN_DOWNLOAD_TITLE = "Principal isoforms (APPRIS)";
APPRIS.MAIN_DUMP_FILE = "appris.results.rel7."+APPRIS.VERSION+".main.tsv.gz";
APPRIS.MAIN_DOWNLOAD = "<b><i>"+APPRIS.MAIN_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.MAIN_DUMP_FILE+"'>"+APPRIS.MAIN_DUMP_FILE+"</a></b>";

APPRIS.FIRESTAR_DOWNLOAD_TITLE = "Functional residues (firestar)";
APPRIS.FIRESTAR_DUMP_FILE = "appris.results.rel7."+APPRIS.VERSION+".firestar.gtf.gz";
APPRIS.FIRESTAR_DOWNLOAD = "<b><i>"+APPRIS.FIRESTAR_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.FIRESTAR_DUMP_FILE+"'>"+APPRIS.FIRESTAR_DUMP_FILE+"</a></b>";

APPRIS.MATADOR3D_DOWNLOAD_TITLE = "Tertiary structure (Matador3D)";
APPRIS.MATADOR3D_DUMP_FILE = "appris.results.rel7."+APPRIS.VERSION+".matador3d.gtf.gz";
APPRIS.MATADOR3D_DOWNLOAD = "<b><i>"+APPRIS.MATADOR3D_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.MATADOR3D_DUMP_FILE+"'>"+APPRIS.MATADOR3D_DUMP_FILE+"</a></b>";

APPRIS.CORSAIR_DOWNLOAD_TITLE = "Vertebrate conservation (CORSAIR)";
APPRIS.CORSAIR_DUMP_FILE = "appris.results.rel7."+APPRIS.VERSION+".corsair.gtf.gz";
APPRIS.CORSAIR_DOWNLOAD = "<b><i>"+APPRIS.CORSAIR_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.CORSAIR_DUMP_FILE+"'>"+APPRIS.CORSAIR_DUMP_FILE+"</a></b>";

APPRIS.SPADE_DOWNLOAD_TITLE = "Functional domains (SPADE)";
APPRIS.SPADE_DUMP_FILE = "appris.results.rel7."+APPRIS.VERSION+".spade.gtf.gz";
APPRIS.SPADE_DOWNLOAD = "<b><i>"+APPRIS.SPADE_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.SPADE_DUMP_FILE+"'>"+APPRIS.SPADE_DUMP_FILE+"</a></b>";

APPRIS.INERTIA_DOWNLOAD_TITLE = "Neutral evolution of exons (INERTIA)";
APPRIS.INERTIA_DUMP_FILE = "appris.results.rel7."+APPRIS.VERSION+".inertia.gtf.gz";
APPRIS.INERTIA_DOWNLOAD = "<b><i>"+APPRIS.INERTIA_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.INERTIA_DUMP_FILE+"'>"+APPRIS.INERTIA_DUMP_FILE+"</a></b>";

APPRIS.CEXONIC_DOWNLOAD_TITLE = "Conserved exonic structure (CExonic)";
APPRIS.CEXONIC_DUMP_FILE = "appris.results.rel7."+APPRIS.VERSION+".cexonic.gtf.gz";
APPRIS.CEXONIC_DOWNLOAD = "<b><i>"+APPRIS.CEXONIC_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.CEXONIC_DUMP_FILE+"'>"+APPRIS.CEXONIC_DUMP_FILE+"</a></b>";

APPRIS.THUMP_DOWNLOAD_TITLE = "Transmembrane helices (THUMP)";
APPRIS.THUMP_DUMP_FILE = "appris.results.rel7."+APPRIS.VERSION+".thump.gtf.gz";
APPRIS.THUMP_DOWNLOAD = "<b><i>"+APPRIS.THUMP_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.THUMP_DUMP_FILE+"'>"+APPRIS.THUMP_DUMP_FILE+"</a></b>";

APPRIS.CRASH_DOWNLOAD_TITLE = "Signal peptides/Mitochondrial signals (CRASH)";
APPRIS.CRASH_DUMP_FILE = "appris.results.rel7."+APPRIS.VERSION+".crash.gtf.gz";
APPRIS.CRASH_DOWNLOAD = "<b><i>"+APPRIS.CRASH_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.CRASH_DUMP_FILE+"'>"+APPRIS.CRASH_DUMP_FILE+"</a></b>";


/* 
 * CONSTANTS: Feature labels 
 */
APPRIS.NO_LABEL				= "NO";
APPRIS.NO_ANNOT				= "No Principal Isoform";
APPRIS.UNKNOWN_LABEL		= "UNKNOWN";
APPRIS.UNKNOWN_ANNOT		= "Possible Principal Isoform";
APPRIS.OK_LABEL				= "OK";
APPRIS.OK_LABEL2			= "YES";
APPRIS.OK_ANNOT				= "Principal Isoform";

/* 
 * CONSTANTS: Method labels 
 */
APPRIS.METHOD_LABELS = new Array();
APPRIS.METHOD_NAMES = new Array();
APPRIS.METHOD_NAMES_2 = new Array();

APPRIS.APPRIS_TYPE = 'principal_isoform';
APPRIS.METHOD_LABELS[APPRIS.APPRIS_TYPE] = "Principal Isoform";
APPRIS.METHOD_NAMES[APPRIS.APPRIS_TYPE] = "appris";

APPRIS.FIRESTAR_TYPE = 'functional_residue';
APPRIS.METHOD_LABELS[APPRIS.FIRESTAR_TYPE] = "No. Functional Residues";
APPRIS.METHOD_NAMES[APPRIS.FIRESTAR_TYPE] = "firestar";
APPRIS.METHOD_NAMES_2[APPRIS.FIRESTAR_TYPE] = "vfirestar";

APPRIS.MATADOR3D_TYPE = 'homologous_structure';
APPRIS.METHOD_LABELS[APPRIS.MATADOR3D_TYPE] = "Tertiary Structure Score";
APPRIS.METHOD_NAMES[APPRIS.MATADOR3D_TYPE] = "matador3d";
APPRIS.METHOD_NAMES_2[APPRIS.MATADOR3D_TYPE] = "vmatador3d";

APPRIS.CORSAIR_TYPE = 'vertebrate_conservation';
APPRIS.METHOD_LABELS[APPRIS.CORSAIR_TYPE] = "Conservation Score (vertebrates)";
APPRIS.METHOD_NAMES[APPRIS.CORSAIR_TYPE] = "corsair";
APPRIS.METHOD_NAMES_2[APPRIS.CORSAIR_TYPE] = "vcorsair";

APPRIS.SPADE_TYPE = 'functional_domain';
APPRIS.METHOD_LABELS[APPRIS.SPADE_TYPE] = "Whole Domains";
APPRIS.METHOD_NAMES[APPRIS.SPADE_TYPE] = "spade";
APPRIS.METHOD_NAMES_2[APPRIS.SPADE_TYPE] = "vspade";

APPRIS.INERTIA_TYPE = 'neutral_evolution';
APPRIS.METHOD_LABELS[APPRIS.INERTIA_TYPE] = "Neutral Evolution of Exons";
APPRIS.METHOD_NAMES[APPRIS.INERTIA_TYPE] = "inertia";
APPRIS.METHOD_NAMES_2[APPRIS.INERTIA_TYPE] = "vinertia";

APPRIS.CEXONIC_TYPE = 'exon_conservation';
APPRIS.METHOD_LABELS[APPRIS.CEXONIC_TYPE] = "Conserved Exonic Structure";
APPRIS.METHOD_NAMES[APPRIS.CEXONIC_TYPE] = "cexonic";
APPRIS.METHOD_NAMES_2[APPRIS.CEXONIC_TYPE] = "vcexonic";

APPRIS.THUMP_TYPE = 'transmembrane_signal';
APPRIS.METHOD_LABELS[APPRIS.THUMP_TYPE] = "No. Transmembrane Helices";
APPRIS.METHOD_NAMES[APPRIS.THUMP_TYPE] = "thump";
APPRIS.METHOD_NAMES_2[APPRIS.THUMP_TYPE] = "vthump";

//APPRIS.CRASH_TYPE = 'peptide_mitochondrial_signal';
//APPRIS.METHOD_LABELS[APPRIS.CRASH_TYPE] = "Peptide or Mitochondrial Signal";

APPRIS.CRASH_SP_TYPE = 'signal_peptide';
APPRIS.METHOD_LABELS[APPRIS.CRASH_SP_TYPE] = "Signal Peptide Sequences";
APPRIS.METHOD_NAMES[APPRIS.CRASH_SP_TYPE] = "crash";
APPRIS.METHOD_NAMES_2[APPRIS.CRASH_SP_TYPE] = "vcrash";

APPRIS.CRASH_TP_TYPE = 'mitochondrial_signal';
APPRIS.METHOD_LABELS[APPRIS.CRASH_TP_TYPE] = "Mitochondrial Signal Sequence";
APPRIS.METHOD_NAMES[APPRIS.CRASH_TP_TYPE] = "crash";
APPRIS.METHOD_NAMES_2[APPRIS.CRASH_TP_TYPE] = "vcrash";

/* DEPRECATED
APPRIS.PROTEO_TYPE = 'peptide_evidence';
APPRIS.METHOD_LABELS[APPRIS.PROTEO_TYPE] = "No. peptides";
APPRIS.METHOD_NAMES[APPRIS.PROTEO_TYPE] = "proteo";
APPRIS.METHOD_NAMES_2[APPRIS.PROTEO_TYPE] = "vproteo";
 */


/* 
 * CONSTANTS: Export panels 
 */
APPRIS.EXPORT_DATA_SUMMARY_PANEL = new Array();
APPRIS.EXPORT_DATA_SUMMARY_PANEL['table'] = "";
APPRIS.EXPORT_DATA_SUMMARY_PANEL['url'] = "";

APPRIS.EXPORT_DATA_APPRIS_PANEL = new Array();
APPRIS.EXPORT_DATA_APPRIS_PANEL['table'] = "";
APPRIS.EXPORT_DATA_APPRIS_PANEL['url'] = "";

APPRIS.EXPORT_DATA_SEQUENCE_PANEL = new Array();
APPRIS.EXPORT_DATA_SEQUENCE_PANEL['url'] =  APPRIS.RESTWS_URL+"sequence";
APPRIS.EXPORT_DATA_SEQUENCE_PANEL['url2'] =  APPRIS.RESTWS_URL+"residues";

APPRIS.EXPORT_DATA_UCSC_PANEL = "";
APPRIS.EXPORT_DATA_UCSC_PROTEO_PANEL = ""; 


/* 
 * CONSTANTS: Archive frame of web site 
 */
APPRIS.ARCHIVES =
"\
<span class='archives'>\
 <a title='Archive sites' onclick='infoPopUpWindow(APPRIS.REPORT_INFO_ARCHIVES)'>View in archive sites</a>\
</span>\
";

APPRIS.REPORT_INFO_ARCHIVES = 
"\
<div id='content_panel'>\
\
<div class='content_title'>\
	<span class='content_highlighting'>APPRIS ARCHIVES</span>\
</div> <!-- div.content_title -->\
\
\
<p>The main APPRIS site is updated with the latest data from GENCODE.\
	The Archive sites have been set up from a particular release (e.g. rel3c from Gencode3c data) in APPRIS.\
</p>\
<div class='content_subtitle2'>Archives:</div> <!-- Transcript Status -->\
<ul>\
	<li><span class='content_highlighting'>APPRIS-Gencode 3c</span>, Aug 2011: <a href='../gencode3c/' class='linkPage'>http://appris.bioinfo.cnio.es/archives/gencode3c/</a></li>\
</ul>\
\
\
\
</div> <!-- div.main_content -->\
";


/* 
 * CONSTANTS: Help and documentation 
 */

APPRIS.SEARCH_ERROR_SMS =
"<p>The <b>database server is currently down</b>. <b>We are working on it right now</b>. <br/>"+
"Sorry for the inconvenience. Please contact with the server administrator: "+
"<a title='Email contact' href='mailto:jmrodriguez@cnio.es' target='_blank' style='cursor: pointer'>jmrodriguez@cnio.es</a></p>";

APPRIS.SEARCH_NOT_MATCH_SMS = 
"<p>Your query does not match any genes in the database. Note that the query must:<br/>"+
"	<ul>"+
"		<li>have alphanumeric values, at least one of which must be a letter</li>"+
"		<li>be at least three characters long</li>"+
"		<li>not match any combination of these values: ENST00, ENSG00, ENSP00, CCDS, OTTHUMG00, OTTHUMT00.<br/>"+
"		For this cases, you have to give the exact identifier.</li>"+
"	</ul>"+
"</p>";
					
APPRIS.DOC_MENU = 
"\
<h2><a href='docs.html' class='linkPage'>Help & Documentations</a></h2>\
<ul>\
	<h3>Data Production:</h3>\
	<li>\
		<ul>\
			<li><a href='gene_and_transcript_types.html' class='linkPage'>Gene and Transcript types</a></li>\
			<li><a href='appris.html' class='linkPage'>APPRIS System</a></li>\
		</ul>\
	</li>\
	<p />\
	<h3>Data Access:</h3>\
	<li>\
		<ul>\
			<li><a href='api.html' class='linkPage'>Perl API Documentation</a></li>\
			<li><a href='aws.html' class='linkPage'>Web Services</a></li>\
			<li><a href='biomart.html' class='linkPage'>BioMart</a></li>\
			<li><a href='downloads.html' class='linkPage'>Downloads</a></li>\
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

APPRIS.INFO_FRAME_DOC = 
"\
<a title='BioMart' href='http://appris.bioinfo.cnio.es/biomart/martview/' target='_blank'>BioMart</a>\
 | <a title='Download' href='docs/downloads.html'>Downloads</a>\
 | <a title='Help' href='docs/docs.html'>Help & Docs</a>\
 | <a title='Contact' href='docs/contact.html' >Contact</a>\
\
";

APPRIS.INFO_FRAME = 
"\
<a title='BioMart' href='http://appris.bioinfo.cnio.es/biomart/martview/' target='_blank'>BioMart</a>\
 | <a title='Download' href='downloads.html'>Downloads</a>\
 | <a title='Help' href='docs.html'>Help & Docs</a>\
 | <a title='Contact' href='contact.html' >Contact</a>\
\
";


/* 
 * CONSTANTS: Description of every panel of report page 
 */
APPRIS.REPORT_INFO_SUMMARY_PANEL =
"\
<div id='content_panel'>\
\
<div class='content_title'>\
	<span class='content_highlighting'>Principal and alternative isoforms</span>\
</div> <!-- div.content_title -->\
<p>This table shows all protein coding variants and defines the consitutive isoform, \
or principal functional variant. Non-coding transcripts can also be viewed by clicking on the link.\
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
<div class='content_subtitle2'>Transcript Class (or Biotype):</div> <!-- Transcript Class -->\
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
<p>The GENCODE consortium supplies genome-wide features on three different confidence levels:</p>\
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
<div class='content_subtitle2'>Principal Isoform:</div> <!-- Principal Isoform -->\
<p>Isoforms are marked with the following icons.\
\
\
<table>\
<tbody>\
	<tr>\
		<td class='reference'><img src='img/OK_2-icon.png'/></td>\
		<td class='reference'>Principal Isoform. Reliability score is more than 90%</td>\
	</tr>\
	<tr>\
		<td class='reference'><img src='img/OK_1-icon.png'/></td>\
		<td class='reference'>Principal Isoform. Reliability score is more than 80%</td>\
	</tr>\
	<tr>\
		<td class='reference'><img src='img/OK-icon.png'/></td>\
		<td class='reference'>Principal Isoform. Reliability score is less than 80%</td>\
	</tr>\
	<tr>\
		<td class='reference'><img src='img/UNKNOWN-icon.png'/></td>\
		<td class='reference'>Potential Principal Isoform.</td>\
	</tr>\
	<tr>\
		<td class='reference'><img src='img/NO-icon.png'/></td>\
		<td class='reference'>Alternative Isoform.</td>\
	</tr>\
</tbody>\
</table>\
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
<p><b>APPRIS</b> detects principal isoforms based on a range of methods, \
including, for example, protein <b>structural information</b>, \
<b>functionally important residues</b>, <b>conservation of functional domains</b> \
and <b>evidence of non-neutral evolution of exons</b>.</p>\
\
\
<div class='content_subtitle2'>Num. Functional Residues:</div> <!-- FIRESTAR -->\
<p><b>firestar</b> predicts <b>functionally important residues</b>. \
The box shows the total number of functional residues detected by firestar for each transcript.</p>\
<p>The <b>result in detail</b> shows: \
<ul>\
<li>the peptide position, </li>\
<li>the functional amino acid,</li>\
<li>PDB ligand id,</li>\
<li>and a score of all predicted catalytic residues. It is a measure of prediction reliablity. The score \
should be close to six.\
</ul>\
</p>\
\
\
<div class='content_subtitle2'>Tertiray Structure Score:</div> <!-- Matador3D -->\
<p><b>Matador3D</b> analyses <b>protein structural information</b> for each variant. \
The score is based on the number of exons that can be mapped to structural homologues. \
This score is only comparable for transcripts within the same gene and should not be used \
to compare between genes.</p>\
<p>The <b>result in detail</b> shows: \
<ul>\
<li>the range of peptides, </li>\
<li>the best template of PDB,</li>\
<li>and the percentage of identity.\
</ul>\
</p>\
\
\
<div class='content_subtitle2'>Conservation score (vertebrates):</div> <!-- CORSAIR -->\
<p><b>CORSAIR</b> carries out BLAST <b>searches against vertebrates</b> to determine \
the most likely principal isoform. The score approximates to the number of species \
that have isoforms that can be aligned to each tested isoform without introducing gaps.</p>\
<p>The <b>result in detail</b> shows: \
<ul>\
<li>the nearest homologue specie, </li>\
<li>and the percentage of identity.\
</ul>\
</p>\
\
\
<div class='content_subtitle2'>Whole Domains:</div> <!-- SPADE -->\
<p><b>SPADE</b> identifies the <b>functional domains present</b> in a transcript \
and detects those domains that are damaged (not whole). Variants that are marked \
with a cross have either <i><b>lost</b></i> conserved functional domains or have \
damaged functional domains with respect to other transcripts.</p>\
<p>The <b>result in detail</b> shows: \
<ul>\
<li>the alignment start, </li>\
<li>the alignment end, </li>\
<li>domain name, </li>\
<li>the best e-value that has obtained. This e-value could come from other transcript that shares \
the same peptide region.</li>\
<li>And the Pfam alignments.</li>\
</ul>\
</p>\
\
\
<div class='content_subtitle2'>Num. Transmembrane Helices:</div> <!-- THUMP -->\
<p><b>THUMP</b> makes <b>unanimous predictions of trans-membrane helices</b>. \
The score shows the number of trans-membrane helices predicted by THUMP for each variant.</p>\
<p>The <b>result in detail</b> shows: \
<ul>\
<li>helix start, </li>\
<li>helix end, </li>\
<li>and flag if applied that says whether helix is damaged. </li>\
</ul>\
</p>\
\
\
<div class='content_subtitle2'>Signal Peptide Sequences and Mitochondrial Signal Sequences:</div> <!-- CRASH -->\
<p><b>CRASH</b> predicts the <b>presence and location of signal peptides</b> \
and <b>cleavage sites in amino acid sequences</b> using an especially reliable form of \
<b>SignalP</b> and <b>TargetP</b>. \
Variants that are predicted to have reliable signal sequences are marked with a tick.</p>\
<p>The <b>result in detail</b> shows: \
<ul>\
<li>the type of singal, </li>\
<li>start position of signal, </li>\
<li>and end position of signal. </li>\
</ul>\
</p>\
\
\
<div class='content_subtitle2'>Neutral Evolution of Exons: [Currently, this method is not affecting in the selection of the principal isoform]</div> <!-- INERTIA -->\
<p>Variants with <b>differently evolving exons</b> are detected by <b>INERTIA</b>. \
Variants that are marked with a cross have alternative exons that are evolving in a non-neutral fashion.</p>\
Transcripts are aligned against vertebrate species using three alignment methods (<b>MAF</b>, <b>PRANK</b>, and <b>KAlign</b>) \
to limit alignment errors (or in case one fails). \
Evolutionary rates of exons from the same gene are contrasted using <bSLR</b> program. \
<p>The <b>result in detail</b> shows: \
<ul>\
<li>the SLR omega score, </li>\
<li>the exon's start coordinate, </li>\
<li>and the exon's end coordinate. </li>\
</ul>\
</p>\
\
\
<div class='content_subtitle2'>Conserved Exonic Structure: [Currently, this method is not affecting in the selection of the principal isoform]</div> <!-- CExonic -->\
<p><b>CExonic</b> analyses the <b>conservation of exonic structure</b> \
between orthologous splicing isoforms of two species (<i>human-mouse</i>). \
If one transcript does not have conserved exonic structure, \
while all the rest have, this transcript is marked with a cross.</p>\
<p>The <b>result in detail</b> shows: \
<ul>\
<li>num. of human exons, </li>\
<li>num. of mouse exons, </li>\
<li>the num. of non-aligned introns, </li>\
<li>the coordinates for the non-aligned introns, </li>\
<li>and a visualization of alignment between species. </li>\
</ul>\
</p>\
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


APPRIS.REPORT_INFO_SEQUENCE_PANEL = 
"\
<div id='content_panel'>\
\
<div class='content_title'>\
	<span class='content_highlighting'>Sequences</span>\
</div> <!-- div.content_title -->\
\
\
<p>This section displays the <b>protein sequences</b> of all isoforms. Besides, it shows the <b>regions \
for the annotations of some methods</b>.</p>\
<p>By default the annotations are disabled. To show the annotations, you have to click on 'Show all' button.\
</p>\
<p>The annotations that could be shown are:\
<ul>\
<li>Functional residues</li>\
<li>Tertiary structure</li>\
<li>Functional domain</li>\
<li>Transmembrane helices</li>\
<li>Peptide/Mitochondrial sequence</li>\
</ul>\
</p>\
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
	<span class='content_highlighting'>APPRIS tracks in UCSC Genome Browser</span>\
</div> <!-- div.content_title -->\
\
\
<p>The <a href='http://genome.ucsc.edu/cgi-bin/hgGateway' target='_blank'>Genome Browser</a> stacks annotation tracks \
beneath genome coordinate positions, allowing rapid visual correlation of different types of information. \
It zooms and scrolls over chromosomes, showing the work of annotators worldwide.<br/> \
For more information go to <a href='http://genome.ucsc.edu/goldenPath/help/hgTracksHelp.html' target='_blank'>user guide</a> of \
UCSC Genome Browser.</p> \
\
<p align='center'><img src='img/UCSC_human.jpg'/></p> \
\
<p>Here we show <b>APPRIS tracks from a screenshot of the UCSC Genome Browser that is generated dynamically using \
description tracks in BED format</b>. The browser window shows a section of the genome that corresponds to the \
genomic region of the gene.</p> \
\
<p>The top panel shows the <a href='http://www.ncbi.nlm.nih.gov/CCDS/CcdsBrowse.cgi' target='blank'>Consensus CDS</a> tracks \
and the annotated <a href='http://www.ensembl.org/' target='_blank'>Ensembl transcripts</a> \
(taken from the current version of Ensembl, there may be a few differences with the version of \
Ensembl in APPRIS).</p>\
\
<p>The visible transcript tracks show the transcripts for the gene in the report view. However, the browser window may also include \
transcripts from neighbouring genes, in particular when one or more transcripts <i>'reads through'</i> to the neighbouring gene.</p>\
\
<p>The tracks show <b>protein coding transcripts only</b>.</p>\
\
<p>The middle panel <b>shows how the results from the APPRIS services map to the annotated Ensembl/GENCODE transcripts</b>. \
Tracks are shown <b>only where the methods generate results</b>. The tracks come from the following annotations:\
\
<ul>\
<li>APPRIS principal isoform (from APPRIS).</li>\
<li>Known functional residues (from firestar).</li>\
<li>Regions with known 3D structure (from Matador3D).</li>\
<li>Whole Pfam functional domains (from SPADE).</li>\
<li>Damaged Pfam functional domains (from SPADE).</li>\
<li>Isoform with the most cross-species evidence (from CORSAIR).</li>\
<li>Neutrally evolving exons (from INERTIA).</li>\
<li>Unusually evolving exons (from INERTIA).</li>\
<li>Signal peptide sequences (from CRASH).</li>\
<li>Mitochondrial signal sequences (from CRASH).</li>\
<li>Transmembrane helices (from THUMP).</li>\
<li>Damaged transmembrane helices (from THUMP).</li>\
<li>Exonic structures conserved in Mouse (from CExonic).</li>\
<li>Exonic structures not conserved in Mouse (from CExonic).</li>\
</ul>\
</p>\
\
<br/>\
\
<p>Clicking on the image will take you to the UCSC Genome Browser with the APPRIS tracks, which will allow you to include \
all the available tracks from the UCSC browser.</p>\
\
<p>For more information refer to the \
<a href='http://genome.ucsc.edu/goldenPath/help/hgTracksHelp.html' target='_blank'>user guide of UCSC Genome Browser</a>. \
The UCSC Genome Browser was created by the Genome Bioinformatics Group of UC Santa Cruz. \
Software Copyright (c) The Regents of the University of California. All rights reserved.</p>\
\
\
\
</div> <!-- div.main_content -->\
";


APPRIS.REPORT_INFO_UCSC_PROTEO_PANEL = 
"\
<div id='content_panel'>\
\
<div class='content_title'>\
	<span class='content_highlighting'>Proteomic evidence tracks in UCSC Genome Browser</span>\
</div> <!-- div.content_title -->\
\
\
<p>Here we show <b>proteomic evidence tracks</b> from a screenshot of the UCSC Genome Browser that is generated dynamically using \
description tracks in BED format. The browser window shows a section of the genome that corresponds to the \
genomic region of the gene.</p> \
\
<p>We show two kind of proteomics tracks for each variant. First, we show the mapped peptides from the \
(<a href='http://www.ncbi.nlm.nih.gov/pubmed/22446687' target='_blank'>Ezkurdia I, del Pozo A, et al.,2012</a>) dataset \
scored by the number of experiments in which peptide was detected. These are tagged as <b>Valencia Lab Peptides</b>. \
The second track is from the Human Build, Apr 2012 of <b>Peptide Atlas</b> \
(<a href='http://www.ncbi.nlm.nih.gov/pubmed/15642101' target='_blank'>Desiere F et al.,2004</a>). \
These tracks show <b>where peptide evidence exists</b>, but there is no means of scoring these tracks. \
These are tagged as <b>Aebersold Lab Peptides</b>. The two sets of peptides overlap to a large extent.</p>\
\
<br/>\
\
<p>Clicking on the image will take you to the UCSC Genome Browser with the APPRIS tracks, which will allow you to include \
all the available tracks from the UCSC browser.</p>\
\
<p>For more information refer to the \
<a href='http://genome.ucsc.edu/goldenPath/help/hgTracksHelp.html' target='_blank'>user guide of UCSC Genome Browser</a>. \
The UCSC Genome Browser was created by the Genome Bioinformatics Group of UC Santa Cruz. \
Software Copyright (c) The Regents of the University of California. All rights reserved.</p>\
\
\
\
</div> <!-- div.main_content -->\
";


APPRIS.REPORT_INFO_UCSC_RNASEQ_PANEL = 
"\
<div id='content_panel'>\
\
<div class='content_title'>\
	<span class='content_highlighting'>RNA-Seq tracks in UCSC Genome Browser</span>\
</div> <!-- div.content_title -->\
\
\
<p>Here we show <b>RNA-seq tracks</b> from \
<a href='http://genes.mit.edu/burgelab/' target='_blank'>Chris Burge's lab</a> (Wang et al.,2008) \
on a screenshot of the UCSC Genome Browser. These are mapped to the genome using <b>GEM Mapper</b> by the \
<a href='http://pasteur.crg.es/portal/page/portal/Internet/02_Research/01_Programmes/01_Bioinformatics_Genomics/01_Bioinformatics_Genomics' target='_blank'>Guigó lab</a> \
at the <b>Center for Genomic Regulation</b> (<a href='http://www.crg.es/' target='_blank'>CRG</a>). \
The subtracks display RNA-seq data from various tissues/cell lines: Brain, Breast, Heart, and Lymph Node. \
The browser window shows a section of the genome that corresponds to the genomic region of the gene.</p> \
\
<br/>\
\
<p>For more information refer to the \
<a href='http://genome.ucsc.edu/goldenPath/help/hgTracksHelp.html' target='_blank'>user guide of UCSC Genome Browser</a>. \
The UCSC Genome Browser was created by the Genome Bioinformatics Group of UC Santa Cruz. \
Software Copyright (c) The Regents of the University of California. All rights reserved.</p>\
\
\
\
</div> <!-- div.main_content -->\
";
