/*
 * 
 * Methods of 'Annotated isoforms' panel
 * 
 */

/**
* Create HTML response from APPRIS report
* @private
* @param  {Object} oReport JSON object
* @return {String} sResponse HTML response
*/
function printAPPRISInfo(oReport)
{
	var sExportData = '';
	var sResponse =	"<center>"+
						"<table class='appris_panel'>"+
						"<thead>"+	
							"<tr>";
	if (oReport) {
		sResponse += "<th><div class='label'>Transcript Id</div></th>";
		sExportData += "transcript_id" + ",";
		
		for (var sMethodType in APPRIS.METHOD_LABELS) {
			if ( sMethodType != APPRIS.APPRIS_TYPE ) { // no print the final annotation of appris
				var sMethodLabel = APPRIS.METHOD_LABELS[sMethodType];
			 	sResponse += "<th id='"+sMethodType+"'>"+
								"<div class='label'>"+sMethodLabel+"</div>"+
							"</th>";
				sExportData += sMethodType + ",";				
			}
		}
	}
	else {
		sResponse += "<th>Annotations were not found</th>";
	}
	sExportData = sExportData.replace(/,$/g,"\n");
	sResponse += "</tr>"+
					"</thead>"+
					"<tbody>";
	for (var sTranscriptId in oReport) {
		var oTranscriptReport = oReport[sTranscriptId];
		
		var sTransResponse = '';
		var sTransExport = '';
		var bHasResults = false;
		
		// print different style if transcript is principal isoform
		var sValueClass = '';
		if (oTranscriptReport[APPRIS.APPRIS_TYPE]) {
			sValueClass = 'pi';
		}		
		
		for (var sType in APPRIS.METHOD_LABELS) {
			if ( sType != APPRIS.APPRIS_TYPE ) { // no print the final annotation of appris
				var sLabel = APPRIS.METHOD_LABELS[sType];			
				var sValueLabel = '-';
				if (oTranscriptReport[sType]) {
					var sValue = oTranscriptReport[sType];
					sValueLabel = sValue;
	 				switch (sValue) {
						case APPRIS.NO_LABEL:
							sValueLabel = "X";
							break;
						case APPRIS.UNKNOWN_LABEL:
							sValueLabel = "<div class='"+APPRIS.OK_LABEL+"'></div>";
							break;
						case APPRIS.OK_LABEL:
							sValueLabel = "<div class='"+APPRIS.OK_LABEL+"'></div>";
							break;
						case APPRIS.OK_LABEL2:
							sValueLabel = "<div class='"+APPRIS.OK_LABEL+"'></div>";
							break;
					}
					sTransExport += sValue + ",";
					bHasResults = true;
				}
				if ( (sValueLabel != '-') && (sValueLabel != '0') ) {
					var sMethod = APPRIS.METHOD_NAMES_2[sType];
					if ( !(sMethod == 'vcrash' && sValue == APPRIS.NO_LABEL) ) {
						var sMethodLink = APPRIS.RESTWS_URL+sMethod+'/id/'+sTranscriptId;
						sValueLabel = "<div class='pop_external_ref' title='Result in detail' value='"+sMethodLink+"'>"+ sValueLabel +"</div>";
					}
				}
				sTransResponse += "<td class='"+sValueClass+"'>" + sValueLabel + "</td>";
			}
		}
		if (bHasResults) {
			sResponse +=
				"<tr>" +
					"<th>" + sTranscriptId + "</th>" + sTransResponse +
				"</tr>";
			sExportData += sTranscriptId + "," + sTransExport;
			sExportData = sExportData.replace(/,$/g,"\n");
		}
	}
	APPRIS.EXPORT_DATA_APPRIS_PANEL['table'] += sExportData;
	sResponse += "</tbody>"+
				"</table>"+
				"</center>";
	return sResponse;
}

