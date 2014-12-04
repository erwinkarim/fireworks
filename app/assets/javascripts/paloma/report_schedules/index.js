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
    // Do something here.
    //

    //setup the accordion body as it get loaded
    // ab_handle must be class .accordion-body created by _schedule_accordion_group template
    var setup_accordion_body = function(ab_handle){
      var rs_id = ab_handle.attr('data-id');

      //handle the accordion
      ab_handle.on('show', function(){
        //if report table contents empty, refresh
        //setup tooltip for
        ab_handle.find('.scheduled-tooltip').tooltip();

      }); // ab_handle.on('show', function(){

      //when submiting the form, do sanity checks
      ab_handle.find('.schedule-form').on('ajax:before', function(){
        if( $(this).find('#schedule-title-input').val() == '') {
          //highlight title
          $(this).find('#schedule-title-group').addClass('error');
          return false;
        }
      }).on('ajax:success', function(e, data, textStatus, jqXHR){
  
        //if the new report schedule is open, close it
        //reset the form and hide it
        $('#new_report_schedule')[0].reset();
        $('#new-schedule-group').hide();
        $('#new-schedule-btn').show();


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
    }; //var setup_accordion_body = function(ab_handle){

    $(document).ready( function(){
			/*
      $('.accordion-body').each( function(index) {
        setup_accordion_body( $(this) );  
      }) // $('.accordion-body').each( function(index) {
			*/

			//load accordion contents when shown
			$('#schedule-accordion').find('a[data-toggle=collapse]').each( function(index){
				var link_handle = $(this);
				var accordion_body = $( link_handle.attr('href') );
				accordion_body.on('shown', function(){
					if(link_handle.attr('data-setup') == 'false') {
						$.get('/report_schedules/' + link_handle.attr('data-report-schedule') + '.template', null, function(data, textStatus, jqXHR){
							accordion_body.find('.accordion-inner').append(data).ready( function(){
								_l.setup_report_tab(accordion_body.find('.tabbable'));
								accordion_body.find('.loading-report').remove();
							});
						});
						link_handle.attr('data-setup', 'true');
					}
				});
			});

      $('.delete-licserver').click( function(){
        delete_licserver($(this) );
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
