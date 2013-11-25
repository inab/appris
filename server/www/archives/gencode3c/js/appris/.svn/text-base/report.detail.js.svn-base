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
	if(oReport) {
		sResponse += "<th><div class='label'>Transcript Id</div></th>";
		sExportData += "transcript_id" + ",";
		
		for (var sMethodType in APPRIS.METHOD_LABELS) {
			var sMethodLabel = APPRIS.METHOD_LABELS[sMethodType];
		 	sResponse += "<th id='"+sMethodType+"'>"+
							"<div class='label'>"+sMethodLabel+"</div>"+
						"</th>";
			sExportData += sMethodType + ",";
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
		
		for (var sType in APPRIS.METHOD_LABELS) {
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
				}
				sTransExport += sValue + ",";
				bHasResults = true;
			}
			sTransResponse += "<td>" + sValueLabel + "</td>";
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
* @param  {String} sReport GTF report
* @return {Object} oReport APPRIS report 
*/
function createAPPRISdetailReport(sTranscriptIdList,sReport)
{
	// Convert GTF report to JSON
	var oReport = convertGTF2JSON(sReport);
	
	// Init report of each transcript
	var oTranscriptReportList = new Array();
	var aTransIdList = sTranscriptIdList.split(',');
	for (var i = 0; i < aTransIdList.length; i++) {
		if (aTransIdList[i]) {
			var sTranscriptId = aTransIdList[i];
			oTranscriptReportList[sTranscriptId] = new Array();
			oTranscriptReportList[sTranscriptId][APPRIS.FIRESTAR_TYPE]	= 0;
			oTranscriptReportList[sTranscriptId][APPRIS.MATADOR3D_TYPE]	= 0;
			oTranscriptReportList[sTranscriptId][APPRIS.SPADE_TYPE]	= '';
			oTranscriptReportList[sTranscriptId][APPRIS.INERTIA_TYPE]	= '';
			oTranscriptReportList[sTranscriptId][APPRIS.CRASH_SP_TYPE]	= '';
			oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TP_TYPE]	= '';
			oTranscriptReportList[sTranscriptId][APPRIS.THUMP_TYPE]		= '';
			oTranscriptReportList[sTranscriptId][APPRIS.CEXONIC_TYPE]	= '';
			oTranscriptReportList[sTranscriptId][APPRIS.CORSAIR_TYPE]	= 0;
		}
	}

	// Scan results for each method	
	for (var i = 0; i < oReport.length; i++)
	{
		var sTranscriptId = '';
		var sType = '';
		var sSource = '';
		var sAnnotation = '';
		var sScore = '';

		// Get values
		if (oReport[i].source) { sSource += oReport[i].source }
		if (oReport[i].type) { sType += oReport[i].type }				
		if (oReport[i].score) { sScore += oReport[i].score }		
		if (oReport[i].attributes) {
			var aAttributes = oReport[i].attributes;
			for (var j = 0; j < aAttributes.length; j++) {
				var sKey = aAttributes[j].key;
				var sValue = aAttributes[j].value;
				if (sKey == 'transcript_id') {
					sTranscriptId += sValue;
				} else {
					if (sKey == 'annotation') {
						sAnnotation += sValue;
					}
				}
			}
		}
		
		// Get HTML values for each report
		if (sTranscriptId != '' && oTranscriptReportList[sTranscriptId]) {
			if (sSource != '' && sSource == 'APPRIS' && sType != '' && sScore != '') {
				switch (sType) {
					case APPRIS.FIRESTAR_TYPE:
							if(sScore != '.') {
								oTranscriptReportList[sTranscriptId][APPRIS.FIRESTAR_TYPE] = sScore;
							}
						break;
					case APPRIS.MATADOR3D_TYPE:
							if(sScore != '.') {
								oTranscriptReportList[sTranscriptId][APPRIS.MATADOR3D_TYPE] = sScore;
							}
						break;
					case APPRIS.SPADE_TYPE:
							switch (sAnnotation) {
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.SPADE_TYPE] = APPRIS.UNKNOWN_LABEL;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.SPADE_TYPE] = APPRIS.OK_LABEL;
									break;
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.SPADE_TYPE] = APPRIS.NO_LABEL;
									break;
							}
						break;
					case APPRIS.INERTIA_TYPE:
							switch (sAnnotation) {
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.INERTIA_TYPE] = APPRIS.UNKNOWN_LABEL;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.INERTIA_TYPE] = APPRIS.OK_LABEL;
									break;
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.INERTIA_TYPE] = APPRIS.NO_LABEL;
									break;
							}
						break;
					case APPRIS.CRASH_SP_TYPE:
							switch (sAnnotation) {
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_SP_TYPE] = APPRIS.UNKNOWN_LABEL;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_SP_TYPE] = APPRIS.OK_LABEL;
									break;
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_SP_TYPE] = APPRIS.NO_LABEL;
									break;
							}
						break;
					case APPRIS.CRASH_TP_TYPE:
							switch (sAnnotation) {
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TP_TYPE] = APPRIS.UNKNOWN_LABEL;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TP_TYPE] = APPRIS.OK_LABEL;
									break;
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CRASH_TP_TYPE] = APPRIS.NO_LABEL;
									break;
							}
						break;
					case APPRIS.THUMP_TYPE:
							if(sScore != '.') {								
								oTranscriptReportList[sTranscriptId][APPRIS.THUMP_TYPE] = sScore;
							}
						break;
					case APPRIS.CEXONIC_TYPE:
							switch (sAnnotation) {
								case APPRIS.UNKNOWN_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CEXONIC_TYPE] = APPRIS.UNKNOWN_LABEL;
									break;
								case APPRIS.OK_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CEXONIC_TYPE] = APPRIS.OK_LABEL;
									break;
								case APPRIS.NO_LABEL:
									oTranscriptReportList[sTranscriptId][APPRIS.CEXONIC_TYPE] = APPRIS.NO_LABEL;
									break;
							}
					case APPRIS.CORSAIR_TYPE:
							if(sScore != '.') {
								oTranscriptReportList[sTranscriptId][APPRIS.CORSAIR_TYPE] = sScore;
							}
						break;
				}
			}			
		}
	}
	return oTranscriptReportList;
}

