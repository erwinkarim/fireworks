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

      //load the chart
      $.ajax( 
        '/users/' + e.target.attributes['data-user-id'].value + 
        '/machines/' + e.target.attributes['data-machine-id'].value + '/gen_features', {
        dataType:'json'
      }).done( function(data, textStatus, jqXHR){
        console.log(data);
        $('.tab-pane[data-machine-id="' + e.target.attributes['data-machine-id'].value + 
          '"][data-user-id="' + e.target.attributes['data-user-id'].value + '"]').highcharts('StockChart', {
          //setup the chart
          title: { text: 'Features usage by the user on machine' },
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
          series: data
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
