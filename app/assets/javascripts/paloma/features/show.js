(function(){
  // You access variables from before/around filters from _x object.
  // You can also share variables to after/around filters through _x object.
  var _x = Paloma.variableContainer;

  // We are using _L as an alias for the locals container.
  // Use either of the two to access locals from other scopes.
  //
  // Example:
  // _L.otherController.localVariable = 100;
  var _L = Paloma.locals;

  // Access locals for the current scope through the _l object.
  //
  // Example:
  // _l.localMethod(); 
  var _l = _L['features'];

  Paloma.callbacks['features']['show'] = function(params){
    function load_daily_graph( handle){
      handle.highcharts('StockChart', {
        title: { text: handle.attr('data-feature') + ' Daily Usage' },
        chart: {
          events:{
            load: function(){
              console.log('lazy load daily data');
              var chart_handle = this;
              var data_load_path = '/licservers/' + handle.attr('data-licserver') + '/features/' + 
                handle.attr('data-feature') + '/get_data';
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
                    $('#load-older').removeAttr('disabled');
                    $('#dump-everything').removeAttr('disabled');
                    $('.daily-graph').attr('data-last-point', data['last_id']);
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
          { name:'current', data:[ ] },
          { name:'max' , data:[ ]}
        ],
        plotOptions: {
        }
      }); // handle.highcharts('StockChart', {
    };

    function load_monthly_histogram( handle ) {
      handle.highcharts({
        title: { text:'Last 30 days Frequency Histogram' },
        subtitle: { text:'Middle on left axis is the median, graph is zoomable' },
        chart: {
          events:{
            load: function(){
              console.log('lazy load monthly chart');
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
    };

    function load_users(handle){
      //load the table
      load_path = '/licservers/' + handle.attr('data-licserver') + '/features/' + handle.attr('data-feature') +
        '/users';
      $.get( load_path, null, function( data, textStatus, jqXHR) {
        handle.find('tbody').empty();
        handle.find('tbody').append(data);
      }, 'html' ); 
    };

    // Do something here.
    $(document).ready( function(){
      console.log('features/show loaded');

      //load the daily graph
      load_daily_graph( $('.daily-graph:first') );
      load_monthly_histogram( $('.monthly-graph:first') );
      load_users( $('#user-listings') );

      //refresh user listings
      $('#reload-users').click(function(){
        $('#user-listings').find('tbody').empty().append(
          $.parseHTML('<tr><td class="loading-users" colspan=2><i class="fa fa-spinner fa-spin fa-4x"></i></td></tr>')
        ).ready( function(){
          load_users( $('#user-listings') );
        });
      });

      //load more data into the graph
      $('#load-older').click( function(){

        var data_load_path = '/licservers/' + $('.daily-graph').attr('data-licserver') + '/features/' + 
          $('.daily-graph').attr('data-feature') + '/get_data';
        chart_handle = $('.daily-graph').highcharts();

        $.ajax(data_load_path, { 
          data: {start_id:$('.daily-graph').attr('data-last-point') },
          dataType:'json', 
          beforeSend: function(){
            $('#load-older').attr('disabled', 'disabled');
            $('#dump-everything').attr('disabled', 'disabled');
            chart_handle.showLoading();
          },
          complete: function(){
            chart_handle.redraw();
            chart_handle.hideLoading();
            $('#load-older').removeAttr('disabled');
            $('#dump-everything').removeAttr('disabled');
          }
        }).done( function(data, textStatus, jqXHR){
          for(i=0; i < data['data'][0]['data'].length; i++){
            chart_handle.series[0].addPoint( data['data'][0]['data'][i], false, false );
            chart_handle.series[1].addPoint( data['data'][1]['data'][i], false, false );
          }
          $('.daily-graph').attr('data-last-point', data['last_id']);
        });
      
      });

      //dump eveyrthing into the graph (this can take a while)
      $('#dump-everything').click( function(){
        var data_load_path = '/licservers/' + $('.daily-graph').attr('data-licserver') + '/features/' + 
          $('.daily-graph').attr('data-feature') + '/data_dump';
        chart_handle = $('.daily-graph').highcharts();

        $.ajax(data_load_path, {
          dataType:'json',
          beforeSend: function(){
            $('#load-older').remove();
            $('#dump-everything').attr('disabled', 'disabled');
            chart_handle.showLoading();
          },
          complete: function(){
            //chart_handle.redraw();
            chart_handle.hideLoading();
            $('#dump-everything').remove();
          }
        }).done( function(data, textStatus, jqXHR){
          chart_handle.series[0].setData(data['data'][0]['data'], true);
          chart_handle.series[1].setData(data['data'][1]['data'], true);
        }); 
      });

    });
  }; // Paloma.callbacks['features']['show'] = function(params){
})();
