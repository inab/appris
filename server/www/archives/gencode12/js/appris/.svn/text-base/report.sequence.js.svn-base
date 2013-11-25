/*
 * 
 * Sequence methods
 * 
 */

// Print sequence report
function printSequenceInfo(aSeqReportList)
{
	var sResponse =	'';	
	for (var i = 0; i < aSeqReportList.length; i++) {
		var oSeqReport = aSeqReportList[i];
		var sId = oSeqReport.id;
		var sName = oSeqReport.name;
		var sLength = oSeqReport.length;
		var sSequence = oSeqReport.sequence;
		sResponse += "<tr id='"+sId+"' class='title'>"+
						"<td class='title'>"+
							"<input class='sequence_id' type='checkbox' value='"+sId+"'/>"+
						"</td>"+
						"<td class='title'>"+
							"<span class='title_seq'>"+sId+" | "+sName+" | "+sLength+"</span>"+
							"<div class='show_seq'>"+
								"<span class='show' title='Show sequence'>Show</span> / "+
								"<span class='hide' title='Hide sequence'>Hide</span>"+
							"</div>"+						
						"</td>"+
						"<td class='title'>"+
							"<div class='show_methods_btn'>"+
								"<input class='hide' type='button' value='Hide all'></input>"+
								"<input class='show' type='button' value='Show all'></input>"+
							"</div>"+						
						"</td>"+
					"</tr>"+
					"<tr id='"+sId+"' class='sequence'>"+
						"<td class='img_seq' colspan='2'>"+
							"<div class='seq'><span>"+sSequence+"</span></div>"+
							"<div class='status_panel'>"+
								"<div class='loading_frame'></div>"+	
								"<div class='status_message'></div>"+
							"</div>"+							
						"</td>"+
						"<td class='show_methods'></td>"+
					"</tr>";
					
	}
	var sResponseHTML = 
				"<table class='sequence_panel'>"+
					"<tbody>"+
						"<tr>"+
							"<th><center><input class='all_sequence_id' type='checkbox' value=''/></center></th>"+
							"<th>Sequence</th>"+
							"<th>Annotations</th>"+
						"</tr>"+
						sResponse+						
					"</tbody>"+
				"</table>";
	return sResponseHTML;	
}

// Get sequence report
function getSequenceReport(sSeqReport)
{	
	// Init report of each transcript
	var aSeqReportList = new Array();
	var aSeqRepList = sSeqReport.split('>');
	for (var i = 0; i < aSeqRepList.length; i++) {
		if (aSeqRepList[i] !== undefined && aSeqRepList[i] != '') {
			var sSeqRep = aSeqRepList[i];
			// Get sequence report
			var aSRepList = sSeqRep.split('\n');
			if (aSRepList[0] !== undefined && aSRepList[0] != '') {
				// Get comment info
				var sComment = aSRepList[0];
				var sId = '';
				var sMainId = '';
				var sName = '';
				var sLength = '';
				var aCommentList = sComment.split('|');
				if (aCommentList[0] !== undefined && aCommentList[0] != '') {
					sId = aCommentList[0]; 
				}				
				if (aCommentList[1] !== undefined && aCommentList[1] != '') {
					sMainId = aCommentList[1];
				}				
				if (aCommentList[2] !== undefined && aCommentList[2] != '') {
					sName = aCommentList[2]; 
				}				
				if (aCommentList[3] !== undefined && aCommentList[3] != '') {
					sLength = aCommentList[3]; 
				}
				// Get sequence
				var sSeq = '';
				for (var j = 1; j < aSRepList.length; j++) {
					if (aSRepList[j] !== undefined && aSRepList[j] != '') {
						sSeq += aSRepList[j]+'\n';
					}
				}
				sSeq = sSeq.replace(/\n$/g,"");
				var oSeqReport = {
						'id': sId,
						'main': sMainId,
						'name': sName,
						'comment': sComment,
						'length': sLength,
						'sequence': sSeq
				};
				aSeqReportList.push(oSeqReport);
			}			
		}		
	}
	return aSeqReportList;
}

