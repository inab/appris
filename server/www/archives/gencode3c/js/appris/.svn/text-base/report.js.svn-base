/*
 * 
 * Geneal methods
 * 
 */

// Init Configuration
function initReportPanel(){
	$('#summary_panel .report').css({ display: 'none' });
	$('#appris_panel .report').css({ display: 'none' });
	$('#ucsc_panel .report').css({ display: 'none' });
	$('#sequence_panel .report').css({ display: 'none' });	
}

// Stop status panels
function stopStatusPanels() {
	$('#title_panel .head').html("<p>Your query matched no entries in the search database</p>");
	printStatusMessage('#header_panel',false,'');
	printStatusMessage('#appris_panel',false,'');
	printStatusMessage('#summary_panel',false,'');
	printStatusMessage('#ucsc_panel',false,'');
	$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });
}

// Parse the genome position
function getGenomicPosition(oGeneXML)
{
	var sPosition = "";
	if (Sarissa.getParseErrorText(oGeneXML) == Sarissa.PARSED_OK) {
		var oNode = oGeneXML.selectSingleNode("//match");
		if (oNode) {
			/*
			var sChr = Sarissa.getText(oNode.selectSingleNode("@chr"));
			var sStart = Sarissa.getText(oNode.selectSingleNode("@start"));
			var sEnd = Sarissa.getText(oNode.selectSingleNode("@end"));
			*/
			var sChr = oNode.selectSingleNode("@chr").nodeValue;
			var sStart = oNode.selectSingleNode("@start").nodeValue;
			var sEnd = oNode.selectSingleNode("@end").nodeValue;			
			sPosition += "chr"+sChr+":"+sStart+"-"+sEnd;
		}
	}
	return sPosition;
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
	}
	return sType;
}

// Get the label from method name
function getMethodLabel(sName)
{
	var sType;
						
	switch (sName)
	{
		case "functional_residue": sType = "Functional residue"; break;
		case "conservation_structure": sType = "Conservation structure"; break;
		case "domain_signal": sType = "Domain signal"; break;
		case "unusual_evolution": sType = "Unusual evolution"; break;
		case "peptide_signal": sType = "Peptide signal of sequence"; break;
		case "mitochondrial_signal": sType = "Mitochondrial signal of sequence"; break;
		case "transmembrane_signal": sType = "Signal of transmembrane helices"; break;
		case "conservation_exon": sType = "Exonic structure conserved in mouse"; break;
		case "vertebrate_signal": sType = "Vertebrate conservation"; break;
		case "principal_isoform": sType = "Principal isoform"; break;
	}
	return sType;
}

