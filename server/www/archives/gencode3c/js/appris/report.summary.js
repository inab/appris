/*
 * 
 * Global variables
 * 
 */

// Fields that we retrieve from cgi server
var aPARAMS = [
			"identifier",
			"external_name",
			"class",
			"status",
			"length_na",
			"length_aa",
			"codons_not_found",
			"ccds_id",
			"principal_isoform",
			"principal_isoform_source"
];

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
	"Annotated Isoform",
];

/*
var aTABLE_LABELS = new Array();
aTABLE_LABELS["identifier"]			= "Transcript Id";
aTABLE_LABELS["external_name"]		= "Name";
aTABLE_LABELS["class"]				= "Class";
aTABLE_LABELS["status"]				= "Status";
aTABLE_LABELS["length_na"]			= "Length (bp)";
aTABLE_LABELS["length_aa"]			= "Length (aa)";
aTABLE_LABELS["codons_not_found"]	= "Codons not found";
aTABLE_LABELS["ccds_id"]			= "CCDS";
aTABLE_LABELS["principal_isoform"]	= "Annotated Isoform";
*/

/*
 * 
 * Methods of 'Annotated isoforms' panel
 * 
 */

/**
* Create Hash structure coming from response of cgi service
* @private
* @param  {String} sReport Report coming from cgi
* @return {Object} oReport APPRIS report 
*/
function createAPPRISsumaryReport(sReport)
{
	var oReport = new Array();
	
	// Parser report of cgi service
	var aMainResults = sReport.split('\n');
	for (var i = 0; i < aMainResults.length; i++) {
		if (aMainResults[i]) {
			var aResults = aMainResults[i].split('\t');
			if (aResults.length > 0) {
			
				for (var j = 0; j < aPARAMS.length; j++) {
					var sParamName = aPARAMS[j];
					var sParamValue = aResults[j];
					
					// Ensembl transcript identifier
					if (sParamName == 'identifier' &&
					sParamValue !== undefined &&
					sParamValue != '') {
						var sTranscriptId = sParamValue;
						if (oReport[sTranscriptId] === undefined) {
							oReport[sTranscriptId] = {}
						}
					}
					
					// The rest of parameters
					if (sParamValue !== undefined && sParamValue != '') {
						oReport[sTranscriptId][sParamName] = sParamValue;
						
						// Source of annotated isoform
						if (sParamName == 'principal_isoform_source') {
							var sSourceOfPrincipalIsoform = sParamValue;
							var sPIAnnotation = oReport[sTranscriptId]['principal_isoform'];
							if (sPIAnnotation == 'YES' && sSourceOfPrincipalIsoform != '' && sSourceOfPrincipalIsoform == 'vertebrate_signal') {
								sPIAnnotation += '_Probably';
							}
							oReport[sTranscriptId]['principal_isoform'] = sPIAnnotation;
						}
					}
				}
			}
		}
	}
	
	return oReport;
}

