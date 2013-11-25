=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Intruder

=head1 SYNOPSIS

  $intruder = APPRIS::Intruder->new(
    -dbhost  => 'localhost',
    -dbname  => 'homo_sapiens_encode_3c',
    -dbuser  => 'jmrodriguez'
    );

  $intruder->feed_by_analysis_from_stable_id($gene);

=head1 DESCRIPTION

All Adaptors are stored/registered using this module.
This module should then be used to get the adaptors needed.

The intruder can be loaded from a configuration file or from database info.


=head1 METHODS

=cut

package APPRIS::Intruder;

use strict;
use warnings;
use Data::Dumper;
use Config::IniFiles;

use APPRIS::Gene;
use APPRIS::Transcript;
use APPRIS::Translation;
use APPRIS::Exon;
use APPRIS::CDS;
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

    APPRIS::Intruder->new()

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

    $intruder->load_registry_from_db(
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

    $intruder->load_registry_from_ini(
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

=head2 feed_by_analysis

  Arg [1]    : APPRIS::Gene $gene 
               The analysis of the result to insert
  Arg [2]    : String $type (optional)
               The type of analysis of the transcript to insert
  Example    : $intruder->feed_by_analysis($gene,'inertia');
  Description: Add an analysis object into the database.
  Returntype : None
  Exceptions : if we find some problems
  Caller     : general
  Status     : Stable

=cut

sub feed_by_analysis {
	my ($self, $gene, $type) = @_;

	# Connection to DBAdaptor
	my ($db_adaptor) = APPRIS::DBSQL::DBAdaptor->new
	(
		dbhost => $self->dbhost,
		dbport => $self->dbport,
		dbname => $self->dbname,
		dbuser => $self->dbuser,
		dbpass => $self->dbpass,
	);

	if ($gene->transcripts) {
		foreach my $transcript (@{$gene->transcripts}) {			
			my ($transcript_id) = $transcript->stable_id;
	
			# Get Transcript Entity info
			my($transcript_entity_id);
			eval {
				my ($transcript_list) = $db_adaptor->query_entity(identifier => $transcript_id);
				unless (defined $transcript_list and (scalar(@{$transcript_list}) > 0) ) {
					throw('Argument must be a correct stable id');
				}			
				$transcript_entity_id = $transcript_list->[0]->{'entity_id'};			
			};
			throw('Argument must be a correct stable id') if ($@);
			throw('No a correct stable id') unless (defined $transcript_entity_id);
	
			# If not defined 'type' of analysis, we retrieve all the results
			$type = 'all' unless (defined $type);
	
			if ($transcript->analysis) {
				my ($analysis) = $transcript->analysis;
							
				# Insert INERTIA analysis -----------------
				if (defined $type and ($type eq 'inertia' or $type eq 'all') and $analysis->inertia) {
					my ($inertia) = $analysis->inertia;
					
					# Insert inertia
					my ($annotation);
					if ($inertia->unusual_evolution) {
						$annotation = $inertia->unusual_evolution;					
					}
					else {
						throw('No inertia analysis');			
					}
	
					my($global_id);
					eval {
						$global_id = $db_adaptor->insert_inertia(
										entity_id			=> $transcript_entity_id,
										unusual_evolution	=> $annotation
						);
					};
					throw('No inertia analysis') if ($@);
	
					for (my $icds = 0; $icds < scalar(@{$inertia->regions}); $icds++) {
						my ($residue) = $inertia->regions->[$icds];
						if ( $residue->start and $residue->end and $residue->strand and $residue->unusual_evolution ) {
							eval {
								my ($method_residues_id) = $db_adaptor->insert_inertia_residues(
																		inertia_id			=> $global_id,
																		inertia_exon_id		=> $icds+1,
																		start				=> $residue->start,
																		end					=> $residue->end,
																		strand				=> $residue->strand,
																		unusual_evolution	=> $residue->unusual_evolution
								);
							};
							throw('No inertia residue analysis') if ($@);					
						}
						else {
							throw('No inertia residue analysis');						
						}
					}
	
					# Insert omega
					my (@ALIGMENT_TYPES);
					eval {	
						my ($type_list) = $db_adaptor->query_slr_type();
						for (my $i = 0; $i < scalar(@{$type_list}); $i++) {
							push(@ALIGMENT_TYPES, $type_list->[$i]->{'name'});						
						}
					};
					throw('No alignment types') if ($@);				
					
					foreach my $type (@ALIGMENT_TYPES) {
						
						# get the type of alignment
						my ($alignment);
						if ( ($type eq 'filter') and $inertia->mafft_alignment) {
							$alignment = $inertia->mafft_alignment;
						}
						elsif ( ($type eq 'prank') and $inertia->prank_alignment) {
							$alignment = $inertia->prank_alignment;
						}
						elsif ( ($type eq 'kalign') and $inertia->kalign_alignment) {
							$alignment = $inertia->kalign_alignment;
						}
						else {
							next; # we don't have aligment
						}

						# insert main
						my ($type_id2);
						eval {	
							my ($type_list) = $db_adaptor->query_slr_type(name => $type);
							$type_id2 = $type_list->[0]->{'slr_type_id'};
						};
						throw("No inertia-omega $type analysis") if ($@);
						
						if ( $alignment->result and $alignment->unusual_evolution ) { #if ( $alignment->average and $alignment->st_desviation and $alignment->result and $alignment->unusual_evolution )
							my($global_id2);
							eval {
								$global_id2 = $db_adaptor->insert_omega(
												inertia_id			=> $global_id,
												slr_type_id			=> $type_id2,
												omega_average		=> $alignment->average,
												omega_st_desviation	=> $alignment->st_desviation,
												result				=> $alignment->result,
												unusual_evolution	=> $alignment->unusual_evolution
								);
							};
							throw("No inertia-omega $type analysis") if ($@);
							
							# insert residues		
							for (my $icds = 0; $icds < scalar(@{$alignment->regions}); $icds++) {
								my ($residue2) = $alignment->regions->[$icds];
								#if ( $residue2->start and $residue2->end and $residue2->omega_mean and $residue2->st_deviation and 
								#	 $residue2->p_value and $residue2->difference_value and $residue2->unusual_evolution )
								if ( $residue2->start and $residue2->end and $residue2->unusual_evolution ) {
									eval {
										my ($method_residues_id) = $db_adaptor->insert_omega_residues(
																				omega_id			=> $global_id2,
																				omega_exon_id		=> $icds+1,
																				start				=> $residue2->start,
																				end					=> $residue2->end,
																				omega_mean			=> $residue2->omega_mean,
																				st_deviation		=> $residue2->st_deviation,
																				p_value				=> $residue2->p_value,
																				difference_value	=> $residue2->difference_value,
																				unusual_evolution	=> $residue2->unusual_evolution
																				
										);
									};
									throw("No inertia-omega $type residues") if ($@);
								}
								else {
									throw("No inertia-omega $type residues");
									
								}
							}					
						}
						else {
							throw("No inertia-omega $type analysis");
						}
					}
				}
			}
			else {
				throw('No analysis');			
			}
		}		
	}
	
	$db_adaptor->commit(); # Do commit of everything
	$db_adaptor->disconnect();

	return undef;	
}

sub DESTROY {}

1;
