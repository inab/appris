/*
 * 
 * UCSC methods
 * 
 */

// Get RNA-Seq tracks in UCSC
function getRNASeqUCSCGenomeBrowser(sQueryId)
{
	printStatusMessage('#ucsc_rnaseq_panel',true,'Loading...');
	
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
	$('#ucsc_rnaseq_panel .report').html(sReportHTML);
	
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
					
					$('#ucsc_rnaseq_panel table.ucsc_img_head').css({ 'background-image': "url('"+sUCSC_PROXY_IMG_BG+"')" });				
					$('#ucsc_rnaseq_panel table.ucsc_img_head img.imgDataUCSC').attr('src',sUCSC_PROXY_IMG_HGT);
					$('#ucsc_rnaseq_panel table.ucsc_img_head img.imgSideUCSC').attr('src',sUCSC_PROXY_IMG_SIDE); 
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
		url: APPRIS.RESTWS+'ucsc/'+'id/'+sQueryId,
		data: {
			'format': 'bed',
			'head': 'only:burgeRnaSeqGemMapperAlign'
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
					var sUCSC_PROXY_IMG_BG = APPRIS.RESTWS_URL + "img_ucsc/hgt/"+"blueLines800-118-12.png";
					//var sUCSC_PROXY_IMG_BG = APPRIS.RESTWS_URL + "img_ucsc/hgt/"+"blueLines1100-118-12.png";					
					var sUCSC_PROXY_IMG_HGT = APPRIS.RESTWS_URL + "img_ucsc/hgt/"+data.hgt;
					var sUCSC_PROXY_IMG_SIDE = APPRIS.RESTWS_URL + "img_ucsc/hgtSide/"+data.side;
					
					$('#ucsc_rnaseq_panel table.ucsc_img_data').css({ 'background-image': "url('"+sUCSC_PROXY_IMG_BG+"')" });
					$('#ucsc_rnaseq_panel table.ucsc_img_data img.imgDataUCSC').attr('src',sUCSC_PROXY_IMG_HGT);
					$('#ucsc_rnaseq_panel table.ucsc_img_data img.imgSideUCSC').attr('src',sUCSC_PROXY_IMG_SIDE);					
				}
			}
			printStatusMessage('#ucsc_rnaseq_panel',false,'');
			initPanelMenu('ucsc_rnaseq_panel');
		},
		error: function(xhr,textStatus,errorThrown) {
			printStatusMessage('#ucsc_rnaseq_panel',false,'');
			initPanelMenu('ucsc_rnaseq_panel');
			if ( xhr.status == '503' ) {
				ucscNotRespond();
			}
			else {
				annotationsNotFound();	
			}			
		}
	});
	
	function annotationsNotFound() {					
		$('#ucsc_rnaseq_panel a.imgHeadUCSC').html('Annotations were not found');
		$('#ucsc_rnaseq_panel a.imgHeadUCSC').removeAttr('href');
		$('#ucsc_rnaseq_panel a.imgUCSC').html('');
		$('#ucsc_rnaseq_panel a.imgHeadUCSC').css({ cursor: 'default' });
		$('#ucsc_rnaseq_panel a.imgUCSC').css({ cursor: 'default' });
	}
	function ucscNotRespond() {					
		$('#ucsc_rnaseq_panel a.imgHeadUCSC').html('UCSC Genome Browser does not respond');
		$('#ucsc_rnaseq_panel a.imgHeadUCSC').removeAttr('href');
		$('#ucsc_rnaseq_panel a.imgUCSC').html('');
		$('#ucsc_rnaseq_panel a.imgHeadUCSC').css({ cursor: 'default' });
		$('#ucsc_rnaseq_panel a.imgUCSC').css({ cursor: 'default' });
	}	
}
