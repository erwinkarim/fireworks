(function(){
  // Initializes callbacks container for the this specific scope.
  Paloma.callbacks['features'] = {};

  // Initializes locals container for this specific scope.
  // Define a local by adding property to 'locals'.
  //
  // Example:
  // locals.localMethod = function(){};
  var locals = Paloma.locals['features'] = {};

  // ~> Start local definitions here and remove this line.

	// load daily_grpah into a handle
	// requirements:
	// 		handle must have the following attributes:-
	// 		data-feature			The name of the feature
	// 		data-licserver		the licserver id
	// 		data-last_data_point
  locals.load_daily_graph = function( handle){
			//setup the graph
			graph_handle = handle.find('.graph');
      graph_handle.highcharts('StockChart', {
        title: { text: handle.attr('data-feature') + ' Daily Usage' },
        chart: {
          events:{
            load: function(){
              //console.log('lazy load daily data');
              var chart_handle = this;
              var data_load_path = '/licservers/' + handle.attr('data-licserver') + '/features/' +
                handle.attr('data-feature') + '/get_data.json';
              //since share common w/ tags/index, share this out
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
                    //console.log('load data into the graph upto id ' + data['last_id'] )

                    //add current data
                    //better wayt load 10000 data points at a time
                    for(i=0; i < data['data'][0]['data'].length; i++){
                      //chart_handle.series[0].addPoint( data['data'][0]['data'][i], false, false );
                      chart_handle.series[0].addPoint( {
                         x: data['data'][0]['data'][i][0],
                         y: data['data'][0]['data'][i][1],
                         id: data['data'][0]['data'][i][2],
                         name: data['data'][0]['data'][i][2]
                        }, false, false );
                      chart_handle.series[1].addPoint( data['data'][1]['data'][i], false, false );
                    }

                    //only draw for the first time
                    if(last_data_point == null){
                      chart_handle.redraw();
                      chart_handle.hideLoading();
                    };

                    //for now it's slow and lock up the browser
                    //recursive_data_load(data['last_id']);
                    handle.find('#load-older').removeAttr('disabled');
                    handle.find('#dump-everything').removeAttr('disabled');
                    handle.attr('data-last-point', data['last_id']);
                  });
                };
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
          { name:'current', data:[ ] , turboThreshold: 0 },
          { name:'max' , data:[ ]}
        ],
        plotOptions: {
          series:{
            allowPointSelect: true,
            events:{
              click:function(e){
                //console.log(e.point.x);

                //load new users when historical user listing is active
                if( $('#historical-users').hasClass('active')  ){
                  $('#historical-user-listings').empty();
                  load_path = '/licservers/' + handle.attr('data-licserver') +  '/features/' +
                    handle.attr('data-feature') + '/historical_users';
                  $.get( load_path, { time_id:e.point.x } , function(data,textStatus,jqXHR){
                    $('#historical-user-listings').append(data).ready( function(){
                    });
                  }, 'html' );
                }
              }
            }
          }
        }
      }); // handle.highcharts('StockChart', {

			//setup the buttons

      //load more data into the graph
      handle.find('#load-older').click( function(){

        var data_load_path = '/licservers/' + handle.attr('data-licserver') + '/features/' +
          handle.attr('data-feature') + '/get_data.json';
        chart_handle = handle.find('.graph').highcharts();

        $.ajax(data_load_path, {
          data: {start_id:handle.attr('data-last-point') },
          dataType:'json',
          beforeSend: function(){
            handle.find('#load-older').attr('disabled', 'disabled');
            handle.find('#dump-everything').attr('disabled', 'disabled');
            chart_handle.showLoading();
          },
          complete: function(){
						console.log('run complete function');
            chart_handle.redraw();
            chart_handle.hideLoading();
            handle.find('#load-older').removeAttr('disabled');
            handle.find('#dump-everything').removeAttr('disabled');
          }
        }).done( function(data, textStatus, jqXHR){
          for(i=0; i < data['data'][0]['data'].length; i++){
            chart_handle.series[0].addPoint( data['data'][0]['data'][i], false, false );
            chart_handle.series[1].addPoint( data['data'][1]['data'][i], false, false );
          }
          handle.attr('data-last-point', data['last_id']);
        });

      }); // handle.find('#load-older').click( function(){

      //dump eveyrthing into the graph (this can take a while)
      handle.find('#dump-everything').click( function(){
        var data_load_path = '/licservers/' + handle.attr('data-licserver') + '/features/' +
          handle.attr('data-feature') + '/data_dump';
        chart_handle = handle.find('.graph').highcharts();

        $.ajax(data_load_path, {
          dataType:'json',
          beforeSend: function(){
            handle.find('#load-older').remove();
            handle.find('#dump-everything').attr('disabled', 'disabled');
            chart_handle.showLoading();
          },
          complete: function(){
            //chart_handle.redraw();
            chart_handle.hideLoading();
            handle.find('#dump-everything').remove();
          }
        }).done( function(data, textStatus, jqXHR){
          chart_handle.series[0].setData(data['data'][0]['data'], true);
          chart_handle.series[1].setData(data['data'][1]['data'], true);
        });
      }); // handle.find('#dump-everything').click( function(){
    }; // locals.load_daily_graph = function( handle){


		//load monthly histrogram into a handle
    locals.load_monthly_histogram = function( handle ) {
      handle.highcharts({
        title: { text:'Last 30 days Frequency Histogram' },
        subtitle: { text:'Middle on left axis is the median, graph is zoomable' },
        chart: {
          events:{
            load: function(){
              //console.log('lazy load monthly chart');
              var chart_handle = this;
              load_path = '/licservers/' + handle.attr('data-licserver') + '/features/' + handle.attr('data-feature') +
                '/monthly';
              $.get( load_path, { office_hours:'yes' }, function(data, textStatus, jqXHR){
                for(i=0; i < data.length; i++){
                  chart_handle.series[0].addPoint( data[i], false, false);
                };
                chart_handle.redraw();
              }, 'json' );
              $.get( load_path, null , function(data, textStatus, jqXHR){
                for(i=0; i < data.length; i++){
                  chart_handle.series[1].addPoint( data[i], false, false);
                };
                chart_handle.redraw();
              }, 'json' );
            }
          },  // events:{
          type: 'spline',
          zoomType: 'x'
        },
        series: [
          { name:'Office Hours', data:[] },
          { name:'All Hours', data:[] }

        ]
      });
    }; // locals.load_monthly_histogram = function( handle ) {


		//populate a local table and will up w/ user listings
		//handle structure
		//<handle data-licserver=.. data-feature=..
    locals.load_users = function(handle){
      //load the table

			function load_users_table(handle){
				load_path = '/licservers/' + handle.attr('data-licserver') + '/features/' + handle.attr('data-feature') +
					'/users';
				$.get( load_path, null, function( data, textStatus, jqXHR) {
					handle.find('tbody').empty();
					handle.find('tbody').append(data).ready( function(){
						//error handing w/
						handle.find('.kill_user').bind('ajax:error', function(event , xhr, status, error){
							alert('must sign in to kill');
						});
					});
					$('#user-list-last-update').empty().append(
						$.parseHTML('Updated: ' + (new Date( $.now()).toLocaleString() ) )
					);
          $('#user-count').empty().append(
              handle.find('tbody').find('tr').length + ' User(s)'
          )
				}, 'html' );
			};

      //refresh user listings
      handle.find('#reload-users').click(function(){
        handle.find('tbody').empty().append(
          $.parseHTML('<tr><td class="loading-users" colspan=2><i class="fa fa-cog fa-spin fa-4x"></i></td></tr>')
        ).ready( function(){
          load_users_table( handle );
        });
      });

			//now load the init table
			load_users_table(handle);
    };

		//nuke users from the table listing
		locals.nuke_users = function(handle){
			handle.closest('#user-listings').find('#nuke-users').removeAttr('disabled');

			//configure on click
			handle.on('click', function(){
				console.log('nukem button pressed')

				var modal_handle = handle.closest('.modal');
				var confirmation_handle = modal_handle.find('#nuke-confirmation-box');
				var nuke_alert_box = modal_handle.find('.nuke-alert-box');

				if ( confirmation_handle.val() == handle.attr('data-feature')){
					console.log('correct answer');

					//start nuking users
					handle.closest('.tab-content').find('.kill-user').each( function(index){
						$(this).click();
					});

					//reset the form and hide
					confirmation_handle.val('');
					modal_handle.modal('hide');
					nuke_alert_box.html('Nuking users of ' + handle.attr('data-feature') + '...');
				} else {
					console.log('incorrect answer');
					confirmation_handle.val('');
					nuke_alert_box.html('Wrong Answer');
				}

			});
		};

  // Remove this line if you don't want to inherit locals defined
  // on parent's _locals.js
  Paloma.inheritLocals({from : '/', to : 'features'});
})();
