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
                //load the data from watchlist/watch_list.id/show.template and execute the appropiate javascript
                var handle = $(this).find('.accordion-inner');
                $.get(document.location.pathname + '/' + $(this).attr('data-id') + '.template' , null, function(data,textStatus, jqXHR){
                  handle.append(data);
                });
                /*
                $(this).find('.accordion-inner').append(
                  $.parseHTML('load watch list item')
                );
                */
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
