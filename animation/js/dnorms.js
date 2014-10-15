(function($) {
    $(document).ready(function() {
	
	$('#dnorms').scianimator({
	    'images': ['images/dnorms1.png', 'images/dnorms2.png', 'images/dnorms3.png', 'images/dnorms4.png', 'images/dnorms5.png'],
	    'width': 480,
	    'delay': 1000,
	    'loopMode': 'loop'
	});
	$('#dnorms').scianimator('play');
    });
})(jQuery);
