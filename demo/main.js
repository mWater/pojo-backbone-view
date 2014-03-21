require.config({
	paths: {
		jQuery: 'src/lib/jquery/jquery',
		Underscore: 'src/lib/underscore/underscore',
		Backbone: 'src/lib/backbone/backbone'
	}
});

require([

	'index',

	'src/lib/jquery/jquery-min',
	'src/lib/underscore/underscore-min',
	'src/lib/backbone/backbone-min'
	
	], function(App){
		App.initialize();
	});

	define([

	'jQuery',
	'Underscore',
	'Backbone'
	], function($,_,Backbone){
		return {};
	})