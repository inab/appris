/*
 * 
 * Summary frame
 * 
 */

// Print Summary information of query
function printSearchInfo(oMatch)
{
	var sLabel = oMatch.label;
	var sNamespace = oMatch.namespace;
	var sChr = oMatch.chr;
	var sStart = oMatch.start;
	var sEnd = oMatch.end;
	var sBioType = oMatch.biotype;
	var sStatus = oMatch.status;

	// Get the type of namespace
	var sQueryId = sLabel;
	var sQueryNamespace = sNamespace;
	var sTypeLabel = getNamespaceLabel(sNamespace);

	// Add DBLinks
	var sDBLinkResponse = '';
	var sExternalId = '';
	if (oMatch.dblink) {
		var oDBLink = oMatch.dblink;
		for (var i = 0; i < oDBLink.length; i++) {
			var sIdDBLink = oDBLink[i].id;
			var sNamespaceDBLink = oDBLink[i].namespace;
			var sLabelDBLink = getNamespaceLabel(sNamespaceDBLink);
			if (sIdDBLink && sNamespaceDBLink && sLabelDBLink) {
				if (sNamespaceDBLink == "External_Id") {
					sExternalId += sIdDBLink;
				} else {
					if (sNamespaceDBLink == "Ensembl_Gene_Id") {
						var sReportLink = "javascript: window.location='report.html?id="+sIdDBLink+"&namespace="+sNamespaceDBLink+"'";
						sDBLinkResponse += "<span class='subtitle'>"+sLabelDBLink+": <a onclick=\""+sReportLink+"\">"+sIdDBLink+"</a></span>";
					}
				}
			}
		}
	}

	// Add input info
	var sResponse = "<div class='title'>"+sTypeLabel+": " +sLabel+ " ("+sExternalId+")"+"</div>";	
	if(sChr && sStart && sEnd) {
		sResponse += "<span class='subtitle'>Location:</span> "+"chr"+sChr+":"+sStart+"-"+sEnd+"<br/>";
	}
	if(sBioType) {
		sResponse += "<span class='subtitle'>Class:</span> "+sBioType+"<br/>";
	}						
	if(sStatus) {
		sResponse += "<span class='subtitle'>Status:</span> "+sStatus;
	}
	sResponse += "<br/>"+sDBLinkResponse;
	
	return sResponse;
}

// Print a summary of identifier from the search cgi
function printSearchInfos(oReport){
	var sSummaryInfoHTML = '';
	var bLog = true;
	if (oReport.query && oReport.match && oReport.match.length > 0) {
		if (oReport.match.length == 1) {
			sSummaryInfoHTML += printSearchInfo(oReport.match[0]);
			$('#title_panel .report').html(sSummaryInfoHTML);
			bLog = true;
		} else {
			bLog = false;
		}
	} else {
		bLog = false;
	}
	return bLog;			
}

/**
* Get Summary info from given query
* @private
* @param {String} sQueryId List of identifier 
*/
function runReportPipeline(sQueryId, sNamespace)
{
	var oXML = $.ajax({
		type: 'GET',
		url: APPRIS.RESTWS+'search/query/'+sQueryId,
		data: {
			'format': 'json'
		},
		dataType: 'json',
		success: function(data) {		
			if (data == null) { // ERROR message
				stopStatusPanels(); // No Entries
			}
			else {
				printStatusMessage('#header_panel',true,'Loading...');

				if (printSearchInfos(data)) {

					printStatusMessage('#header_panel',false,'');
					$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });			

					initReportPanel(); // Init configuration of report panel

					var sQueryIdList = getQueryIdList(sQueryId,sNamespace,data);						
					getTranscriptInfoFromAPPRIS(sQueryId);
					getAPPRISInfo(sQueryId,sQueryIdList);
					getSequence(sQueryId,'aa');
					getUCSCGenomeBrowser(sQueryId);
					getProteoUCSCGenomeBrowser(sQueryId);
					getRNASeqUCSCGenomeBrowser(sQueryId);
				}
				else {
					stopStatusPanels(); // No Entries
				}
			}
		},
		error: function(xhr,textStatus,errorThrown) {
			var sMsg = "<div id='log_panel'>"+APPRIS.SEARCH_NOT_MATCH_SMS+"</div>";
			if ( xhr.status == '500' ) {
				var sMsg = "<div id='log_panel'>"+APPRIS.SEARCH_ERROR_SMS+"</div>";
			}			
			$('#result_panel').html(sMsg);

			printStatusMessage('#header_panel',false,'');
			$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });
		}		
	});

	return oXML;			
}
