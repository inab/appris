/*
 * 
 * Google Analytics code for INB and APPRIS
 * 
 */

// Google Analytics of INB
function google_analytics_INB(){
	var _gaq = _gaq || [];
	_gaq.push(['_setAccount', 'UA-25973460-1']);
	_gaq.push(['_trackPageview']);
	
	(function(){
		var ga = document.createElement('script');
		ga.type = 'text/javascript';
		ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0];
		s.parentNode.insertBefore(ga, s);
	})();
}

// Google Analytics of APPRIS
function google_analytics_APPRIS(){
	var _gaq = _gaq || [];
	_gaq.push(['_setAccount', 'UA-25975549-1']);
	_gaq.push(['_trackPageview']);
	
	(function(){
		var ga = document.createElement('script');
		ga.type = 'text/javascript';
		ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0];
		s.parentNode.insertBefore(ga, s);
	})();
}