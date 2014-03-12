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
    //setup accordion body
  locals.setup_accordion_body = function( handle) {
    handle.find('a[data-toggle="tab"]').on('shown', function(e){
      //when clicked, start gather features data
      $('.tab-pane[data-machine-id="' + e.target.attributes['data-machine-id'].value + 
        '"][data-user-id="' + e.target.attributes['data-user-id'].value + '"]').append(
        $.parseHTML('<i class="fa fa-spinner fa-spin fa-4x"></i>')
      );

      //show the thing is being loaded

      var data_load_path = '/users/' + e.target.attributes['data-user-id'].value + 
        '/machines/' + e.target.attributes['data-machine-id'].value + '/gen_features';

      //load the chart
      $.ajax( data_load_path, {
        dataType:'json'
      }).done( function(data, textStatus, jqXHR){
        $('.tab-pane[data-machine-id="' + e.target.attributes['data-machine-id'].value + 
          '"][data-user-id="' + e.target.attributes['data-user-id'].value + '"]').highcharts('StockChart', {
          //setup the chart
          title: { text: 'Features usage by the user on machine' },
          chart: {
            events : {
              load: function(){
                var chart_handle = this;
                function recursive_data_load(last_data_point){
                  //only call ajax if there's more data to load in the graph
                  if(last_data_point != 0){
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
                      recursive_data_load(data['last_data_point']);
                    });
                  }
                };
  
                recursive_data_load(data['last_data_point']);
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
      }); // $.ajax( 

      //remove the spinner
    }); // handle.find('a[data-toggle="tab"]').on('shown', function(e){
    handle.removeAttr('data-init');
  }; // setup_accordion_body = function( handle) {


  // Remove this line if you don't want to inherit locals defined
  // on parent's _locals.js
  Paloma.inheritLocals({from : '/', to : 'users'});
})();
