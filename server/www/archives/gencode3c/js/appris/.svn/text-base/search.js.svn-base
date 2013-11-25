/*
 * 
 * Geneal methods
 * 
 */
// Obtain HTTP GET Parameters
function obtainGETparameters() {
	var oGetParameters = new Array();

	var sLocation = location.search.split("?");	
	if(sLocation.length > 1) {
		var sParameterList =sLocation[1].split("&"); 

		for(var i=0; i < sParameterList.length; i++) { 
			sParameterList[i] = sParameterList[i].split("+").join(" ");
			var aValues = sParameterList[i].split("=");
			var sId = aValues[0];
			var sValue = aValues[1];
			oGetParameters[sId]=sValue;
		}				
	}
	return oGetParameters;
}
// Print Status log
function printStatusMessage(sId,sLoad,sMessage) {

	$(sId + ' .status_panel .status_message').html(sMessage);
	if (sMessage == '') {
		$(sId + ' .status_panel .status_message').css({ display: 'none' });
	} else {
		$(sId + ' .status_panel .status_message').css({ display: 'block' });
	}
	
	if (sLoad) {
		$(sId + ' .status_panel .loading_frame').css({ display: 'block' });
	} else {
		$(sId + ' .status_panel .loading_frame').css({ display: 'none' });
	}
}
// Search entity by means of several search frames
function searchEntity(event) {
	if ((this.id == 'search_frame_input' && event.keyCode == 13) || // Enter key code
		(this.id == 'search_frame_image' && event.type == 'click')) {
			var sQueryId = $('#search_frame_input').val();
			window.location = "search.html?queryId=" + sQueryId;
	}
}
function searchEntity2(event) {
	if ((this.id == 'search_frame_input2' && event.keyCode == 13) || // Enter key code
		(this.id == 'search_frame_image2' && event.type == 'click')) {
			var sQueryId = $('#search_frame_input2').val();
			window.location = "search.html?queryId=" + sQueryId;
	}
}
function searchEntity3(event) {
	if ((this.id == 'search_frame_input' && event.keyCode == 13) || // Enter key code
		(this.id == 'search_frame_image' && event.type == 'click')) {
			var sQueryId = $('#search_frame_input').val();
			window.location = "../search.html?queryId=" + sQueryId;
	}
}

