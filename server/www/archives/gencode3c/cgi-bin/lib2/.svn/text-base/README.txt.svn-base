					
					PERL API DOCUMENTATION OF APPRIS (release 3c)


APPRIS uses MySQL relational databases to store its information. A comprehensive set of 
Application Programming Interfaces (APIs) serve as a middle-layer between underlying database schemes.
The APIs aim to encapsulate the database layout by providing efficient high-level access to data tables 
and isolate applications from data layout changes.

APPRIS's API is written in Perl.

This API documentation (http://appris.bioinfo.cnio.es/docs/apprislib/index.html) 
is automatically generated from POD within the modules by Pdoc.


INSTALLATION

There are two ways of installing the Perl API.

You can check it out using GitHub (Secure source code hosting and collaborative development - https://github.com), 
or you can download the files in gzipped TAR format from either our website.

1. Create an installation directory

	$ cd
	$ mkdir appris_rel3c
	$ cd appris_rel3c

2. Download the API packages:

	2.1 From our website:
		http://appris.bioinfo.cnio.es/data/appris_rel3c.api.tar.gz
	
	2.2 Or from Github:
		git clone git@github.com:josemrc/appris_rel3c.git

3. Download required packages using CPAN:

	Bio::Seq
	Bio::SeqIO
	Exporter
	FindBin
	Config::IniFiles
	Time::localtime
	File::Basename
	Getopt::Long
	Data::Dumper
	DBI
	DBD::mysql
	Bio::EnsEMBL::Registry (see http://www.ensembl.org/ documentation)

4. Set up your environment:

	You have to tell Perl where to find the modules you just installed. The best way to do this is adding the modules into 
	PERL5LIB environment variable.

	Under bash, ksh, or any sh-derived shell:

		APPRIS_LIB='path of APPRIS's API'
		PERL5LIB=${PERL5LIB}:${APPRIS_LIB}
		export PERL5LIB

	Under csh or tcsh:

		setenv PERL5LIB ${PERL5LIB}:'path of APPRIS's API'

5. APPRIS's database dump:

	Entire MySQL database can be downloaded from our site in gzipped TAR format. See next section to 
	know how to install the APPRIS data.


INSTALLING APPRIS DATA

	1. Entire MySQL database can be downloaded from our site in gzipped TAR format: 

		http://appris.bioinfo.cnio.es/data/mysql/appris.cexonic.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz
		http://appris.bioinfo.cnio.es/data/mysql/appris.corsair.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz
		http://appris.bioinfo.cnio.es/data/mysql/appris.crash.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz
		http://appris.bioinfo.cnio.es/data/mysql/appris.entity.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz
		http://appris.bioinfo.cnio.es/data/mysql/appris.firestar.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz
		http://appris.bioinfo.cnio.es/data/mysql/appris.inertia.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz
		http://appris.bioinfo.cnio.es/data/mysql/appris.matador3d.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz
		http://appris.bioinfo.cnio.es/data/mysql/appris.pi.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz
		http://appris.bioinfo.cnio.es/data/mysql/appris.spade.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz
		http://appris.bioinfo.cnio.es/data/mysql/appris.thump.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz

	2. Create APPRIS database:
	
		mysqladmin -h ${HOST} -u ${USER} -p${PWD} create ${DATABASE}
		
	3. Import entity tables:
		
		gunzip < appris.entity.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}		
		
	4. Import the rest of tables:
		
		gunzip < appris.firestar.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}
		gunzip < appris.matador3d.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}
		gunzip < appris.spade.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}		
		gunzip < appris.inertia.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}
		gunzip < appris.crash.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}
		gunzip < appris.thump.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}
		gunzip < appris.cexonic.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}
		gunzip < appris.corsair.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}
		gunzip < appris.pi.homo_sapiens_encode_3c_dev.21Jun2011.v28.dump.gz | mysql ${DATABASE} -h ${HOST} -u ${USER} -p${PWD}		


API DOCUMENTATION

The APPRIS's API has a code documentation in the form of standard Perl POD (Plain Old Documentation).
This is documentation is mixed in with the actual code, but can be automatically extracted and formatted using some software tools.
For example the following command will bring up some documentation about the module analysis of APPRIS class and each of its methods:

	perldoc APPRIS::Analysis::APPRIS

Also, a web version is available on the http://appris.bioinfo.cnio.es/docs/apprislib/index.html.


- Connecting to the Database - The Registry

All data used and created by APPRIS is stored in MySQL relational databases. If you want to access this database the first thing you 
have to do is to connect to it. For that, you will need to know some things:

db_host_name - the name of the host where the APPRIS database lives
db_name      - the name of APPRIS database
db_user      - the user name used to access the database
db_user_pwd  - the password of user used to access the database
db_port      - the port to access the database


First, we need a connection to an APPRIS database through the Registry module that has been imported. 
There are several ways to connect to APPRIS database. Almost every APPRIS script that you will write 
will contain a use statement like the following:

