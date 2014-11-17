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
  var _l = _L['watch_lists'];


  Paloma.callbacks['watch_lists']['index'] = function(params){
    // Do something here.
    $(document).ready( function(){
      console.log('watch_lists/index loaded');
      $.get(document.location.pathname + '.template', null, function(data,textStatus, jqXHR){
        $("#watch-list").append(data).ready( function(){
          //load the contents when shown
          $('#watch-list').find('.accordion-body').each( function(index){
            $(this).on('shown', function(){
              if( $(this).attr('data-init') == 'false') {
                var handle = $(this);
                $.get(document.location.pathname + '/' + $(this).attr('data-id') + '.template' , null, function(data,textStatus, jqXHR){
                  handle.find('.accordion-inner').append(data).ready(function(){
										//load the data from watchlist/watch_list.id/show.template and execute the appropiate javascript
										//kinda works, but because you might get multiple types, it only load for the first loaded item of the same type
										if(handle.attr('data-model-type') == 'FeatureHeader'){
											console.log('load FeatureHeader scripts');
											_L.features.load_daily_graph( handle.find('.daily-graph') );
											_L.features.load_monthly_histogram( handle.find('.monthly-graph') );
											_L.features.load_users( handle.find('#user-listings') );
										} else if (handle.attr('data-model-type') == 'Licserver'){
											console.log('load Licserver scripts');
										} else if (handle.attr('data-model-type') == 'User'){
											console.log('load User scripts');
											_L.users.setup_accordion_body( handle.find('.user-machines')  );
										} else if (handle.attr('data-model-type') == 'Tag'){
											console.log('load Tag scripts');
											Paloma.callbacks['tags']['show']();
										};
									});
                });
                $(this).attr('data-init', 'true');
              }
            });
          });
        });
        $('#watch-list').find('.loading').hide();
      });
    }); // $(document).ready( function(){
  };
})();
