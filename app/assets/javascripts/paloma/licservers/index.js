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
			load_more_servers = function(target){
				var last_id = null; 
				if($(target).children().length == 0){
					last_id = null;
				} else {
					last_id = { last_id:$(target).attr('last') }; 
				}

				//load the spinner in the target
				$(target).append(
					$.parseHTML('<div class="spin"><i class="fa fa-cog fa-spin fa-4x"></i></div>')
				);
				$.get('/licservers/get_more', last_id, function( data, textStatus, jqXHR){
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
				console.log(handle);
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

			console.log('loaded licserver/index.js');

			//load the init batch of servers
			load_more_servers('#server-listings');
			
			//action when 'Load More servers clicked'
			$('#load-more-servers').click( function(){
				console.log( 'load more servers'); 
				load_more_servers('#server-listings');
			});
		});
  }; // Paloma.callbacks['licservers']['index'] = function(params){
})();
