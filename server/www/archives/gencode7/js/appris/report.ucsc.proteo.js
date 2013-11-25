/*
 * 
 * UCSC methods
 * 
 */

// Get Peptide evidences in UCSC
function getProteoUCSCGenomeBrowser(sQueryId)
{
	printStatusMessage('#ucsc_proteo_panel',true,'Loading...');
	
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
						"</td></tr>"+
					"</tbody>"+
				"</table>"+
				"</center>";
	$('#ucsc_proteo_panel .report').html(sReportHTML);
	
	// call head image
	$.ajax({
		type: 'GET',
		url: APPRIS.RESTWS+'ucsc/'+'id/'+sQueryId,		
		data: {
			'format': 'bed',
			'head': 'only:ensGene,ccdsGene'
		},
		dataType: 'json',
		success: function(data) {
			if (data == null) {
				annotationsNotFound();
			}
			else {
				if (data.error) {
					annotationsNotFound();
				}
				else {
					//var sUCSC_PROXY_IMG_BG = APPRIS.RESTWS_URL + "img_ucsc/hgt/"+"blueLines800-118-12.png";
					var sUCSC_PROXY_IMG_BG = APPRIS.RESTWS_URL + "img_ucsc/hgt/"+"blueLines1100-118-12.png";					
					var sUCSC_PROXY_IMG_HGT = APPRIS.RESTWS_URL + "img_ucsc/hgt/"+data.hgt;
					var sUCSC_PROXY_IMG_SIDE = APPRIS.RESTWS_URL + "img_ucsc/hgtSide/"+data.side;
					
					$('#ucsc_proteo_panel table.ucsc_img_head').css({ 'background-image': "url('"+sUCSC_PROXY_IMG_BG+"')" });				
					$('#ucsc_proteo_panel table.ucsc_img_head img.imgDataUCSC').attr('src',sUCSC_PROXY_IMG_HGT);
					$('#ucsc_proteo_panel table.ucsc_img_head img.imgSideUCSC').attr('src',sUCSC_PROXY_IMG_SIDE); 
				}
			}			
		},
		error: function(xhr,textStatus,errorThrown) {
			if ( xhr.status == '503' ) {
				ucscNotRespond();
			}
			else {
				annotationsNotFound();	
			}			
		}
	});
		
	// call annotation image
	$.ajax({
		type: 'GET',
		url: APPRIS.RESTWS+'ucsc_proteo/'+'id/'+sQueryId,
		data: {
			'format': 'bedg',
		},
		dataType: 'json',
		success: function(data) {
			if (data == null) {
				annotationsNotFound();				
			}
			else {
				if (data.error) {
					annotationsNotFound();
				}
				else {
					//var sUCSC_PROXY_IMG_BG = APPRIS.RESTWS_URL + "img_ucsc/hgt/"+"blueLines800-118-12.png";
					var sUCSC_PROXY_IMG_BG = APPRIS.RESTWS_URL + "img_ucsc/hgt/"+"blueLines1100-118-12.png";					
					var sUCSC_PROXY_IMG_HGT = APPRIS.RESTWS_URL + "img_ucsc/hgt/"+data.hgt;
					var sUCSC_PROXY_IMG_SIDE = APPRIS.RESTWS_URL + "img_ucsc/hgtSide/"+data.side;					
					$('#ucsc_proteo_panel table.ucsc_img_data').css({ 'background-image': "url('"+sUCSC_PROXY_IMG_BG+"')" });
					$('#ucsc_proteo_panel table.ucsc_img_data img.imgDataUCSC').attr('src',sUCSC_PROXY_IMG_HGT);
					$('#ucsc_proteo_panel table.ucsc_img_data img.imgSideUCSC').attr('src',sUCSC_PROXY_IMG_SIDE);
					
					var sPROTEO = APPRIS.PROTEO_RESTWS_URL + "export.cgi/id/"+sQueryId+'?'+"format=bedg";
					APPRIS.EXPORT_DATA_UCSC_PROTEO_PANEL = sPROTEO;
					var sUCSC = APPRIS.UCSC_URL+'hgTracks?'+
												"db=hg19"+'&'+
												"position="+sQueryId+'&'+
												"hgt.customText="+sPROTEO;					
					$('#ucsc_proteo_panel a.imgUCSC').attr('title','Click to alter the display of original UCSC Genome Browser');				
					$('#ucsc_proteo_panel a.imgUCSC').attr('href',sUCSC);
				}
			}
			printStatusMessage('#ucsc_proteo_panel',false,'');
			initPanelMenu('ucsc_proteo_panel');
		},
		error: function(xhr,textStatus,errorThrown) {
			printStatusMessage('#ucsc_proteo_panel',false,'');
			initPanelMenu('ucsc_proteo_panel');
			if ( xhr.status == '503' ) {
				ucscNotRespond();
			}
			else {
				annotationsNotFound();	
			}			
		}
	});
	
	function annotationsNotFound() {					
		$('#ucsc_proteo_panel a.imgHeadUCSC').html('Annotations were not found');
		$('#ucsc_proteo_panel a.imgHeadUCSC').removeAttr('href');
		$('#ucsc_proteo_panel a.imgUCSC').html('');
		$('#ucsc_proteo_panel a.imgHeadUCSC').css({ cursor: 'default' });
		$('#ucsc_proteo_panel a.imgUCSC').css({ cursor: 'default' });
	}	
	function ucscNotRespond() {					
		$('#ucsc_proteo_panel a.imgHeadUCSC').html('UCSC Genome Browser does not respond');
		$('#ucsc_proteo_panel a.imgHeadUCSC').removeAttr('href');
		$('#ucsc_proteo_panel a.imgUCSC').html('');
		$('#ucsc_proteo_panel a.imgHeadUCSC').css({ cursor: 'default' });
		$('#ucsc_proteo_panel a.imgUCSC').css({ cursor: 'default' });
	}
}