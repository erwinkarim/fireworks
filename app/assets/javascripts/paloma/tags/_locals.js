(function(){
  // Initializes callbacks container for the this specific scope.
  Paloma.callbacks['tags'] = {};

  // Initializes locals container for this specific scope.
  // Define a local by adding property to 'locals'.
  //
  // Example:
  // locals.localMethod = function(){};
  var locals = Paloma.locals['tags'] = {};

  
  // ~> Start local definitions here and remove this line.
  // setup tabs body
  locals.setup_tab = function(handle){
		//handle.on('shown', function(e){
		handle.on('shown.bs.tab', function(e){
			//when the licserver is clicked, show licserver info and detected features
			$.get('/licservers/' + e.target.attributes['data-licserver'].value + '.template', null, 
				function(data, textStatus, jqXHR){
					if(
						$(
							'#' + e.target.attributes['data-tag'].value + '-' + e.target.attributes['data-licserver'].value
						).children().length == 0
					){
						$('#' + e.target.attributes['data-tag'].value + '-' + e.target.attributes['data-licserver'].value).append(
							data
						).ready( function(){
							//load the featres listings
							$.get('/licservers/' + e.target.attributes['data-licserver'].value + '/features/list', null, 
								function(data, textStatus, jqXHR){
									$('#licserver-' + e.target.attributes['data-licserver'].value + '-features').find('.fa-spinner').remove();
									$('#licserver-' + e.target.attributes['data-licserver'].value + '-features-listing').append(
										data
									).ready( function(){
										//when a feature is selected, show it's usage over time. lazy load the data
										$('.panel[data-init-features="false"]').each( function(index,value){
											locals.setup_features_accordion($(this));
										});


									});
								}, 'html' ).fail( function(){
									console.log('fail to load server');
									$('#licserver-' + e.target.attributes['data-licserver'].value + '-features').find('.fa-spinner').remove();
									$('#licserver-' + e.target.attributes['data-licserver'].value + '-features-listing').append(
										$.parseHTML('Opss, something went wrong. Failed to load feature listings')
									);
								}); //$.get('/licservers/' + e.target.attributes['data-licserver'].value + '/features/list', null, 
						});
					};
				}, 'html' );
		});
		handle.removeAttr('data-setup');
	}; // locals.setup_tab = function(handle){

	locals.setup_features_accordion = function(handle){
		//handle.find('.panel-body').on('show', function(){
		handle.on('shown.bs.collapse', function(){
			console.log('show them panels');
			//load the graph
			if(handle.find('.features-graph').children().length == 0){
				var data_load_path = '/licservers/' + handle.attr('data-licserver') + '/features/' + 
					handle.attr('data-feature') + '/get_data';
				handle.find('.features-graph').highcharts('StockChart', {
					title: { text: handle.attr('data-feature') + ' Usage' },
					chart: {
						events: {
							load: function(){
								//lazy load the data here
								var chart_handle = this;
								function recursive_data_load(last_data_point){
									if(last_data_point != 0 || last_data_point == null){
										chart_handle.showLoading();
										if(last_data_point == null){
											var data_header = {};
										} else {
											var data_header = { start_id:last_data_point };
										}
										$.ajax( data_load_path, {
											dataType:'json', data:data_header
										}).done( function(data, textStatus, jqXHR){
											console.log('load data into the graph upto id ' + data['last_id'] )
								
											//add current data
											//better wayt load 10000 data points at a time
											for(i=0; i < data['data'][0]['data'].length; i++){
												chart_handle.series[0].addPoint( data['data'][0]['data'][i], false, false );
												chart_handle.series[1].addPoint( data['data'][1]['data'][i], false, false );
											}

											//only draw for the first time
											if(last_data_point == null){
												chart_handle.redraw();
												chart_handle.hideLoading();
											};

											//for now it's slow and lock up the browser
											//recursive_data_load(data['last_id']);
										});
									}
								}

								recursive_data_load(null);
								chart_handle.redraw();
							}
						}
					},
					rangeSelector: {
						buttons: [
							{ type: 'hour', count: 1, text: '1h' }, 
							{ type: 'day', count: 1, text: '1d' }, 
							{ type: 'week', count: 1, text: '1w' }, 
							{ type: 'month', count: 1, text: '1m' }, 
							{ type: 'year', count: 1, text: '1y' }, 
							{ type: 'all', text: 'All' }
						], selected : 2 // all
					} ,
					series:[
						{ name:'current', data:[ ] },
						{ name:'max' , data:[ ]}
					],
					plotOptions: {
					}
				}); // handle.find('.features-graph').highcharts('StockChart', {
					
			}
		});
		handle.removeAttr('data-init-feature');
		
	}; // locals.setup_features_accordion = function(handle){

  // Remove this line if you don't want to inherit locals defined
  // on parent's _locals.js
  Paloma.inheritLocals({from : '/', to : 'tags'});
})();
