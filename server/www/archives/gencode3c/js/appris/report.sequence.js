/*
 * 
 * Sequence methods
 * 
 */

// Print sequence report
function printSequenceInfo(aSeqReportList)
{
	var sTools = "<select name='tools' disabled='disabled'>"+
					"<option value='functional_residue'>Firestar</option>"+
					"<option value='homologous_structure'>Matador3D</option>"+
					"<option value='functional_domain'>PfamScan</option>"+
					"<option value='muscle'>MUSCLE</option>"+					
				"</select>"+
				"<input type='button' value='Go' disabled='disabled' onclick='' />";
				
	var sResponse =	'';	
	for (var i = 0; i < aSeqReportList.length; i++) {
		var oSeqReport = aSeqReportList[i];
		var sId = oSeqReport.id;
		var sName = oSeqReport.name;
		var sLength = oSeqReport.length;
		var sSequence = oSeqReport.sequence;
		sResponse += "<tr>"+
						"<td><input class='sequence_id' type='checkbox' value='"+sId+"'/></td>"+
						"<td class='title'>"+sId+" ("+sName+")"+"</td>"+
						"<td class='title'>"+sLength+"</td>"+
						//"<td class='title'>"+sTools+"</td>"+
					"</tr>"+
					"<tr>"+
						"<td class='sequence' colspan='2'>"+sSequence+"</td>"
					"</tr>";
					
	}
	var sResponseHTML = 
				"<table class='sequence_panel'>"+
					"<tbody>"+
						"<tr>"+
							"<th></th>"+
							"<th>Sequence</th>"+
							"<th>Length</th>"+
							//"<th>Tools</th>"+
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
		url: 'cgi-bin/export_sequence.cgi',
		data: {
			'id': sQueryId,
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
			}			
			$('#sequence_panel .report').html(sReportHTML);

			printStatusMessage('#sequence_panel',false,'');

			APPRIS.EXPORT_DATA_SEQUENCE_PANEL = APPRIS.RELEASE_URL+"cgi-bin/export_sequence.cgi?"+
																					"format=fasta"+
																					'&'+"type=aa"+
																					'&';
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