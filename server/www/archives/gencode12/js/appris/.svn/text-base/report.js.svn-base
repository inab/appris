/*
 * 
 * General methods
 * 
 */

// Init Configuration
function initReportPanel(){
	$('#summary_panel .report').css({ display: 'none' });
	$('#appris_panel .report').css({ display: 'none' });
	$('#sequence_panel .report').css({ display: 'none' });
	$('#ucsc_appris_panel .report').css({ display: 'none' });
	$('#ucsc_proteo_panel .report').css({ display: 'none' });
	$('#ucsc_rnaseq_panel .report').css({ display: 'none' });	
}

// Stop status panels
function stopStatusPanels() {
	var sMsg = "<div id='log_panel'>"+APPRIS.SEARCH_NOT_MATCH_SMS+"</div>"; 			
	$('#result_panel').html(sMsg);
	printStatusMessage('#header_panel',false,'');
	printStatusMessage('#appris_panel',false,'');
	printStatusMessage('#summary_panel',false,'');
	printStatusMessage('#ucsc_appris_panel',false,'');
	printStatusMessage('#ucsc_proteo_panel',false,'');
	printStatusMessage('#ucsc_rnaseq_panel',false,'');
	$('#search_frame_image').css({ 'background-image': "url('./img/isearch.png')" });
}

// Parse the genome position
function getGenomicPosition(oReport)
{
	var sPosition = "";
	if (oReport.query && oReport.match && oReport.match.length == 1) {
		var oMatch = oReport.match[0];
		var sChr = oMatch.chr;
		var sStart = oMatch.start;
		var sEnd = oMatch.end;
		sPosition += "chr"+sChr+":"+sStart+"-"+sEnd;
	}
	return sPosition;
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
		case "exon_conservation": sType = "Exonic structure conserved in mouse"; break;
		case "vertebrate_signal": sType = "Vertebrate conservation"; break;
		case "principal_isoform": sType = "Principal isoform"; break;
	}
	return sType;
}

// Get Id list
function getQueryIdList(sQueryId,sNamespace,oReport)
{
	var sQueryIdList = "";
	if(sNamespace == 'Ensembl_Gene_Id') {
		// Get DBLinks
		if (oReport.query && oReport.match && oReport.match.length == 1) {
			var oMatch = oReport.match[0];
			var oDBLink = oMatch.dblink;
			for (var i = 0; i < oDBLink.length; i++) {
				var sIdDBLink = oDBLink[i].id;
				var sNamespaceDBLink = oDBLink[i].namespace;
				if (sNamespaceDBLink == 'Ensembl_Transcript_Id') {
					sQueryIdList += sIdDBLink + ",";
				}
			}
			sQueryIdList = sQueryIdList.replace(/\,$/g,"");			
		}
	} else {
		if (sNamespace == 'Ensembl_Transcript_Id') {
			sQueryIdList = sQueryId;
		}
	}
	return sQueryIdList;
}

// Init Menu Panel
function initPanelMenu(sPanel) {
	// Init configuration for (Menu report: Show,Hide, and Export tools)
	$('#'+sPanel+' .report').css({ display: 'none' });			
	$('#'+sPanel+' .menu .show').css({ 'text-decoration': 'underline', cursor: 'pointer' });			
	$('#'+sPanel+' .menu .hide').css({ 'text-decoration': 'none', cursor: 'default' });
	$('#'+sPanel+' .menu .export').css({ 'text-decoration': 'none', cursor: 'default' });
	$('#'+sPanel+' .menu .tool').css({ 'text-decoration': 'none', cursor: 'default' });
	
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
			$('#' + sParentId + ' .menu .tool').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#' + sParentId + ' .menu .tool').bind('click',openToolData);
			
			// check or not check (all sequence)
			$('table.'+sParentId+' input.all_sequence_id').click(function() {
				var sCStatus = this.checked;
				$('table.'+sParentId+' input.sequence_id').each(function() {
					if (!this.disabled) {
						this.checked = sCStatus;						
					}
				});
			});
			
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
			$('#' + sParentId + ' .menu .tool').css({ 'text-decoration': 'none', cursor: 'default' });
			$('#' + sParentId + ' .menu .tool').unbind('click');
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
	$(this).parents('.export_menu ul').fadeOut(300, function(){
			$(this).parent().parent().css({display: ''});
			$(this).remove();
	});
	$(this).parents('.tool_menu ul').fadeOut(300, function(){
			$(this).parent().parent().css({display: ''});
			$(this).remove();
	});
}

