/*
 * 
 * UCSC methods
 * 
 */

// Get UCSC report info
function getUCSCGenomeBrowser(sPosition)
{
	printStatusMessage('#ucsc_panel',true,'Loading...');
	
	var sReportHTML = 
				"<center>"+
				"<table class='ucsc_panel'>"+
					"<tbody>"+
						"<tr><td>"+
							"<a class='imgHeadUCSC' target='_blank'>"+
								"<table class='ucsc_img_head'>"+
								"<tbody>"+
								"<tr><td>"+
									"<div style='width: 2px;'><img class='imgSideUCSC'/></div>"+
								"</td>"+
								"<td width=800 class='tdData'>"+
									"<div style='height: -23px;'><img class='imgDataUCSC'/></div>"+
								"</td></tr>"+
								"</table>"+
							"</a>"+
						"</td></tr>"+
						"<tr><td>"+
							"<a class='imgUCSC' target='_blank'>"+
								"<table class='ucsc_img_data'>"+
								"<tbody>"+
								"<tr><td>"+
									"<div style='width: 2px;'><img class='imgSideUCSC'/></div>"+
								"</td>"+
								"<td width=800 class='tdData'>"+
									"<div style='height: -23px;'><img class='imgDataUCSC'/></div>"+
								"</td></tr>"+
								"</table>"+
							"</a>"+							
						"</th></tr>"+
					"</tbody>"+
				"</table>"+
				"</center>";
	$('#ucsc_panel .report').html(sReportHTML);
	$.ajax({
		type: 'GET',
		url: 'cgi-bin/proxy_ucsc.cgi',
		data: { 'position' : sPosition, 'format': 'bed', 'head': 'only' },
		dataType: 'json',
		success: function(data) {
			if (data == null) {
				$('#ucsc_panel a.imgHeadUCSC').html('Annotations were not found');
				$('#ucsc_panel a.imgUCSC').html('');
				$('#ucsc_panel a.imgHeadUCSC').css({ cursor: 'default' });
				$('#ucsc_panel a.imgUCSC').css({ cursor: 'default' });
			}
			else {
				if (data.error) {
					$('#ucsc_panel a.imgHeadUCSC').html('Annotations were not found');
					$('#ucsc_panel a.imgUCSC').html('');
					$('#ucsc_panel a.imgHeadUCSC').css({ cursor: 'default' });
					$('#ucsc_panel a.imgUCSC').css({ cursor: 'default' });
				}
				else {				
					$('#ucsc_panel table.ucsc_img_head img.imgSideUCSC').attr('src',data.side);
					$('#ucsc_panel table.ucsc_img_head img.imgDataUCSC').attr('src',data.hgt);
				}
			}			
		},
	});
		
	$.ajax({
		type: 'GET',
		url: 'cgi-bin/proxy_ucsc.cgi',
		data: { 'position' : sPosition, 'format': 'bed', 'head': 'no' },
		dataType: 'json',		
		success: function(data) {
			var sUCSC = '';
			if (data == null) {
				$('#ucsc_panel a.imgHeadUCSC').html('Annotations were not found');
				$('#ucsc_panel a.imgUCSC').html('');
				$('#ucsc_panel a.imgHeadUCSC').css({ cursor: 'default' });
				$('#ucsc_panel a.imgUCSC').css({ cursor: 'default' });
			}
			else {
				if (data.error) {
					$('#ucsc_panel a.imgHeadUCSC').html('Annotations were not found');
					$('#ucsc_panel a.imgUCSC').html('');
					$('#ucsc_panel a.imgHeadUCSC').css({ cursor: 'default' });
					$('#ucsc_panel a.imgUCSC').css({ cursor: 'default' });
				}
				else {
					var sAPPRIS = APPRIS.RELEASE_URL + "cgi-bin/export_data.cgi?"+"position="+sPosition+'&'+
																					"format=bed"+'&'+
																					"head=yes";																							
					APPRIS.EXPORT_DATA_UCSC_PANEL = sAPPRIS;
					var sUCSC = APPRIS.UCSC_URL+'hgTracks?'+
												"db=hg19"+'&'+
												"position="+sPosition+'&'+
												"hgt.customText="+sAPPRIS;
	
					$('#ucsc_panel a.imgHeadUCSC').attr('title','Click to alter the display of original UCSC Genome Browser');
					$('#ucsc_panel a.imgHeadUCSC').attr('href',sUCSC);
					$('#ucsc_panel a.imgUCSC').attr('title','Click to alter the display of original UCSC Genome Browser');				
					$('#ucsc_panel a.imgUCSC').attr('href',sUCSC);
					$('#ucsc_panel table.ucsc_img_head').css({ 'background-image': "url('"+APPRIS.UCSC_URL+"../trash/hgt/blueLines800-118-12.png')" });
					$('#ucsc_panel table.ucsc_img_data').css({ 'background-image': "url('"+APPRIS.UCSC_URL+"../trash/hgt/blueLines800-118-12.png')" });
					$('#ucsc_panel table.ucsc_img_data img.imgSideUCSC').attr('src',data.side);
					$('#ucsc_panel table.ucsc_img_data img.imgDataUCSC').attr('src',data.hgt);					
				}
			}
			printStatusMessage('#ucsc_panel',false,'');
			initPanelMenu('ucsc_panel');
		},
		error: function(text, textStatus)
		{
			$('#ucsc_panel img.imgUCSC').html('Annotations were not found');
			$('#ucsc_panel img.imgUCSC').css({ padding: '0px 3px 0px 3px' });
			$('#ucsc_panel .imgHeadUCSC').css({ cursor: 'default' });
			$('#ucsc_panel .imgUCSC').css({ cursor: 'default' });				
		}
	});
}

