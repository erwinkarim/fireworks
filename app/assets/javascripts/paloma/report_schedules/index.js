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
				accordion_body.on('shown', function(){
					if(link_handle.attr('data-setup') == 'false') {
						$.get('/report_schedules/' + link_handle.attr('data-report-schedule') + '.template', { delete_enabled:'true' } , function(data, textStatus, jqXHR){
							accordion_body.find('.accordion-inner').append(data).ready( function(){
								_l.setup_report_tab(accordion_body.find('.tabbable'));
								accordion_body.find('.loading-report').remove();
							});
						});
						link_handle.attr('data-setup', 'true');
					}
				});
			});

      //adding new 
      $('#new-schedule-btn').click( function(){
        $('#new-schedule-group').show('slow').find('.accordion-toggle').click();
        $('#new-schedule-btn').hide();
        //reset the form before sending out
      });

      //cancle adding new schedule
      $('#new-schedule-cancel').click( function(){
        $('#new-schedule-group').hide('slow');
        $('#new-schedule-btn').show();
      });


    }); // $(document).ready( function(){
  }; // Paloma.callbacks['report_schedule']['index'] = function(params){
})();
