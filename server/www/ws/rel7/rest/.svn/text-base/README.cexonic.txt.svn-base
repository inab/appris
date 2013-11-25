						RESTful WEB SERVICE
						
The APPRIS allows manipulation of the database data through various RESTful web services.
For example, there are services that retrieves useful information about Gene, Transcript and Translation.
Other services retrieve the output results of APPRIS method that executed from a given Gene or Transcript.

- cexonic
	CExonic is a method for the determination of conservation of exonic structure. The conservation of 
	exonic structure between orthologous splice isoforms of two species (human and mouse) would suggest 
	that their biological function may be conserved.

	E.g.
		http://appris.bioinfo.cnio.es/ws/rest/cexonic/id/ENSG00000099904
		http://appris.bioinfo.cnio.es/ws/rest/cexonic/name/CRISP3
		http://appris.bioinfo.cnio.es/ws/rest/cexonic/id/ENST00000334554
		http://appris.bioinfo.cnio.es/ws/rest/cexonic/name/OTTHUMT00000040871
		http://appris.bioinfo.cnio.es/ws/rest/cexonic/name/CCDS4929
		
	Parameters:
		
		- id (string), Ensembl gene/transcript identifier (e.g. ENSG00000099904, or ENST00000334554).
		
		- name (string), is a query input that could be:
			- VEGA gene/transcript identifier (e.g. OTTHUMT00000040871), 
			- gene/transcript name (e.g. ZDHHC8 or ZDHHC8P-205),
			- CCDS identifier (e.g. CCDS4929).
			
	Response:
		The output is a text/plain format.
		
		It contains several sections:

			CExonic generates a schematic figure of the human transcript (or gene) and of the predicted transcript in mouse.
			The exon/intron boundaries are represented as "><". If the aligned intron positions coincide, the exonic 
			structure is conserved.
			
			At the end of the alignment, CExonic returns a "summary line" starting with a hash sign.

			Below are a few examples of the summary line. In the first example, the transcript is conserved in mouse.
				#       1       2       4       4       3
			The 1 and 2 (second and third field if the # is the first) indicate sequence 1 and sequence 2, this does not 
			change. Sequence 1 is the human sequence and sequence 2 is the mouse sequence. The name of the transcript is 
			indicated at the beginning of the alignment. The fourth and fifth field indicate the number of exons in 
			sequence 1 and two, respectively. The sixth field indicates the number of intron positions that could be aligned. 
			If the number of exons in both transcripts is the same and the number of aligned intron positions is one less than 
			the number of exons, the exonic structure is conserved.

			In the example below, the exonic structure is not conserved. The sixth field indicates that no intron positions 
			could be aligned. The fields following the sixth now indicate which intron positions could not be aligned, all 
			four in this case.
				#       1       2       5       5       0       1       2       3       4
			
			Below the summary line, the coordinates of the non-aligned introns are given, as can be seen in the complete 
			example of the alignment that CExonic produces below.
			
					
		E.g.
			1:ENST00000263045 2:ENSG00000096006_mus_musculus_1
			      >                                                                     
			1     ATGTC-TAGCTCAGGGATTGTAAATACACCAACCGGCACTCTGTATCTAGCTCAAGGTTT          
			      ** **  *** **  ** *  *** *  * * *   *** ***  ** *  ** ******          
			2     ATTTCACAGCCCAAAGAGTTGAAACATCCAATCACACACACTGAGTCCAAATCTAGGTTT          
			      >                                                                     
			                  <>                                                        
			1     GTAAACACACCAA---------AACGCATCGGAACA--TCAGAAGAAACAAACTCCAGAC          
			          **   *  *           * * ** ****   **  * **   *  *****  *          
			2     CCTGACTTTCAGAGTTCCCTTTGTCTCCTCAGAACGGCTCCAAGGATGGAGCCTCCAAGC          
			                                                                            
			                                                                            
			1     CCAGACACGCCACCTTAAGAGCTGTAACACTCACCTCGAGGGTCCGCGGCTTCATTCTTG          
			        ** ***   * * *  **           ***     **  * *  **   **  ***          
			2     TGAGGCACAGTATCATTTGA----------CCACTGATGGGTCCTGTTGCAGGATATTTG          
			                                                                            
			                          <>                                                
			1     AAGTCAGTGAGACCAAGAACCGTTTTCATTAGCAGTGTGAGAACAGATTAATGCAGTAAA          
			      *  * *********  *** *       * ** **    * *  *** * *  *  * **          
			2     ATTTAAGTGAGACCTGGAAGC-------TGAGAAG---AAAAGGAGAGTGAAAC--TGAA          
			         <>                                                                 
			                                                      <>                    
			1     TTGGTACAGGTAGAGTTGGATGCTGCTGTAAAGATACCCGAAAATGTGAGTAAGA-CA-T          
			       * *** **  **** ******  ****  *****    **    *** ****** ** *          
			2     GTTGTA-AGAAAGAGCTGGATGGGGCTGGTAAGAT----GACTCCGTGGGTAAGAGCACT          
			                                                                            
			                                                                            
			1     GACTTTGCTCCTCCTTTGCCTTTCACCATGATTGTGAGGCCTCCCCAGCCTTGTGGAACT          
			      *********  ******  * ****   ** *** **      *   * ** * * * **          
			2     GACTTTGCTTGTCCTTTCTCCTTCATTTTGTTTGAGA------CAAGGTCTCGGGTAGCT          
			          <>                                                                
			                                                                            
			1     GTGAGTCAATTAAACCTTTTTCCTCTA-----CAGACTACCCAGTCCTGGGTATGTCTTT          
			      * ** * *  *  *****   * ***      * *  * **   ***   **********          
			2     GGGACTGACCTTGACCTTGACCTTCTGATCCTCTGGTTTCCATCTCCCAAGTATGTCTTT          
			                                                           <>               
			                              <>                                            
			1     ATT---AGAACTGGGAGAACAGAGTTAAATGAAAGAGCTTAGTCAGATTCCAACCCAGAT          
			      * *   ** *** **  ******  ********* * * ***  *****  **   ****          
			2     AATCCCAGCACTTGGGAAACAGACATAAATGAAATATC-TAGAAAGATT--AATAAAGAT          
			                                     <>                                     
			                                                                            
			1     TGT-CTGCCTCCAAAACCTGTGTTTTAACCACTACATTCTATAGGCAGCATTGTTTATCA          
			       **  **   *** *   **** *   *** **   * **  *  *****    *** **          
			2     AGTGATGGGGCCAGA---TGTGGTGGCACCTCTCATTCCTGCACCCAGCAGGCATTAGCA          
			                                                                            
			         <>                                                                 
			1     GGTAACAACTTTTAAGCTCTCATTAATTTAAATAATAAATGAGGTTCTTAAGCCCCCTTG          
			      ** ** * ** * ** ** **  *** *  * ** **   **** * * **********           
			2     GGGAAAATCTCTGAATCTATCTGTAACTACAGTACTA---GAGGATATGAAGCCCCCTTC          
			                     <>                                                     
			                                           <>                               
			1     TGGCGAAAAGCAGTAACAAGAATTACATC-----AGAATCCCTCATACCTATTTCCACTT          
			      *** ***** * * ***** ** *****      *  ** * **    ** * *****            
			2     TGGTGAAAAACTGAAACAAAAAGTACATTTAGGAAATATTCTTCTGTGCTGTCTCCAC--          
			         <>                                                                 
			                                                                            
			1     AAACCTCTG-GCCACAATGGTGATGTTTA-ATTTAAAAGAGACTATGGGGCCGGGCATGG          
			        ******* ** *  * *  ** *****  *  ** * ***    ** ***********          
			2     --ACCTCTGAGCGAAGAAGAAGAAGTTTATGTACAATAAAGAAATGGGAGCCGGGCATGG          
			                              <>                                            
			                                                     <                      
			1     TGGGTCACACCTGTAATCCCAGCAATTTGGGAGGCCGAGGTGGGCAGA                      
			      ***  **  *** ********** * * ******* ****  *** **                      
			2     TGGCACATGCCTTTAATCCCAGC-ACTCGGGAGGCAGAGGCAGGCGGA                      
			                                                     <                      
			##	1	2	7	8	0	1	2	3	4	5	6
			
			Coordinates for the non-aligned introns:
			# intron:1	6	49704221	49705037	-
			# intron:2	6	49703305	49704103	-
			# intron:3	6	49701562	49703216	-
			# intron:4	6	49701006	49701415	-
			# intron:5	6	49698965	49700907	-
			# intron:6	6	49696571	49698875	-
