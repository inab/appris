=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Registry

=head1 SYNOPSIS

  $registry = APPRIS::Registry->new(
    -dbhost  => 'localhost',
    -dbname  => 'homo_sapiens_encode_3c',
    -dbuser  => 'jmrodriguez'
    );

  $gene = $registry->fetch_by_stable_id($stable_id);

  @genes = @{ $registry->fetch_by_region('X', 1, 10000) };

=head1 DESCRIPTION

All Adaptors are stored/registered using this module.
This module should then be used to get the adaptors needed.

The registry can be loaded from a configuration file or from database info.

=head1 METHODS

=cut

package APPRIS::Registry;

use strict;
use warnings;
use Data::Dumper;
use Config::IniFiles;

use APPRIS::Gene;
use APPRIS::Transcript;
use APPRIS::Translation;
use APPRIS::Exon;
use APPRIS::CDS;
use APPRIS::Codon;
use APPRIS::XrefEntry;
use APPRIS::Analysis;
use APPRIS::Analysis::Region;
use APPRIS::Analysis::Firestar;
use APPRIS::Analysis::Matador3D;
use APPRIS::Analysis::SPADE;
use APPRIS::Analysis::INERTIA;
use APPRIS::Analysis::CRASH;
use APPRIS::Analysis::THUMP;
use APPRIS::Analysis::CExonic;
use APPRIS::Analysis::CORSAIR;
use APPRIS::Analysis::APPRIS;
use APPRIS::DBSQL::DBAdaptor;
use APPRIS::Utils::Argument qw(rearrange);
use APPRIS::Utils::Exception qw(throw warning deprecate);

my ($API_VERSION) = 'rel3c';

