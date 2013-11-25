/*
 * 
 * Global variables
 * 
 */

// Head of sumary table
var aHEAD_TABLE = [
	"Transcript Id",
	"Name",
	"Class",
	"Status",
	"Length (bp)",
	"Length (aa)",
	"Codons not found",
	"CCDS",
	"Principal Isoform",
];


/*
 * 
 * Methods of 'Annotated isoforms' panel
 * 
 */

/**
* Create HTML response from Summary report
* @private
* @param {Object} oReport Report of summary 
*/
function createAPPRISsumaryHTML(oReport)
{
	var oBody = new Array();
	var oBodyNonPep = new Array();
	
	// Get the minor value of reliability
	var sGlobalReliability = 100
	for (var i = 0; i < oReport.length; i++) {
		var oLine = oReport[i];
		if ( oLine.transcript_id !== undefined ) {
			var sTranscriptId = oLine.transcript_id;
			if ( oLine.reliability !== undefined ) {
				if ( parseInt(oLine.reliability) < sGlobalReliability ) {
					sGlobalReliability = parseInt(oLine.reliability);
				}
			}			
		}
	}	
	
	// Prepare the report for HTML response
	for (var i = 0; i < oReport.length; i++) {
		var oLine = oReport[i];
		if ( oLine.transcript_id !== undefined ) {
			//var sTranscriptId = oLine.transcript_id;
			var sTransIdLink = APPRIS.ENSEMBL_URL + ';t='+ oLine.transcript_id;
			var sTranscriptId = "<div class='content_external_ref' title='Redirect to Ensembl' value='"+sTransIdLink+"'>"+oLine.transcript_id+"</div>";
			
			var sName = '-';
			if ( oLine.transcript_name !== undefined ) { sName = oLine.transcript_name }
			var sBioType = '-';
			if ( oLine.biotype !== undefined ) { sBioType = oLine.biotype }
			var sStatus = '-';
			if ( oLine.status !== undefined ) { sStatus = oLine.status }
			var sLengthNA = '-';
			if ( oLine.length_na !== undefined ) { sLengthNA = oLine.length_na }
			var sLengthAA = '-';
			if ( oLine.length_aa !== undefined ) { sLengthAA = oLine.length_aa }
			var sCodons = '-';
			if ( oLine.no_codons !== undefined ) { sCodons = oLine.no_codons }
			var sCCDS = '-';
			if ( oLine.ccds_id !== undefined ) { sCCDS = oLine.ccds_id }
			var sPrincipalIsoform = '-';
			if ( oLine.annotation !== undefined ) { sPrincipalIsoform = oLine.annotation }
			var sReliability = '-';
			if ( oLine.reliability !== undefined ) { sReliability = oLine.reliability }
			
			// get the icon of annotation
			var sClassAnnot = '';
			if ( sPrincipalIsoform == APPRIS.NO_ANNOT || sPrincipalIsoform == '-' ) {
				sClassAnnot = 'NO';
			}				
			else if ( sPrincipalIsoform == APPRIS.UNKNOWN_ANNOT ) {
				sClassAnnot = 'UNKNOWN';
			}
			else if ( sPrincipalIsoform == APPRIS.OK_ANNOT && sGlobalReliability >= 90 ) {
				sClassAnnot = 'OK_2';
			}
			else if ( sPrincipalIsoform == APPRIS.OK_ANNOT && sGlobalReliability >= 80 ) {
				sClassAnnot = 'OK_1';
			}
			else if ( sPrincipalIsoform == APPRIS.OK_ANNOT && sGlobalReliability < 80 ) {
				sClassAnnot = 'OK';
			}
		
			if ( sLengthNA != '-' && sLengthAA != '-') {
				var sAnnot = ""
				if ( sPrincipalIsoform == APPRIS.OK_ANNOT ) {
					sAnnot = "<div class='"+sClassAnnot+"' title='"+sPrincipalIsoform+'. '+sGlobalReliability+'%'+" of reliability' style='cursor: help'></div>";
				}
				else if ( sPrincipalIsoform == APPRIS.UNKNOWN_ANNOT ) {
					sAnnot = "<div class='"+sClassAnnot+"' title='"+sPrincipalIsoform+'. '+sReliability+'%'+" of reliability' style='cursor: help'></div>";
				}
				else if ( sPrincipalIsoform == APPRIS.NO_ANNOT ) {
					sAnnot = "<div class='"+sClassAnnot+"' title='"+sPrincipalIsoform+'. '+sReliability+'%'+" of reliability' style='cursor: help'></div>";
				}				
				oBody[sTranscriptId] = [
						sName,
						sBioType,
						sStatus,
						sLengthNA,
						sLengthAA,
						sCodons,
						sCCDS,
						sAnnot						
				];
			}
			else {
				sClassAnnot = APPRIS.NO_LABEL;
				oBodyNonPep[sTranscriptId] = [
						sName,
						sBioType,
						sStatus,
						sLengthNA,
						sLengthAA,
						sCodons,
						sCCDS,
						"<div class='"+sClassAnnot+"'></div>"
				];
			}
		}
	}

	// Create HTML response
	var sResponse = '';
	
	// create summary table of transcript with peptide sequence
	if (getKeys(oBody).length > 0) {
		var oTable = new table('summary_panel', aHEAD_TABLE, oBody);
		sResponse += oTable.getHTMLElement();
	}
	
	// create reference table
	/*
	sResponse += "<center><table class='reference'>"+
					"<tbody>"+
						"<tr>"+
							"<th class='reference'><div class='"+APPRIS.OK_LABEL+"'></div></th>"+
							"<td class='reference'>Principal Isoform</td>"+
							"<th class='reference'><div class='"+APPRIS.UNKNOWN_LABEL+"'></div></th>"+
							"<td class='reference'>Potential Principal Isoform</td>"+
							"<th class='reference'><div class='"+APPRIS.NO_LABEL+"'></div></th>"+
							"<td class='reference'>Alternative Isoform</td>"+					
						"</tr>"+
					"</tbody>"+
					"</table>";
	sResponse += "</tbody>"+
				"</table></center>";
	*/

	// create summary table of transcript without peptide sequence
	if (getKeys(oBodyNonPep).length > 0) {
		sResponse += "<div id='summary_nopep_panel'>";
		sResponse += "<div class='description'>"+
							"<p>The list of non-coding transcripts ("+
								"<span class='show' title='Show Non-peptide table'>Show</span> | "+
								"<span class='hide' title='Hide Non-peptide table'>Hide</span>"+
							")</p>"+
						"</div>";
		sResponse += "<div class='nonpep_report'>";		
		var oTableNonPep = new table('summary_panel', aHEAD_TABLE, oBodyNonPep);
		sResponse += oTableNonPep.getHTMLElement();
		sResponse += "</div>"; // class: nonpep_report
		sResponse += "</div>"; // class: summary_nopep_panel
	}				

	return sResponse;	
}

