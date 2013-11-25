function disableSearchPanels()
{
	$('#search_frame_input').attr('disabled','disabled');
	$('#search_frame_image').attr('disabled','disabled');
	$('#search_frame_image').css('cursor', 'default');
	$('#search_frame_image').unbind('click');
}
// Check server
function checkServer()
{
	$.ajax({
		type: 'GET',
		url: APPRIS.RESTWS+'search/query/BRCA1',
		data: {
			'format': 'json'
		},
		dataType: 'json',
		success: function(data) {		
		},
		error: function(xhr,textStatus,errorThrown) {			
			if ( xhr.status == '500' ) {
				//disableSearchPanels(); // TODO: this method must be available in the whole site
				$('#content_panel .content_leftcol_first').html(APPRIS.SEARCH_ERROR_SMS);				
			}
		}
	});					
}