function APPRIS(){}

/* 
 * CONSTANTS: Feature for web site 
 */

//APPRIS.RESTWS = "ws/latest/rest/";
APPRIS.RESTWS = "ws/rest/";
APPRIS.RELEASE_URL = "http://appris.bioinfo.cnio.es/";
APPRIS.RESTWS_URL = "http://appris.bioinfo.cnio.es/"+APPRIS.RESTWS;
//APPRIS.RESTWS_URL = "http://localhost/~jmrodriguez/APPRIS/"+APPRIS.RESTWS;

APPRIS.API_VERSION = "rel15";
APPRIS.VERSION = "9Jun2013.v2";
APPRIS.RELEASE_TITLE = "APPRIS release 3.1 - Jun 2013";
APPRIS.PERL_API_FILE = "<a href='../download/api/appris.perl-api.rel15.v1.tar.gz'>http://appris.bioinfo.cnio.es/download/api/appris.perl-api.rel15.v1.tar.gz</a>";

APPRIS.ENSEMBL_URL = "http://jan2013.archive.ensembl.org";
APPRIS.UCSC_URL = "http://genome-euro.ucsc.edu/cgi-bin/";
APPRIS.UCSC_CNIO_URL = "http://ucsc.cnio.es/cgi-bin/";
APPRIS.PROTEO_RESTWS_URL = "http://proteo.bioinfo.cnio.es/cgi-bin/";
//APPRIS.PROTEO_RESTWS_URL = "http://lobo.cnio.es/~jmrodriguez/PROTEO/cgi-bin/";
//APPRIS.UCSC_IMG_BG = "img/blueLines800-118-12.png";
APPRIS.UCSC_IMG_BG = "img/blueLines1100-118-12.png";


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

APPRIS.MYSQL_FILE_E = "appris.entity.appris_homo_sapiens_gencode_15."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_F = "appris.firestar.appris_homo_sapiens_gencode_15."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_M = "appris.matador3d.appris_homo_sapiens_gencode_15."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_C = "appris.corsair.appris_homo_sapiens_gencode_15."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_S = "appris.spade.appris_homo_sapiens_gencode_15."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_I = "appris.inertia.appris_homo_sapiens_gencode_15."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_X = "appris.cexonic.appris_homo_sapiens_gencode_15."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_T = "appris.thump.appris_homo_sapiens_gencode_15."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_R = "appris.crash.appris_homo_sapiens_gencode_15."+APPRIS.VERSION+".dump.gz";
APPRIS.MYSQL_FILE_A = "appris.pi.appris_homo_sapiens_gencode_15."+APPRIS.VERSION+".dump.gz";

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
APPRIS.MAIN_DUMP_FILE = "appris.results."+APPRIS.API_VERSION+"."+APPRIS.VERSION+".main.tsv.gz";
APPRIS.MAIN_DOWNLOAD = "<b><i>"+APPRIS.MAIN_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.MAIN_DUMP_FILE+"'>"+APPRIS.MAIN_DUMP_FILE+"</a></b>";

APPRIS.FIRESTAR_DOWNLOAD_TITLE = "Functional residues (firestar)";
APPRIS.FIRESTAR_DUMP_FILE = "appris.results."+APPRIS.API_VERSION+"."+APPRIS.VERSION+".firestar.gtf.gz";
APPRIS.FIRESTAR_DOWNLOAD = "<b><i>"+APPRIS.FIRESTAR_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.FIRESTAR_DUMP_FILE+"'>"+APPRIS.FIRESTAR_DUMP_FILE+"</a></b>";

APPRIS.MATADOR3D_DOWNLOAD_TITLE = "Tertiary structure (Matador3D)";
APPRIS.MATADOR3D_DUMP_FILE = "appris.results."+APPRIS.API_VERSION+"."+APPRIS.VERSION+".matador3d.gtf.gz";
APPRIS.MATADOR3D_DOWNLOAD = "<b><i>"+APPRIS.MATADOR3D_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.MATADOR3D_DUMP_FILE+"'>"+APPRIS.MATADOR3D_DUMP_FILE+"</a></b>";

