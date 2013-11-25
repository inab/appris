						RESTful WEB SERVICE
						
The APPRIS allows manipulation of the database data through various RESTful web services.
For example, there are services that retrieves useful information about Gene, Transcript and Translation.
Other services retrieve the output results of APPRIS method that executed from a given Gene or Transcript.

- corsair,
	CORSAIR is a method that is implemented locally that counts the 
	number of orthologous protein sequences from a BLAST search against 
	a vertebrate sequence database that align correctly to each alternative transcript.

	E.g.
		http://appris.bioinfo.cnio.es/ws/rest/corsair/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rest/corsair/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rest/corsair/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rest/corsair/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rest/corsair/name/CCDS4929
		
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
		
