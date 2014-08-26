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
  var _l = _L['tags'];


  Paloma.callbacks['tags']['index'] = function(params){

    //setup the accordion
    function setup_accordion( handle ){
      //when the accordion is shown, load the licserver
      handle.on('shown', function(){
        if(handle.find('.accordion-inner').children().length == 0 ) {
          $.get('/tags/' + $(this).attr('data-title') + '.template' , null, function(data, textStatus, jqXHR){
            handle.find('.accordion-inner').append(data).ready( function(){
              //when the licserver is clicked, show licserver info and detected features
              $('a[data-toggle="tab"][data-init="false"]').each( function(index, value){
								_l.setup_tab($(this));
                //setup_tab($(this));
              });

              
            });
          }, 'html' );
        }
      });
    };

    // Do something here.
    $(document).ready( function(){

      Highcharts.setOptions({
        global:{ 
          useUTC: false
        }
      });
    
      //init_load();
      //load all them tags
      $.get( '/tags/gen_accordion', null,
        function(data, textStatus, jqXHR){
          $('#tags-accordion').empty().append(data).ready( function(){
            //process the accordion
            $('.accordion-tag').each( function(index, value) {
              setup_accordion( $(this) );
            });
          }) 
        }, 'html'
      );

      //setup search query
      $('#search-tags').typeahead({
        source: function(query, process){
          return $.get('/tags/search/', { query:query }, function(data, textStatus, jqXHR){
            return process(data.options);
          }, 'json'); 
        } 
      }).bind('keypress', function(e){
        var code = e.keyCode || e.which;
        if(code==13){ //Enter keycode
          //prevent from reloading the page
          e.preventDefault();

          if( $(this).val().length != 0){
            //clear everything and return the one's with 
            $.get('/tags/search', { query:$(this).val() }, function(data, textStatus, jqXHR){
              $('#tags-accordion').empty();
              $('#tags-accordion').append(data).ready(function(){
                $('.accordion-tag').each( function(index,value){
                  setup_accordion( $(this) );
                });
              });
            }, 'html' );
          }else{
            //reset the page
            $('#tags-accordion').empty();
            init_load();
          };
        };
      });
    });
  }; // Paloma.callbacks['tags']['index'] = function(params){
})();