APPRIS.CORSAIR_DOWNLOAD_TITLE = "Vertebrate conservation (CORSAIR)";
APPRIS.CORSAIR_DUMP_FILE = "appris.results."+APPRIS.API_VERSION+"."+APPRIS.VERSION+".corsair.gtf.gz";
APPRIS.CORSAIR_DOWNLOAD = "<b><i>"+APPRIS.CORSAIR_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.CORSAIR_DUMP_FILE+"'>"+APPRIS.CORSAIR_DUMP_FILE+"</a></b>";

APPRIS.SPADE_DOWNLOAD_TITLE = "Functional domains (SPADE)";
APPRIS.SPADE_DUMP_FILE = "appris.results."+APPRIS.API_VERSION+"."+APPRIS.VERSION+".spade.gtf.gz";
APPRIS.SPADE_DOWNLOAD = "<b><i>"+APPRIS.SPADE_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.SPADE_DUMP_FILE+"'>"+APPRIS.SPADE_DUMP_FILE+"</a></b>";

APPRIS.INERTIA_DOWNLOAD_TITLE = "Neutral evolution of exons (INERTIA)";
APPRIS.INERTIA_DUMP_FILE = "appris.results."+APPRIS.API_VERSION+"."+APPRIS.VERSION+".inertia.gtf.gz";
APPRIS.INERTIA_DOWNLOAD = "<b><i>"+APPRIS.INERTIA_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.INERTIA_DUMP_FILE+"'>"+APPRIS.INERTIA_DUMP_FILE+"</a></b>";

APPRIS.CEXONIC_DOWNLOAD_TITLE = "Conserved exonic structure (CExonic)";
APPRIS.CEXONIC_DUMP_FILE = "appris.results."+APPRIS.API_VERSION+"."+APPRIS.VERSION+".cexonic.gtf.gz";
APPRIS.CEXONIC_DOWNLOAD = "<b><i>"+APPRIS.CEXONIC_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.CEXONIC_DUMP_FILE+"'>"+APPRIS.CEXONIC_DUMP_FILE+"</a></b>";

APPRIS.THUMP_DOWNLOAD_TITLE = "Transmembrane helices (THUMP)";
APPRIS.THUMP_DUMP_FILE = "appris.results."+APPRIS.API_VERSION+"."+APPRIS.VERSION+".thump.gtf.gz";
APPRIS.THUMP_DOWNLOAD = "<b><i>"+APPRIS.THUMP_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.THUMP_DUMP_FILE+"'>"+APPRIS.THUMP_DUMP_FILE+"</a></b>";

APPRIS.CRASH_DOWNLOAD_TITLE = "Signal peptides/Mitochondrial signals (CRASH)";
APPRIS.CRASH_DUMP_FILE = "appris.results."+APPRIS.API_VERSION+"."+APPRIS.VERSION+".crash.gtf.gz";
APPRIS.CRASH_DOWNLOAD = "<b><i>"+APPRIS.CRASH_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.CRASH_DUMP_FILE+"'>"+APPRIS.CRASH_DUMP_FILE+"</a></b>";

APPRIS.APPRIS_DOWNLOAD_TITLE = "Principal isoforms (APPRIS) - chromosome location -";
APPRIS.APPRIS_DUMP_FILE = "appris.results."+APPRIS.API_VERSION+"."+APPRIS.VERSION+".appris.gtf.gz";
APPRIS.APPRIS_DOWNLOAD = "<b><i>"+APPRIS.APPRIS_DOWNLOAD_TITLE+":</i></b> "+
"<b><a href='../download/data/"+APPRIS.APPRIS_DUMP_FILE+"'>"+APPRIS.APPRIS_DUMP_FILE+"</a></b>";

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
APPRIS.METHOD_LABELS[APPRIS.INERTIA_TYPE] = "Selective Pressure Evolution";
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
 * CONSTANTS: Download labels 
 */
APPRIS.APPRIS_DLABELS = new Array();
APPRIS.METHOD_DLABELS = new Array();