/**
* Create HTML response from Summary report
* @private
* @param {Object} oReport Report of summary 
*/
function createAPPRISsumaryHTML(oReport)
{
	var oBody = new Array();
	var oBodyNonPep = new Array();
	
	// Prepare the report for HTML response
	for (var sTranscriptId in oReport)
	{
		var sName = '-';
		if (oReport[sTranscriptId]['external_name'] !== undefined ) { sName = oReport[sTranscriptId]['external_name'] }
		
		var sClass = '-';
		if (oReport[sTranscriptId]['class'] !== undefined ) { sClass = oReport[sTranscriptId]['class'] }
		
		var sStatus = '-';
		if (oReport[sTranscriptId]['status'] !== undefined ) { sStatus = oReport[sTranscriptId]['status'] }
		
		var sLengthNA = '-';
		if (oReport[sTranscriptId]['length_na'] !== undefined ) { sLengthNA = oReport[sTranscriptId]['length_na'] }
		
		var sLengthAA = '-';
		if (oReport[sTranscriptId]['length_aa'] !== undefined ) { sLengthAA = oReport[sTranscriptId]['length_aa'] }
		
		var sCodons = '-';
		if (oReport[sTranscriptId]['codons_not_found'] !== undefined ) { sCodons = oReport[sTranscriptId]['codons_not_found'] }
		
		var sCCDS = '-';
		if (oReport[sTranscriptId]['ccds_id'] !== undefined ) { sCCDS = oReport[sTranscriptId]['ccds_id'] }
		
		var sPrincipalIsoform = '-';
		if (oReport[sTranscriptId]['principal_isoform'] !== undefined ) { sPrincipalIsoform = oReport[sTranscriptId]['principal_isoform'] }
		
		var sClassPI = '';
		switch (sPrincipalIsoform)
		{
			case APPRIS.NO_LABEL: sClassPI = APPRIS.NO_LABEL; break;
			case APPRIS.UNKNOWN_LABEL: sClassPI = APPRIS.UNKNOWN_LABEL; break;
			case APPRIS.OK_LABEL: sClassPI = APPRIS.OK_LABEL; break;
			case APPRIS.OK_PROB_LABEL: sClassPI = APPRIS.OK_PROB_LABEL; break;
		}
		
		// create body hashes for html response	
		if (oReport[sTranscriptId]['principal_isoform_source'] !== undefined &&
			oReport[sTranscriptId]['principal_isoform_source'] == 'no_peptide')
		{
			oBodyNonPep[sTranscriptId] = [
					sName,
					sClass,
					sStatus,
					sLengthNA,
					sLengthAA,
					sCodons,
					sCCDS,
					"<div class='"+sClassPI+"'></div>"
			];
		}
		else {
			oBody[sTranscriptId] = [
					sName,
					sClass,
					sStatus,
					sLengthNA,
					sLengthAA,
					sCodons,
					sCCDS,
					"<div class='"+sClassPI+"'></div>"
			];			
		}
	}

	// Create HTML response
	var sResponse = '';
	
	// create summary table of transcript with peptide sequence
	var oTable = new table('summary_panel', aHEAD_TABLE, oBody);
	sResponse += oTable.getHTMLElement();
	
	// create reference table
	/*
	var aReference = new Array();
	aReference["Principal Isoform"]								= ["<div class='"+APPRIS.OK_LABEL+"'></div>"];
	aReference["Principal Isoform by vertebrate conservation"]	= ["<div class='"+APPRIS.OK_PROB_LABEL+"'></div>"];
	aReference["Potential Principal Isoform"]					= ["<div class='"+APPRIS.UNKNOWN_LABEL+"'></div>"];
	aReference["Alternative Isoform"]							= ["<div class='"+APPRIS.NO_LABEL+"'></div>"];
	var oTableRef = new table('reference', null, aReference);
	sResponse += oTableRef.getHTMLElement();
	*/	
	sResponse += "<center><table class='reference'>"+
					"<tbody>"+
						"<tr>"+
							"<th class='reference'><div class='"+APPRIS.OK_LABEL+"'></div></th>"+
							"<td class='reference'>Principal Isoform</td>"+
							"<th class='reference'><div class='"+APPRIS.OK_PROB_LABEL+"'></div></th>"+
							"<td class='reference'>Principal Isoform by vertebrate conservation</td>"+
							"<th class='reference'><div class='"+APPRIS.UNKNOWN_LABEL+"'></div></th>"+
							"<td class='reference'>Potential Principal Isoform</td>"+
							"<th class='reference'><div class='"+APPRIS.NO_LABEL+"'></div></th>"+
							"<td class='reference'>Alternative Isoform</td>"+					
						"</tr>"+
					"</tbody>"+
					"</table>";
	sResponse += "</tbody>"+
				"</table></center>";

	// create summary table of transcript without peptide sequence
	if (getKeys(oBodyNonPep).length > 0) {
		sResponse += "<div id='summary_nopep_panel'>";
		sResponse += "<div class='description'>"+
							"<p>The table of transcripts without peptide sequences ("+
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
* @param {String} sQueryIdList List of identifier 
*/
function getTranscriptInfoFromAPPRIS(sQueryIdList)
{
	printStatusMessage('#summary_panel',true,'Loading...');
	
	var sParamList = '';
	for (var i = 0; i < aPARAMS.length; i++) {
		sParamList += aPARAMS[i] + ",";
	}
	sParamList = sParamList.replace(/,$/g,"");
	
	$.ajax({
		type: 'GET',
		url: 'cgi-bin/export_appris.cgi',
		data:
		{
			'id': sQueryIdList,
			'param': sParamList,
		},
		success: function(text,textStatus)
		{
			var aMatchValues = text.match(/^Query ERROR: ([^\n]+)\n/); //"Query ERROR: caught BioMart::Exception::Database"
			var aMatchValues2 = text.match(/^503 Service Temporarily Unavailable\n/); //"503 Service Temporarily Unavailable"
			var aMatchValues3 = text.match(/^500 Can't connect/); //"500 Can't connect to"
			if ((aMatchValues && aMatchValues.length >= 0) || (aMatchValues2 && aMatchValues2.length >= 0) || (aMatchValues3 && aMatchValues3.length >= 0)) {
				var sResponse =	"<center>"+
						"<table class='summary_panel'>"+
						"<thead>"+	
							"<tr>"+"<th>Service Temporarily Unavailable</th>"+"</tr>"+
						"</thead></center>";
				$('#summary_panel .report').html(sResponse);
			}
			else
			{				
				var oReport = createAPPRISsumaryReport(text);
				var sReportHTML = createAPPRISsumaryHTML(oReport);
				$('#summary_panel .report').html(sReportHTML);
				$("#summary_panel .report table.summary_panel").tablesorter({ sortList: [[0,0]] }); // sort on the name column (second column)
				APPRIS.EXPORT_DATA_SUMMARY_PANEL['url'] = this.url + '&head=yes';
			}

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
		},
		error: function(text, textStatus)
		{
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
