# _________________________________________________________________
# $Id: Constant.pm 1373 2011-02-24 17:25:36Z jmrodriguez $
# $Revision: 1373 $
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________
package Constant;

###################
# Global variable #
###################
use vars qw(
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
	$SLR_METHOD
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
);

# PI annotations
$PI_METHOD='PI';
$UNKNOWN_LABEL='UNKNOWN';
$OK_LABEL='YES';
$NO_LABEL='NO';
$PI_LABEL='principal_isoform';

# Constant for 'SignalP' method
$SIGNALP_METHOD='SignalP';
$SP_TYPE="euk"; 
$SP_FORMAT="full";
$SP_METHOD="nn+hmm";
$SP_TRUNCATE=70;

# Constant for 'TargetP' method
$TARGETP_METHOD='TargetP';

# Constant for 'Firestar' method
$FIRESTAR_METHOD='Firestar';
$FIRESTAR_ACCEPT_LABEL='ACCEPT';
$FIRESTAR_REJECT_LABEL='REJECT';

# Constant for 'CExonic' method
$CEXONIC_METHOD='CExonic';

# Constant for 'Matador3D' method
$MATADOR3D_METHOD='Matador3D';

# Constant for 'THUMP' method
$THUMP_METHOD='THUMP';

# Constant for 'SPADE' method
$SPADE_METHOD='SPADE';

# Constant for 'CORSAIR' method
$CORSAIR_METHOD='CORSAIR';

# Constant for 'Slr' method
$SLR_METHOD='Slr';

# Constant for 'Omega' method
$OMEGA_METHOD='Omega';
$OMEGA_THRESHOLD=0.25;
$OMEGA_D_VALUE_THRESHOLD=0.35;
$OMEGA_P_VALUE_THRESHOLD=0.025;

# Constant for 'Inertia' method
$INERTIA_METHOD='Inertia';

# MOBY constants
$MOBY_NAMESPACE='http://www.biomoby.org/moby';
$MOBY_CENTRAL_URL='http://moby-dev.inab.org/cgi-bin/MOBY-Central.pl';
$MOBY_CENTRAL_URI='http://moby-dev.inab.org/MOBY/Central';

# Source
$HAVANA_SOURCE='HAVANA';
$ENSEMBL_SOURCE='ENSEMBL';


1;