APPRIS.APPRIS_LIST_TYPE = 'principal_isoform_list';
APPRIS.APPRIS_DLABELS[APPRIS.APPRIS_LIST_TYPE] = "List of Principal Isoforms";

APPRIS.APPRIS_SCORE_TYPE = 'principal_isoform_score';
APPRIS.APPRIS_DLABELS[APPRIS.APPRIS_SCORE_TYPE] = "Scores of APPRIS";

APPRIS.APPRIS_LABEL_TYPE = 'principal_isoform_labels';
APPRIS.APPRIS_DLABELS[APPRIS.APPRIS_LABEL_TYPE] = "Labels of APPRIS";


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
 * CONSTANTS: Tool panels 
 */
APPRIS.TOOL_DATA_SEQUENCE_PANEL = new Array();
APPRIS.TOOL_DATA_SEQUENCE_PANEL['url'] =  APPRIS.RESTWS_URL+"tool/blastp";
APPRIS.TOOL_DATA_SEQUENCE_PANEL['url2'] =  APPRIS.RESTWS_URL+"tool/muscle";


/* 
 * CONSTANTS: Species DB labels 
 */
APPRIS.UCSC_SPECIE_DB = new Array();

APPRIS.UCSC_SPECIE_DB['homo_sapiens'] = "hg19";
APPRIS.UCSC_SPECIE_DB['mus_musculus'] = "mm10";
APPRIS.UCSC_SPECIE_DB['rattus_norvegicus'] = "rn4";



/* 
 * CONSTANTS: Archive frame of web site 
 */
APPRIS.ARCHIVES =
"\
<span class='archives'>\
 <a title='Archive sites' onclick='infoPopUpWindow(APPRIS.REPORT_INFO_ARCHIVES)'>Archive sites</a>\
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
	<li><span class='content_highlighting'>APPRIS-Gencode 3c</span>, Aug 2011: <a href='archives/gencode3c/' class='linkPage'>http://appris.bioinfo.cnio.es/archives/gencode3c/</a></li>\
	<li><span class='content_highlighting'>APPRIS-Gencode 7</span>, Dec 2012: <a href='archives/gencode7/' class='linkPage'>http://appris.bioinfo.cnio.es/archives/gencode7/</a></li>\
	<li><span class='content_highlighting'>APPRIS-Gencode 12</span>, Mar 2013: <a href='archives/gencode12/' class='linkPage'>http://appris.bioinfo.cnio.es/archives/gencode12/</a></li>\
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
"		<li>valid Ensembl identifier.<br/>"+
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
			<!-- <li><a href='biomart.html' class='linkPage'>BioMart</a></li> -->\
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
<!-- <a title='BioMart' href='http://appris.bioinfo.cnio.es/biomart/martview/' target='_blank'>BioMart</a> | -->\
<a title='Download' href='docs/downloads.html'>Downloads</a> | \
<a title='Help' href='docs/docs.html'>Help & Docs</a> | \
<a title='Contact' href='docs/contact.html' >Contact</a>\
\
";

