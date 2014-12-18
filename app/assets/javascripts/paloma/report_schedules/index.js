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
  var _l = _L['report_schedules'];


  Paloma.callbacks['report_schedules']['index'] = function(params){
		
		//setup the accordion, new schedule and cancel button when the document is fully loaded
    $(document).ready( function(){
			//load accordion contents when shown
			$('#schedule-accordion').find('a[data-toggle=collapse]').each( function(index){
				var link_handle = $(this);
				var accordion_body = $( link_handle.attr('href') );
				accordion_body.on('shown.bs.collapse', function(){
					if(link_handle.attr('data-setup') == 'false') {
						$.get('/report_schedules/' + link_handle.attr('data-report-schedule') + '.template', { delete_enabled:'true' } , function(data, textStatus, jqXHR){
							accordion_body.find('.panel-body').append(data).ready( function(){
								_l.setup_report_tab(accordion_body.find('.tabbable'));
								accordion_body.find('.loading-report').remove();
							});
						});
						link_handle.attr('data-setup', 'true');
					}
				});
			});

			//setup the new schedule
			_l.setup_report_tab( $('#new-schedule-modal').find('.tabbable') );

			//configure create new report scheduke
			$(document).find('.new-schedule-button').click( function(){
				console.log('create new schedule clicked');

				var handle = $('#new-schedule-modal');
				var form_handle = handle.find('.schedule-form');

				//create new schedule as template and get the results and add it as a new panel
				$.post( '/report_schedules.template', form_handle.serialize(), function(data, textStatus, jqXHR){
					console.log('new report created');
					form_handle.trigger('reset');
					handle.find('.new-schedule-button').attr('disabled', 'disabled');
	
					$('#new-schedule-group').before(data).ready( function(){
						_l.setup_report_tab( $(this) );	
					});

					handle.modal('hide');

				}, 'html');
			});

    }); // $(document).ready( function(){
  }; // Paloma.callbacks['report_schedule']['index'] = function(params){
})();
