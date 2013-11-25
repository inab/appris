						RESTful WEB SERVICE
						
The APPRIS allows manipulation of the database data through various RESTful web services.
For example, there are services that retrieves useful information about Gene, Transcript and Translation.
Other services retrieve the output results of APPRIS method that executed from a given Gene or Transcript.

- spade
	SPADE uses a locally installed version of the program Pfamscan (http://pfam.sanger.ac.uk/) to identify the 
	effect of alternative splicing on the conservation of protein functional domains.  

	E.g.
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/spade/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/spade/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/spade/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/spade/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rel3c/rest/spade/name/CCDS4929
		
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
		
			/*
			 * SPADE
			 *   predicts the presence of protein domains thanks to Pfamscan tool
			 *   ftp://ftp.sanger.ac.uk/pub/databases/Pfam/Tools/README .
			 * 
			 * The Pfam database (http://pfam.sanger.ac.uk) is a large collection of protein families,
			 * each represented by multiple sequence alignments and hidden Markov models (HMMs).
			 * 
			 */
			
			# ========================== #
			# Presence of protein domain #
			# ========================== #
			>ENST00000405930	1	0	0	0
			domain	2	105	157	105	159	PF01529.13	zf-DHHC	Family	1	53	55	87.2	2.9e-25	1	No_clan
			>ENST00000436518	1	0	0	0
			domain	2	94	146	94	148	PF01529.13	zf-DHHC	Family	1	53	55	90.3	3.1e-26	1	No_clan
			>ENST00000320602	0	0	0	0
			>ENST00000334554	1	0	0	0
			domain	2	105	157	105	159	PF01529.13	zf-DHHC	Family	1	53	55	87.2	2.8e-25	1	No_clan
			
			# ============ #
			# Pfam reports #
			# ============ #
			>ENST00000405930    105    157    105    159 PF01529.13  zf-DHHC           Family     1    53    55     87.2   2.9e-25   1 No_clan  
			#HMM       fCktCniikpprskHckdcgrcvlrfDHhCpwlgncIGkrNhkyFilfllslv
			#MATCH     +C tC+ ++ppr++Hc++c++cv++fDHhCpw++ncIG+rN++yF+lfllsl+
			#PP        8*************************************************986
			#SEQ       WCATCHFYRPPRCSHCSVCDNCVEDFDHHCPWVNNCIGRRNYRYFFLFLLSLS
			>ENST00000436518     94    146     94    148 PF01529.13  zf-DHHC           Family     1    53    55     90.3   3.1e-26   1 No_clan  
			#HMM       fCktCniikpprskHckdcgrcvlrfDHhCpwlgncIGkrNhkyFilfllslv
			#MATCH     +C tC+ ++ppr++Hc++c++cv++fDHhCpw++ncIG+rN++yF+lfllsl+
			#PP        9*************************************************986
			#SEQ       WCATCHFYRPPRCSHCSVCDNCVEDFDHHCPWVNNCIGRRNYRYFFLFLLSLS
			>ENST00000320602    105    128    105    130 PF01529.13  zf-DHHC           Family     1    24    55     22.0   6.8e-05   1 No_clan  
			#HMM       fCktCniikpprskHckdcgrcvl
			#MATCH     +C tC+ ++ppr++Hc++c++cv+
			#PP        8*********************97
			#SEQ       WCATCHFYRPPRCSHCSVCDNCVE
			>ENST00000334554    105    157    105    159 PF01529.13  zf-DHHC           Family     1    53    55     87.2   2.8e-25   1 No_clan  
			#HMM       fCktCniikpprskHckdcgrcvlrfDHhCpwlgncIGkrNhkyFilfllslv
			#MATCH     +C tC+ ++ppr++Hc++c++cv++fDHhCpw++ncIG+rN++yF+lfllsl+
			#PP        8*************************************************986
			#SEQ       WCATCHFYRPPRCSHCSVCDNCVEDFDHHCPWVNNCIGRRNYRYFFLFLLSLS
			
			# ============= #
			# Whole domains #
			# ============= #
			>ENST00000405930	UNKNOWN
			>ENST00000436518	UNKNOWN
			>ENST00000334554	UNKNOWN
			>ENST00000320602	NO