/**
* Get information of transcripts from cgi service
* @private
* @param {String} sQueryId List of identifier 
*/
function getTranscriptInfoFromAPPRIS(sQueryId)
{
	printStatusMessage('#summary_panel',true,'Loading...');
		
	$.ajax({
		type: 'GET',
		url: APPRIS.RESTWS+'export/'+'id/'+sQueryId,		
		data: {
			'source': 'appris',
			'format': 'json',
		},
		dataType: 'json',
		success: function(data) {		
			if (data == null) { // ERROR message
				var sResponse =	"<center>"+
						"<table class='summary_panel'>"+
						"<thead>"+	
							"<tr>"+"<th>Annotations were not found</th>"+"</tr>"+
						"</thead></center>";
				$('#summary_panel .report').html(sResponse);
				
				printStatusMessage('#summary_panel',false,'');
				initPanelMenu('summary_panel');
	
				// Default values of links
				$('#summary_panel .report').css({ display: 'block' });
				$('#summary_panel .menu .show').css({ 'text-decoration': 'none', cursor: 'default' });
				$('#summary_panel .menu .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
				$('#summary_panel .menu .export').css({ 'text-decoration': 'underline', cursor: 'pointer' });
				$('#summary_panel .menu .export').click(openExportData);
			}
			else {
				// Add report to table
				var sReportHTML = createAPPRISsumaryHTML(data);
				$('#summary_panel .report').html(sReportHTML);
				$("#summary_panel .report table.summary_panel").tablesorter({ sortList: [[0,0]] }); // sort on the name column (second column)
				APPRIS.EXPORT_DATA_SUMMARY_PANEL['url'] = this.url;
	
				// Initialize panel				
				printStatusMessage('#summary_panel',false,'');
	
				// Initialize functionality of links
				initPanelMenu('summary_panel');
				initNonPepPanelMenu('summary_nopep_panel');
	
				// Default values of links
				$('#summary_panel .report').css({ display: 'block' });
				$('#summary_panel .menu .show').css({ 'text-decoration': 'none', cursor: 'default' });
				$('#summary_panel .menu .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
				$('#summary_panel .menu .export').css({ 'text-decoration': 'underline', cursor: 'pointer' });
				$('#summary_panel .menu .export').click(openExportData);
	
				$('#summary_nopep_panel .report').css({ display: 'none' });
				$('#summary_nopep_panel .show').css({ 'text-decoration': 'underline', cursor: 'pointer' });
				$('#summary_nopep_panel .hide').css({ 'text-decoration': 'none', cursor: 'default' });
				
				// Event of external link references
				$('#summary_panel .content_external_ref').click(newWindow);
			}
		},
		error: function(text, textStatus) { // ERROR message
			var sResponse =	"<center>"+
					"<table class='summary_panel'>"+
					"<thead>"+	
						"<tr>"+"<th>Annotations were not found</th>"+"</tr>"+
					"</thead></center>";
			$('#summary_panel .report').html(sResponse);
			
			printStatusMessage('#summary_panel',false,'');
			initPanelMenu('summary_panel');

			// Default values of links
			$('#summary_panel .report').css({ display: 'block' });
			$('#summary_panel .menu .show').css({ 'text-decoration': 'none', cursor: 'default' });
			$('#summary_panel .menu .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#summary_panel .menu .export').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#summary_panel .menu .export').click(openExportData);
		}		
	});
}
