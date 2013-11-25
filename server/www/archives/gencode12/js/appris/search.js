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
			window.location = "search.html?query=" + sQueryId;
	}
}
function searchEntity2(event) {
	if ((this.id == 'search_frame_input2' && event.keyCode == 13) || // Enter key code
		(this.id == 'search_frame_image2' && event.type == 'click')) {
			var sQueryId = $('#search_frame_input2').val();
			window.location = "search.html?query=" + sQueryId;
	}
}
function searchEntity3(event) {
	if ((this.id == 'search_frame_input' && event.keyCode == 13) || // Enter key code
		(this.id == 'search_frame_image' && event.type == 'click')) {
			var sQueryId = $('#search_frame_input').val();
			window.location = "../search.html?query=" + sQueryId;
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
function printSearchIdentifier(oMatch)
{
	var sResponse = "";
	
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

	// Add input info
	var sReportLink = "javascript: window.location='report.html?id="+sQueryId+"&namespace="+sQueryNamespace+"'";
	sResponse += "<a onclick=\""+sReportLink+"\">"+sTypeLabel+": "+sLabel+"</a>";

	sResponse += "<p>";
	if(sChr && sStart && sEnd) {
		sResponse += "<span class='subtitle'>Location:</span> "+"chr"+sChr+":"+sStart+"-"+sEnd+"<br/>";
	}
	if(sBioType) {
		sResponse += "<span class='subtitle'>Biotype:</span> "+sBioType+"<br/>";
	}						
	if(sStatus) {
		sResponse += "<span class='subtitle'>Status:</span> "+sStatus+"<br/>";
	}

	// Add DBLinks
	var aDBLinkList = new Array();
	if (oMatch.dblink) {
		var oDBLink = oMatch.dblink;
		for (var i = 0; i < oDBLink.length; i++) {
			var sIdDBLink = oDBLink[i].id;
			var sNamespaceDBLink = oDBLink[i].namespace;
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
function printSearchIdentifiers(oReport) {
	if (oReport.query && oReport.match && oReport.match.length > 0) {
		var iNumGenes = 0;
		var iNumTranscripts = 0;
		var sSearchGeneResponse = '';
		var sSearchTranscriptResponse = '';
		var oMatch = oReport.match;
		for (var i = 0; i < oMatch.length; i++) {
			if (oMatch[i].namespace == 'Ensembl_Transcript_Id') {
				sSearchTranscriptResponse += printSearchIdentifier(oMatch[i]);
				iNumTranscripts++;
			}
			if (oMatch[i].namespace == 'Ensembl_Gene_Id') {
				sSearchGeneResponse += printSearchIdentifier(oMatch[i]);
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
		if (sSearchResponse != '') {
			$('#search_panel').append(sSearchResponse);
			$('#search_panel .list .head .num_searches').click(function(){
				var sDisplayReport = $(this.parentNode.nextElementSibling).css("display");
				if (sDisplayReport == 'none') {
					$('#bottom_panel').css({ position: 'relative' });
					$(this.previousElementSibling).css("background-image","url('./img/arrow_down.png')");
					$(this.parentNode.nextElementSibling).fadeIn(400, function(){
						$(this).css({ display: 'block' });
					});						
				}
				else {
					$(this.previousElementSibling).css("background-image","url('./img/arrow_right.png')");
					$(this.parentNode.nextElementSibling).fadeOut(400, function(){
						$(this).css({ display: 'none' });
						$('#bottom_panel').css({ position: 'absolute' });
					});
				}
			});
			$('#search_panel .list .head .arrow').click(function(){
				var sDisplayReport = $(this.parentNode.nextElementSibling).css("display");
				if (sDisplayReport == 'none') {
					$('#bottom_panel').css({ position: 'relative' });
					$(this).css("background-image","url('./img/arrow_down.png')");
					$(this.parentNode.nextElementSibling).fadeIn(400, function(){
						$(this).css({ display: 'block' });
					});						
				}
				else {
					$(this).css("background-image","url('./img/arrow_right.png')");
					$(this.parentNode.nextElementSibling).fadeOut(400, function(){
						$(this).css({ display: 'none' });
						$('#bottom_panel').css({ position: 'absolute' });
					});
				}
			});	
		}
		else {
			var sSearchHeadResponse = "<div class='head'>"+APPRIS.SEARCH_NOT_MATCH_SMS+"</div>";
			$('#search_panel').append(sSearchHeadResponse);				
		}
	}
	else
	{
		var sSearchHeadResponse = "<div class='head'>"+APPRIS.SEARCH_NOT_MATCH_SMS+"</div>";		
		$('#search_panel').append(sSearchHeadResponse);
	}		
}

// Get Search Response from input identifier
function searchIdentifier(sQueryId)
{
	printStatusMessage('#header_panel',true,'Loading...');		
	$('#search_frame_image').css({ 'background-image': "url('./img/iloading.gif')" });
	
	$.ajax({
		type: 'GET',
		url: APPRIS.RESTWS+'search/query/'+sQueryId,
		data: {
			'format': 'json'
		},
		dataType: 'json',
		success: function(data) {		
			if (data == null) { // ERROR message
				var sMsg = "<div id='log_panel'>"+APPRIS.SEARCH_NOT_MATCH_SMS+"</div>";
				$('#search_panel').html(sMsg);
	
				printStatusMessage('#header_panel',false,'');
				$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });
			}
			else {			
				// Process report
				printSearchIdentifiers(data);

				printStatusMessage('#header_panel',false,'');
				$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });
			}

		},
		error: function(xhr,textStatus,errorThrown) {			
			var sMsg = "<div id='log_panel'>"+APPRIS.SEARCH_NOT_MATCH_SMS+"</div>";
			if ( xhr.status == '500' ) {
				var sMsg = "<div id='log_panel'>"+APPRIS.SEARCH_ERROR_SMS+"</div>";
			}
			$('#search_panel').html(sMsg);

			printStatusMessage('#header_panel',false,'');
			$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });
		}
	});					
}

// Get info PopUp window 
function infoPopUpWindow(sInfo)
{
	var sPopUpId = '#popup_info .popup_info_sms';
	$(sPopUpId).append("<div id='sPopup-container'>"+
						"<div id='sPopup-popup'>"+
							"<div title='close' id='sPopup-close'></div>"+
								"<div style='clear:both;'></div>"+
									sInfo+
							"</div>"+
						"</div>"+
					"</div>");
	$('body').css({ overflow : 'hidden' });
	$(sPopUpId).fadeIn(400, function(){
		$(this).css({ display: 'block' });
	});
	$('#sPopup-close').click(function(){
		$('body').css({ overflow : 'auto' });
		$('#sPopup-container').fadeOut(400, function(){
			$(this).remove();
		});
	});	
}