						RESTful WEB SERVICE
						
The APPRIS allows manipulation of the database data through various RESTful web services.
For example, there are services that retrieves useful information about Gene, Transcript and Translation.
Other services retrieve the output results of APPRIS method that executed from a given Gene or Transcript.

- matador3d
	Matador3D is a locally-installed method that checks for structural homologues for each transcript in the PDB. 

	E.g.
		http://appris.bioinfo.cnio.es/ws/rest/matador3d/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rest/matador3d/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rest/matador3d/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rest/matador3d/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rest/matador3d/name/CCDS4929
		
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
		
			>ENST00000263045	5.0625
			- 1:24[1]	0
				1:24	0[0]
			- 25:63[2]	1
				25:63	1[1*1*1]	1XX5_C[47.7]
			- 64:92[3]	0.5625
				64:92	0.5625[0.75*1*0.75]	1WVR_A[48.6]
			- 93:141[4]	1
				93:141	1[1*1*1]	1RC9_A[48.2]
			- 142:174[5]	0.75
				142:174	0.75[0.75*1*1]	1QNX_A[32.1]
			- 175:204[6]	1
				175:204	1[1*1*1]	1XX5_C[47.7]
			- 205:246[7]	0.75
				205:246	0.75[0.75*1*1]	2CQ7_A[52.8]
			>ENST00000371159	5.0625
			- 1:12[1]	0
				1:12	0[0]
			- 13:37[2]	0
				13:13	0[0]
				14:37	0[0]
			- 38:76[3]	1
				38:76	1[1*1*1]	1XX5_C[47.7]
			- 77:105[4]	0.5625
				77:105	0.5625[0.75*1*0.75]	1WVR_A[48.6]
			- 106:154[5]	1
				106:154	1[1*1*1]	1RC9_A[48.2]
			- 155:187[6]	0.75
				155:187	0.75[0.75*1*1]	1QNX_A[32.1]
			- 188:217[7]	1
				188:217	1[1*1*1]	1XX5_C[47.7]
			- 218:259[8]	0.75
				218:259	0.75[0.75*1*1]	2CQ7_A[52.8]
			>ENST00000393666	5.0625
			- 1:24[1]	0
				1:24	0[0]
			- 25:63[2]	1
				25:63	1[1*1*1]	1XX5_C[47.7]
			- 64:92[3]	0.5625
				64:92	0.5625[0.75*1*0.75]	1WVR_A[48.6]
			- 93:141[4]	1
				93:141	1[1*1*1]	1RC9_A[48.2]
			- 142:174[5]	0.75
				142:174	0.75[0.75*1*1]	1QNX_A[32.1]
			- 175:204[6]	1
				175:204	1[1*1*1]	1XX5_C[47.7]
			- 205:246[7]	0.75
				205:246	0.75[0.75*1*1]	2CQ7_A[52.8]
			>ENST00000423399	5.0625
			- 1:24[1]	0
				1:24	0[0]
			- 25:63[2]	1
				25:63	1[1*1*1]	1XX5_C[47.7]
			- 64:92[3]	0.5625
				64:92	0.5625[0.75*1*0.75]	1WVR_A[48.6]
			- 93:141[4]	1
				93:141	1[1*1*1]	1RC9_A[48.2]
			- 142:174[5]	0.75
				142:174	0.75[0.75*1*1]	1QNX_A[32.1]
			- 175:204[6]	1
				175:204	1[1*1*1]	1XX5_C[47.7]
			- 205:246[7]	0.75
				205:246	0.75[0.75*1*1]	2CQ7_A[52.8]
			
			# ==================================== #
			# Conservation of homologous structure #
			# ==================================== #
			>ENST00000263045	UNKNOWN
			>ENST00000371159	UNKNOWN
			>ENST00000393666	UNKNOWN
			>ENST00000423399	UNKNOWN
