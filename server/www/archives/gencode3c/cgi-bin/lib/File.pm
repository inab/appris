# _________________________________________________________________
# $Id: File.pm 690 2010-03-23 12:23:54Z jmrodriguez $
# $Revision: 690 $
# Developed by:
#		Jose Manuel Rodriguez Carrasco -jmrodriguez@cnio.es-
# _________________________________________________________________
package File;

use Time::localtime;
use File::Basename;

#####################
# Method prototypes #
#####################
sub getLocalTime();
sub printStringIntoTmpFile($);
sub printStringIntoFile($$);
sub updateStringIntoFile($$);
sub getStringFromFile($);
sub getTotalStringFromFile($);
sub add_last_character_directory($);
sub prepare_workspace($);
sub remove_workspace_recursive($);
sub parse_file($);

#################
# Method bodies #
#################
sub getLocalTime()
{
	my($systime)=localtime();
	my($date_string)=sprintf("%04d%02d%02d%02d%02d%02d", $systime->year()+1900 ,$systime->mon()+1, $systime->mday(), $systime->hour(), $systime->min(), $systime->sec());
	return $date_string;
}

# Print string into temporal file
sub printStringIntoTmpFile($)
{
	my ($string) = @_;
	my($file)='/tmp/encode_'.getppid.'.faa';
	local(*HANDLE);
	open(HANDLE,">$file") or return undef;
	print HANDLE $string;
	close(HANDLE);
	return $file;
}
sub printStringIntoFile($$)
{
	my ($string,$file) = @_;
	local(*HANDLE);
	open(HANDLE,">$file") or return undef;
	print HANDLE $string;
	close(HANDLE);
	return $file;
}
sub updateStringIntoFile($$)
{
	my ($string,$file) = @_;
	local(*HANDLE);
	open(HANDLE,">>$file") or return undef;
	print HANDLE $string;
	close(HANDLE);
	return $file;
}
# Get string from file
sub getStringFromFile($)
{
	my ($file) = @_;

	$/=undef;
	local(*FILE);
	open(FILE,$file) or return undef;
	my($string)=<FILE>;
	close(FILE);
	$/='\n';
	return $string;
}
# Get string from file
sub getTotalStringFromFile($)
{
	my ($file) = @_;

	local(*FILE);
	open(FILE,$file) or return undef;
	my(@string)=<FILE>;
	close(FILE);

	return \@string;
}
# If given directory does not have '/' charecter, we include it
sub add_last_character_directory($)
{
        # Get parameter
        my ($inputPath) = @_;
        my ($outputPath) = $inputPath;

        if (substr($outputPath, -1, 1) ne '/') { $outputPath = $inputPath.'/'; }
        return $outputPath;
}
# Prepare directory recursively
sub prepare_workspace($)
{
	my ($directory) = @_;

	my ($dir,$accum)=('','');
	
	foreach $dir (split(/\//, $directory))
	{
		$accum = "$accum$dir/";
		if($dir ne "")
		{
			if(! -d "$accum")
			{
				mkdir($accum) || return undef;
			}
		}
	}
	$directory = $directory.'/' if (substr($directory, -1, 1) ne '/');
	return $directory;
}


# Remove directory of outputs
sub remove_workspace_recursive($)
{
	my ($directory) = @_;

	# Path where will be save funcut results
	if(-e $directory)
	{
		system("rm -rf $directory") == 0 or return undef;
	}
	return 'OK';
}
# Parse file paths into directory, filename and suffix
sub parse_file($)
{
	my($path)=@_;
	my($dirname,$basename)=(undef,undef);
	
	$basename=basename($path);
	$dirname=dirname($path);
	
	return($dirname,$basename);	
}
1;