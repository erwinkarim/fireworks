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
					handle.parent().find('#monitored_licserver_:first').empty().append(data); 
				},
				'html' 
			);
		});
	};

	//in licserver to be monitored listing, delete the one that is being clicked.
	//if there's only 1 left, disable delete button to prevent it from monitoring and empty list
	var delete_licserver = function(handle){
		var licserver_listing_handle = handle.closest('.licserver-listing');
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
			var licserver_listing_handle = $(this).closest('.licserver-listing');
	
			//generate new listings from website
			$.get( '/report_schedules/gen_monitored_obj_listings', function(data){
					licserver_listing_handle.find('.licserver:last').after(data).ready( function(){
						//ensure that all minus is enabled and works
						licserver_listing_handle.find('.licserver').each(function(index, e){
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

		//when submiting the form, do sanity checks
		handle.find('.schedule-form').on('ajax:before', function(){
			if( $(this).find('#schedule-title-input').val() == '') {
				//highlight title
				$(this).find('#schedule-title-group').addClass('error');
				return false;
			}
		}).on('ajax:success', function(e, data, textStatus, jqXHR){

			//if the new report schedule is open, close it
			//reset the form and hide it
			if( $('#new_report_schedule').length > 0 ) {
				$('#new_report_schedule')[0].reset();
				$('#new-schedule-group').hide();
				$('#new-schedule-btn').show();
			};


			//update or recreate new accordion-group
			var accordion_id = data.id
			if( data.id != null && $('.accordion-group[data-id=' + data.id + ']').length == 0){
				//group does not exist and data.id is valid, create a new one!
				$.ajax('/report_schedules/' + data.id + '/accordion', {
					dataType:'html'
				}).done( function(data, statusText, jqXHR){
					$('#new-schedule-group').before(
						$.parseHTML(data)
					).ready( function(){
						setup_accordion_body( $('.accordion-group[data-id=' + accordion_id + ']') );
					})
				});
			} else {
				//group exists, update it
				var accord_handle = $('.accordion-group[data-id=' + data.id + ']');
				accord_handle.find('.accordion-toggle').text(data.title);
			}

		}).on('ajax:error', function(xhr, status, error){
			//if got error (usually the title uniqueness) highlight the error and move on
		});
	}; // locals.setup_report_tab = function(handle){


  // Remove this line if you don't want to inherit locals defined
  // on parent's _locals.js
  Paloma.inheritLocals({from : '/', to : 'report_schedules'});
})();
