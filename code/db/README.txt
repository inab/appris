#####################
# LIST OF DATABASES #
#####################
	sprot_clean_trembl_clean_90
	active_site.dat
	Pfam-A.hmm
	Pfam-B.hmm
	nr20_12Aug11_a3m_db
	nr20_12Aug11.cs219
	nr20_12Aug11_hhm_db
	pdb
	refseq_vert
	refseq_vert_files
	fdbTptDB_16Jan2013
	chads_16Jan2013
	hhblits_16Jan2013_a3m_db
	hhblits_16Jan2013.cs219
	hhblits_16Jan2013_hhm_db
	sprot_clean_trembl_clean_70
		
############################
# DESCRIPTION OF DATABASES #
############################
		
* v1: Jan-2013

>> PDB created by José María. In thise case, you have to discard empty sequences:
	
1. Discard empty sequence
	perl discardEmptySeqsPDB.pl missingOutput.fasta 1> pdb
	
2. Index database	
	formatdb -i pdb -p T

>> RefSeq Vertebrate database comes from "vertebrate_mamalian" and "vertebrate_other" (ftp://ftp.ncbi.nlm.nih.gov/refseq/release/)

1. Get RefSeq database from
	wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/vertebrate_mammalian/vertebrate_mammalian.*.protein.faa.gz
	wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/vertebrate_mammalian/vertebrate_other.*.protein.faa.gz
	
2. Unzip them	
	gzip -d vertebrate_*
	
3. Concatenate them	
	cat vertebrate_mammalian.* vertebrate_other.* >> refseq_vert

4. Index database
	formatdb -i refseq_vert -p T

>> Pfam, ftp://ftp.sanger.ac.uk/pub/databases/Pfam/

1. Get the Pfam database from
	ftp://ftp.sanger.ac.uk/pub/databases/Pfam/.  In particular you need
	the files Pfam-A.fasta, Pfam_ls, Pfam_fs, Pfam_ls.bin, Pfam_fs.bin,
	Pfam_ls.ssi Pfam_fs.bin.ssi, and Pfam-A.seed, and optionally
	Pfam-C.  To use the active site option you will also need to
	download the active site alignments which are available as a
	tarball (active_site.tgz).

2. Unzip them if necessary
    $ gunzip Pfam*.gz

3. Grab and install HMMER, NCBI BLAST and Bioperl, and make sure your
   paths etc are set up properly.

4. Index Pfam-A.fasta for BLAST searches
    $ formatdb -i Pfam-A.fasta -p T

5. Index the Pfam_ls and Pfam_fs libraries for HMM fetching
    $ hmmindex Pfam_ls
    $ hmmindex Pfam_fs
    
>> sprot_clean_trembl_clean_70, fdbTptDB_16Jan2013, chads_16Jan2013, FireDB, hhblits_16Jan2013, , nr20_12Aug11 for firestar