// Open menu of export data
function openExportData(oEvent)
{
	$(this).parent().find('.export').fadeIn(200, function(){
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
					var sURLJSON = sHostName + sURL;
					var sURLGTF = sURLJSON.replace(/json/g,'gtf');
					sExportMenu =
						"<ul>\
						<div class='close' title='close'></div>\
						<div style='clear:both;'></div>\
							<li><a href=\""+sURLJSON+"\" target='_blank'>Export complete data as JSON</a></li>\
							<li><a href=\""+sURLGTF+"\" target='_blank'>Export complete data as GTF</a></li>\
						</ul>";
				break;
				case 'appris_panel':
					sTableData = APPRIS.EXPORT_DATA_APPRIS_PANEL['table'];
					var sURL = APPRIS.EXPORT_DATA_APPRIS_PANEL['url'];
					var sURLJSON = sHostName + sURL;
					var sURLGTF = sURLJSON.replace(/json/g,'gtf');
					sExportMenu =
						"<ul>\
						<div class='close' title='close'></div>\
						<div style='clear:both;'></div>\
							<li><a class='export_link' target='_blank'>Export data as text</a></li>\
							<li><a href=\""+sURLJSON+"\" target='_blank'>Export complete data as JSON</a></li>\
							<li><a href=\""+sURLGTF+"\" target='_blank'>Export complete data as GTF</a></li>\
						</ul>";
					sFileName = 'appris_table.csv';
				break;
				case 'sequence_panel':					
					var sIdList = '';
					$('table.sequence_panel input.sequence_id:checked').each(function() {
						sIdList += $(this).val()+',';
					});
					if (sIdList != '') {
						sIdList = sIdList.replace(/,$/g,"");
						//var sURLData = APPRIS.EXPORT_DATA_SEQUENCE_PANEL.replace(/id=([^\&]*)/g,'id='+sIdList);
						//var sURLData = APPRIS.EXPORT_DATA_SEQUENCE_PANEL['url']+'?id='+sIdList+'&type=aa&format=fasta';
						//var sURLData2 = APPRIS.EXPORT_DATA_SEQUENCE_PANEL['url2']+'?id='+sIdList;
						var sURLData = APPRIS.EXPORT_DATA_SEQUENCE_PANEL['url']+'/id/'+sIdList+'?type=aa&format=fasta';
						var sURLData2 = APPRIS.EXPORT_DATA_SEQUENCE_PANEL['url2']+'/id/'+sIdList;
						sExportMenu =
							"<ul>\
							<div class='close' title='close'></div>\
							<div style='clear:both;'></div>\
								<li><a href=\""+sURLData+"\" target='_blank'>Export protein sequence as FASTA</a></li>\
								<li><a href=\""+sURLData2+"\" target='_blank'>Export residues annotations as JSON</a></li>\
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
				case 'ucsc_appris_panel':
					var sURLData = APPRIS.EXPORT_DATA_UCSC_PANEL;
					sExportMenu =
						"<ul>\
						<div class='close' title='close'></div>\
						<div style='clear:both;'></div>\
							<li><a href=\""+sURLData+"\" target='_blank'>Export data as BED</a></li>\
						</ul>";
				break;
				case 'ucsc_proteo_panel':
					var sURLData = APPRIS.EXPORT_DATA_UCSC_PROTEO_PANEL;
					sExportMenu =
						"<ul>\
						<div class='close' title='close'></div>\
						<div style='clear:both;'></div>\
							<li><a href=\""+sURLData+"\" target='_blank'>Export data as BED</a></li>\
						</ul>";
				break;				
			}
			$(this).find('.export_menu').html(sExportMenu);
			$(this).find('.export_link').bind('click',{
				filename: sFileName,
				table: sTableData
			}
			,popStatic);
			$(this).find('.close').click(closeExportData);
			$(this).css({ display: 'inline-block' });
			$(this).find('a').click(closeExportData);							
		}
	});
}

