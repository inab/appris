						RESTful WEB SERVICE
						
The APPRIS allows manipulation of the database data through various RESTful web services.
For example, there are services that retrieves useful information about Gene, Transcript and Translation.
Other services retrieve the output results of APPRIS method that executed from a given Gene or Transcript.

- thump
	THUMP makes conservative predictions of trans-membrane helices by analyzing the 
	output of three locally installed trans-membrane prediction methods, 
	ProDiv (http://www.pdc.kth.se/~hakanv/prodiv-tmhmm/about.html),
	MemSat (http://saier-144-21.ucsd.edu/barmemsat.html), and 
	Phobius (http://www.ebi.ac.uk/Tools/phobius/).
	
	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/thump/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/thump/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/thump/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/thump/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/thump/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
			- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
			- CCDS identifier (e.g. CCDS4929).

	Response:
		The output is a text/plain format.
		
		It contains several sections:
			
					
		E.g.
			ENSG00000099904.faa.ENST00000405930	length 778 a.a.	NO
			helix number 1 start: 16	end: 35
			helix number 2 start: 151	end: 171
			helix number 3 start: 187	end: 207
			ENSG00000099904.faa.ENST00000436518	length 180 a.a.	NO
			helix number 1 start: 38	end: 53
			helix number 2 start: 140	end: 160
			ENSG00000099904.faa.ENST00000320602	length 673 a.a.	NO
			helix number 1 start: 16	end: 35
			helix number 2 start: 47	end: 66
			ENSG00000099904.faa.ENST00000334554	length 765 a.a.	YES
			helix number 1 start: 16	end: 35
			helix number 2 start: 47	end: 65
			helix number 3 start: 151	end: 165
			helix number 4 start: 187	end: 207