// Get Id list
function getQueryIdList(sQueryId,sNamespace,oGeneXML)
{
	var sQueryIdList = "";
	if(sNamespace == 'Ensembl_Gene_Id')
	{
		if (Sarissa.getParseErrorText(oGeneXML) == Sarissa.PARSED_OK) {
			var oNodeList = oGeneXML.selectNodes("//match/dblink");
			if (oNodeList.length > 0) {
				for (var i = 0; i < oNodeList.length; i++) {
				
					// Get DBLinks
					/*
					var sId = Sarissa.getText(oNodeList[i].selectSingleNode("@id"));
					var sNamespace = Sarissa.getText(oNodeList[i].selectSingleNode("@namespace"));
					*/
					var sId = oNodeList[i].selectSingleNode("@id").nodeValue;
					var sNamespace = oNodeList[i].selectSingleNode("@namespace").nodeValue;
					if (sNamespace == 'Ensembl_Transcript_Id') {
						sQueryIdList += sId + ",";
					}
				}
				sQueryIdList = sQueryIdList.replace(/\,$/g,"");
			}
		}
	} else {
		if(sNamespace == 'Ensembl_Transcript_Id')
		{
			sQueryIdList = sQueryId;
		}
	}
	return sQueryIdList;
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

// Init Menu Panel
function initPanelMenu(sPanel) {
	// Init configuration for (Menu report: Show,Hide, and Export tools)
	$('#'+sPanel+' .report').css({ display: 'none' });			
	$('#'+sPanel+' .menu .show').css({ 'text-decoration': 'underline', cursor: 'pointer' });			
	$('#'+sPanel+' .menu .hide').css({ 'text-decoration': 'none', cursor: 'default' });
	$('#'+sPanel+' .menu .export').css({ 'text-decoration': 'none', cursor: 'default' });
	
	$('#'+sPanel+' .menu .show').click(function (eval){
		var sParentId = this.parentNode.parentNode.id;
		if ($('#' + sParentId + ' .report').css('display') == 'none') {			
			$('#' + sParentId + ' .report').fadeIn(300, function() {
				$(this).css({ display: 'block' });
			});
			
			$('#' + sParentId + ' .menu .show').css({ 'text-decoration': 'none', cursor: 'default' });
			$('#' + sParentId + ' .menu .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#' + sParentId + ' .menu .export').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#' + sParentId + ' .menu .export').bind('click',openExportData);
			
			// Patch code of summary_nopep_panel
			$('#summary_nopep_panel .nonpep_report').css({ display: 'none' });
			$('#summary_nopep_panel .show').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#summary_nopep_panel .hide').css({ 'text-decoration': 'none', cursor: 'default' });
		}
	});			
	$('#'+sPanel+' .menu .hide').click(function (eval){
		var sParentId = this.parentNode.parentNode.id;
		if ($('#' + sParentId + ' .report').css('display') == 'block') {
			$('#' + sParentId + ' .report').fadeOut(300, function(){
				$(this).css({ display: 'none' });
			});
			$('#' + sParentId + ' .menu .show').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#' + sParentId + ' .menu .hide').css({ 'text-decoration': 'none', cursor: 'default' });
			$('#' + sParentId + ' .menu .export').css({ 'text-decoration': 'none', cursor: 'default' });
			$('#' + sParentId + ' .menu .export').unbind('click');
			$('#' + sParentId + ' .menu .close').click();
		}
	});
}

// Init Menu Panel
function initNonPepPanelMenu(sPanel) {
	// Init configuration for (Menu report: Show,Hide, and Export tools)
	$('#'+sPanel+' .nonpep_report').css({ display: 'none' });			
	$('#'+sPanel+' .show').css({ 'text-decoration': 'underline', cursor: 'pointer' });			
	$('#'+sPanel+' .hide').css({ 'text-decoration': 'none', cursor: 'default' });
	
	$('#'+sPanel+' .show').click(function (eval){
		var sParentId = this.parentNode.parentNode.parentNode.id;
		if ($('#' + sParentId + ' .nonpep_report').css('display') == 'none') {
			$('#' + sParentId + ' .nonpep_report').fadeIn(300, function(){
				$(this).css({ display: 'block' });
			});
			$('#' + sParentId + ' .show').css({ 'text-decoration': 'none', cursor: 'default' });
			$('#' + sParentId + ' .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
		}
	});			
	$('#'+sPanel+' .hide').click(function (eval){
		var sParentId = this.parentNode.parentNode.parentNode.id;
		if ($('#' + sParentId + ' .nonpep_report').css('display') == 'block') {
			$('#' + sParentId + ' .nonpep_report').fadeOut(300, function(){
				$(this).css({ display: 'none' });
			});
			$('#' + sParentId + ' .show').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#' + sParentId + ' .hide').css({ 'text-decoration': 'none', cursor: 'default' });
		}
	});
}

// Get keys of a hash
function getKeys(obj)
{
	var keys = [];
	for (key in obj) {
		if (obj.hasOwnProperty(key)) { keys[keys.length] = key; }
	}
	return keys;
}

// Export data
function popStatic(oEvent)
{
	$('body').append('<form id="exportform" action="export.php" method="post" target="_blank">\
						<input type="hidden" id="filename" name="filename" />\
						<input type="hidden" id="exportdata" name="exportdata" />\
					</form>');
    $('#filename').val(oEvent.data.filename);
    $('#exportdata').val(oEvent.data.table);
    $('#exportform').submit().remove();
    return true; 
	
}
// Close menu of export data 
function closeExportData() {
	$(this).parents('.export_menu').children(0).fadeOut(300, function(){
			$(this).remove();
	});
}
// Open menu of export data
function openExportData(oEvent)
{
	$(this).parent().find('.export_menu').fadeIn(200, function(){
		if (!($(this).find('ul').length > 0)) {
			var sExportMenu = '';
			var sFileName = '';
			var sTableData = '';
			
			var sHostName = window.location.href;
			sHostName = sHostName.replace(/([^\/]+)$/g,"");

			var sPanelType = $(this).parent('.menu').parent().attr('id');
			switch (sPanelType) {
				case 'summary_panel':
					var sURL = APPRIS.EXPORT_DATA_SUMMARY_PANEL['url'];
					var sURLData = sHostName + sURL;
					sExportMenu =
						"<ul>\
						<div class='close' title='close'></div>\
						<div style='clear:both;'></div>\
							<li><a href=\""+sURLData+"\" target='_blank'>Export complete data as text</a></li>\
						</ul>";
				break;
				case 'appris_panel':
					sTableData = APPRIS.EXPORT_DATA_APPRIS_PANEL['table'];
					var sURL = APPRIS.EXPORT_DATA_APPRIS_PANEL['url'];
					var sURLData = sHostName + sURL;
					sExportMenu =
						"<ul>\
						<div class='close' title='close'></div>\
						<div style='clear:both;'></div>\
							<li><a class='export_link' target='_blank'>Export data as text</a></li>\
							<li><a href=\""+sURLData+"\" target='_blank'>Export complete data as text</a></li>\
						</ul>";
					sFileName = sQueryId + '.appris_table.csv';
				break;
				case 'sequence_panel':
					
					// TODO: Get the IDS
					var sIdList = '';
					$('table.sequence_panel input.sequence_id:checked').each(function() {
						sIdList += $(this).val()+',';
					});
					if (sIdList != '') {
						sIdList = sIdList.replace(/,$/g,"");
						var sURLData = APPRIS.EXPORT_DATA_SEQUENCE_PANEL+'id='+sIdList;
						sExportMenu =
							"<ul>\
							<div class='close' title='close'></div>\
							<div style='clear:both;'></div>\
								<li><a href=\""+sURLData+"\" target='_blank'>Export Protein sequence as FASTA</a></li>\
							</ul>";						
					} else {
						sExportMenu =
							"<ul>\
							<div class='close' title='close'></div>\
							<div style='clear:both;'></div>\
								Please, select one sequence at least.\
							</ul>";
					}	
				break;
				case 'ucsc_panel':
					var sURLData = APPRIS.EXPORT_DATA_UCSC_PANEL;
					sExportMenu =
						"<ul>\
						<div class='close' title='close'></div>\
						<div style='clear:both;'></div>\
							<li><a href=\""+sURLData+"\" target='_blank'>Export data as BED</a></li>\
						</ul>";
				break;
			}
			$(this).append(sExportMenu);
			$(this).find('.export_link').bind('click',{
				filename: sFileName,
				table: sTableData
			}
			,popStatic);
			$(this).find('.close').click(closeExportData);
			$(this).css({ display: 'block' });
			$(this).find('a').click(closeExportData);							
		}
	});
}