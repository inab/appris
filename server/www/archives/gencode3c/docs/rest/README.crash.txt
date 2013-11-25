						RESTful WEB SERVICE
						
The APPRIS allows manipulation of the database data through various RESTful web services.
For example, there are services that retrieves useful information about Gene, Transcript and Translation.
Other services retrieve the output results of APPRIS method that executed from a given Gene or Transcript.

- crash
	From a transcript, CRASH makes conservative predictions of signal peptides and mitochondrial signal sequences 
	by analyzing the output of the SignalP (http://www.cbs.dtu.dk/services/SignalP/) and 
	TargetP (http://www.cbs.dtu.dk/services/TargetP/) programs. 
	Predicted signal sequences are tagged as either reliable or potential, based on the output of the two programs. 

	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/crash/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/crash/name/CRISP3-203
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/crash/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/crash/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl transcript identifier (e.g. ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA transcript identifier (e.g. OTTHUMT00000040871), 
			- transcript name (e.g. CRISP3-203),
			- CCDS identifier (e.g. CCDS4929).

	Response:
		The output is a text/plain format.
		
		It contains several sections:
			
			### crash: signalp 3.0 and targetp v1.1 prediction results ##################################
			----------------------------------------------------------------------
			#id	start	end	s_mean	d_score	c_max	s_prob	sp_score	peptide_signal	localization	reliability	tp_score	mitochondrial_signal
			
					
		E.g.
			>ENST00000263045	1	20	0.897	0.672	0.730	0.999	2	YES	S	1	-2	NO
