(function(){
  // Initializes callbacks container for the this specific scope.
  Paloma.callbacks['users'] = {};

  // Initializes locals container for this specific scope.
  // Define a local by adding property to 'locals'.
  //
  // Example:
  // locals.localMethod = function(){};
  var locals = Paloma.locals['users'] = {};

  //recursively load data into the chart
  var data_load_recursive = function( load_path, chart_handle, last_data_point, countdown ){
    if(countdown != 0 && last_data_point != 0){
      var extra_info = null;
      if(last_data_point != null){
            extra_info = { start_id:last_data_point};
      };

      $.get(load_path, extra_info, function(data){
        chart_handle.series.data = [];
        $.each(data['graph_data'], function(index, value){
          chart_handle.series[0].addPoint({ x:value.data[0][0], y:value.data[0][1], name:value.name, color:'#13AFA8'}, false);
        });
        chart_handle.redraw();
        data_load_recursive( load_path, chart_handle, data['last_data_point'], countdown-1);
      }, 'json');
    };
  };

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

     Highcharts.setOptions({ global: {useUTC:false}});
      tab_handle.highcharts('StockChart', {
        title: { text: 'Features usage by ' + tab_handle.attr('data-user-name') + '@' + tab_handle.attr('data-machine-name') },
        rangeSelector: {
            buttons: [
              { type: 'hour', count:1, text: '1h'},
              { type: 'day', count:1, text: '1d'},
              { type: 'week', count:1, text: '1w'},
              { type: 'month', count:1, text: '1m'},
              { type: 'all', text: 'all'}
          ]
        },
        tooltip:{
          pointFormat:'{point.x:%e-%b-%Y %H:%M:%S}<br/><span style="color:{point.color}"></span> {point.name}: <b>{point.y}</b><br/>'
        },
        series: [{
          name:'Module Used',
          data:[]
        }],
        chart: {
          type:'scatter',
          events:{
            load: function(){
              data_load_recursive( data_load_path, this, null, 10)
            }
          }
        }
      });

      //remove the spinner
			anchor_handle.attr('data-init', 'true' );
    }); // handle.find('a[data-toggle="tab"]').on('shown', function(e){
    handle.attr('data-init', 'true');
  }; // setup_accordion_body = function( handle) {

  // Remove this line if you don't want to inherit locals defined
  // on parent's _locals.js
  Paloma.inheritLocals({from : '/', to : 'users'});
})();
