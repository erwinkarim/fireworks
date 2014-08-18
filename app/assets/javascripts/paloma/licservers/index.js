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
  var _l = _L['licservers'];


  Paloma.callbacks['licservers']['index'] = function(params){
    // Do something here.
    $(document).ready( function(){

			//load more servers
			load_more_servers = function(target, mode){
				var last_id = null; 
				if($(target).children().length == 0){
					last_id = null;
				} else {
					last_id = { last_id:$(target).attr('last') }; 
				}

				var load_path = '';
				if(mode == 'search'){
					load_path = '/licservers/search';
				} else {
					load_path = '/licservers/get_more';
				}

				//load the spinner in the target
				$(target).append(
					$.parseHTML('<div class="spin"><i class="fa fa-cog fa-spin fa-4x"></i></div>')
				);
				$.get(load_path, last_id, function( data, textStatus, jqXHR){
					$(target).append(
						$.parseHTML(data)
					).ready( function(){
						//update the target list
						$(target).attr('last', $(target).children('.accordion-group').last().attr('data-id') );

						//unload the spinner
						$(target).find('.spin').remove();

						//setup the accordion so it'd will dynamically load the server info when shown
						$(target).find('.accordion-group[data-init="false"]').each( function(index, value){
							setup_accordion($(this));
						});
						
					});
				}, 'html');
			};

			//setup accordion
			var setup_accordion = function(handle){
				handle.on('shown', function(){
					if(handle.find('.info').children().length == 0){	
						//add spinner
						handle.find('.info').append( 
							$.parseHTML('<div class="spin"><i class="fa fa-cog fa-spin fa-2x"></i></div>')
						);

						//load server info
						$.get('/licservers/' + handle.attr('data-id') + '/info', null, function(data, textStatus, jqXHR){
							handle.find('.info').append(data);

							//remove spinner
							handle.find('.spin').remove();
						}, 'html').done(
						);	

					}

				});
				handle.attr('data-init', 'true');
				
			};
			
      //search servers
      $('#search-servers').typeahead({
        source: function(query, process){
          return $.get( '/licservers/search', {
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

          if($(this).val().length != 0){
            //reload the accordion and put the revelent people
            $.ajax( '/licservers/search', {
              data: { query:$(this).val() },
              dataType:'html'
            }).done( function(data,textStatus, jqXHR){
              $('#server-listings').empty();
              $('#server-listings').append(
                $.parseHTML(data)
              ).ready( function(){
                $('.accordion-group[data-init="false"]').each( function(index) {
									setup_accordion($(this));
                });
              });

            }); // $.ajax( '/licserver/serach', {
          } else {
            $('#load-more-servers').attr('data-mode', 'default');
            $('#server-listings').empty();
						load_more_servers('#server-listings', $('#load-more-servers').attr('data-mode') );
          } // if($(this).val().length != 0){
        }
      });

			//#########################################################
			//# do the work starts here
			//#########################################################
			//load the servers
			load_more_servers('#server-listings', $('#load-more-servers').attr('data-mode') );
		}); // $(document).ready( function(){
  }; // Paloma.callbacks['licservers']['index'] = function(params){
})();
