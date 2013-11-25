						RESTful WEB SERVICE
						
The APPRIS allows manipulation of the database data through various RESTful web services.
For example, there are services that retrieves useful information about Gene, Transcript and Translation.
Other services retrieve the output results of APPRIS method that executed from a given Gene or Transcript.

- firestar
	Firestar (Lopez et al., 2007) is a RESTful services that predicts functionally important residues in protein sequences. 

	All these RESTful services has a site-specific prefix, followed by method name, type of query and query string.

		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/name/CRISP3
		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^ ^^^^ ^^^^^^
				site-specific prefix           method  type  query

	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/firestar/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
			- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
			- CCDS identifier (e.g. CCDS4929).
		
	Response:
		The output is a text/plain format.
		
		It contains several sections:
			
			# ============================================ #
			# Functional residues and structural templates #
			# ============================================ #
			######
			<position of residue {1}>	<score of residue {1}>	<motif of residue {1}>	<list of PDBs {1}>
					...
			<position of residue {i}>	<score of residue {i}>	<motif of residue {i}>	<list of PDBs {i}>
			>>>     <identifier of sequence {x}>	<num. residues>	<list of positions>
			######
			<position of residue {1}>	<score of residue {1}>	<motif of residue {1}>	<list of PDBs {1}>
					...
			<position of residue {j}>	<score of residue {j}>	<motif of residue {j}>	<list of PDBs {j}>
			>>>     <identifier of sequence {z}>	<num. residues>	<list of positions>
			
			# ============================== #
			# Prediction of consensus motifs #
			# ============================== #
			######
			<position of residue {1}>	<score of residue {1}>	<motif of residue {1}>	<list of PDBs {1}>
					...
			<position of residue {i}>	<score of residue {i}>	<motif of residue {i}>	<list of PDBs {i}>
			C>>     <identifier of sequence {x}>	<num. residues>	<list of positions>
			######
			<position of residue {1}>	<score of residue {1}>	<motif of residue {1}>	<list of PDBs {1}>
					...
			<position of residue {j}>	<score of residue {j}>	<motif of residue {j}>	<list of PDBs {j}>
			C>>     <identifier of sequence {z}>	<num. residues>	<list of positions>
			
			# ================================ #
			# Potential main variants -APPRIS- #
			# ================================ #
			ACCEPT: <identifier of sequence {x}>	<total score of residues>	<num. res. with score 6>	<num. res. with score 5>	<num. res. with score 4>
			REJECT: <identifier of sequence {z}>	<total score of residues>	<num. res. with score 6>	<num. res. with score 5>	<num. res. with score 4>
			
		
		E.g.
									
			/*
			 * firestar
			 *   prediction of functionally important residues using structural templates and alignment reliability.
			 * Gonzalo Lopez; A. Valencia; M. Tress Nucleic Acids Research, doi:10.1093/nar/gkm297
			 * Date: Jan 1, 2011
			 */
			
			# ============================================ #
			# Functional residues and structural templates #
			# ============================================ #
			######
			84	6	NQCNYRHSNPKDR	 1xtaA  2ddbD
			138	6	PNAVVGHYTQVVW	 1xtaA  2ddbD
			>>>	ENST00000263045	2	84,138
			######
			97	6	NQCNYRHSNPKDR	 1xtaA  2ddbD
			151	6	PNAVVGHYTQVVW	 1xtaA  2ddbD
			>>>	ENST00000371159	2	97,151
			######
			84	6	NQCNYRHSNPKDR	 1xtaA  2ddbD
			138	6	PNAVVGHYTQVVW	 1xtaA  2ddbD
			>>>	ENST00000393666	2	84,138
			######
			84	6	NQCNYRHSNPKDR	 1xtaA  2ddbD
			138	6	PNAVVGHYTQVVW	 1xtaA  2ddbD
			>>>	ENST00000423399	2	84,138
			
			# ============================== #
			# Prediction of consensus motifs #
			# ============================== #
			######
			C>>	ENST00000263045
			######
			C>>	ENST00000371159
			######
			C>>	ENST00000393666
			######
			C>>	ENST00000423399
			
			# ================================ #
			# Potential main variants -APPRIS- #
			# ================================ #
			ACCEPT: ENST00000263045	12	2	2	0	0
			ACCEPT: ENST00000371159	12	2	2	0	0
			ACCEPT: ENST00000393666	12	2	2	0	0
			ACCEPT: ENST00000423399	12	2	2	0	0