APPRIS.INFO_FRAME = 
"\
<!-- <a title='BioMart' href='http://appris.bioinfo.cnio.es/biomart/martview/' target='_blank'>BioMart</a> | -->\
<a title='Download' href='downloads.html'>Downloads</a> | \
<a title='Help' href='docs.html'>Help & Docs</a> | \
<a title='Contact' href='contact.html' >Contact</a>\
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
and <b>evidence of unusual evolution of exons</b>.</p>\
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
<div class='content_subtitle2'>Selective Pressure Evolution of Exons: [Currently, this method is not affecting in the selection of the principal isoform]</div> <!-- INERTIA -->\
<p>Variants with <b>differently evolving exons</b> are detected by <b>INERTIA</b>. \
Variants that are marked with a cross have alternative exons that are evolving in a unusual fashion.</p>\
Transcripts are aligned against vertebrate species using three alignment methods (<b>MAF</b>, <b>PRANK</b>, and <b>KAlign</b>) \
to limit alignment errors (or in case one fails). \
Evolutionary rates of exons from the same gene are contrasted using <b>SLR</b> program. \
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
<p>Peptides were assembled from five previously available proteomics data sets. Three of the peptide data sets came from published large-scale experiments \
(<a href='http://mbe.oxfordjournals.org/content/29/9/2265.long' target='_blank'>Ezkurdia</a>, \
<a href='http://www.nature.com/msb/journal/v7/n1/full/msb201181.html' target='_blank'>Nagaraj</a>, \
<a href='http://www.mcponline.org/content/11/3/M111.014050.long' target='_blank'>Geiger</a>) \
and the others were from two large spectra libraries, PeptideAtlas (\
<a href='http://pubs.acs.org/doi/abs/10.1021/pr301012j' target='_blank'>Farrah</a>) and \
NIST (<a href='http://peptide.nist.gov/' target='_blank'>http://peptide.nist.gov/</a>). \
In addition we searched against spectra from the GPM (\
<a href='http://bioinformatics.oxfordjournals.org/content/20/9/1466.long' target='_blank'>Craig</a>) and <b>PeptideAtlas</b> to identify further peptides.\
\
<p>These tracks show <b>where peptide evidence exists</b> (0 or 1) , but there is no means of scoring these tracks.</p>\
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



APPRIS.REPORT_INFO_DOWNLOAD_PANEL = 
"\
<div id='content_panel'>\
\
<div class='content_title'>\
	<span class='content_highlighting'>Download Data</span>\
</div> <!-- div.content_title -->\
<p>Description of the method scores:\
<ul>\
	<li><b>firestar</b> are the absolute numbers of functional residues detected.</li>\
	<li><b>Matador3D</b> is a score related to the number of exon that map to structure.</li>\
	<li><b>CORSAIR</b> shows the number of vertebrate species that have an isoform that aligns to the human isoform over the whole sequence and without gaps (human scores just 0.5).</li>\
	<li><b>SPADE</b> shows the absolute numbers of pfam domains that are detected. The numbers after the decimal indicate the numbers of partial domains.</li>\
	<li><b>THUMP</b> shows the number of TMH detected. Again numbers after the decimal indicate partial TMH.</li>\
	<li><b>CRASH</b> gives a reliability score for signal peptides (we use a score of 3 or above as a reliable signal peptide). Crash-M does the same thing for mitochondrial signal sequences.</li>\
</ul>\
</p>\
<p>The Principal score is the reliability that we give our selection of principal isoform for each gene (where we have selected an isoform, there is no score for those genes with just a single transcript).\
It goes from 60 to 100. The more reliable selections have scores of 85+.\
</p>\
<ul>\
	<li>\
		<a name='main_download'></a>\
		<div class='main_download'></div> <!-- get the files from APPRIS.js -->\
		<p>\
		This file has a <i>tabular format</i> whose columns are the following:\
		<ul>\
			<li><u>Chromosome</u></li>\
			<li><u>Ensembl gene identifier</u></li>\
			<li><u>Ensembl transcript identifier</u></li>\
			<li><u>Transcript name</u></li>\
			<li><u>CCDS identifier</u> (otherwise '-')</li>\
			<li><u>APPRIS annotation</u> where the variant was predicted as the main isoform (PRINCIPAL), and it is not able to decide which is the main isoform (LONGEST)</li>\
		</ul>\
		</p>\
		<p>\
			Where APPRIS is not able to decide which is the main isoform, APPRIS selects the variant with the longest protein sequence among those isoforms that APPRIS considers as candidate isoforms</p>\
		</p>\
	</li>\
	<li>\
		<a name='firestar_download'></a>\
		<div class='firestar_download'></div> <!-- get the files from APPRIS.js -->\
		<p>\
		This file has a <i>GTF format</i> that is a tabular file whose columns are the following:\
		</p>\
		<ul>\
			<li><u>Chromosome</u></li>\
			<li><u>Method name</u>: 'FIRESTAR'</li>\
			<li><u>Type of annotation</u>: 'functional_residue'</li>\
			<li><u>Start position</u> of functional residue</li>\
			<li><u>End position</u> of functional residue</li>\
			<li><u>Score</u>: for these annotations it is always '0'</li>\
			<li><u>Strand</u></li>\
			<li><u>Frame</u>: for these annotations it is always '.'</li>\
			<li><u>Attributes</u> end in a semicolon\
				<ul>\
					<li><u>note</u>: peptide position of functional residue</li>\
				</ul>\
			</li>\
		</ul>\
	</li>\
	<li>\
		<a name='matador3d_download'></a>\
		<div class='matador3d_download'></div>\
		<p>\
		This file has a <i>GTF format</i> that is a tabular file whose columns are the following:\
		</p>\
		<ul>\
			<li><u>Chromosome</u></li>\
			<li><u>Method name</u>: 'MATADOR3D'</li>\
			<li><u>Type of annotation</u>: 'homologous_structure'</li>\
			<li><u>Start position</u> of tertiary structure</li>\
			<li><u>End position</u> of tertiary structure</li>\
			<li><u>Score</u>: based on the number of regions that can be mapped to structural homologues</li>\
			<li><u>Strand</u></li>\
			<li><u>Frame</u>: for these annotations it is always '.'</li>\
			<li><u>Attributes</u> end in a semicolon\
				<ul>\
					<li><u>note</u>: pdb id and identity</li>\
				</ul>\
			</li>\
		</ul>\
	</li>\
	<li>\
		<a name='corsair_download'></a>\
		<div class='corsair_download'></div>\
		<p>\
		This file has a <i>GTF format</i> that is a tabular file whose columns are the following:\
		</p>\
		<ul>\
			<li><u>Chromosome</u></li>\
			<li><u>Method name</u>: 'CORSAIR'</li>\
			<li><u>Type of annotation</u>: 'no_vert_conservation', 'doubtful_vert_conservation', and 'vertebrate_conservation'</li>\
			<li><u>Start position</u> of transcript</li>\
			<li><u>End position</u> of transcript</li>\
			<li><u>Score</u>: that is approximately the number of vertebrate species that can be aligned without introducing gaps</li>\
			<li><u>Strand</u></li>\
			<li><u>Frame</u>: for these annotations it is always '.'</li>\
			<li><u>Attributes</u> end in a semicolon</li>\
		</ul>\
	</li>\
	<li>\
		<a name='spade_download'></a>\
		<div class='spade_download'></div>\
		<p>\
		This file has a <i>GTF format</i> that is a tabular file whose columns are the following:\
		</p>\
		<ul>\
			<li><u>Chromosome</u></li>\
			<li><u>Method name</u>: 'SPADE'</li>\
			<li><u>Type of annotation</u>: 'domain', 'domain_possibly_damaged', 'domain_damaged', and 'domain_wrong'</li>\
			<li><u>Start position</u> of domain</li>\
			<li><u>End position</u> of domain</li>\
			<li><u>Score</u>: a local pfam domain integrity score which decides whether a domain is damaged or not</li>\
			<li><u>Strand</u></li>\
			<li><u>Frame</u>: for these annotations it is always '.'</li>\
			<li><u>Attributes</u> end in a semicolon</li>\
		</ul>\
	</li>\
	<li>\
		<a name='thump_download'></a>\
		<div class='thump_download'></div>\
		<p>\
		This file has a <i>GTF format</i> that is a tabular file whose columns are the following:\
		</p>\
		<ul>\
			<li><u>Chromosome</u></li>\
			<li><u>Method name</u>: 'THUMP'</li>\
			<li><u>Type of annotation</u>: 'tmh_signal', and 'damaged_tmh_signal'</li>\
			<li><u>Start position</u> of transmembrane helix</li>\
			<li><u>End position</u> of transmembrane helix</li>\
			<li><u>Score</u>: for these annotations it is always '0'</li>\
			<li><u>Strand</u></li>\
			<li><u>Frame</u>: for these annotations it is always '.'</li>\
			<li><u>Attributes</u> end in a semicolon</li>\
		</ul>\
	</li>\
</ul>\
\
\
\
</div> <!-- div.main_content -->\
";