{
    # Encapsulated class data
    #___________________________________________________________
    my %_attr_data = # DEFAULT
		(
			dbhost			=>  undef,
			dbport			=>  '3306',
			dbname			=>  undef,
			dbuser			=>  undef,
			dbpass			=>  '',
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
	
	sub dbhost {
		my ($self, $arg) = @_;
		$self->{dbhost} = $arg if defined $arg;
		return $self->{dbhost};
	}

	sub dbport {
		my ($self, $arg) = @_;
		$self->{dbport} = $arg if defined $arg;
		return $self->{dbport};
	}

	sub dbname {
		my ($self, $arg) = @_;
		$self->{dbname} = $arg if defined $arg;
		return $self->{dbname};
	}

	sub dbuser {
		my ($self, $arg) = @_;
		$self->{dbuser} = $arg if defined $arg;
		return $self->{dbuser};
	}

	sub dbpass {
		my ($self, $arg) = @_;
		$self->{dbpass} = $arg if defined $arg;
		return $self->{dbpass};
	}
}

=head2 new

  Example :

    APPRIS::Registry->new()

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
  
sub software_version{
	my ($self) = @_;
	return $API_VERSION;
}

=head2 load_registry_from_db

  Arg [dbhost] : string
                The domain name of the database host to connect to.

  Arg [dbport] : string (Optional)
                The port to use when connecting to the database.

  Arg [dbname] : string
                The name of database to connect to.

  Arg [dbuser] : string
                The name of the database user to connect with.

  Arg [dbpass] : string
                The password to be used to connect to the database.

  Example :

    $registry->load_registry_from_db(
       -dbhost  => 'localhost',
       -dbname  => 'homo_sapiens_encode_3c',
       -dbuser  => 'jmrodriguez'
       -dbpass  => ''
    );

  Description: Will load the correct versions of the appris
               databases for the software release it can find on a
               database instance into the registry.

  Exceptions : None.
  Status     : Stable

=cut

sub load_registry_from_db {
	my ($self) = shift;
	
	my (
		$dbhost,	$dbport,
		$dbname,	$dbuser,
		$dbpass
    )
    = rearrange( [
		'dbhost',	'dbport',
		'dbname',	'dbuser',
		'dbpass'
	],
	@_
	);
	return undef
		unless (
			defined $dbhost and defined $dbname and
			defined $dbuser	and defined $dbpass 
	);
	
 	$self->dbhost($dbhost);
 	$self->dbname($dbname);
 	$self->dbuser($dbuser);
 	$self->dbpass($dbpass);

	return $self;
}

=head2 load_registry_from_ini

  Arg [file] : string
                Config ini file to connect to database.

  Example :

    $registry->load_registry_from_ini(
       -file  => 'config.ini'
    );

  Description: Will load the correct versions of the appris
               databases for the software release it can find on a
               database instance into the registry.
               The ini file has to be like:
                  [ENCODE_DB]
                    host=localhost
                    db=
                    user=
                    pass=
                    port=

  Exceptions : None.
  Status     : Stable

=cut

sub load_registry_from_ini {
	my ($self) = shift;

	my (
		$file
    )
    = rearrange( [
		'file'
	],
	@_
	);
	return undef
		unless (
			defined $file 
	);

	my ($cfg) = new Config::IniFiles(
		-file =>  $file
	); 
	my ($dbhost) = $cfg->val( 'ENCODE_DB', 'host');
	my ($dbname) = $cfg->val( 'ENCODE_DB', 'db' );
	my ($dbport) = $cfg->val( 'ENCODE_DB', 'port');
	my ($dbuser) = $cfg->val( 'ENCODE_DB', 'user');
	my ($dbpass) = $cfg->val( 'ENCODE_DB', 'pass');
	return undef
		unless (
			defined $dbhost and defined $dbname and
			defined $dbuser	and defined $dbpass 
	);
	
 	$self->dbhost($dbhost);
 	$self->dbname($dbname);
 	$self->dbuser($dbuser);
 	$self->dbpass($dbpass);

	return $self;
}

=head2 fetch_basic_by_region

  Arg [1]    : string $chr
               The name of the sequence region that the slice will be
               created on.
  Arg [2]    : int $start (optional)
               The start of the slice on the sequence region
  Arg [3]    : int $end (optional)
               The end of the slice on the sequence region
  Example    : $gene = $registry->fetch_basic_by_region('M', 1, 1000);
  Description: Retrieves a listref of gene object 
               from the database via its stable id.
               If the regions is not found undef is returned instead.
  Returntype : Listref of APPRIS::Gene or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_basic_by_region {
	my ($self, $chr, $start, $end) = @_;

	my ($entity_list);
	
	# Connection to DBAdaptor
	my ($db_adaptor) = APPRIS::DBSQL::DBAdaptor->new
	(
		dbhost => $self->dbhost,
		dbport => $self->dbport,
		dbname => $self->dbname,
		dbuser => $self->dbuser,
		dbpass => $self->dbpass,
	);

	# Get gene list
	my ($gene_list);
	eval {
		my ($datasource) = $db_adaptor->query_datasource(name => 'Ensembl_Gene_Id')->[0];

		my (%region) = (
				datasource_id	=> $datasource->{'datasource_id'},
				chromosome		=> $chr
		);
		$region{'start'} = $start if (defined $start);
		$region{'end'} = $end if (defined $end);
		
		$gene_list = $db_adaptor->query_entity_coordinate3(%region);
		throw('Argument must be a correct region') unless (defined $gene_list and scalar(@{$gene_list}) > 0);
	};
	throw('Argument must be a correct region') if ($@);

	$db_adaptor->commit(); # Do commit of everything
	$db_adaptor->disconnect();
	
	# Get every gene
	foreach my $gene (@{$gene_list})
	{
		my ($entity) = $self->fetch_by_gene_stable_id($gene->{'identifier'});
		push(@{$entity_list},$entity) if (defined $entity);
	}

	return $entity_list;
}

=head2 fetch_by_region

  Arg [1]    : string $chr
               The name of the sequence region that the slice will be
               created on.
  Arg [2]    : int $start (optional)
               The start of the slice on the sequence region
  Arg [3]    : int $end (optional)
               The end of the slice on the sequence region
  Example    : $gene = $registry->fetch_by_region('M', 1, 1000);
  Description: Retrieves a listref of gene object 
               from the database via its stable id.
               If the regions is not found undef is returned instead.
               Note: Entity object contains the results of analysis methods.
  Returntype : Listref of APPRIS::Gene or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_by_region {
	my ($self, $chr, $start, $end) = @_;

	my ($entity_list);
	my ($get_analysis)=1; # Flag of 'get_analysis' is active
	
	# Connection to DBAdaptor
	my ($db_adaptor) = APPRIS::DBSQL::DBAdaptor->new
	(
		dbhost => $self->dbhost,
		dbport => $self->dbport,
		dbname => $self->dbname,
		dbuser => $self->dbuser,
		dbpass => $self->dbpass,
	);

	# Get gene list
	my ($gene_list);
	eval {
		my ($datasource) = $db_adaptor->query_datasource(name => 'Ensembl_Gene_Id')->[0];

		my (%region) = (
				datasource_id	=> $datasource->{'datasource_id'},
				chromosome		=> $chr
		);
		$region{'start'} = $start if (defined $start);
		$region{'end'} = $end if (defined $end);
		
		$gene_list = $db_adaptor->query_entity_coordinate3(%region);
		throw('Argument must be a correct region') unless (defined $gene_list and scalar(@{$gene_list}) > 0);
	};
	throw('Argument must be a correct region') if ($@);
	
	$db_adaptor->commit(); # Do commit of everything
	$db_adaptor->disconnect();
	
	# Get every gene
	foreach my $gene (@{$gene_list})
	{
		my ($entity) = $self->fetch_by_gene_stable_id($gene->{'identifier'},$get_analysis);
		push(@{$entity_list},$entity) if (defined $entity);
	}

	return $entity_list;
}

=head2 fetch_basic_by_position

  Arg [1]    : string $chr
               The name of the sequence region that the slice will be
               created on.
  Arg [2]    : int $start
               The start of the slice on the sequence region
  Arg [3]    : int $end (optional)
               The end of the slice on the sequence region
               If is not defined, the position starts and ends in the 
               given 'start' position
  Arg [4]    : string $type (optional)
               Type of entity: gene or transcript. By default are both
  Example    : $entity = $registry->fetch_basic_by_position('M', 1000);
  Description: Retrieves a listref of entity object 
               from the database via its stable id.
               If the regions is not found undef is returned instead.
  Returntype : Listref of APPRIS::Gene and APPRIS::Transcript or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_basic_by_position {
	my ($self, $chr, $start, $end, $type) = @_;

	my ($entity_list);
	
	# Connection to DBAdaptor
	my ($db_adaptor) = APPRIS::DBSQL::DBAdaptor->new
	(
		dbhost => $self->dbhost,
		dbport => $self->dbport,
		dbname => $self->dbname,
		dbuser => $self->dbuser,
		dbpass => $self->dbpass,
	);

	# Get list of several entities
	my ($aux_entity_list);
	eval {
		my (%region) = (
				chromosome		=> $chr
		);
		$region{'start'} = $start if (defined $start);
		if (defined $end) {
			$region{'end'} = $end;
		} else {
			$region{'end'} = $start;
		}
		
		$aux_entity_list = $db_adaptor->query_entity_coordinate4(%region);
		return undef unless (defined $aux_entity_list and scalar(@{$aux_entity_list}) > 0);
	};
	throw('Argument must be a correct position') if ($@);

	# Get gene and trascript list
	my ($gene_datasource_id);
	my ($transcript_datasource_id);
	eval {
		my ($datasource) = $db_adaptor->query_datasource(name => 'Ensembl_Gene_Id')->[0];
		$gene_datasource_id = $datasource->{'datasource_id'} if (defined $datasource);
		my ($datasource2) = $db_adaptor->query_datasource(name => 'Ensembl_Transcript_Id')->[0];
		$transcript_datasource_id = $datasource2->{'datasource_id'} if (defined $datasource2);
	};
	throw('Wrong datasource') if ($@);
	
	$db_adaptor->commit(); # Do commit of everything
	$db_adaptor->disconnect();
	
	foreach my $aux_entity (@{$aux_entity_list})
	{
		# If the type of entity is not defined, we return the list of gene and transcript		
		if (defined $type) {
			if ( ($type eq 'gene') and ($aux_entity->{'datasource_id'} eq $gene_datasource_id) ) {
				my ($entity) = $self->fetch_by_gene_stable_id($aux_entity->{'identifier'});
				push(@{$entity_list},$entity) if (defined $entity);
			}
			elsif ( ($type eq 'transcript') and ($aux_entity->{'datasource_id'} eq $transcript_datasource_id) ) {
				my ($entity) = $self->fetch_by_transc_stable_id($aux_entity->{'identifier'});
				push(@{$entity_list},$entity) if (defined $entity);			
			}			
		}
		else {
			if ($aux_entity->{'datasource_id'} eq $gene_datasource_id) {
				my ($entity) = $self->fetch_by_gene_stable_id($aux_entity->{'identifier'});
				push(@{$entity_list},$entity) if (defined $entity);
			}
			elsif ($aux_entity->{'datasource_id'} eq $transcript_datasource_id) {
				my ($entity) = $self->fetch_by_transc_stable_id($aux_entity->{'identifier'});
				push(@{$entity_list},$entity) if (defined $entity);			
			}			
		}
	}	

	return $entity_list;
}

=head2 fetch_by_position

  Arg [1]    : string $chr
               The name of the sequence region that the slice will be
               created on.
  Arg [2]    : int $start
               The start of the slice on the sequence region
  Arg [3]    : int $end (optional)
               The end of the slice on the sequence region
               If is not defined, the position starts and ends in the 
               given 'start' position
  Arg [4]    : string $type (optional)
               Type of entity: gene or transcript. By default are both               
  Example    : $gene = $registry->fetch_by_position('M', 1000);
  Description: Retrieves a listref of entity objects 
               from the database via its stable id.
               If the regions is not found undef is returned instead.
               Note: Entity object contains the results of analysis methods.
  Returntype : Listref of APPRIS::Gene and APPRIS::Transcript or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_by_position {
	my ($self, $chr, $start, $end, $type) = @_;

	my ($entity_list);
	my ($get_analysis)=1; # Flag of 'get_analysis' is active
	
	# Connection to DBAdaptor
	my ($db_adaptor) = APPRIS::DBSQL::DBAdaptor->new
	(
		dbhost => $self->dbhost,
		dbport => $self->dbport,
		dbname => $self->dbname,
		dbuser => $self->dbuser,
		dbpass => $self->dbpass,
	);

	# Get list of several entities
	my ($aux_entity_list);
	eval {
		my (%region) = (
				chromosome		=> $chr
		);
		$region{'start'} = $start if (defined $start);
		if (defined $end) {
			$region{'end'} = $end;
		} else {
			$region{'end'} = $start;
		}
		
		$aux_entity_list = $db_adaptor->query_entity_coordinate4(%region);
		return undef unless (defined $aux_entity_list and scalar(@{$aux_entity_list}) > 0);
	};
	throw('Argument must be a correct position') if ($@);

	# Get gene and trascript list
	my ($gene_datasource_id);
	my ($transcript_datasource_id);
	eval {
		my ($datasource) = $db_adaptor->query_datasource(name => 'Ensembl_Gene_Id')->[0];
		$gene_datasource_id = $datasource->{'datasource_id'} if (defined $datasource);
		my ($datasource2) = $db_adaptor->query_datasource(name => 'Ensembl_Transcript_Id')->[0];
		$transcript_datasource_id = $datasource2->{'datasource_id'} if (defined $datasource2);
	};
	throw('Wrong datasource') if ($@);

	$db_adaptor->commit(); # Do commit of everything
	$db_adaptor->disconnect();
	
	foreach my $aux_entity (@{$aux_entity_list})
	{
		# If the type of entity is not defined, we return the list of gene and transcript
		if (defined $type) {
			if ( ($type eq 'gene') and ($aux_entity->{'datasource_id'} eq $gene_datasource_id) ) {
				my ($entity) = $self->fetch_by_gene_stable_id($aux_entity->{'identifier'},$get_analysis);
				push(@{$entity_list},$entity) if (defined $entity);
			}
			elsif ( ($type eq 'transcript') and ($aux_entity->{'datasource_id'} eq $transcript_datasource_id) ) {
				my ($entity) = $self->fetch_by_transc_stable_id($aux_entity->{'identifier'},$get_analysis);
				push(@{$entity_list},$entity) if (defined $entity);			
			}			
		}
		else {
			if ($aux_entity->{'datasource_id'} eq $gene_datasource_id) {
				my ($entity) = $self->fetch_by_gene_stable_id($aux_entity->{'identifier'},$get_analysis);
				push(@{$entity_list},$entity) if (defined $entity);
			}
			elsif ($aux_entity->{'datasource_id'} eq $transcript_datasource_id) {
				my ($entity) = $self->fetch_by_transc_stable_id($aux_entity->{'identifier'},$get_analysis);
				push(@{$entity_list},$entity) if (defined $entity);			
			}			
		}
	}	

	return $entity_list;
}

=head2 fetch_basic_by_xref_entry

  Arg [1]    : String $xref_entry 
               An external identifier of the entity to be obtained
  Example    : $gene = $registry->fetch_basic_by_xref_entry('TRMT2A');
  Description: Retrieves a entity object (gene or transcript) 
               from the database via external reference entry.
               If the gene or transcript is not found
               undef is returned instead.
  Returntype : APPRIS::Gene or APPRIS::Transcript or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_basic_by_xref_entry {
	my ($self, $xref_entry) = @_;

	my ($entity) = $self->fetch_entity_by_xref_entry($xref_entry);
	return $entity;
}

=head2 fetch_by_xref_entry

  Arg [1]    : String $xref_entry 
               An external identifier of the entity to be obtained
  Example    : $gene = $registry->fetch_by_xref_entry('TRMT2A');
  Description: Retrieves a entity object (gene or transcript) 
               from the database via external reference entry.
               If the gene or transcript is not found
               undef is returned instead.
               Note: Entity object contains the results of analysis methods.
  Returntype : APPRIS::Gene or APPRIS::Transcript or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_by_xref_entry {
	my ($self, $xref_entry) = @_;

	my ($get_analysis)=1; # Flag of 'get_analysis' is active

	my ($entity) = $self->fetch_entity_by_xref_entry($xref_entry,$get_analysis);
	return $entity;
}

=head2 fetch_basic_by_stable_id

  Arg [1]    : name of the type of entity in the registry.
  Arg [2]    : String $id 
               The stable ID of the entity to retrieve
  Example    : $gene = $registry->fetch_basic_by_stable_id('gene','ENSG00000148944');
  Description: Retrieves a entity object (gene or transcript) 
               from the database via its stable id.
               If the gene or transcript is not found
               undef is returned instead.
  Returntype : APPRIS::Gene or APPRIS::Transcript or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_basic_by_stable_id {
	my ($self, $type, $stable_id) = @_;

	my ($entity);

	if ($type eq 'gene') {
		$entity = $self->fetch_by_gene_stable_id($stable_id);
	} elsif ($type eq 'transcript') {
		$entity = $self->fetch_by_transc_stable_id($stable_id);
	}
	return $entity;
}

=head2 fetch_by_stable_id

  Arg [1]    : name of the type of entity in the registry.
  Arg [2]    : String $id 
               The stable ID of the entity to retrieve
  Example    : $gene = $registry->fetch_by_stable_id('gene','ENSG00000148944');
  Description: Retrieves a entity object (gene or transcript) 
               from the database via its stable id.
               If the gene or transcript is not found
               undef is returned instead.
               Note: Entity object contains the results of analysis methods.
  Returntype : APPRIS::Gene or APPRIS::Transcript or undef
  Exceptions : if we cant get the gene or transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_by_stable_id {
	my ($self, $type, $stable_id) = @_;

	my ($entity);
	my ($get_analysis)=1; # Flag of 'get_analysis' is active
	
	if ($type eq 'gene') {
		$entity = $self->fetch_by_gene_stable_id($stable_id,$get_analysis); 
	} elsif ($type eq 'transcript') {
		$entity = $self->fetch_by_transc_stable_id($stable_id,$get_analysis);
	}
	return $entity;
}

=head2 fetch_entity_by_xref_entry

  Arg [1]    : String $xref_entry 
               An external identifier of the entity to be obtained
  Example    : $gene = $registry->fetch_entity_by_xref_entry('TRMT2A');
  Description: Retrieves a gene object 
               from the database via its stable id.
               If the gene or transcript is not found
               undef is returned instead.
  Returntype : APPRIS::Gene or APPRIS::Transcript or undef
  Exceptions : if we cant get the gene in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_entity_by_xref_entry {
	my ($self, $xref_entry, $get_analysis) = @_;
	
	my ($entity_list);
	
	# Connection to DBAdaptor
	my ($db_adaptor) = APPRIS::DBSQL::DBAdaptor->new
	(
		dbhost => $self->dbhost,
		dbport => $self->dbport,
		dbname => $self->dbname,
		dbuser => $self->dbuser,
		dbpass => $self->dbpass,
	);

	# Get list of datasource
	my ($datasource_list);
	my ($datasource_list2);
	eval {
		$datasource_list = $db_adaptor->query_datasource();
		foreach my $ds (@{$datasource_list})
		{
			$datasource_list2->{$ds->{'datasource_id'}} = $ds;
		}
	};
		
	# Get entity report
	my ($aux_query_entity_list);
	my ($query_entity_list);
	eval {
		# Check from the main 'entity' table
		$aux_query_entity_list = $db_adaptor->query_entity_like(identifier => $xref_entry);
	};
	throw('Argument must be a correct entry') if ($@);

	# Check from the 'xref_entity' table
	unless (defined $aux_query_entity_list and scalar(@{$aux_query_entity_list})>0)
	{
		eval
		{
			$aux_query_entity_list = $db_adaptor->query_xref_identify_like(identifier => $xref_entry);
			foreach my $xref_report (@{$aux_query_entity_list})
			{
				my ($xref_identifier_list) = $db_adaptor->query_entity(entity_id => $xref_report->{'entity_id'});
				foreach my $xref_identifier (@{$xref_identifier_list})
				{
					push(@{$query_entity_list},{
										'entity_id'		=> $xref_identifier->{'entity_id'},
										'identifier'	=> $xref_identifier->{'identifier'},
										'datasource_id'	=> $xref_identifier->{'datasource_id'},
										'class'			=> $xref_identifier->{'class'},
										'status'		=> $xref_identifier->{'status'},
										'source'		=> $xref_identifier->{'source'},
										'level'			=> $xref_identifier->{'level'}
					});
				}		
			}
		};
		throw('Argument must be a correct entry') if ($@);		
	} else {
		$query_entity_list = $aux_query_entity_list;
	}
	throw('Argument must be a correct entry') unless (defined $query_entity_list or scalar(@{$query_entity_list})<0);

	# For each mapped entity it prints the list of objets
	foreach my $query_entity (@{$query_entity_list})
	{
		my ($entity_report);
		my ($entity_id) = $query_entity->{'entity_id'};
		my ($datasource_id) = $query_entity->{'datasource_id'};
		my ($namespace) = $datasource_list2->{$datasource_id}->{'name'};
		
		$entity_report->{'identifier'} = $query_entity->{'identifier'};		
		$entity_report->{'namespace'} = $namespace;
		$entity_report->{'class'} = $query_entity->{'class'};
		$entity_report->{'status'} = $query_entity->{'status'};
		$entity_report->{'source'} = $query_entity->{'source'};
		$entity_report->{'level'} = $query_entity->{'level'};

		# Get coordinate of entity
		my ($coordinate);
		eval {
			my ($coordinate_list) = $db_adaptor->query_coordinate(entity_id => $entity_id);
			if (defined $coordinate_list and defined $coordinate_list->[0]) {
				$coordinate = $coordinate_list->[0];
			}
			else {
				throw('Wrong coordinate');
			}
		};
		throw('Wrong coordinate') if ($@);
					
		# Get external name, xref identify
		my ($external_name);
		my ($xref_identifies);
		my ($trans_id_list);
		foreach my $datasource (@{$datasource_list})
		{
			eval {
				my ($datasource_name) = $datasource->{'name'};
				my ($datasource_id) = $datasource->{'datasource_id'};
				my ($datasource_desc) = $datasource->{'description'};
				my ($xref_id_list) = $db_adaptor->query_xref_identify
				(
					entity_id => $entity_id,
					datasource_id => $datasource_id
				);
				my ($xref_id);
				if (defined $xref_id_list and scalar(@{$xref_id_list}) > 0) {
					$xref_id = $xref_id_list->[0]->{'identifier'};
				}
	
				# External name			
				if ($datasource_name eq 'External_Id' and defined $xref_id) {
					$external_name = $xref_id;
				}
				# Xref identifiers
				elsif ((
						$datasource_name eq 'CCDS' or
						$datasource_name eq 'UniProtKB_SwissProt' or 
						$datasource_name eq 'Ensembl_Gene_Id' or
						$datasource_name eq 'Vega_Gene_Id' or
						$datasource_name eq 'Vega_Transcript_Id'
						)
						and defined $xref_id) {
					push(@{$xref_identifies},
						APPRIS::XrefEntry->new
						(
							-id				=> $xref_id,
							-dbname			=> $datasource_name,
							-description	=> $datasource_desc
						)
					);
				}
				# Xref identifiers
				elsif (($datasource_name eq 'Ensembl_Transcript_Id') and defined $xref_id_list and (scalar(@{$xref_id_list}) > 0)) {
					foreach my $xref (@{$xref_id_list}) {
						push(@{$trans_id_list}, $xref->{'identifier'});
					}
				}							
			};
			throw('Wrong xref identify') if ($@);	
		}

		# Get transcript list
		my ($transcripts);
		foreach my $transcript_id (@{$trans_id_list}) {
			my ($transcript) = $self->fetch_by_transc_stable_id($transcript_id, $get_analysis);
			if (defined $transcript_id) {
				push(@{$transcripts}, $transcript);
			}
			else {
				throw('Wrong transcript');	
			}
		}
		
		# Create object
		my ($entity);
		if ($namespace eq 'Ensembl_Gene_Id' or
			$namespace eq 'Vega_Gene_Id')
		{
			$entity = APPRIS::Gene->new();
			$entity->transcripts($transcripts);
		}
		elsif ($namespace eq 'Ensembl_Transcript_Id' or
			$namespace eq 'Vega_Transcript_Id')
		{
			$entity = APPRIS::Transcript->new();			
		}

		$entity->chromosome($coordinate->{'chromosome'});
		$entity->start($coordinate->{'start'});
		$entity->end($coordinate->{'end'});
		$entity->strand($coordinate->{'strand'});
		$entity->stable_id($entity_report->{'identifier'});
		$entity->biotype($entity_report->{'class'});
		$entity->status($entity_report->{'status'});
		$entity->source($entity_report->{'source'});
		$entity->level($entity_report->{'level'});
		$entity->external_name($external_name) if (defined $external_name);
		$entity->xref_identify($xref_identifies) if (defined $xref_identifies);
		
		
		push(@{$entity_list}, $entity) if (defined $entity);
	}	

	$db_adaptor->commit(); # Do commit of everything
	$db_adaptor->disconnect();

	return $entity_list;
}

=head2 fetch_by_gene_stable_id

  Arg [1]    : String $id 
               The stable ID of the gene to retrieve
  Example    : $gene = $registry->fetch_by_gene_stable_id('ENSG00000148944');
  Description: Retrieves a gene object 
               from the database via its stable id.
               If the gene or transcript is not found
               undef is returned instead.
  Returntype : APPRIS::Gene or undef
  Exceptions : if we cant get the gene in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_by_gene_stable_id {
	my ($self, $stable_id, $get_analysis) = @_;
	
	# Connection to DBAdaptor
	my ($db_adaptor) = APPRIS::DBSQL::DBAdaptor->new
	(
		dbhost => $self->dbhost,
		dbport => $self->dbport,
		dbname => $self->dbname,
		dbuser => $self->dbuser,
		dbpass => $self->dbpass,
	);

	# Get entity report
	my ($entity);
	eval {
		my ($entity_list) = $db_adaptor->query_entity(identifier => $stable_id);
		if (defined $entity_list and scalar(@{$entity_list}) > 0) {
			$entity = $entity_list->[0];
		}
		else {
			throw('Argument must be a correct stable id');
		}
	};
	throw('Argument must be a correct stable id') if ($@);

	# Get coordinate of entity
	my ($coordinate);
	eval {
		my ($coordinate_list) = $db_adaptor->query_coordinate(entity_id => $entity->{'entity_id'});
		if (defined $coordinate_list and defined $coordinate_list->[0]) {
			$coordinate = $coordinate_list->[0];
		}
		else {
			throw('Wrong coordinate');
		}
	};
	throw('Wrong coordinate') if ($@);

	# Get the list of datasources for this gene
	my ($datasource_list) = $db_adaptor->query_datasource();
	
	# Get external name, xref identifiers, and transcript id list
	my ($external_name);
	my ($xref_identifies);
	my ($trans_id_list);	
	foreach my $datasource (@{$datasource_list}) {
		eval {
			my ($datasource_name) = $datasource->{'name'};
			my ($datasource_id) = $datasource->{'datasource_id'};
			my ($datasource_desc) = $datasource->{'description'};
			
			my ($xref_id_list) = $db_adaptor->query_xref_identify
			(
				entity_id => $entity->{'entity_id'},
				datasource_id => $datasource_id
			);

			# External name
			if (($datasource_name eq 'External_Id') and defined $xref_id_list and (scalar(@{$xref_id_list}) > 0)) {
				my ($xref_id) = $xref_id_list->[0]->{'identifier'};
				$external_name = $xref_id if (defined $xref_id);
			}
			# Xref identifiers
			elsif (($datasource_name eq 'UniProtKB_SwissProt' or
					$datasource_name eq 'Vega_Gene_Id')
					and defined $xref_id_list and (scalar(@{$xref_id_list}) > 0)) {
				my ($xref_id) = $xref_id_list->[0]->{'identifier'};
				if (defined $xref_id) {
					push(@{$xref_identifies},
						APPRIS::XrefEntry->new
						(
							-id				=> $xref_id,
							-dbname			=> $datasource_name,
							-description	=> $datasource_desc
						)
					);					
				}
			}
			# Xref identifiers
			elsif (($datasource_name eq 'Ensembl_Transcript_Id') and defined $xref_id_list and (scalar(@{$xref_id_list}) > 0)) {
				foreach my $xref (@{$xref_id_list}) {
					push(@{$trans_id_list}, $xref->{'identifier'});
				}
			}			
		};
		throw('Wrong xref identify') if ($@);	
	}

	# Get transcript list
	my ($transcripts);
	foreach my $transcript_id (@{$trans_id_list}) {
		my ($transcript) = $self->fetch_by_transc_stable_id($transcript_id,$get_analysis);
		if (defined $transcript_id) {
			push(@{$transcripts}, $transcript);
		}
		else {
			throw('Wrong transcript');	
		}
	}
	
	$db_adaptor->commit(); # Do commit of everything
	$db_adaptor->disconnect();

	# Create object
	my ($gene) = APPRIS::Gene->new
	(
		-chr		=> $coordinate->{'chromosome'},
		-start		=> $coordinate->{'start'},
		-end		=> $coordinate->{'end'},
		-strand		=> $coordinate->{'strand'},
		-stable_id	=> $entity->{'identifier'},
		-biotype	=> $entity->{'class'},
		-status		=> $entity->{'status'},
		-source		=> $entity->{'source'},
		-level		=> $entity->{'level'},
	);
	$gene->external_name($external_name) if (defined $external_name);
	$gene->xref_identify($xref_identifies) if (defined $xref_identifies);
	$gene->transcripts($transcripts);
	
	return $gene;
}

=head2 fetch_by_transc_stable_id

  Arg [1]    : String $id 
               The stable ID of the transcript to retrieve
  Example    : $transcript = $registry->fetch_trans_by_stable_id('ENST00000148944');
  Description: Retrieves a transcript object 
               from the database via its stable id.
               If the gene or transcript is not found
               undef is returned instead.
  Returntype : APPRIS::Transcript or undef
  Exceptions : if we cant get the transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_by_transc_stable_id {
	my ($self, $stable_id, $get_analysis) = @_;
	
	# Connection to DBAdaptor
	my ($db_adaptor) = APPRIS::DBSQL::DBAdaptor->new
	(
		dbhost => $self->dbhost,
		dbport => $self->dbport,
		dbname => $self->dbname,
		dbuser => $self->dbuser,
		dbpass => $self->dbpass,
	);

	# Get entity report
	my ($entity);
	eval {
		my ($entity_list) = $db_adaptor->query_entity(identifier => $stable_id);
		if (defined $entity_list and scalar(@{$entity_list}) > 0) {
			$entity = $entity_list->[0];
		}
		else {
			throw('Argument must be a correct stable id');
		}
	};
	throw('Argument must be a correct stable id') if ($@);

	# Get coordinate of entity
	my ($coordinate);
	eval {
		my ($coordinate_list) = $db_adaptor->query_coordinate(entity_id => $entity->{'entity_id'});
		if (defined $coordinate_list and defined $coordinate_list->[0]) {
			$coordinate = $coordinate_list->[0];
		}
		else {
			throw('Wrong coordinate');
		}
	};
	throw('Wrong coordinate') if ($@);

	# Get sequence
	my($sequence);
	eval {
		my ($type_list) = $db_adaptor->query_type(name => 'transcript');
		my ($transcript_type_id) = $type_list->[0]->{'type_id'};			
		
		my($sequence_list)=$db_adaptor->query_sequence
		(
			entity_id => $entity->{'entity_id'},
			type_id => $transcript_type_id
		);
		if(defined $sequence_list and scalar(@{$sequence_list}) > 0) {
			$sequence=$sequence_list->[0]->{'sequence'};		
		}
	};
	throw('Wrong nucleotide sequence') if ($@);	
	
	# Get the list of datasource for this transcript
	my ($datasource_list) = $db_adaptor->query_datasource();

	# Get external name, xref identify
	my ($external_name);
	my ($xref_identifies);
	foreach my $datasource (@{$datasource_list}) {
		eval {
			my ($datasource_name) = $datasource->{'name'};
			my ($datasource_id) = $datasource->{'datasource_id'};
			my ($datasource_desc) = $datasource->{'description'};
			my ($xref_id_list) = $db_adaptor->query_xref_identify
			(
				entity_id => $entity->{'entity_id'},
				datasource_id => $datasource_id
			);
			my ($xref_id);
			if (defined $xref_id_list and scalar(@{$xref_id_list}) > 0) {
				$xref_id = $xref_id_list->[0]->{'identifier'};
			}

			# External name			
			if ($datasource_name eq 'External_Id' and defined $xref_id) {
				$external_name = $xref_id;
			}
			# Xref identifiers
			elsif ((
					$datasource_name eq 'CCDS' or
					$datasource_name eq 'UniProtKB_SwissProt' or 
					$datasource_name eq 'Ensembl_Gene_Id' or
					$datasource_name eq 'Vega_Gene_Id' or
					$datasource_name eq 'Vega_Transcript_Id'
					)
					and defined $xref_id) {
				push(@{$xref_identifies},
					APPRIS::XrefEntry->new
					(
						-id				=> $xref_id,
						-dbname			=> $datasource_name,
						-description	=> $datasource_desc
					)
				);
			}
		};
		throw('Wrong xref identify') if ($@);	
	}

	# Get translation
	my ($translate) = $self->fetch_by_transl_stable_id($stable_id);

	# Get exons
	my ($exons);
	eval {
		my ($exon_list) = $db_adaptor->query_exon(entity_id => $entity->{'entity_id'}); 
		foreach my $exon (@{$exon_list}){
			my($exon_report);
			$exon_report->{'exon_id'}=$exon->{'exon_id'} if(defined $exon->{'exon_id'});
			$exon_report->{'identifier'}=$exon->{'identifier'} if(defined $exon->{'identifier'});						
			$exon_report->{'strand'}=$exon->{'strand'} if(defined $exon->{'strand'});
			$exon_report->{'start'}=$exon->{'start'} if(defined $exon->{'start'});
			$exon_report->{'end'}=$exon->{'end'} if(defined $exon->{'end'});						
			
			push(@{$exons},
				APPRIS::Exon->new
				(
					-start		=> $exon->{'start'},
					-end		=> $exon->{'end'},
					-strand		=> $exon->{'strand'},
					-stable_id	=> $exon->{'identifier'}
				)
			);
		}
	};
	throw('Wrong exons') if ($@);	

	# Get Analysis
	my ($analysis);
	if (defined $get_analysis) {
		$analysis = $self->fetch_analysis_by_stable_id($stable_id);
	}
	
	$db_adaptor->commit(); # Do commit of everything
	$db_adaptor->disconnect();

	# Create object
	my ($transcript) = APPRIS::Transcript->new
	(
		-chr		=> $coordinate->{'chromosome'},
		-start		=> $coordinate->{'start'},
		-end		=> $coordinate->{'end'},
		-strand		=> $coordinate->{'strand'},
		-stable_id	=> $entity->{'identifier'},
		-biotype	=> $entity->{'class'},
		-status		=> $entity->{'status'},
		-source		=> $entity->{'source'},
		-level		=> $entity->{'level'},
	);
	$transcript->sequence($sequence) if (defined $sequence);
	$transcript->external_name($external_name) if (defined $external_name);
	$transcript->xref_identify($xref_identifies) if (defined $xref_identifies);
	$transcript->translate($translate) if (defined $translate);
	$transcript->exons($exons) if (defined $exons);
	$transcript->analysis($analysis) if (defined $analysis);

	return $transcript;	
}

=head2 fetch_by_transl_stable_id

  Arg [1]    : String $id 
               The stable ID of the transcript to retrieve
  Example    : $translate = $registry->fetch_by_transl_stable_id('ENST000001');
  Description: Retrieves a transcript object 
               from the database via its stable id.
               If the gene or transcript is not found
               undef is returned instead.
  Returntype : APPRIS::Translation or undef
  Exceptions : if we cant get the transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_by_transl_stable_id {
	my ($self, $stable_id) = @_;
	
	# Connection to DBAdaptor
	my ($db_adaptor) = APPRIS::DBSQL::DBAdaptor->new
	(
		dbhost => $self->dbhost,
		dbport => $self->dbport,
		dbname => $self->dbname,
		dbuser => $self->dbuser,
		dbpass => $self->dbpass,
	);

	# Get entity report
	my ($entity);
	eval {
		my ($entity_list) = $db_adaptor->query_entity(identifier => $stable_id);
		if (defined $entity_list and scalar(@{$entity_list}) > 0) {
			$entity = $entity_list->[0];
		}
		else {
			throw('Argument must be a correct stable id');
		}
	};
	throw('Argument must be a correct stable id') if ($@);
	
	# Get sequence
	my ($sequence);
	eval {
		my ($type_list) = $db_adaptor->query_type(name => 'peptide');
		my ($transcript_type_id) = $type_list->[0]->{'type_id'};			
		
		my($sequence_list)=$db_adaptor->query_sequence
		(
			entity_id => $entity->{'entity_id'},
			type_id => $transcript_type_id
		);
		if(defined $sequence_list and scalar(@{$sequence_list}) > 0) {
			$sequence=$sequence_list->[0]->{'sequence'};		
		}
	};
	throw('Wrong aminoacid sequence') if ($@);

	# Get translate id
	my ($translate_id);
	eval {
		my ($datasource) = $db_adaptor->query_datasource(name => 'Ensembl_Peptide_Id')->[0];
		if (defined $datasource) {
			my ($datasource_name) = $datasource->{'name'};
			my ($datasource_id) = $datasource->{'datasource_id'};
			my ($datasource_desc) = $datasource->{'description'};
			my ($xref_id_list) = $db_adaptor->query_xref_identify
			(
				entity_id => $entity->{'entity_id'},
				datasource_id => $datasource_id
			);
			if (defined $xref_id_list and scalar(@{$xref_id_list}) > 0) {
				$translate_id = $xref_id_list->[0]->{'identifier'};
			}	
		}
	};
	throw('Wrong translate identify') if ($@);	

	# Get CDS
	my ($cds);
	eval {
		my ($cds_list) = $db_adaptor->query_cds(entity_id => $entity->{'entity_id'});
		foreach my $cds_rep (@{$cds_list}){
			push(@{$cds},
				APPRIS::CDS->new
				(
					-start		=> $cds_rep->{'start'},
					-end		=> $cds_rep->{'end'},
					-strand		=> $cds_rep->{'strand'},
					-phase		=> $cds_rep->{'phase'}
				)
			);
		}
	};
	throw('Wrong cds') if ($@);	
	
	# Get Codon
	my ($codons);
	eval {
		my ($codon_list) = $db_adaptor->query_codon(entity_id => $entity->{'entity_id'});  		
		foreach my $codon_rep (@{$codon_list}){
			push(@{$codons},
				APPRIS::Codon->new
				(
					-start		=> $codon_rep->{'start'},
					-end		=> $codon_rep->{'end'},
					-strand		=> $codon_rep->{'strand'},
					-phase		=> $codon_rep->{'phase'},
					-type		=> $codon_rep->{'type'}
				)
			);
		}
	};
	throw('Wrong codon') if ($@);	
	
	$db_adaptor->commit(); # Do commit of everything
	$db_adaptor->disconnect();

	my ($translate);
	if (defined $sequence) {
		$translate = APPRIS::Translation->new();
		$translate->stable_id($translate_id) if (defined $translate_id);	
		$translate->sequence($sequence) if (defined $sequence);	
		$translate->cds($cds) if (defined $cds);
		$translate->codons($codons) if (defined $codons);
	}
		
	return $translate;
}

=head2 fetch_analysis_by_xref_entry

  Arg [1]    : String $xref_entry 
               An external identifier of the entity to be obtained
  Arg [2]    : String $type (optional)
               The type of analysis of the transcript to retrieve
  Example    : $analysis = $registry->fetch_analysis_by_stable_name('CRISP3-001','firestar');
  Description: Retrieves an analysis object 
               from the database via its stable id.
               If the gene or transcript is not found
               undef is returned instead.
  Returntype : APPRIS::Analysis or undef
  Exceptions : if we cant get the transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_analysis_by_xref_entry {
	my ($self, $xref_entry, $type) = @_;
	my ($entity);
	my ($xref_list) = $self->fetch_basic_by_xref_entry($xref_entry);
	if (defined $xref_list and scalar(@{$xref_list}) > 0) {
		my ($xref) = $xref_list->[0];
		if ( $xref->stable_id ) {
			$entity = $self->fetch_analysis_by_stable_id($xref->stable_id, $type);
		}
	}
	
	return $entity;	
}

=head2 fetch_analysis_by_stable_id

  Arg [1]    : String $id 
               The stable ID of the transcript to retrieve
  Arg [2]    : String $type (optional)
               The type of analysis of the transcript to retrieve
  Example    : $analysis = $registry->fetch_analysis_by_stable_id('ENST000001','firestar');
  Description: Retrieves an analysis object 
               from the database via its stable id.
               If the gene or transcript is not found
               undef is returned instead.
  Returntype : APPRIS::Analysis or undef
  Exceptions : if we cant get the transcript in given coord system
  Caller     : general
  Status     : Stable

=cut

sub fetch_analysis_by_stable_id {
	my ($self, $stable_id, $type) = @_;

	my ($firestar);
	my ($matador3d);
	my ($spade);
	my ($inertia);
	my ($crash);
	my ($thump);
	my ($cexonic);
	my ($corsair);
	my ($appris);
		
	# Connection to DBAdaptor
	my ($db_adaptor) = APPRIS::DBSQL::DBAdaptor->new
	(
		dbhost => $self->dbhost,
		dbport => $self->dbport,
		dbname => $self->dbname,
		dbuser => $self->dbuser,
		dbpass => $self->dbpass,
	);

	# Get entity report
	my ($entity);
	eval {
		my ($entity_list) = $db_adaptor->query_entity(identifier => $stable_id);
		if (defined $entity_list and scalar(@{$entity_list}) > 0) {
			$entity = $entity_list->[0];
		}
		else {
			throw('Argument must be a correct stable id');
		}
	};
	throw('Argument must be a correct stable id') if ($@);

	# If not defined 'type' of analysis, we retrieve all the results
	$type = 'all' unless (defined $type);

	
	# Get FIRESTAR analysis -----------------
	if (defined $type and ($type eq 'firestar' or $type eq 'all')) {
		my ($method);
		my ($regions);		
		eval {	
			my ($list) = $db_adaptor->query_firestar(entity_id => $entity->{'entity_id'});
			if (defined $list and scalar(@{$list}) > 0) {
				$method = $list->[0];
			}				
		};
		throw('No firestar analysis') if ($@);
		eval {	
			my ($list) = $db_adaptor->query_firestar_residues(entity_id => $entity->{'entity_id'});
			foreach my $residue (@{$list}) {
				push(@{$regions},
					APPRIS::Analysis::FirestarRegion->new
					(
						-start		=> $residue->{'start'},
						-end		=> $residue->{'end'},
						-strand		=> $residue->{'strand'},
						-residue	=> $residue->{'peptide_position'},
						-score		=> $residue->{'score'}
					)				
				);
			}
		};
		throw('No firestar analysis') if ($@);
		if (defined $method) { # Create object
			eval {
				$firestar = APPRIS::Analysis::Firestar->new
				(
					-result					=> $method->{'result'},
					-functional_residue		=> $method->{'functional_residue'},
					-num_residues			=> $method->{'num_residues'}
				);
				$firestar->residues($regions) if (defined $regions);				
			};
			throw('No firestar object') if ($@);
		}	
	}
	
	# Get MATADOR3D analysis -----------------
	if (defined $type and ($type eq 'matador3d' or $type eq 'all')) {
		my ($method);
		my ($regions);
		my ($num_alignments) = 0; # TODO: add this field into database
		eval {	
			my ($list) = $db_adaptor->query_matador3d(entity_id => $entity->{'entity_id'});
			if (defined $list and scalar(@{$list}) > 0) {
				$method = $list->[0];
			}				
		};
		throw('No matador analysis') if ($@);
		eval {	
			my ($list) = $db_adaptor->query_matador3d_alignments(entity_id => $entity->{'entity_id'});
			foreach my $residue (@{$list}) {
				$num_alignments++ if ($residue->{'alignment_score'} ne '0');
				push(@{$regions},
					APPRIS::Analysis::Matador3DRegion->new
					(
						-start	=> $residue->{'trans_start'},
						-end	=> $residue->{'trans_end'},
						-strand	=> $residue->{'trans_strand'},
						-pstart	=> $residue->{'start'},
						-pend	=> $residue->{'end'},
						-score	=> $residue->{'alignment_score'},
						-cds_id	=> $residue->{'cds_id'},					
						-pdb_id	=> $residue->{'pdb_id'}
					)				
				);
			}
		};
		throw('No matador analysis') if ($@);
		if (defined $method) { # Create object
			eval {
				$matador3d = APPRIS::Analysis::Matador3D->new
				(
					-result						=> $method->{'result'},
					-conservation_structure		=> $method->{'conservation_structure'},
					-score						=> $method->{'score'},
					-num_alignments				=> $num_alignments
				);
				$matador3d->alignments($regions) if (defined $regions);				
			};
			throw('No matador object') if ($@);
		}
	}
	
	# Get SPADE analysis -----------------
	if (defined $type and ($type eq 'spade' or $type eq 'all')) {
		my ($method);
		my ($regions);		
		eval {	
			my ($list) = $db_adaptor->query_spade(entity_id => $entity->{'entity_id'});
			if (defined $list and scalar(@{$list}) > 0) {
				$method = $list->[0];
			}				
		};
		throw('No spade analysis') if ($@);
		eval {
			my ($list) = $db_adaptor->query_spade_alignments(entity_id => $entity->{'entity_id'});
			foreach my $residue (@{$list}) {
				push(@{$regions},
					APPRIS::Analysis::SPADERegion->new
					(
						-start								=> $residue->{'trans_start'},
						-end								=> $residue->{'trans_end'},
						-strand								=> $residue->{'trans_strand'},						
						-score								=> $residue->{'score'},						
						-type_domain						=> $residue->{'type_domain'},						
						-alignment_start					=> $residue->{'alignment_start'},					
						-alignment_end						=> $residue->{'alignment_end'},
						-envelope_start						=> $residue->{'envelope_start'},					
						-envelope_end						=> $residue->{'envelope_end'},
						-hmm_start							=> $residue->{'hmm_start'},					
						-hmm_end							=> $residue->{'hmm_end'},
						-hmm_length							=> $residue->{'hmm_length'},					
						-hmm_acc							=> $residue->{'hmm_acc'},
						-hmm_name							=> $residue->{'hmm_name'},					
						-hmm_type							=> $residue->{'hmm_type'},
						-bit_score							=> $residue->{'bit_score'},
						-evalue								=> $residue->{'evalue'},
						-significance						=> $residue->{'significance'},
						-clan								=> $residue->{'clan'},
						-predicted_active_site_residues		=> $residue->{'predicted_active_site_residues'},
						-external_id						=> $residue->{'external_id'}						
					)				
				);
			}
		};
		throw('No spade analysis') if ($@);
		if (defined $method) { # Create object
			eval {
				$spade = APPRIS::Analysis::SPADE->new
				(
					-result							=> $method->{'result'},
					-domain_signal					=> $method->{'domain_signal'},
					-num_domains					=> $method->{'num_domains'},
					-num_possibly_damaged_domains	=> $method->{'num_possibly_damaged_domains'},
					-num_damaged_domains			=> $method->{'num_damaged_domains'},
					-num_wrong_domains				=> $method->{'num_wrong_domains'}
				);
				$spade->regions($regions) if (defined $regions);				
			};
			throw('No spade object') if ($@);
		}
	}
	
	# Get INERTIA analysis -----------------
	if (defined $type and ($type eq 'inertia' or $type eq 'all')) {
		my ($method);
		my ($method2);
		my ($method3);
		my ($method4);
		my ($regions);
		my ($regions2);		
		my ($regions3);
		my ($regions4);
		my ($slr2);
		my ($slr3);
		my ($slr4);		
		eval {	
			my ($list) = $db_adaptor->query_inertia(entity_id => $entity->{'entity_id'});
			if (defined $list and scalar(@{$list}) > 0) {
				$method = $list->[0];				
			}
		};
		throw('No inertia analysis') if ($@);
		eval {	
			my ($list2) = $db_adaptor->query_inertia_residues(entity_id => $entity->{'entity_id'});
			foreach my $residue (@{$list2}) {
				push(@{$regions},
					APPRIS::Analysis::INERTIARegion->new
					(
						-start				=> $residue->{'start'},
						-end				=> $residue->{'end'},
						-strand				=> $residue->{'strand'},
						-unusual_evolution	=> $residue->{'inertia_residue_unusual_evolution'}
					)
				);
			}
		};
		throw('No inertia analysis') if ($@);	
		
		eval { # Get mafft alignment 			
			my ($type_list) = $db_adaptor->query_slr_type(name => 'filter');
			my ($type_id) = $type_list->[0]->{'slr_type_id'};

			my ($list) = $db_adaptor->query_omega(
								entity_id => $entity->{'entity_id'},
								slr_type_id => $type_id
			);
			if (defined $list and scalar(@{$list}) > 0) {
				$method2 = $list->[0];				
			}
			my ($list2) = $db_adaptor->query_omega_residues(
								entity_id => $entity->{'entity_id'},
								slr_type_id => $type_id
			);
			foreach my $residue (@{$list2}) {
				push(@{$regions2},
					APPRIS::Analysis::OmegaRegion->new
					(
						-start				=> $residue->{'start'},
						-end				=> $residue->{'end'},
						-omega_mean			=> $residue->{'omega_mean'},
						-st_deviation		=> $residue->{'st_deviation'},
						-p_value			=> $residue->{'p_value'},
						-difference_value	=> $residue->{'difference_value'},
						-unusual_evolution	=> $residue->{'unusual_evolution'}
					)
				);
			}
			my ($list3) = $db_adaptor->query_slr_alignments(
								entity_id => $entity->{'entity_id'},
								slr_type_id => $type_id
			);
			if (defined $list3 and scalar(@{$list3}) > 0) {
				my ($method2_slr) = $list3->[0];
				$slr2 = APPRIS::Analysis::SLR->new
				(
					-result		=> $method2_slr->{'result'},
					-alignment	=> $method2_slr->{'alignment'},
					-tree		=> $method2_slr->{'tree'}
				);
			}
		};
		throw('No inertia-omega-slr-mafft analysis') if ($@);				

		eval { # Get prank alignment		
			my ($type_list) = $db_adaptor->query_slr_type(name => 'prank');
			my ($type_id) = $type_list->[0]->{'slr_type_id'};

			my ($list) = $db_adaptor->query_omega(
								entity_id	=> $entity->{'entity_id'},
								slr_type_id	=> $type_id
			);
			if (defined $list and scalar(@{$list}) > 0) {
				$method3 = $list->[0];				
			}
			my ($list2) = $db_adaptor->query_omega_residues(
								entity_id	=> $entity->{'entity_id'},
								slr_type_id	=> $type_id
			);
			foreach my $residue (@{$list2}) {
				push(@{$regions3},
					APPRIS::Analysis::OmegaRegion->new
					(
						-start				=> $residue->{'start'},
						-end				=> $residue->{'end'},
						-omega_mean			=> $residue->{'omega_mean'},
						-st_deviation		=> $residue->{'st_deviation'},
						-p_value			=> $residue->{'p_value'},
						-difference_value	=> $residue->{'difference_value'},
						-unusual_evolution	=> $residue->{'unusual_evolution'}
					)
				);
			}
			my ($list3) = $db_adaptor->query_slr_alignments(
								entity_id => $entity->{'entity_id'},
								slr_type_id => $type_id
			);
			if (defined $list3 and scalar(@{$list3}) > 0) {
				my ($method3_slr) = $list3->[0];
				$slr3 = APPRIS::Analysis::SLR->new
				(
					-result		=> $method3_slr->{'result'},
					-alignment	=> $method3_slr->{'alignment'},
					-tree		=> $method3_slr->{'tree'}
				);
			}
		};
		throw('No inertia-omega-slr-prank analysis') if ($@);	

		eval { # Get kalign alignment		
			my ($type_list) = $db_adaptor->query_slr_type(name => 'kalign');
			my ($type_id) = $type_list->[0]->{'slr_type_id'};

			my ($list) = $db_adaptor->query_omega(
								entity_id	=> $entity->{'entity_id'},
								slr_type_id	=> $type_id
			);
			if (defined $list and scalar(@{$list}) > 0) {
				$method4 = $list->[0];				
			}
			my ($list2) = $db_adaptor->query_omega_residues(
								entity_id	=> $entity->{'entity_id'},
								slr_type_id	=> $type_id
			);
			foreach my $residue (@{$list2}) {
				push(@{$regions4},
					APPRIS::Analysis::OmegaRegion->new
					(
						-start				=> $residue->{'start'},
						-end				=> $residue->{'end'},
						-omega_mean			=> $residue->{'omega_mean'},
						-st_deviation		=> $residue->{'st_deviation'},
						-p_value			=> $residue->{'p_value'},
						-difference_value	=> $residue->{'difference_value'},
						-unusual_evolution	=> $residue->{'unusual_evolution'}
					)
				);
			}
			my ($list3) = $db_adaptor->query_slr_alignments(
								entity_id => $entity->{'entity_id'},
								slr_type_id => $type_id
			);
			if (defined $list3 and scalar(@{$list3}) > 0) {
				my ($method4_slr) = $list3->[0];
				$slr4 = APPRIS::Analysis::SLR->new
				(
					-result		=> $method4_slr->{'result'},
					-alignment	=> $method4_slr->{'alignment'},
					-tree		=> $method4_slr->{'tree'}
				);
			}
		};
		throw('No inertia-omega-slr-kalign analysis') if ($@);	
				
		if (defined $method) { # Create object
			eval {
				$inertia = APPRIS::Analysis::INERTIA->new
				(
					-result					=> $method->{'result'},
					-unusual_evolution		=> $method->{'unusual_evolution'}
				);
				$inertia->regions($regions) if (defined $regions);				
			};
			throw('No inertia object') if ($@);
			
			if (defined $method2) { # Create object
				eval {		
					my ($mafft) = APPRIS::Analysis::Omega->new
					(
						-average			=> $method2->{'omega_average'},
						-st_desviation		=> $method2->{'omega_st_desviation'},
						-result				=> $method2->{'result'},
						-unusual_evolution	=> $method2->{'unusual_evolution'}
					);
					$mafft->regions($regions2) if (defined $regions2);
					$inertia->mafft_alignment($mafft);
				};
				throw('No omega-maf object') if ($@);
			}
	
			if (defined $method3) { # Create object
				eval {		
					my ($prank) = APPRIS::Analysis::Omega->new
					(
						-average			=> $method3->{'omega_average'},
						-st_desviation		=> $method3->{'omega_st_desviation'},
						-result				=> $method3->{'result'},
						-unusual_evolution	=> $method3->{'unusual_evolution'}
					);
					$prank->regions($regions3) if (defined $regions3);
					$inertia->prank_alignment($prank);
				};
				throw('No omega-prank object') if ($@);
			}
	
			if (defined $method4) { # Create object
				eval {				
					my ($kalign) = APPRIS::Analysis::Omega->new
					(
						-average			=> $method4->{'omega_average'},
						-st_desviation		=> $method4->{'omega_st_desviation'},
						-result				=> $method4->{'result'},
						-unusual_evolution	=> $method4->{'unusual_evolution'}
					);
					$kalign->regions($regions4) if (defined $regions4);
					$inertia->kalign_alignment($kalign);
				};
				throw('No omega-kalign object') if ($@);
			}
		}
		
	}

	# Get CRASH analysis -----------------
	if (defined $type and ($type eq 'crash' or $type eq 'all')) {
		my ($method);
		my ($method2);
		my ($regions);
		my ($regions2);		
		eval {	
			my ($list) = $db_adaptor->query_signalp(entity_id => $entity->{'entity_id'});
			if (defined $list and scalar(@{$list}) > 0) {
				$method = $list->[0];				
			}
			foreach my $residue (@{$list}) {
				push(@{$regions},
					APPRIS::Analysis::CRASHRegion->new
					(
						-start		=> $residue->{'trans_start'},
						-end		=> $residue->{'trans_end'},
						-strand		=> $residue->{'trans_strand'},						
						-pstart		=> $residue->{'start'},						
						-pend		=> $residue->{'end'},						
						-s_mean		=> $residue->{'s_mean'},					
						-s_prob		=> $residue->{'s_prob'},
						-d_score	=> $residue->{'d_score'},					
						-c_max		=> $residue->{'c_max'}
					)				
				);
			}
			my ($list2) = $db_adaptor->query_targetp(entity_id => $entity->{'entity_id'});
			if (defined $list2 and scalar(@{$list2}) > 0) {
				$method2 = $list2->[0];
			}
			foreach my $residue (@{$list2}) {
				push(@{$regions2},
					APPRIS::Analysis::CRASHRegion->new
					(
						-start			=> $residue->{'trans_start'},
						-end			=> $residue->{'trans_end'},
						-strand			=> $residue->{'trans_strand'},						
						-pstart			=> $residue->{'start'},						
						-pend			=> $residue->{'end'},						
						-reliability	=> $residue->{'reliability'},					
						-localization	=> $residue->{'localization'}
					)				
				);
			}
		};
		throw('No crash analysis') if ($@);
		if (defined $method and defined $method2) { # Create object
			# TODO: Add method result for every transcript 
			eval {
				$crash = APPRIS::Analysis::CRASH->new
				(
					#-peptide_result				=> $method->{'result'},
					#-mitochondrial_result			=> $method2->{'result'},
					-peptide_signal					=> $method->{'peptide_signal'},
					-mitochondrial_signal			=> $method2->{'mitochondrial_signal'},
					-peptide_score					=> $method->{'score'},
					-mitochondrial_score			=> $method2->{'score'}
				);
				$crash->peptide_regions($regions) if (defined $regions);				
				$crash->mitochondrial_regions($regions2) if (defined $regions2);
			};
			throw('No crash object') if ($@);
		}
	}


	# Get THUMP analysis -----------------
	if (defined $type and ($type eq 'thump' or $type eq 'all')) {
		my ($method);
		my ($regions);		
		eval {	
			my ($list) = $db_adaptor->query_thump(entity_id => $entity->{'entity_id'});
			if (defined $list and scalar(@{$list}) > 0) {
				$method = $list->[0];
			}				
		};
		throw('No thump analysis') if ($@);
		eval {
			my ($list) = $db_adaptor->query_thump_helixes(entity_id => $entity->{'entity_id'});
			foreach my $residue (@{$list}) {
				push(@{$regions},
					APPRIS::Analysis::THUMPRegion->new
					(
						-start			=> $residue->{'trans_start'},
						-end			=> $residue->{'trans_end'},
						-strand			=> $residue->{'trans_strand'},						
						-pstart			=> $residue->{'start'},						
						-pend			=> $residue->{'end'},						
						-damaged		=> $residue->{'damaged'}					
					)				
				);
			}
		};
		throw('No thump analysis') if ($@);
		if (defined $method) { # Create object
			eval {
				$thump = APPRIS::Analysis::THUMP->new
				(
					-result						=> $method->{'result'},
					-transmembrane_signal		=> $method->{'transmembrane_signal'},
					-num_tmh					=> $method->{'num_tmh'},
					-num_damaged_tmh			=> $method->{'num_damaged_tmh'}
				);
				$thump->regions($regions) if (defined $regions);				
			};
			throw('No thump object') if ($@);
		}
	}

	# Get CEXONIC analysis -----------------
	if (defined $type and ($type eq 'cexonic' or $type eq 'all')) {
		my ($method);
		my ($regions);		
		eval {	
			my ($list) = $db_adaptor->query_cexonic(entity_id => $entity->{'entity_id'});
			if (defined $list and scalar(@{$list}) > 0) {
				$method = $list->[0];
			}				
		};
		throw('No cexonic analysis') if ($@);
		eval {
			my ($list) = $db_adaptor->query_cexonic_residues(entity_id => $entity->{'entity_id'});
			foreach my $residue (@{$list}) {
				push(@{$regions},
					APPRIS::Analysis::CExonicRegion->new
					(
						-start			=> $residue->{'start'},
						-end			=> $residue->{'end'},
						-strand			=> $residue->{'strand'}						
					)				
				);
			}
		};
		throw('No cexonic analysis') if ($@);
		if (defined $method) { # Create object
			eval {
				$cexonic = APPRIS::Analysis::CExonic->new
				(
					-result							=> $method->{'result'},
					-conservation_exon				=> $method->{'conservation_exon'},
					-num_introns					=> $method->{'num_introns'},
					-first_specie_num_exons			=> $method->{'first_specie_num_exons'},
					-second_specie_num_exons		=> $method->{'second_specie_num_exons'}
				);
				$cexonic->regions($regions) if (defined $regions);				
			};
			throw('No cexonic object') if ($@);
		}
	}
	
	# Get CORSAIR analysis -----------------
	if (defined $type and ($type eq 'corsair' or $type eq 'all')) {
		my ($method);
		my ($regions);		
		eval {	
			my ($list) = $db_adaptor->query_corsair(entity_id => $entity->{'entity_id'});
			if (defined $list and scalar(@{$list}) > 0) {
				$method = $list->[0];
			}				
		};
		throw('No corsair analysis') if ($@);
		if (defined $method) { # Create object
			eval {
				$corsair = APPRIS::Analysis::CORSAIR->new
				(
					-vertebrate_signal		=> $method->{'vertebrate_signal'},
					-score					=> $method->{'score'}
				);
			};
			throw('No corsair object') if ($@);
		}
	}	

	# Get APPRIS analysis -----------------
	if (defined $type and ($type eq 'appris' or $type eq 'all')) {
		my ($method);
		my ($regions);		
		eval {	
			my ($list) = $db_adaptor->query_appris(entity_id => $entity->{'entity_id'});
			if (defined $list and scalar(@{$list}) > 0) {
				$method = $list->[0];
			}				
		};
		throw('No appris analysis') if ($@);
		if (defined $method) { # Create object
			eval {
				$appris = APPRIS::Analysis::APPRIS->new
				(
					-functional_residue			=> $method->{'functional_residue'},						
					-conservation_structure		=> $method->{'conservation_structure'},						
					-domain_signal				=> $method->{'domain_signal'},						
					-unusual_evolution			=> $method->{'unusual_evolution'},						
					-peptide_signal				=> $method->{'peptide_signal'},						
					-mitochondrial_signal		=> $method->{'mitochondrial_signal'},						
					-transmembrane_signal		=> $method->{'transmembrane_signal'},		
					-conservation_exon			=> $method->{'conservation_exon'},						
					-vertebrate_signal			=> $method->{'vertebrate_signal'},
					-principal_isoform			=> $method->{'principal_isoform'},
					-source						=> $method->{'source'}
				);
			};
			throw('No appris object') if ($@);
		}
	}	
	
	$db_adaptor->commit(); # Do commit of everything
	$db_adaptor->disconnect();
		
	# Create object
	my ($analysis);
	if (defined $type) {
		$analysis = APPRIS::Analysis->new();
		if (defined $firestar) {
			$analysis->firestar($firestar);
			$analysis->number($analysis->number+1);
		}
		if (defined $matador3d) {
			$analysis->matador3d($matador3d);
			$analysis->number($analysis->number+1);
		}
		if (defined $spade) {
			$analysis->spade($spade);
			$analysis->number($analysis->number+1);
		}
		if (defined $inertia) {
			$analysis->inertia($inertia);
			$analysis->number($analysis->number+1);
		}
		if (defined $crash) {
			$analysis->crash($crash);
			$analysis->number($analysis->number+1);
		}		
		if (defined $thump) {
			$analysis->thump($thump);
			$analysis->number($analysis->number+1);
		}
		if (defined $cexonic) {
			$analysis->cexonic($cexonic);
			$analysis->number($analysis->number+1);
		}
		if (defined $corsair) {
			$analysis->corsair($corsair);
			$analysis->number($analysis->number+1);
		}
		if (defined $appris) {
			$analysis->appris($appris);
			$analysis->number($analysis->number+1);
		}
	}

	return $analysis;
}

sub DESTROY {}

1;
