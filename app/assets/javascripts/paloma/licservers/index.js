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
				//load server info when accordion is clicked
				handle.on('shown', function(){
					if(handle.find('.info').children().length == 0){	
						//add spinner
						handle.find('.info').append( 
							$.parseHTML('<div class="spin"><i class="fa fa-cog fa-spin fa-2x"></i></div>')
						);

						//load server info and setup the buttons
						$.get('/licservers/' + handle.attr('data-id') + '/info', null, function(data, textStatus, jqXHR){
							handle.find('.info').append(data).ready( function(){

								//when the licserver modal has been clicked
								$('.update-licserver').click(function(){
									var handle = $('#licserver-modal-' + $(this).attr('data-id') );


									//check if this is new or editing a current one
									//update of a current server
									var input_port;
									var input_server;
									if( handle.find('#server_info').val().indexOf('@') == -1){
										input_port = '';
										input_server = handle.find('#server_info').val();	
									} else {
										input_port = handle.find('#server_info').val().split('@')[0]
										input_server = handle.find('#server_info').val().split('@')[1]
									}

									$.ajax( '/licservers/' + handle.find('#server_id').val(), {
										data: { 
											licserver:{ port:input_port, server:input_server, 
												monitor_idle:handle.find('#monitor_idle').attr('checked')=='checked' },
											tags:handle.find('#tags').val()
										},
										type:'PUT',
										dataType: 'json'
									}).done( function(data, textStatus, jqXHR){

										//update the accordion
										var accordion_handle = $('.accordion-group[data-id="' + handle.find('#server_id').val() + '"]');
										accordion_handle.find('.accordion-toggle').text( handle.find('#server_info').val() );
										$.get('/licservers/' + handle.find('#server_id').val() + '/info', null, function(data, textStatus, jqXHR){ 
											accordion_handle.find('.info').replaceWith(data);
										}, 'html');

										//dismiss the modal
										handle.modal('hide');
									}); // $.ajax( '/licservers/' + handle.find('#server_id').val(), 
								}); // $('.update-licserver').click(function(){
							});

							//remove spinner
							handle.find('.spin').remove();

						}, 'html').fail( function(){
							//error handling
							handle.find('.info').append( $.parseHTML('<div>Opss... something when wrong</div>') );
							handle.find('.spin').remove();
						});	
						// $.get('/licservers/' + handle.attr('data-id') + '/info', null, function(data, textStatus, jqXHR){

					}

				}); // handle.on('shown', function(){

				handle.attr('data-init', 'true');
				
			}; // var setup_accordion = function(handle){
			
      //search servers as you type
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

			//clear the dialog box
			$('#new-licserver-modal').on('shown', function(){
				$(this).find('#server_info').val('');
				$(this).find('.status').empty();
			});

			//create new licserver 
			$('#new-licserver-btn').click( function(){
				var handle = $('#new-licserver-modal');

				handle.find('.status').empty().append(
					$.parseHTML('<i class="fa fa-cog fa-spin"></i> Adding server...')
				);
				
				$.post('/licservers', { lic:handle.find('#server_info').val() }, function(data, textStatus, jqXHR){
					//create a new accordion and append the info
					$('#server-listings').append(data).ready( function(){
						//setup the accordion so it'd will dynamically load the server info when shown
						$('#server-listings').find('.accordion-group[data-init="false"]').each( function(index, value){
							setup_accordion($(this));
						});
						handle.modal('hide');
					});
				}, 'html').fail( function(){
					handle.find('.status').empty().append(
						$.parseHTML('Error adding server')
					);
				});
			});

			//#########################################################
			//# do the work starts here
			//#########################################################
			//load the servers
			load_more_servers('#server-listings', $('#load-more-servers').attr('data-mode') );
			
		}); // $(document).ready( function(){
  }; // Paloma.callbacks['licservers']['index'] = function(params){
})();
