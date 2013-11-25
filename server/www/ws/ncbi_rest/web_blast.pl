#!/usr/bin/perl -W

# $Id: web_blast.pl,v 1.6 2007/06/06 17:41:09 coulouri Exp $
#
# ===========================================================================
#
#                            PUBLIC DOMAIN NOTICE
#               National Center for Biotechnology Information
#
# This software/database is a "United States Government Work" under the
# terms of the United States Copyright Act.  It was written as part of
# the author's offical duties as a United States Government employee and
# thus cannot be copyrighted.  This software/database is freely available
# to the public for use. The National Library of Medicine and the U.S.
# Government have not placed any restriction on its use or reproduction.
#
# Although all reasonable efforts have been taken to ensure the accuracy
# and reliability of the software and data, the NLM and the U.S.
# Government do not and cannot warrant the performance or results that
# may be obtained by using this software or data. The NLM and the U.S.
# Government disclaim all warranties, express or implied, including
# warranties of performance, merchantability or fitness for any particular
# purpose.
#
# Please cite the author in any work or product based on this material.
#
# ===========================================================================
#
# This code is for example purposes only.
#
# Please refer to http://www.ncbi.nlm.nih.gov/blast/Doc/urlapi.html
# for a complete list of allowed parameters.
#
# Please do not submit or retrieve more than one request every two seconds.
#
# Results will be kept at NCBI for 24 hours. For best batch performance,
# we recommend that you submit requests after 2000 EST (0100 GMT) and
# retrieve results before 0500 EST (1000 GMT).
#
# ===========================================================================
#
# return codes:
#     0 - success
#     1 - invalid arguments
#     2 - no hits found
#     3 - rid expired
#     4 - search failed
#     5 - unknown error
#
# ===========================================================================

use strict;
use warnings;
use URI::Escape;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST GET);

my $ua = LWP::UserAgent->new;

my $argc = $#ARGV + 1;

if ($argc < 3)
    {
    print "usage: web_blast.pl program database query [query]...\n";
    print "where program = megablast, blastn, blastp, rpsblast, blastx, tblastn, tblastx\n\n";
    print "example: web_blast.pl blastp nr protein.fasta\n";
    print "example: web_blast.pl rpsblast cdd protein.fasta\n";
    print "example: web_blast.pl megablast nt dna1.fasta dna2.fasta\n";

    exit 1;
}

my $program = shift;
my $database = shift;

if ($program eq "megablast")
    {
    $program = "blastn&MEGABLAST=on";
    }

if ($program eq "rpsblast")
    {
    $program = "blastp&SERVICE=rpsblast";
    }

# read and encode the queries
my $encoded_query;
foreach my $query (@ARGV) {
	open(QUERY,$query);
	while(<QUERY>) {
		$encoded_query = $encoded_query . uri_escape($_);
	}
}
die ("query is not defined") unless ( defined $encoded_query );

# build the request
my $args = "CMD=Put&PROGRAM=$program&DATABASE=$database&QUERY=" . $encoded_query;
my $req = new HTTP::Request POST => 'http://www.ncbi.nlm.nih.gov/blast/Blast.cgi';
$req->content_type('application/x-www-form-urlencoded');
$req->content($args);

# get the response
my $response = $ua->request($req);
die ("response is not defined") unless ( defined $response );

# parse out the request id
$response->content =~ /^    RID = (.*$)/m;
my $rid=$1;
die ("RID is not defined") unless ( defined $rid );

# parse out the estimated time to completion
$response->content =~ /^    RTOE = (.*$)/m;
my $rtoe=$1;
die ("RTOE is not defined") unless ( defined $rtoe );

print "NCBI:$rid";
exit 0;


# THIS PART OF SCRIPT IS NOT USEFUL... YET

# wait for search to complete
sleep $rtoe;

# poll for results
while (1) {
	sleep 5;
        
	my $req = new HTTP::Request GET => "http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Get&FORMAT_OBJECT=SearchInfo&RID=$rid";
    my $res = $ua->request($req);

	if ($res->content =~ /\s+Status=WAITING/m) {
		print STDERR "Searching...\n";
		next;
	}
	if ($res->content =~ /\s+Status=FAILED/m) {
		print STDERR "Search $rid failed; please report to blast-help\@ncbi.nlm.nih.gov.\n";
		exit 4;
	}
	if ($res->content =~ /\s+Status=UNKNOWN/m) {
		print STDERR "Search $rid expired.\n";
		exit 3;
	}
	if ($res->content =~ /\s+Status=READY/m) {
		if ($res->content =~ /\s+ThereAreHits=yes/m) {
			print STDERR "Search complete, retrieving results...\n";
			last;
		}
		else {
			print STDERR "No hits found.\n";
			exit 2;
		}
	}
    # if we get here, something unexpected happened.
    exit 5;
} # end poll loop

# retrieve and display results
my $f_request = new HTTP::Request GET => "http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Get&FORMAT_TYPE=Text&RID=$rid";
my $f_response = $ua->request($f_request);
print $f_response->content;

exit 0;
