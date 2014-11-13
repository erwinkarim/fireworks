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
    // Do something here.
    $(document).ready( function(){
      //console.log('features/show loaded');

      Highcharts.setOptions({
        global: { useUTC:false }
      });

      //load the daily graph
      _l.load_daily_graph( $('.daily-graph:first') );
      _l.load_monthly_histogram( $('.monthly-graph:first') );
      _l.load_users( $('#user-listings') );


      $('#watchlist').on('ajax:success', function(data, status, xhr){
        //toggle the star
        $(this).find('.fa').toggleClass('fa-star-o').toggleClass('fa-star');
      });

    });
  }; // Paloma.callbacks['features']['show'] = function(params){
})();