// Get sequences from given query
function getSequence(sQueryId,sType)
{
	printStatusMessage('#sequence_panel',true,'Loading...');

	$.ajax({
		type: 'GET',
		//url: APPRIS.RESTWS+'sequence',
		url: APPRIS.RESTWS+'sequence/id/'+sQueryId,
		data: {
			//'id': sQueryId,
			'type': sType,
			'format': 'fasta'
		},
		success: function(text,textStatus) {
			var sReportHTML =
				"<table class='sequence_panel'>"+
					"<thead>" +
						"<tr>" +
						"<th>Sequences were not found</th>" +
						"</tr>" +
					"</thead>"+
				"</table>";
							
			if (text != '') {
				var aSeqReportList = getSequenceReport(text);
				var sReportHTML = printSequenceInfo(aSeqReportList);
				
				$('#sequence_panel .report').html(sReportHTML);
				
				confSeqMenus(aSeqReportList);
			}
			
			printStatusMessage('#sequence_panel',false,'');

			initPanelMenu('sequence_panel');			
		},
		error: function(text, textStatus) {
		
			var sReportHTML =
				"<table class='sequence_panel'>"+
					"<thead>" +
						"<tr>" +
						"<th>Sequences were not found</th>" +
						"</tr>" +
					"</thead>"+
				"</table>";
			$('#sequence_panel .report').html(sReportHTML);

			printStatusMessage('#sequence_panel',false,'');
			initPanelMenu('sequence_panel');			
		}
	});
}

// Get image sequences from given query
function getImgSeq(sQueryId)
{
	$('#sequence_panel .report #'+sQueryId+' td.img_seq div.seq').html('');
	printStatusMessage('#'+sQueryId,true,'Loading...');

	$.ajax({
		type: 'GET',
		url: APPRIS.RESTWS+'img_seq/id/'+sQueryId,
		dataType: 'xml',
		success: function(xml,textStatus) {
			if (xml != '') {
				//var sSVG_IMG_SEQ = APPRIS.RESTWS_URL + "img_seq/id/"+sQueryId;
				var sSVG_IMG_SEQ = this.url;
				var svg = $('#sequence_panel .report #'+sQueryId+' td.img_seq div.seq').svg({
					loadURL: sSVG_IMG_SEQ,
					changeSize: { width: '0', height: '0' }
				});
				
				// Say me the annotations
				confMetMenu(xml,sQueryId);

				printStatusMessage('#'+sQueryId,false,'');				
			}
		},
		error: function(xml, textStatus) {						
			var sReportHTML = "<p>Sequence was not found</p>";
			$('#sequence_panel .report td.img_seq #'+sQueryId).html(sReportHTML);
			
			printStatusMessage('#'+sQueryId,false,'');
		}
	});
}