/**
* Prepare APPRIS report for HTML response
* @private
* @param  {String} sTranscriptIdList List of identifiers
* @param  {Object} oReport JSON object
* @return {Object} oReport APPRIS report 
*/
function createAPPRISdetailReport(sTranscriptIdList,oReport)
{	
	// Init report of each transcript
	var bHasResults = false;
	var oTranscriptReportList = new Array();
	var aTransIdList = sTranscriptIdList.split(',');
	for (var i = 0; i < aTransIdList.length; i++) {
		if ( aTransIdList[i] !== undefined ) {
			var sTranscriptId = aTransIdList[i];
			oTranscriptReportList[sTranscriptId] = new Array();
			oTranscriptReportList[sTranscriptId][APPRIS.FIRESTAR_TYPE]			= 0;
			oTranscriptReportList[sTranscriptId][APPRIS.MATADOR3D_TYPE]			= 0;
			oTranscriptReportList[sTranscriptId][APPRIS.INERTIA_TYPE]			= '';
			oTranscriptReportList[sTranscriptId][APPRIS.CORSAIR_TYPE]			= 0;
			oTranscriptReportList[sTranscriptId][APPRIS.SPADE_TYPE]				= '';
			//oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TYPE]				= '';
			oTranscriptReportList[sTranscriptId][APPRIS.CRASH_SP_TYPE]			= '';
			oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TP_TYPE]			= '';
			oTranscriptReportList[sTranscriptId][APPRIS.THUMP_TYPE]				= '';
			oTranscriptReportList[sTranscriptId][APPRIS.CEXONIC_TYPE]			= '';			
			//oTranscriptReportList[sTranscriptId][APPRIS.PROTEO_TYPE]			= 0; // DEPRECATED
		}
	}

	// Scan results for each method	
	for (var i = 0; i < oReport.length; i++) {
		// Get values
		var oLine = oReport[i];
		var sTranscriptId = '';
		var sType = '';
		var sSource = '';
		var sAnnotation = '';
		var sScore = '';
		if ( oLine.transcript_id !== undefined ) { sTranscriptId = oLine.transcript_id }
		if ( oLine.type !== undefined ) { sType = oLine.type }
		if ( oLine.source !== undefined ) { sSource = oLine.source }
		if ( oLine.score !== undefined ) { sScore = oLine.score }
		if ( oLine.annotation !== undefined ) { sAnnotation = oLine.annotation }


		// Get HTML values for each report
		if (sTranscriptId != '' && (oTranscriptReportList[sTranscriptId] !== undefined) ) {
			if (sSource != '' && sSource == 'APPRIS' && sType != '' && sScore != '') {				
				switch (sType) {
					case APPRIS.APPRIS_TYPE:
							switch (sAnnotation) {
								case APPRIS.UNKNOWN_ANNOT:
									oTranscriptReportList[sTranscriptId][APPRIS.APPRIS_TYPE] = APPRIS.OK_LABEL;
									bHasResults = true;
									break;
								case APPRIS.OK_ANNOT:
									oTranscriptReportList[sTranscriptId][APPRIS.APPRIS_TYPE] = APPRIS.OK_LABEL;
									bHasResults = true;
									break;
							}
						break;					
					case APPRIS.FIRESTAR_TYPE:
							if(sScore != '.') {
								oTranscriptReportList[sTranscriptId][APPRIS.FIRESTAR_TYPE] = sScore;
								bHasResults = true;
							}
						break;
					case APPRIS.MATADOR3D_TYPE:
							if(sScore != '.') {
								oTranscriptReportList[sTranscriptId][APPRIS.MATADOR3D_TYPE] = sScore;
								bHasResults = true;
							}
						break;
					case APPRIS.CORSAIR_TYPE:
							if(sScore != '.') {
								oTranscriptReportList[sTranscriptId][APPRIS.CORSAIR_TYPE] = sScore;
								bHasResults = true;
							}
						break;
					case APPRIS.SPADE_TYPE:
							switch (sAnnotation) {
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.SPADE_TYPE] = APPRIS.NO_LABEL;
									bHasResults = true;
									break;
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.SPADE_TYPE] = APPRIS.UNKNOWN_LABEL;
									bHasResults = true;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.SPADE_TYPE] = APPRIS.OK_LABEL;
									bHasResults = true;
									break;
								case APPRIS.OK_LABEL2:
									oTranscriptReportList[sTranscriptId][APPRIS.SPADE_TYPE] = APPRIS.OK_LABEL;
									bHasResults = true;
									break;
							}
						break;						
					case APPRIS.INERTIA_TYPE:
							switch (sAnnotation) {
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.INERTIA_TYPE] = APPRIS.NO_LABEL;
									bHasResults = true;
									break;
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.INERTIA_TYPE] = APPRIS.UNKNOWN_LABEL;
									bHasResults = true;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.INERTIA_TYPE] = APPRIS.OK_LABEL;
									bHasResults = true;
									break;
								case APPRIS.OK_LABEL2:
									oTranscriptReportList[sTranscriptId][APPRIS.INERTIA_TYPE] = APPRIS.OK_LABEL;
									bHasResults = true;
									break;
							}
						break;
					case APPRIS.CEXONIC_TYPE:
							switch (sAnnotation) {
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CEXONIC_TYPE] = APPRIS.NO_LABEL;
									bHasResults = true;
									break;
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CEXONIC_TYPE] = APPRIS.UNKNOWN_LABEL;
									bHasResults = true;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CEXONIC_TYPE] = APPRIS.OK_LABEL;
									bHasResults = true;
									break;
								case APPRIS.OK_LABEL2:
									oTranscriptReportList[sTranscriptId][APPRIS.CEXONIC_TYPE] = APPRIS.OK_LABEL;
									bHasResults = true;
									break;
							}
						break;
					case APPRIS.THUMP_TYPE:
							if(sScore != '.') {								
								oTranscriptReportList[sTranscriptId][APPRIS.THUMP_TYPE] = sScore;
								bHasResults = true;
							}
						break;
					/*					
					case APPRIS.CRASH_TYPE:
							switch (sAnnotation) {
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TYPE] = APPRIS.NO_LABEL;
									bHasResults = true;
									break;
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TYPE] = APPRIS.UNKNOWN_LABEL;
									bHasResults = true;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TYPE] = APPRIS.OK_LABEL;
									bHasResults = true;
									break;
								case APPRIS.OK_LABEL2:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TYPE] = APPRIS.OK_LABEL;
									bHasResults = true;
									break;
							}
						break;
					*/
					case APPRIS.CRASH_SP_TYPE:
							switch (sAnnotation) {
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_SP_TYPE] = APPRIS.NO_LABEL;
									break;
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_SP_TYPE] = APPRIS.UNKNOWN_LABEL;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_SP_TYPE] = APPRIS.OK_LABEL;
									break;
								case APPRIS.OK_LABEL2:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_SP_TYPE] = APPRIS.OK_LABEL;
									break;
							}
						break;
					case APPRIS.CRASH_TP_TYPE:
							switch (sAnnotation) {
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TP_TYPE] = APPRIS.NO_LABEL;
									break;
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TP_TYPE] = APPRIS.UNKNOWN_LABEL;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TP_TYPE] = APPRIS.OK_LABEL;
									break;
								case APPRIS.OK_LABEL2:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TP_TYPE] = APPRIS.OK_LABEL;
									break;
							}
						break;
					/* DEPRECATED
					case APPRIS.PROTEO_TYPE:
							if(sScore != '.') {
								oTranscriptReportList[sTranscriptId][APPRIS.PROTEO_TYPE] = sScore;
								bHasResults = true;
							}
						break;
					*/
				}
			}			
		}
	}
	if (!bHasResults) {
		oTranscriptReportList = null;
	}
	return oTranscriptReportList;
}