1. We've made a connection to an APPRIS Registry and passed parameters using the -attribute => 'somevalue' syntax:

	use APPRIS::Registry;
	
	my $registry = APPRIS::Registry->new(
		-dbhost  => 'db_host_name',
		-dbname  => 'db_name',
		-dbuser  => 'db_user',
		-dbpass  => 'db_user_pwd',
		-dbport  => 'db_port',
	);

2. We passed the parameters of connection (-attribute => 'somevalue' syntax) using the 'load_registry_from_db' method 
of APPRIS Registry module:

	use APPRIS::Registry;
	
	my $registry = APPRIS::Registry->new();
	$registry->load_registry_from_db(
		-dbhost  => 'db_host_name',
		-dbname  => 'db_name',
		-dbuser  => 'db_user',
		-dbpass  => 'db_user_pwd',
		-dbport  => 'db_port',
	);


3. Config::IniFiles (http://config-inifiles.sourceforge.net) module provides a way to have readable configuration 
files (INI) outside your Perl script. INI files consist of a number of sections, each preceded with the section 
name in square brackets, followed by parameter names and their values. Configuration of APPRIS database can be accessed 
from a tied hash:  

	[ENCODE_DB]
	  host=db_host_name
	  db=db_name
	  user=db_user
	  pass=db_user_pwd
	  port=db_port

We passed the parameters of connection using the Config INI file and 'load_registry_from_ini' method of APPRIS Registry module:

	use APPRIS::Registry;

	my $registry = APPRIS::Registry->new();
	$registry->load_registry_from_ini(
		-file  => '/path/configfile.ini'
	);



In addition to the parameters provided above the optional 'dbport' and 'dbpass' parameters can be used specify the 
TCP port to connect via and the password to use respectively. These values have sensible defaults and can often be omitted.


- Perl script samples


The APPRIS API allows manipulation of the database data through various objects. For example, some of the more heavily used 
objects are the Gene, Transcript and Translation objects.These objects are retrieved and stored in the database through the 
use of classes. Here we show you some useful samples how to use the APPRIS API:

 
	- Retrieve a list reference of gene objects:

		use APPRIS::Registry;
		
		my $registry = APPRIS::Registry->new(
			-dbhost  => 'db_host_name',
			-dbname  => 'db_name',
			-dbuser  => 'db_user',
			-dbpass  => 'db_user_pwd',
			-dbport  => 'db_port',
		);
		
		my $chromosome = $registry->fetch_by_region('M');	
		foreach my $gene (@{$chromosome}) {
			print "gene_id: ". $gene->stable_id ." source: ".$gene->source." external: ".$gene->external_name."\n";
		}


	- Another useful way to obtain information with respect to a gene:

		my $gene = $registry->fetch_by_gene_stable_id('ENSG00000135541');
		print("gene start:end:strand is "
				. join( ":", map { $gene->$_ } qw(start end strand) )
				. "\n" );


	- Retrieve a transcript and translate object from given transcript id:

		my $transcript = $registry->fetch_by_transc_stable_id('ENST00000367800');  
		print "\nTranscript ENST00000367800:\n".
				"* stable_id: ".$transcript->stable_id."\n".
				"* sequence:\n".$transcript->sequence."\n".
				"* pep. sequence:\n".$transcript->translation->sequence."\n";

		
		my $translation = $registry->fetch_by_transl_stable_id('ENST00000367800');
		print "\nTranslate ENST00000367800:\n".
			"* stable_id: ".$translation->stable_id."\n* pep. sequence:\n".$translation->sequence."\n";
	

	- Retrieve CDS positions:
		
		use APPRIS::Registry;
		
		my $registry = APPRIS::Registry->new(
			-dbhost  => 'db_host_name',
			-dbname  => 'db_name',
			-dbuser  => 'db_user',
			-dbpass  => 'db_user_pwd',
			-dbport  => 'db_port',
		);

		my $chromosome = $registry->fetch_basic_by_region('M');
		foreach my $gene (@{$chromosome}) {
			foreach my $transcript (@{$gene->transcripts}) {			
					
				if ($transcript->translate and $transcript->exons) {
					my ($exons) = $transcript->exons;
					my ($translate) = $transcript->translate;
					for(my $icds=0;$icds<scalar(@{$translate->cds});$icds++) {
						my ($cds) = $translate->cds->[$icds];
						my ($exon) = $exons->[$icds];
		
						print	"gene_id: ". $gene->stable_id .
								"transcript_id: ". $transcript->stable_id .
								"exon_id: ". $exon->stable_id .
								" cds_start: ".$cds->start." cds_end: ".$cds->end." cds_strand: ".$cds->strand."\n";
					}
				}
			}
		}


These and other useful scripts can be found on the following sites:

	- http://appris.bioinfo.cnio.es/data/samples/sample.pl - prints useful information of a gene/transcript/peptide
	- http://appris.bioinfo.cnio.es/data/samples/sample2.pl - prints CDS positions from a genomic region  