// Get the label when is given datasource namespace
function getNamespaceLabel(sNamespace)
{
	var sType;
	
	switch (sNamespace)
	{
		case "Vega_Gene_Id": sType = "VEGA Gene"; break;
		case "Vega_Transcript_Id": sType = "VEGA Transcript"; break;
		case "Vega_Peptide_Id": sType = "VEGA Peptide"; break;
		case "Ensembl_Gene_Id": sType = "ENSEMBL Gene"; break;
		case "Ensembl_Transcript_Id": sType = "ENSEMBL Transcript"; break;
		case "Ensembl_Peptide_Id": sType = "ENSEMBL Peptide"; break;
		case "External_Id": sType = "External Id"; break;
		case "UniProtKB_SwissProt": sType = "UniProtKB/SwissProt"; break;
		case "CCDS": sType = "CCDS"; break;
	}
	return sType;
}
// Print information of searched 
function printSearchIdentifier(oNode)
{
	var sResponse = "";
	/*
	var sLabel = Sarissa.getText(oNode.selectSingleNode("@label"));
	var sNamespace = Sarissa.getText(oNode.selectSingleNode("@namespace"));
	var sChr = Sarissa.getText(oNode.selectSingleNode("@chr"));
	var sStart = Sarissa.getText(oNode.selectSingleNode("@start"));
	var sEnd = Sarissa.getText(oNode.selectSingleNode("@end"));
	var sClass = Sarissa.getText(oNode.selectSingleNode("class"));
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

	// Add input info
	var sReportLink = "javascript: window.location='report.html?queryId="+sQueryId+"&namespace="+sQueryNamespace+"'";
	sResponse += "<a onclick=\""+sReportLink+"\">"+sTypeLabel+": "+sLabel+"</a>";

	sResponse += "<p>";
	if(sChr && sStart && sEnd) {
		sResponse += "<span class='subtitle'>Location:</span> "+"chr"+sChr+":"+sStart+"-"+sEnd+"<br/>";
	}
	if(sClass) {
		sResponse += "<span class='subtitle'>Class:</span> "+sClass+"<br/>";
	}						
	if(sStatus) {
		sResponse += "<span class='subtitle'>Status:</span> "+sStatus+"<br/>";
	}

	// Add DBLinks
	var aDBLinkList = new Array();
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
				if (aDBLinkList[sLabelDBLink] === undefined) {
					aDBLinkList[sLabelDBLink] = new Array();
				}
				aDBLinkList[sLabelDBLink].push(sIdDBLink);	
			}
		}
	}
	for (var sLabelDBLink in aDBLinkList) {
		var oDBLink = aDBLinkList[sLabelDBLink];
		var sIdDBLinkList = '';
		for (var i = 0; i < oDBLink.length; i++) {
			sIdDBLinkList += oDBLink[i] + ", ";
		}
		sIdDBLinkList = sIdDBLinkList.replace(/\, $/g,'');
		sResponse += "<span class='subtitle'>"+sLabelDBLink + ":</span> " + sIdDBLinkList + "<br/>";
	}
	sResponse += "</p>";
	return sResponse;
}
// Print the list of identifiers from the search cgi
function printSearchIdentifiers(sXML, sStatus) {
	if (Sarissa.getParseErrorText(sXML) == Sarissa.PARSED_OK) {
		var oNodeList = sXML.selectNodes("//match");
		if (oNodeList.length == 0) {
			var sSearchHeadResponse = "<div class='head'>Your query matched no entries in the search database</div>";
			$('#search_panel').append(sSearchHeadResponse);			
		}
		else {
			if (oNodeList.length > 0) {
				var iNumGenes = 0;
				var iNumTranscripts = 0;
				var sSearchGeneResponse = '';
				var sSearchTranscriptResponse = '';
				for (var i = 0; i < oNodeList.length; i++) {
					/*
					var sNamespace = Sarissa.getText(oNodeList[i].selectSingleNode("@namespace"));
					*/
					var sNamespace = oNodeList[i].selectSingleNode("@namespace").nodeValue;
					if (sNamespace == 'Ensembl_Transcript_Id') {
						sSearchTranscriptResponse += printSearchIdentifier(oNodeList[i]);
						iNumTranscripts++;
					}
					if (sNamespace == 'Ensembl_Gene_Id') {
						sSearchGeneResponse += printSearchIdentifier(oNodeList[i]);
						iNumGenes++;
					}
				}
				var sSearchResponse = '';
				if ((sSearchTranscriptResponse != '') && (iNumTranscripts != 0)) {
					sSearchResponse +=
								"<div class='list'>"+
									"<div class='head'>"+
										"<div class='arrow'></div>"+
										"Your query matched <span class='num_searches'>"+iNumTranscripts+" transcripts</span> in the search database."+
									"</div>"+
									"<div class='report'>"+sSearchTranscriptResponse+"</div>"+									
								"</div>";
				}
				if ((sSearchGeneResponse != '') && (iNumGenes != 0)) {
					sSearchResponse += 
								"<div class='list'>"+
									"<div class='head'>"+
										"<div class='arrow'></div>"+					
										"Your query matched <span class='num_searches'>"+iNumGenes+" genes</span> in the search database."+
									"</div>"+
									"<div class='report'>"+sSearchGeneResponse+"</div>"+								
								"</div>";									
				}
			}
			if (sSearchResponse != '') {
				$('#search_panel').append(sSearchResponse);
				$('#search_panel .list .head .num_searches').click(function(){
					var sDisplayReport = $(this.parentNode.nextElementSibling).css("display");
					if (sDisplayReport == 'none') {
						$(this.previousElementSibling).css("background-image","url('./img/arrow_down.png')");
						$(this.parentNode.nextElementSibling).fadeIn(400, function(){
							$(this).css({ display: 'block' });
						});						
					}
					else {
						$(this.previousElementSibling).css("background-image","url('./img/arrow_right.png')");
						$(this.parentNode.nextElementSibling).fadeOut(400, function(){
							$(this).css({ display: 'none' });
						});						
					}
				});
				$('#search_panel .list .head .arrow').click(function(){
					var sDisplayReport = $(this.parentNode.nextElementSibling).css("display");
					if (sDisplayReport == 'none') {
						$(this).css("background-image","url('./img/arrow_down.png')");
						$(this.parentNode.nextElementSibling).fadeIn(400, function(){
							$(this).css({ display: 'block' });
						});						
					}
					else {
						$(this).css("background-image","url('./img/arrow_right.png')");
						$(this.parentNode.nextElementSibling).fadeOut(400, function(){
							$(this).css({ display: 'none' });
						});						
					}
				});	
			}
			else {
				var sSearchHeadResponse = "<div class='head'>Your query matched no entries in the search database</div>";
				$('#search_panel').append(sSearchHeadResponse);				
			}
		}
	}
	else
	{
		$('#search_panel').html("Your query matched no entries in the search database");			
	}		
}
// Get Search Response from input identifier
function searchIdentifier(sQueryId)
{
	printStatusMessage('#header_panel',true,'Loading...');		
	$('#search_frame_image').css({ 'background-image': "url('./img/iloading.gif')" });
	
	$.ajax({
		type: 'GET',
		url: 'cgi-bin/search_identifiers.cgi',
		data: { 'queryId' : sQueryId },
		success: function(xml,textStatus) {

			printSearchIdentifiers(xml,textStatus);

			printStatusMessage('#header_panel',false,'');
			$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });

		},
		error: function(xml,textStatus) {
			var sMsg = "<div id='log_panel'>"+
							"<p>Database Error Messages.</p>"+
							"<p>Please, contact with the "+
							"<a title='Email contact' href='mailto:jmrodriguez@cnio.es' target='_blank' style='cursor: pointer'>administrator</a></p>"+
						"</div>";
			$('#search_panel').html(sMsg);

			printStatusMessage('#header_panel',false,'');
			$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });
		}
	});					
}
