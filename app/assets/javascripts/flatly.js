// Flatly
// Bootswatch
//= require jquery
//= require jquery_ujs
//= require flatly/loader
//= require flatly/bootswatch

// Primary author: Katie Siegel

$(document).ready( function() {
	// Create popup upon mouseover
	$('#itemize-btn-sub').mouseover(function() {
		$('#coming-soon').show();
	});

	// Remove popup when no longer mousing over note
	$('#itemize-btn-sub').mouseout(function() {
		$('#coming-soon').hide();
	});
})