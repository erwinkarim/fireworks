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
  var _l = _L['users'];


  Paloma.callbacks['users']['index'] = function(params){
    //setup features accordion body
    setup_features_accordion_body = function(handle){
      console.log('called setup_features_accordion_body');
      handle.find('a[data-toggle="tab"]').on('shown', function(e){
        console.log(e.target); 
      });
    }; // setup_feaures_accordion_body = function(handle){

    //setup accordion body
    setup_accordion_body = function( handle) {
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

    //init load
    init_load = function(){
      //init load
      $.ajax( '/users/get_more', {
        dataType:'html'
      }).done( function(data, textStatus, jqXHR){
        $('#user-listings').append(
          $.parseHTML(data)
        ).ready( function(){
          $('.accordion-group[data-init=false]').each( function(index) {
            setup_accordion_body($(this));
          });
          
          //update the add more users button
          $('#load-more-users').attr('data-last-userid', $('#user-listings .accordion-group:last').attr('data-id') );
        });
  
      }); // $.ajax( '/users/get_more', {
    } 
    // Do something here.
    $(document).ready( function(){
      Highcharts.setOptions({
          global: { useUTC: false }
      });
  
      init_load();

      //when load more users button clicked
      $('#load-more-users').click( function(){
        console.log('load more users');

        //load more users
        $.ajax( '/users/get_more', {
          dataType:'html',
          data: { start_id:$(this).attr('data-last-userid')}
        }).done( function(data, textStatus, jqXHR){
          $('#user-listings').append(
            $.parseHTML(data)
          ).ready( function(){
            $('.accordion-group[data-init=false]').each( function(index) {
              setup_accordion_body($(this));
            });
            
            //update the add more users button
            $('#load-more-users').attr('data-last-userid', $('#user-listings .accordion-group:last').attr('data-id') );
          });
    
        }); // $.ajax( '/users/get_more', {

      }); // $('#load-more-users').click( function(){

      //search users
      $('#search-users').typeahead({
        source: function(query, process){
          return $.get( '/users/search/', {
            query:query
          }, function(data){
            return process(data.options);
          }, 'json');
        }
      }).bind('keypress', function(e){
        var code = e.keyCode || e.which;
        if(code==13){ //Enter keycode
          //prevent from reloading the page
          e.preventDefault();

          //if empty, load from strach, otherwise fetch the users which matches the search value
          console.log('search for ' + $(this).val() );

          if($(this).val().length != 0){
            //reload the accordion and put the revelent people
            $.ajax( '/users/search', {
              data: { query:$(this).val() },
              dataType:'html'
            }).done( function(data,textStatus, jqXHR){
              $('#user-listings').empty();
              $('#user-listings').append(
                $.parseHTML(data)
              ).ready( function(){
                $('.accordion-group[data-init=false]').each( function(index) {
                  setup_accordion_body($(this));
                });
              });
            }); // $.ajax( '/users/serach', {
          } else {
            $('#user-listings').empty();
            init_load();
          } // if($(this).val().length != 0){
        }
      });

    }); // $(document).ready( function(){
  }; // Paloma.callbacks['users']['index'] = function(params){
})();
