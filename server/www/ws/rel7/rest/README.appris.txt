						RESTful WEB SERVICE
						
The APPRIS allows manipulation of the database data through various RESTful web services.
For example, there are services that retrieves useful information about Gene, Transcript and Translation.
Other services retrieve the output results of APPRIS method that executed from a given Gene or Transcript.

- appris,
	APPRIS makes principal isoform selections based on eight complementary methods. 
	These methods take into account information relating to the structure, 
	function and localization of the protein isoforms, as well as the domain organization, 
	cross-species conservation and the conservation of exonic structure.

	E.g.
		http://appris.bioinfo.cnio.es/ws/rest/appris/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rest/appris/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rest/appris/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rest/appris/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rest/appris/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
			- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
			- CCDS identifier (e.g. CCDS4929).

	Response:
		The output is a text/plain format.
		
		It contains several sections:
			
			# gene_id <transcript_id>'                 => $transcript_id,
                        'translation'                   => '.',
                        'status'                                => '.',
                        'biotype'                               => '.',
                        'fun_res'                               => '.',
                        'con_struct'                    => '.',
                        'u_evol_con_vertebrate' => '.',
                        'dom_signal'                    => '.',
                        'con_exon'                              => '.',
                        'con_vertebrate'                => '.',
                        'u_e_raw'                               => '.',
                        'u_e_prank'                             => '.',
                        'u_e_kalign'                    => '.',
                        'u_evol'                                => '.',
                        'pep_signal'                    => '.',
                        'mit_signal'                    => '.',
                        'tmh_signal'                    => '.',
                        'prin_isoform'                  => '.',
                        'chromosome'                    => '.',
                        'num_exons'                             => '.',
                        'level'                                 => '.',
                        'ccds_set'                              => '.',
                        'num_fun_res'                   => '.',
                        'score_con_struct'              => '.',
                        'num_domains'                   => '.',
                        'score_con_vertebrate'  => '.',
                        'num_u_e_exons'                 => '.',
                        'score_pep_signal'              => '.',
                        'score_mit_signal'              => '.',
                        'num_tmh'                               => '.',
                        'source'
					
		E.g.
		
