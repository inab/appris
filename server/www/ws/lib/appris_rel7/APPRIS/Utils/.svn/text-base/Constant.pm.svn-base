=head1 CONTACT

  Please email comments or questions to the public INB
  developers list at <inb-tecnico@lists.cnio.es>.

  Questions may also be sent to the developer, 
  Jose Manuel Rodriguez <jmrodriguez@cnio.es>.

=cut

=head1 NAME

APPRIS::Utils::Constant - Utility constants

=head1 SYNOPSIS

  use APPRIS::Utils::Constant
    qw(
       get_protein_cds_sequence
     );

  or to get all methods just

  use APPRIS::Utils::Constant;

  eval { get_protein_cds_sequence(cds_list) };
  if ($@) {
    print "Caught exception:\n$@";
  }

=head1 DESCRIPTION

The functions exported by this package provide a set of useful methods 
to handle files.

=head1 METHODS

=cut

package APPRIS::Utils::Constant;

use strict;
use warnings;

use vars qw(
	$API_VERSION
	$VERSION
	$DATE
	$PI_METHOD
	$UNKNOWN_LABEL
	$OK_LABEL
	$NO_LABEL
	$PI_LABEL
	$SIGNALP_METHOD
	$SP_TYPE
	$SP_FORMAT
	$SP_METHOD
	$SP_TRUNCATE
	$TARGETP_METHOD
	$FIRESTAR_METHOD
	$FIRESTAR_ACCEPT_LABEL
	$FIRESTAR_REJECT_LABEL
	$CEXONIC_METHOD
	$MATADOR3D_METHOD
	$THUMP_METHOD
	$SPADE_METHOD
	$CORSAIR_METHOD	
	$OMEGA_METHOD
	$OMEGA_THRESHOLD
	$OMEGA_D_VALUE_THRESHOLD
	$OMEGA_P_VALUE_THRESHOLD
	$INERTIA_METHOD
	$MOBY_NAMESPACE
	$MOBY_CENTRAL_URL
	$MOBY_CENTRAL_URI
	$HAVANA_SOURCE
	$ENSEMBL_SOURCE
	$METHOD_DESC
);

# Version variables
$API_VERSION = 'rel7';
$VERSION = 'rel7_v17';
$DATE = '22-Jul-2012';


# PI annotations
$PI_METHOD = 'PI';
$UNKNOWN_LABEL = 'UNKNOWN';
$OK_LABEL = 'YES';
$NO_LABEL = 'NO';
$PI_LABEL = 'principal_isoform';

# Constant for 'SignalP' method
$SIGNALP_METHOD = 'SignalP';
$SP_TYPE = "euk"; 
$SP_FORMAT = "full";
$SP_METHOD = "nn+hmm";
$SP_TRUNCATE = 70;

# Constant for 'TargetP' method
$TARGETP_METHOD = 'TargetP';

# Constant for 'Firestar' method
$FIRESTAR_METHOD = 'Firestar';
$FIRESTAR_ACCEPT_LABEL = 'ACCEPT';
$FIRESTAR_REJECT_LABEL = 'REJECT';

# Constant for 'CExonic' method
$CEXONIC_METHOD = 'CExonic';

# Constant for 'Matador3D' method
$MATADOR3D_METHOD = 'Matador3D';

# Constant for 'THUMP' method
$THUMP_METHOD = 'THUMP';

# Constant for 'SPADE' method
$SPADE_METHOD = 'SPADE';

# Constant for 'CORSAIR' method
$CORSAIR_METHOD = 'CORSAIR';

# Constant for 'Omega' method
$OMEGA_METHOD = 'Omega';
$OMEGA_THRESHOLD = 0.25;
$OMEGA_D_VALUE_THRESHOLD = 0.35;
$OMEGA_P_VALUE_THRESHOLD = 0.025;

# Constant for 'Inertia' method
$INERTIA_METHOD = 'Inertia';

# Source
$HAVANA_SOURCE = 'HAVANA';
$ENSEMBL_SOURCE = 'ENSEMBL';

# Method description
$METHOD_DESC = {
	'appris'	=> 'principal_isoform',
	'firestar'	=> 'functional_residue',
	'matador3d'	=> 'homologous_structure',
	'corsair'	=> 'vertebrate_conservation',
	'spade'		=> 'functional_domain',
	'inertia'	=> 'neutral_evolution',
	'cexonic'	=> 'exon_conservation',
	'thump'		=> 'transmembrane_signal',
	'crash'		=> 'peptide_mitochondrial_signal',
	'crash_sp'	=> 'signal_peptide',
	'crash_tp'	=> 'mitochondrial_signal',
};


1;