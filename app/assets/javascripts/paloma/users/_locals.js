(function(){
  // Initializes callbacks container for the this specific scope.
  Paloma.callbacks['users'] = {};

  // Initializes locals container for this specific scope.
  // Define a local by adding property to 'locals'.
  //
  // Example:
  // locals.localMethod = function(){};
  var locals = Paloma.locals['users'] = {};


  // ~> Start local definitions here and remove this line.
	/* setup the tabs
	 * handles must have these stucture:-
	 * <handle>
			%ul.nav.nav-tabs{ :id => 'user' + @user.id.to_s + '-tabs' }
				- @user.machines.each do |machine|
					%li
						%a{ :href => '#user' + @user.id.to_s + '-' + 'machine' + machine.id.to_s,
							:data => { :toggle => 'tab', :'user-id' => @user.id, :'machine-id' => machine.id } }
							= machine.name
			.tab-content
				- @user.machines.each do |machine|
					.tab-pane{ :id => 'user' + @user.id.to_s + '-' + 'machine' + machine.id.to_s,
						:data => { :'machine-id' => machine.id, :'user-id' => @user.id } }
	 *
	 *
	*/
	//setup accordion body
  locals.setup_accordion_body = function( handle) {
    handle.find('a[data-toggle="tab"]').on('shown.bs.tab', function(e){
			//don't load if the data has been loaded
			/*
			var anchor_handle = handle.find('.nav-tabs').find(
				'a[data-machine-id="' + e.target.attributes['data-machine-id'] + '"][data-user-id="' + e.target.attributes['data-user-id'] + '"]'
				);
			*/
			var anchor_handle = handle.find('.nav-tabs').find( "a[data-machine-id='" + e.target.attributes['data-machine-id'].value + "']" );
			if(anchor_handle.attr('data-init') != 'false' ){
					console.log('data loaded, skip loading');
					return;
			};

      //when clicked, start gather features data
      $('.tab-pane[data-machine-id="' + e.target.attributes['data-machine-id'].value +
        '"][data-user-id="' + e.target.attributes['data-user-id'].value + '"]').append(
        $.parseHTML('<i class="fa fa-cog fa-spin fa-4x"></i>')
      );

      //show the thing is being loaded

      var data_load_path = '/users/' + e.target.attributes['data-user-id'].value +
        '/machines/' + e.target.attributes['data-machine-id'].value + '/gen_features';

			var tab_handle = handle.find('.tab-pane[data-machine-id="' + e.target.attributes['data-machine-id'].value +
          '"][data-user-id="' + e.target.attributes['data-user-id'].value + '"]');
      //load the chart
      $.ajax( data_load_path, {
        dataType:'json'
      }).done( function(data, textStatus, jqXHR){
        tab_handle.highcharts('StockChart', {
          //setup the chart
          title: { text: 'Features usage by ' + tab_handle.attr('data-user-name') + '@' + tab_handle.attr('data-machine-name') },
          chart: {
            events : {
              load: function(){
                var chart_handle = this;
                var cycles = 50;
                function recursive_data_load(last_data_point, countdown){
                  //only call ajax if there's more data to load in the graph
                  // this locks up browser as it adds new series in a rapid manner
                  if(last_data_point != 0 && countdown != 0){
                    $.ajax( data_load_path, {
                      dataType:'json',
                      data:{ start_id:last_data_point}
                    }).done( function(data, textStatus, jqXHR) {
                      if( data['graph_data'].length != 0){
                        //load data from matched series, otherwise add new series to the graph
                        $.each( data['graph_data'], function( index, value){

                          var new_series = true;
                          $.each( chart_handle.series, function( chart_index, serie){
                            if( serie.name == value['name']) {
                              new_series = false;
                              $.each( value['data'], function( data_index, data_value ) {
                                serie.addPoint( data_value , false, false);
                              });
                            }
                          });

                          //if the it's a new series, create a new one and then add data points
                          if(new_series){
                            chart_handle.addSeries(value, true);
                          }
                        });
                        chart_handle.redraw();
                      };
                      recursive_data_load(data['last_data_point'], countdown - 1);
                    });
                  }
                } ;
                recursive_data_load(data['last_data_point'], cycles);
              },
              click: function(e){
                console.log(e);
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
          },
          series: data['graph_data']
        });
      }).fail( function(jqXHR, textStatus, errorThrown){
				tab_handle.empty().append(
					'failed to load: ' + textStatus
				);

			}); // $.ajax(

      //remove the spinner
			anchor_handle.attr('data-init', 'true' );
    }); // handle.find('a[data-toggle="tab"]').on('shown', function(e){
    handle.attr('data-init', 'true');
  }; // setup_accordion_body = function( handle) {


  // Remove this line if you don't want to inherit locals defined
  // on parent's _locals.js
  Paloma.inheritLocals({from : '/', to : 'users'});
})();