// Set up seq menu from a list of queries
function confSeqMenus(aSeqReportList)
{
	for (var i = 0; i < aSeqReportList.length; i++) {
		var oSeqReport = aSeqReportList[i];
		var sId = oSeqReport.id;
			confSeqMenu(sId);
			confAllMenu(sId);
	}
}
function confSeqMenu(sQueryId)
{
	// Init
	$('#sequence_panel .report #'+sQueryId+'.title div.show_seq .show').css({ 'text-decoration': 'none', cursor: 'default' });
	$('#sequence_panel .report #'+sQueryId+'.title div.show_seq .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
	
	$('#sequence_panel .report #'+sQueryId+'.title div.show_seq .show').click(function (eval){
		var sParentId = this.parentNode.parentNode.parentNode.id;
		if ($('#sequence_panel .report #'+sParentId+'.sequence').css('display') == 'none') {			
			$('#sequence_panel .report #'+sParentId+'.sequence').fadeIn(300, function() {
				$(this).css({ display: 'table-row' });
			});			
			$('#sequence_panel .report #'+sQueryId+'.title div.show_seq .show').css({ 'text-decoration': 'none', cursor: 'default' });
			$('#sequence_panel .report #'+sQueryId+'.title div.show_seq .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#sequence_panel .report #'+sQueryId+'.title input.sequence_id').removeAttr('disabled');				
		}
	});			
	$('#sequence_panel .report #'+sQueryId+'.title div.show_seq .hide').click(function (eval){
		var sParentId = this.parentNode.parentNode.parentNode.id;
		if ($('#sequence_panel .report #'+sParentId+'.sequence').css('display') == 'table-row') {			
			$('#sequence_panel .report #'+sParentId+'.sequence').fadeIn(300, function() {
				$(this).css({ display: 'none' });
			});			
			$('#sequence_panel .report #'+sQueryId+'.title div.show_seq .hide').css({ 'text-decoration': 'none', cursor: 'default' });
			$('#sequence_panel .report #'+sQueryId+'.title div.show_seq .show').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#sequence_panel .report #'+sQueryId+'.title input.sequence_id').attr('disabled', 'disabled');
			$('#sequence_panel .report #'+sQueryId+'.title input.sequence_id').removeAttr('checked');
		}
	});
}

// Set up menu of all annotations
function confAllMenu(sQueryId)
{
	// Event for "Show all" button
	$('#sequence_panel .report #'+sQueryId+'.title div.show_methods_btn input.show').click(function (eval){
		if ( $('#sequence_panel .report #'+sQueryId+' td.img_seq div.seq svg').length == 0 ) {
			var sShowMetTbl = "<table class='show_methods'>"+
							"<tr class='functional_residue'>"+
								"<td class='demo'></td>"+
								"<td class='desc'>Functional residues</td>"+
								"<td class='show_met'>"+
									"<span class='show' title='Show sequence'>Show</span> / "+
									"<span class='hide' title='Hide sequence'>Hide</span>"+
								"</td>"+						
							"</tr>"+
							"<tr class='homologous_structure'>"+							
								"<td class='demo'></td>"+
								"<td class='desc'>Tertiary structure</td>"+
								"<td class='show_met'>"+
									"<span class='show' title='Show sequence'>Show</span> / "+
									"<span class='hide' title='Hide sequence'>Hide</span>"+
								"</td>"+						
							"</tr>"+
							"<tr class='functional_domain'>"+
								"<td class='demo'></td>"+
								"<td class='desc'>Functional domain</td>"+
								"<td class='show_met'>"+
									"<span class='show' title='Show sequence'>Show</span> / "+
									"<span class='hide' title='Hide sequence'>Hide</span>"+
								"</td>"+
							"</tr>"+
							"<tr class='transmembrane_signal'>"+
								"<td class='demo'></td>"+
								"<td class='desc'>Transmembrane helices</td>"+
								"<td class='show_met'>"+
									"<span class='show' title='Show sequence'>Show</span> / "+
									"<span class='hide' title='Hide sequence'>Hide</span>"+
								"</td>"+
							"</tr>"+
							"<tr class='peptide_mitochondrial_signal'>"+
								"<td class='demo'></td>"+
								"<td class='desc'>Peptide/Mitochondrial sequence</td>"+
								"<td class='show_met'>"+
									"<span class='show' title='Show sequence'>Show</span> / "+
									"<span class='hide' title='Hide sequence'>Hide</span>"+
								"</td>"+
							"</tr>"+
							"</table>";
			$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods').html(sShowMetTbl);
			
			getImgSeq(sQueryId);
		}
		$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods td.show_met').each(function (eval){
			var sMethod = this.parentNode.className;
			showMet(sMethod, sQueryId);
		});
	});
	
	// Event for "Hide all" button
	$('#sequence_panel .report #'+sQueryId+'.title div.show_methods_btn input.hide').click(function (eval){
		$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods td.show_met').each(function (eval){
			var sMethod = this.parentNode.className;
			hideMet(sMethod, sQueryId);
		});
	});	
}

