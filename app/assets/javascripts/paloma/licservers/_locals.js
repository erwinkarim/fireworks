(function(){
  // Initializes callbacks container for the this specific scope.
  Paloma.callbacks['licservers'] = {};

  // Initializes locals container for this specific scope.
  // Define a local by adding property to 'locals'.
  //
  // Example:
  // locals.localMethod = function(){};
  var locals = Paloma.locals['licservers'] = {};

  
  // ~> Start local definitions here and remove this line.
	
	//load licsrver/show.template into a handle
	//handle must have the following attributes
	//	data-licserver		licserver id
	//	data-tag
	locals.load_licserver = function(handle){
		//when the licserver is clicked, show licserver info and detected features
		$.get('/licservers/' + handle.attr('data-licserver') + '.template', null, 
			function(data, textStatus, jqXHR){
				if( handle.children().length == 0 ){
					handle.append( data).ready( function(){
						//load the featres listings
						$.get('/licservers/' + handle.attr('data-licserver') + '/features/list', null, 
							function(data, textStatus, jqXHR){
								handle.find('.fa-cog').remove();
								handle.find('#licserver-' + handle.attr('data-licserver') + '-features-listing').append(
									data
								).ready( function(){
									//when a feature is selected, show it's usage over time. lazy load the data
									$('.panel[data-init-features="false"]').each( function(index,value){
										Paloma.locals.tags.setup_features_accordion($(this));
									});


								});
							}, 'html' ).fail( function(){
								console.log('fail to load server');
								handle.find('licserver-' + handle.attr('data-licserver') + '-features').find('.fa-cog').remove();
								handle.find('#licserver-' + handle.attr('data-licserver') + '-features-listing').append(
									$.parseHTML('Opss, something went wrong. Failed to load feature listings')
								);
							}); //$.get('/licservers/' + e.target.attributes['data-licserver'].value + '/features/list', null, 
							
							//setup the update licserver button
							handle.find('.update-licserver').on('click', function(){
								console.log('update licserver clicked');
								var form_handle = handle.find('form');
								var status_handle = handle.find('.status')

								//sanity checks on the form
								if( form_handle.find('#server_info').val() == '' ){
									form_handle.find('.server-info-control').addClass('has-error');
									status_handle.text('Server port and IP can\'t be blank');
									return;
								};

								//everything ok, post the form
								status_handle.text(
									$.parseHTML('<i class="fa fa-cog fa-spin"></i> Submitting data...')
								);
								$.ajax( '/licservers/' + form_handle.attr('data-licserver')  , { 
									type:'PUT', data:form_handle.serialize(), 
									success: function(data, textStatus, jqXHR){
										console.log('form submited');

										//update handle
										handle.find('.licserver-title').text( form_handle.find('#server_info').val()  );

										//load tags
										$.get( '/licservers/' + form_handle.attr('data-licserver') + '/tags.template', null, function(data, textStatus, jqXHR){
											handle.find('.tags-well').empty().append( data );
										}, 'html');

										status_handle.text('');
										handle.find('.modal').modal('toggle');
									}, 
									error: function(jqXHR, textStatus, errorThrown){
										status_handle.text(textStatus + ": " + errorThrown);
									}
								});

							});
					});
				};

			}, 'html' );
	};



  // Remove this line if you don't want to inherit locals defined
  // on parent's _locals.js
  Paloma.inheritLocals({from : '/', to : 'licservers'});
})();