// Open menu of tool data
function openToolData(oEvent)
{
	$(this).parent().find('.tool').fadeIn(200, function(){
		if (!($(this).find('ul').length > 0)) {
			var sToolMenu = '';
			var sFileName = '';
			var sTableData = '';
			
			var sHostName = window.location.href;
			sHostName = sHostName.replace(/([^\/]+)$/g,"");

			var sPanelType = $(this).parent('.menu').parent().attr('id');
			switch (sPanelType) {
				case 'sequence_panel':					
					var sIdList = '';
					var iNumIdList = 0;
					$('table.sequence_panel input.sequence_id:checked').each(function() {
						sIdList += $(this).val()+',';
						iNumIdList += 1;
					});
					if (iNumIdList == 0) {
						sToolMenu =
							"<ul>\
							<div class='close' title='close'></div>\
							<div style='clear:both;'></div>\
								Please, select one sequence at least.\
							</ul>";
					} else if (iNumIdList == 1) {
						sIdList = sIdList.replace(/,$/g,"");
						var sURLData = APPRIS.TOOL_DATA_SEQUENCE_PANEL['url']+'/id/'+sIdList+'?type=aa&format=fasta';
						sToolMenu =
							"<ul>\
							<div class='close' title='close'></div>\
							<div style='clear:both;'></div>\
								<li><a href=\""+sURLData+"\" target='_blank'>Search protein database (nr) using NCBI-BLASTP</a></li>\
							</ul>";
					} else if (iNumIdList >= 2) {
						sIdList = sIdList.replace(/,$/g,"");
						var sURLData = APPRIS.TOOL_DATA_SEQUENCE_PANEL['url']+'/id/'+sIdList+'?type=aa&format=fasta';
						var sURLData2 = APPRIS.TOOL_DATA_SEQUENCE_PANEL['url2']+'/id/'+sIdList+'?type=aa&format=clw';
						sToolMenu =
							"<ul>\
							<div class='close' title='close'></div>\
							<div style='clear:both;'></div>\
								<li><a href=\""+sURLData+"\" target='_blank'>Search protein database (nr) using NCBI-BLASTP</a></li>\
								<li><a href=\""+sURLData2+"\" target='_blank'>Multiple sequence alignment using EBI-MUSCLE</a></li>\
							</ul>";
					}	
				break;
			}
			$(this).find('.tool_menu').html(sToolMenu);
			$(this).find('.tool_link').bind('click',{
				filename: sFileName,
				table: sTableData
			}
			,popStatic);
			$(this).find('.close').click(closeExportData);
			$(this).css({ display: 'inline-block' });
			$(this).find('a').click(closeExportData);							
		}
	});
}

// Open new Window 
function newWindow(event) {
	if ( $(this).attr('class') == 'pop_external_ref' && event.type == 'click' ) {
		var sHRef = $(this).attr('value');
		var w = 800;
		var h = 800;
		var left = ($(window).width() - w) / 2 ;
		var top = ($(window).height() - h) / 2;		

		var sWSize = "width="+w+", height="+h+", top="+top+", left="+left+"";
		var sWProp = "toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no,"; 		
		var windowName = sHRef;
		window.open(sHRef, windowName, sWProp+sWSize);
	}
	else if ( $(this).attr('class') == 'content_external_ref' && event.type == 'click' ) {
		var sHRef = $(this).attr('value');		
		var windowName = '_blank';
		window.open(sHRef, windowName);
	}
	event.preventDefault();	
}