// Set up method menu
function confMetMenu(xml, sQueryId)
{
	// Init
	$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods td.show_met').each(function (eval){
		var sMethod = this.parentNode.className;
		if ( $(xml).find("rect[class='"+sMethod+"']").length != 0 ) {
			$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .show').css({ 'text-decoration': 'none', cursor: 'default' });
			$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
		}
		if ( sMethod == 'homologous_structure' ) {
			if ( $(xml).find("tspan[class='"+sMethod+"']").length != 0 ) {
				$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .show').css({ 'text-decoration': 'none', cursor: 'default' });
				$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			}
		}
	});
	
	// Event for "Show" method
	$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods td.show_met .show').click(function (eval){
		var sMethod = this.parentNode.parentNode.className;
		showMet(sMethod, sQueryId);
	});
	
	// Event for "Hide" method
	$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods td.show_met .hide').click(function (eval){
		var sMethod = this.parentNode.parentNode.className;
		hideMet(sMethod, sQueryId);
	});
}

// Show method annotations
function showMet(sMethod, sQueryId)
{
	if ($('#sequence_panel .report #'+sQueryId+'.sequence td.img_seq div.seq .'+sMethod).css('display') == 'none') {			
		$('#sequence_panel .report #'+sQueryId+'.sequence td.img_seq div.seq .'+sMethod).fadeIn(300, function() {
			$(this).css({ display: 'block' });
		});			
		$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .show').css({ 'text-decoration': 'none', cursor: 'default' });
		$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
	}
	if ( sMethod == 'homologous_structure' ) {
		if ( ($('#sequence_panel .report #'+sQueryId+'.sequence td.img_seq div.seq .'+sMethod).css('fill') == '#000000') ||
			($('#sequence_panel .report #'+sQueryId+'.sequence td.img_seq div.seq .'+sMethod).css('fill') == "rgb(0, 0, 0)") ) {				
				$('#sequence_panel .report #'+sQueryId+'.sequence td.img_seq div.seq .'+sMethod).fadeIn(300, function() {
					$(this).css({ fill: '#800000' });
				});
				$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .show').css({ 'text-decoration': 'none', cursor: 'default' });
				$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .hide').css({ 'text-decoration': 'underline', cursor: 'pointer' });
		}
	}
}

// Hide method annotations
function hideMet(sMethod, sQueryId)
{
	if ($('#sequence_panel .report #'+sQueryId+'.sequence td.img_seq div.seq .'+sMethod).css('display') == 'block') {
		$('#sequence_panel .report #'+sQueryId+'.sequence td.img_seq div.seq .'+sMethod).css({ display: 'none' });			
			$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .show').css({ 'text-decoration': 'underline', cursor: 'pointer' });
			$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .hide').css({ 'text-decoration': 'none', cursor: 'default' });
	}			
	if ( sMethod == 'homologous_structure' ) {
		if ( ($('#sequence_panel .report #'+sQueryId+'.sequence td.img_seq div.seq .'+sMethod).css('fill') == '#800000') ||
			($('#sequence_panel .report #'+sQueryId+'.sequence td.img_seq div.seq .'+sMethod).css('fill') == "rgb(128, 0, 0)") ) {
				$('#sequence_panel .report #'+sQueryId+'.sequence td.img_seq div.seq .'+sMethod).fadeIn(300, function() {
					$(this).css({ fill: '#000000' });
				});
				$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .show').css({ 'text-decoration': 'underline', cursor: 'pointer' });
				$('#sequence_panel .report #'+sQueryId+'.sequence td.show_methods table.show_methods tr.'+sMethod+' td.show_met .hide').css({ 'text-decoration': 'none', cursor: 'default' });
		}
	}			
}
