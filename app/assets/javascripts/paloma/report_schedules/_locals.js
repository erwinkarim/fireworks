(function(){
  // Initializes callbacks container for the this specific scope.
  Paloma.callbacks['report_schedules'] = {};

  // Initializes locals container for this specific scope.
  // Define a local by adding property to 'locals'.
  //
  // Example:
  // locals.localMethod = function(){};
  var locals = Paloma.locals['report_schedules'] = {};

  
  // ~> Start local definitions here and remove this line.
	//handle changes in monitored object dropdown selection. handle changes when the category changes
	var setup_monitored_obj_dropdown = function(handle){
		//the handle is the category object
		handle.bind('change',  function(){
			//update the licserver listing nearest to this object
			$.get( '/tags/' + $(this).val() + '/gen_licservers', 
				null,
				function(data, textStatus, jqXHR){
					handle.closest('.licserver').find('#monitored_licserver_:first').empty().append(data); 
				},
				'html' 
			);
		});
	};

	//in licserver to be monitored listing, delete the one that is being clicked.
	//if there's only 1 left, disable delete button to prevent it from monitoring and empty list
	var delete_licserver = function(handle){
		//var licserver_listing_handle = handle.closest('.licserver-listing');
		var licserver_listing_handle = handle.closest('.setting');
		$.when(handle.closest('.licserver').remove()).then( function(){
			if(licserver_listing_handle.find('.licserver').length == 1){
				licserver_listing_handle.find('.delete-licserver:first').attr('disabled', 'disabled');
			}
		});
	};
	
	// setup report schedule tabs
	// call this on the page after using ajax to get /report_schedules/<report_schedule_id>/show.template
	locals.setup_report_tab = function(handle){
		console.log('setup report tab');

		//setup tool tip
		handle.find('.scheduled-tooltip').tooltip();

		//configure generate new report
		handle.find('.generate-report').click( function(){
			// TODO: this is problem matic
			$.ajax( '/report_schedules/' + $(this).attr('data-id') + '/reports', {
				type:'POST', 
				dataType:'json'
			}).done(function(data, statusText,jqXHR){
				handle.find('tbody').append(
					$('<tr/>').append(
						$('<td/>', { colspan:5, text:'Generate request sent' })
					)
				)
			});
		});

		//configure refresh-report listing
		handle.find('.refresh-report').click( function(){
			//refresh the report listing
			console.log('report listing refresh called');
			var accordion_handle = $(this).closest('.tabbable');
			$(this).find('.fa-refresh').addClass('fa-spin');
			$.ajax(
				'/report_schedules/' + accordion_handle.attr('data-id') + '/reports', {
				dataType:'html'
			}).done(function (data,statusText, jqXHR){
				//clean and repopulate the table
				accordion_handle.find('tbody').empty();
				accordion_handle.find('tbody').append( data);
			})
			$(this).find('.fa-refresh').removeClass('fa-spin');
		});

		//configure change action on monitored obj category dropdown
		handle.find('.monitored_cat').each( function(index) {
			setup_monitored_obj_dropdown( $(this) );
		});

		//configure add new licservers to monitor 
		handle.find('.add-licserver').click(function(){
			var licserver_listing_handle = $(this).closest('.setting').find('.licserver-listing');
	
			//generate new listings from website
			$.get( '/report_schedules/gen_monitored_obj_listings', function(data){
					//licserver_listing_handle.find('.licserver:last').after(data).ready( function(){
					licserver_listing_handle.before(data).ready( function(){
						//ensure that all minus is enabled and works
						licserver_listing_handle.closest('.setting').find('.licserver').each(function(index, e){
							$(this).find('.delete-licserver').removeAttr('disabled');
						});

						$(this).find('.delete-licserver').click( function(){
							delete_licserver($(this));
						});

						//ensure that the dropdown action of the category works
						$(this).find('.monitored_cat').each( function(index) {
							setup_monitored_obj_dropdown( $(this) );
						});
					})
				}, null, 
				'html'
			); // $.get( '/report_schedules/gen_monitored_obj_listings', function(data){
		}); // hoandle.find('.add-licserver').click(function(){

		//configure schedule title text field. ensure that i
		handle.find('.schedule-title-input').keyup( function(){
			if( $(this).val() == '' ) {
				handle.closest('.modal').find('.new-schedule-button').attr('disabled', 'disabled');
				handle.find('.update-schedule-button').attr('disabled', 'disabled');
			} else {
				//it's move to a modal now
				handle.closest('.modal').find('.new-schedule-button').removeAttr('disabled');
				handle.find('.update-schedule-button').removeAttr('disabled');
			}
		});

		//handle update schedule button
		handle.find('.update-schedule-button').click( function(){
			var panel_handle = $(this).closest('.panel');
			var form_handle = panel_handle.find('.schedule-form');

			console.log('update schedule clicked');
			$.ajax( '/report_schedules/' + $(this).attr('data-id') + '.template', {
					type: 'PUT',
					data: form_handle.serialize(),
					success: function( data, textStatus, jqXHR){
						//update the panel
						console.log('panel_handle ' + panel_handle.attr('data-id') );
						console.log('schedule-title-input: ' + form_handle.find('.schedule-title-input').val() );
						panel_handle.find('.schedule-title').text( form_handle.find('.schedule-title-input').val() );
						$(document).find('.flash-msg').append(data);
					}
			});
		});

		handle.find('.delete-schedule-button').click( function(){
			panel_handle = $(this).closest('.panel');
			$.ajax('/report_schedules/' + $(this).attr('data-id'), {
					type: 'DELETE',
					success: function( data, textStatus, jqXHR){
						panel_handle.fadeOut();
					}
			});
		});
	}; // locals.setup_report_tab = function(handle){


  // Remove this line if you don't want to inherit locals defined
  // on parent's _locals.js
  Paloma.inheritLocals({from : '/', to : 'report_schedules'});
})();