/**
* Get Summary info from given query
* @private
* @param {String} sQueryId Identifier 
* @param {String} sQueryIdList List of all protein coding identifiers of gene
*/
function getAPPRISInfo(sQueryId,sQueryIdList)
{
	printStatusMessage('#appris_panel',true,'Loading...');

	$.ajax({
		type: 'GET',
		url: APPRIS.RESTWS+'export/'+'id/'+sQueryId,		
		data: {
			'format': 'json'
		},
		dataType: 'json',
		success: function(data) {		
			if (data == null) { // ERROR message
				// Annotations were not found
				var oTable = new table('appris_panel', ["Annotations were not found"], null);
				var sResponse = oTable.getHTMLElement();
				$('#appris_panel .report').html(sResponse);
			
				// Initialize panel
				printStatusMessage('#appris_panel',false,'');
			
				// Initialize functionality of links
				initPanelMenu('appris_panel');
			}
			else {			
				// Process report
				var oAPPRISReports = createAPPRISdetailReport(sQueryIdList,data);
				var sReportHTML = printAPPRISInfo(oAPPRISReports);
				$('#appris_panel .report').html(sReportHTML);
				APPRIS.EXPORT_DATA_APPRIS_PANEL['url'] = this.url;			
				
				if (oAPPRISReports) {
					$("#appris_panel .report table.appris_panel").tablesorter({
										sortList: [[0,0]],
										headers: {
											1:  { sorter: false },
											2:  { sorter: false },
											3:  { sorter: false },
											4:  { sorter: false },
											5:  { sorter: false },
											6:  { sorter: false },
											7:  { sorter: false },
											8:  { sorter: false },
											9:  { sorter: false },
											10: { sorter: false },
										}
					});					
				}
				// Initialize panel
				printStatusMessage('#appris_panel',false,'');
			
				// Initialize functionality of links
				initPanelMenu('appris_panel');
				
				// Event of external link references
				$('#appris_panel .pop_external_ref').click(newWindow);
			}
		},
		error: function(text, textStatus)
		{
			// Annotations were not found
			var oTable = new table('appris_panel', ["Annotations were not found"], null);
			var sResponse = oTable.getHTMLElement();
			$('#appris_panel .report').html(sResponse);
			
			// Initialize panel
			printStatusMessage('#appris_panel',false,'');
			
			// Initialize functionality of links
			initPanelMenu('appris_panel');
		}
	});
}