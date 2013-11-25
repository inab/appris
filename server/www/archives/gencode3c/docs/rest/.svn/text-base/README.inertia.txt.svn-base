						RESTful WEB SERVICE
						
The APPRIS allows manipulation of the database data through various RESTful web services.
For example, there are services that retrieves useful information about Gene, Transcript and Translation.
Other services retrieve the output results of APPRIS method that executed from a given Gene or Transcript.

- inertia
	From a transcript, INERTIA detects exons with non-neutral evolutionary rates. Transcripts are aligned 
	against related species using three different alignment methods, the alignments from the 46-way alignments 
	of orthologues in the UCSC and the realignment of the same sequences using KAlign (http://www.ebi.ac.uk/Tools/msa/kalign/) 
	and Prank (L�ytynoja and Goldman, 2005).
	Evolutionary rates of exons for each of the three alignments are contrasted using SLR ((Massingham and Goldman, 2005)), 
	which computes position-specific selection.

	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/inertia/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/inertia/name/CRISP3-203
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/inertia/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/inertia/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl transcript identifier (e.g. ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA transcript identifier (e.g. OTTHUMT00000040871), 
			- transcript name (e.g. CRISP3-203),
			- CCDS identifier (e.g. CCDS4929).

	Response:
		The output is a text/plain format.
		
		It contains several sections:
			
			### Evolutionary rates of exons from MAF alignment ###
			# omega_average	omega_exon_id	start_exon	end_exon	strand_exon	difference_value	p_value	st_desviation	exon_annotation	transcript_list
			
			### Evolutionary rates of exons from Prank alignment ###
			# omega_average	omega_exon_id	start_exon	end_exon	strand_exon	difference_value	p_value	st_desviation	exon_annotation	transcript_list
			
			### Evolutionary rates of exons from Kalign alignment ###
			# omega_average	omega_exon_id	start_exon	end_exon	strand_exon	difference_value	p_value	st_desviation	exon_annotation	transcript_list
			
					
		E.g.
		
			### inertia 1.0 prediction results ##################################
			
			### Evolutionary rates of exons from MAF alignment ###
			# omega_average	omega_exon_id	start_exon	end_exon	strand_exon	difference_value	p_value	st_desviation	exon_annotation	transcript_list
			1.09817073170732	1	49696446	49696570	-	0.1903	0.1581	1.43196894802993	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.732206896551724	2	49703217	49703304	-	0.2022	0.2379	0.603690900053895	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.668884375	4	49700908	49701005	-	0.1748	0.3515	1.34813975587136	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.6489375	5	49705038	49705109	-	0.3213	0.02150	0.433648051858226	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000423399
			0.619155102040816	7	49701416	49701561	-	0.2321	0.02563	0.893682739208296	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.600773333333333	8	49698876	49698964	-	0.1859	0.3125	0.711235513122367	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.580653846153846	9	49704104	49704220	-	0.1889	0.1818	0.636494373748712	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			----------------------------------------------------------------------
			>ENST00000423399	UNKNOWN
			
			### Evolutionary rates of exons from Prank alignment ###
			# omega_average	omega_exon_id	start_exon	end_exon	strand_exon	difference_value	p_value	st_desviation	exon_annotation	transcript_list
			1.13843414634146	1	49696446	49696570	-	0.1975	0.1303	1.573430430081	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.734210344827586	2	49703217	49703304	-	0.1693	0.4455	0.620557246895785	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.632793333333333	4	49698876	49698964	-	0.1475	0.604	0.691466940857515	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.610959183673469	5	49701416	49701561	-	0.2214	0.03788	0.854635965367314	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.602683333333333	6	49705038	49705109	-	0.2797	0.06453	0.350929779507137	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000423399
			0.58673125	8	49700908	49701005	-	0.1596	0.4652	0.84109996737663	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.583117948717949	9	49704104	49704220	-	0.2038	0.1230	0.623060503048331	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			----------------------------------------------------------------------
			>ENST00000423399	UNKNOWN
			
			### Evolutionary rates of exons from Kalign alignment ###
			# omega_average	omega_exon_id	start_exon	end_exon	strand_exon	difference_value	p_value	st_desviation	exon_annotation	transcript_list
			1.06870975609756	1	49696446	49696570	-	0.1814	0.1994	1.39677327129439	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.734075862068966	2	49703217	49703304	-	0.2605	0.05857	0.607730569211139	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.677776666666667	3	49698876	49698964	-	0.1475	0.604	0.703786786719472	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.623078125	5	49700908	49701005	-	0.2038	0.1895	1.13456997302925	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.620108163265306	6	49701416	49701561	-	0.2364	0.02177	0.891523239049497	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			0.611641666666667	7	49705038	49705109	-	0.3369	0.01371	0.333927868957754	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000423399
			0.567476923076923	9	49704104	49704220	-	0.2137	0.09302	0.625453834579566	UNKNOWN	ENST00000263045;ENST00000393666;ENST00000371159;ENST00000423399
			----------------------------------------------------------------------
			>ENST00000423399	UNKNOWN