/**
* Convert GTF report to JSON
* @private
* @param  {String} sReport GTF report
* @return {Object} oReport JSON object 
*/
function convertGTF2JSON(sReport)
{
	var oReport = [];
	
	var aMainResults = sReport.split('\n');
	for (var i = 0; i < aMainResults.length; i++) {
		if (aMainResults[i]) {
			var aResults = aMainResults[i].split('\t');
			if (aResults && aResults.length >= 8) {
				var oFeature = {
					'seqname': aResults[0],
					'source': aResults[1],
					'type': aResults[2],
					'start': aResults[3],
					'end': aResults[4],
					'score': aResults[5],
					'strand': aResults[6],
					'frame': aResults[7]
				};

				var aAttributes = [];
				var sAttributes = '';		
				if (aResults[8] && aResults[8] !== null) {
					sAttributes += aResults[8];					
					var aAttributesValues = sAttributes.split(';');
					for (var j = 0; j < aAttributesValues.length; j++) {
						var sAttributesValues = aAttributesValues[j];
						var aAttrValues = sAttributesValues.match(/^\s*([^\s]+)\s*\"([^\"]+)\"\s*/);
						if (aAttrValues && aAttrValues.length == 3) {
							aAttributes.push({
								key: aAttrValues[1],
								value: aAttrValues[2]
							});
						}
					}
				}
				if(aAttributes !== null){
					oFeature.attributes = aAttributes;	
				}
				oReport.push(oFeature);
			}
		}
	}
	return oReport;	
}

/**
* Get Summary info from given query
* @private
* @param {String} sPosition Position of identifier 
* @param {String} sQueryIdList List of identifier
*/
function getAPPRISInfo(sPosition,sQueryIdList)
{
	printStatusMessage('#appris_panel',true,'Loading...');

	$.ajax({
		type: 'GET',
		url: 'cgi-bin/export_data.cgi',
		data:
		{
			'position': sPosition,
			'format': 'gtf'
		},
		success: function(text,textStatus)
		{
			var aMatchValues = text.match(/^Query ERROR: ([^\n]+)\n/); //"Query ERROR: caught BioMart::Exception::Database"
			var aMatchValues2 = text.match(/^503 Service Temporarily Unavailable\n/); //"503 Service Temporarily Unavailable"
			var aMatchValues3 = text.match(/^500 Can't connect/); //"500 Can't connect to"
			if ((aMatchValues && aMatchValues.length >= 0) || (aMatchValues2 && aMatchValues2.length >= 0) || (aMatchValues3 && aMatchValues3.length >= 0))
			{
				// Service Temporarily Unavailable
				var oTable = new table('appris_panel', ["Service temporarily unavailable"], null);
				var sResponse = oTable.getHTMLElement();
				$('#appris_panel .report').html(sResponse);
			}
			else
			{
				if (text == "")
				{
					// Annotations were not found
					var oTable = new table('appris_panel', ["Annotations were not found"], null);
					var sResponse = oTable.getHTMLElement();
					$('#appris_panel .report').html(sResponse);
				}
				else
				{
					// Process report
					var oAPPRISReports = createAPPRISdetailReport(sQueryIdList,text);
					var sReportHTML = printAPPRISInfo(oAPPRISReports);
					$('#appris_panel .report').html(sReportHTML);
					APPRIS.EXPORT_DATA_APPRIS_PANEL['url'] = this.url;
				
					$("#appris_panel .report table.appris_panel").tablesorter({
										sortList: [[0,0]],
										headers: {
											1: { sorter: false },
											2: { sorter: false },
											3: { sorter: false },
											4: { sorter: false },
											5: { sorter: false },
											6: { sorter: false },
											7: { sorter: false },
											8: { sorter: false },
											9: { sorter: false },
										}
					});
				}
			}
			// Initialize panel
			printStatusMessage('#appris_panel',false,'');
			
			// Initialize functionality of links
			initPanelMenu('appris_panel');
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