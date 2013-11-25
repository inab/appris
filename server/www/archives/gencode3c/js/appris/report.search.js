/*
 * 
 * Summary frame
 * 
 */

// Print Summary information of query
function printSummary(oNode)
{
	/*
	var sLabel = Sarissa.getText(oNode.selectSingleNode("@label"));
	var sNamespace = Sarissa.getText(oNode.selectSingleNode("@namespace"));
	var sChr = Sarissa.getText(oNode.selectSingleNode("@chr"));
	var sStart = Sarissa.getText(oNode.selectSingleNode("@start"));
	var sEnd = Sarissa.getText(oNode.selectSingleNode("@end"));
	var sClass = Sarissa.getText(oNode.selectSingleNode("@class"));
	var sStatus = Sarissa.getText(oNode.selectSingleNode("status"));
	*/
	var sLabel = oNode.selectSingleNode("@label").nodeValue;
	var sNamespace = oNode.selectSingleNode("@namespace").nodeValue;
	var sChr = oNode.selectSingleNode("@chr").nodeValue;
	var sStart = oNode.selectSingleNode("@start").nodeValue;
	var sEnd = oNode.selectSingleNode("@end").nodeValue;
	var sClass = oNode.selectSingleNode("class").textContent;
	var sStatus = oNode.selectSingleNode("status").textContent;	

	// Get the type of namespace
	var sQueryId = sLabel;
	var sQueryNamespace = sNamespace;
	var sTypeLabel = getNamespaceLabel(sNamespace);

	// Add DBLinks
	var sDBLinkResponse = '';
	var sExternalId = '';
	var oNodeListDBLink = oNode.selectNodes("dblink");
	if (oNodeListDBLink.length > 0) {
		for (var i = 0; i < oNodeListDBLink.length; i++) {
			/*
			var sIdDBLink = Sarissa.getText(oNodeListDBLink[i].selectSingleNode("@id"));
			var sNamespaceDBLink = Sarissa.getText(oNodeListDBLink[i].selectSingleNode("@namespace"));
			*/
			var sIdDBLink = oNodeListDBLink[i].selectSingleNode("@id").nodeValue;
			var sNamespaceDBLink = oNodeListDBLink[i].selectSingleNode("@namespace").nodeValue;			
			var sLabelDBLink = getNamespaceLabel(sNamespaceDBLink);
			if (sIdDBLink && sNamespaceDBLink && sLabelDBLink) {

				if (sNamespaceDBLink == "External_Id") {
					sExternalId += sIdDBLink;
				} else {
					if (sNamespaceDBLink == "Ensembl_Gene_Id") {
						var sReportLink = "javascript: window.location='report.html?queryId="+sIdDBLink+"&namespace="+sNamespaceDBLink+"'";
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
	if(sClass) {
		sResponse += "<span class='subtitle'>Class:</span> "+sClass+"<br/>";
	}						
	if(sStatus) {
		sResponse += "<span class='subtitle'>Status:</span> "+sStatus;
	}
	sResponse += "<br/>"+sDBLinkResponse;
	
	return sResponse;
}
// Print a summary of identifier from the search cgi
function printSummaryInfo(sXML){
	var sSummaryInfoHTML = '';
	var bLog = true;
	if (Sarissa.getParseErrorText(sXML) == Sarissa.PARSED_OK) {
		var oNodeList = sXML.selectNodes("//match");
		if (oNodeList.length == 0) {
			bLog = false;
		}
		else {
			if (oNodeList.length == 1) {
				sSummaryInfoHTML += printSummary(oNodeList[0]);
				$('#title_panel .report').html(sSummaryInfoHTML);
				bLog = true;
			} else {
				bLog = false;				
			}
		}
	}
	else
	{
		bLog = false;		
	}
	return bLog;			
}

/**
* Get Summary info from given query
* @private
* @param {String} sQueryId List of identifier 
*/
function runReportPipeline(sQueryId)
{
	var oXML = $.ajax({
		type: 'GET',
		url: 'cgi-bin/search_identifiers.cgi',
		data:
		{
			'queryId' : sQueryId
		},
		success: function(oGeneReportXML, textStatus)
		{
			var sPosition = getGenomicPosition(oGeneReportXML);
			
			if (oGeneReportXML || sPosition != "") {
				printStatusMessage('#header_panel',true,'Loading...');

				if (printSummaryInfo(oGeneReportXML)) {

					printStatusMessage('#header_panel',false,'');
					$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });			

					initReportPanel(); // Init configuration of report panel

					var sQueryIdList = getQueryIdList(sQueryId,sNamespace,oGeneReportXML);						
					getTranscriptInfoFromAPPRIS(sQueryIdList);
					getAPPRISInfo(sPosition,sQueryIdList);
					getSequence(sQueryId,'aa');
					getUCSCGenomeBrowser(sPosition);
				}
				else {
					stopStatusPanels(); // No Entries
				}
			}
		},		
		error: function(oGeneReportXML,textStatus)
		{
			var sMsg = "<div id='log_panel'>"+
							"<p>Database Error Messages.</p>"+
							"<p>Please, contact with the "+
							"<a title='Email contact' href='mailto:jmrodriguez@cnio.es' target='_blank' style='cursor: pointer'>administrator</a></p>"+
						"</div>";
			$('#result_panel').html(sMsg);

			printStatusMessage('#header_panel',false,'');
			$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });
		}		
	});

	return oXML;			
}
