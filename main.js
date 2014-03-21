require.config({
	paths: {
		jQuery: 'src/lib/jquery/jquery',
		Underscore: 'src/lib/underscore/underscore',
		Backbone: 'src/lib/backbone/backbone'
	}
});

require([

	'src/lib/jquery/jquery-min',
	'src/lib/underscore/underscore-min',
	'src/lib/backbone/backbone-min',	
	'index'
	
	], function(App){
		App.initialize();
	});