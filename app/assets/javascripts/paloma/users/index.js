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

    //init load
    init_load = function(){
      //init load
      $.ajax( '/users/get_more', {
        dataType:'html'
      }).done( function(data, textStatus, jqXHR){
        $('#user-listings').append(
          $.parseHTML(data)
        ).ready( function(){
          $('.panel[data-init=false]').each( function(index) {
            _l.setup_accordion_body($(this));
          });
          
          //update the add more users button
          $('#load-more-users').attr('data-last-userid', $('#user-listings .panel:last').attr('data-id') );
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

        //load da spinner
        $('#user-listings').append(
          $.parseHTML('<i class="fa fa-spinner fa-spin fa-4x"></i>')
        );

        //check in which mode that this button is loading
        if( $(this).attr('data-mode') == 'search') {
          var load_path = '/users/search';
          var data_header = { start_id:$(this).attr('data-last-userid'), query:$('#search-users').val() }
        } else {
          var load_path = '/users/get_more';
          var data_header = { start_id:$(this).attr('data-last-userid')}
        }
        //load more users
        $.ajax( load_path, {
          dataType:'html',
          data: data_header
        }).done( function(data, textStatus, jqXHR){
          $('#user-listings').append(
            $.parseHTML(data)
          ).ready( function(){
            $('.panel[data-init=false]').each( function(index) {
              _l.setup_accordion_body($(this));
            });
            
            //update the add more users button
            $('#load-more-users').attr('data-last-userid', $('#user-listings .panel:last').attr('data-id') );

            //remove the spinner
            $('#user-listings').find('.fa-spinner').remove();
          });
    
        }); // $.ajax( '/users/get_more', {

      }); // $('#load-more-users').click( function(){

      //search users
      $('#search-users').typeahead({
        source: function(query, process){
          return $.get( '/users/search/', {
            query:query
          }, function(data, textStatus, jqXHR){
            //load the results while you type here before returning the data 
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
                $('.panel[data-init=false]').each( function(index) {
                  _l.setup_accordion_body($(this));
                });
              });
              $('#load-more-users').attr('data-mode', 'search');
            }); // $.ajax( '/users/serach', {
          } else {
            $('#user-listings').empty();
            init_load();
            $('#load-more-users').attr('data-mode', 'default');
          } // if($(this).val().length != 0){
        }
      });

    }); // $(document).ready( function(){
  }; // Paloma.callbacks['users']['index'] = function(params){
})();
