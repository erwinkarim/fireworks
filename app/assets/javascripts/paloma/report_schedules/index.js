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

        if( 
          ab_handle.find('.new-schedule').length == 0 &&
          ab_handle.find('#reports'  + rs_id).find('tbody').children().length == 0
        ){
          //genearte the report listing
          ab_handle.find('.accordion-inner').append(
            $.parseHTML('<i class="fa fa-spinner fa-4x fa-spin"></i>')
          );
          $.ajax(
            '/report_schedules/' + ab_handle.attr('data-id') + '/reports', {
              dataType:'html'
            }
          ).done( function( data, statusText, jqXHR){

            $('.accordion-body[data-id=' + rs_id + ']').find('.accordion-inner').append(
              $.parseHTML(' ')
            );

            //maybe change this to generate from template
            $('#reports' + rs_id).find('table').after(
                $('<button/>', { text:'Generate', class:'btn btn-primary generate_report', 'data-id':rs_id}
                ).on('click', function(){
                  $('#reports' + rs_id).find('table').find('tbody').append(
                    $('<tr/>', { class:'generating-report'} ).append(
                      $('<td/>', { colspan:4}).prepend(
                        $.parseHTML('<i class="fa fa-spinner fa-spin"></i>')
                      )
                    )
                  );

                  //submit a deaayed jobs to churn out report
                  //$.ajax('generate report')
                  // TODO: this is problem matic
                  $.ajax( '/report_schedules/' + $(this).attr('data-id') + '/reports', {
                    type:'POST', 
                    dataType:'json'
                  }).done(function(data, statusText,jqXHR){
                    $('#reports' + rs_id).find('tbody').append(
                      $('<tr/>').append(
                        $('<td/>', { colspan:5, text:'Generate request sent' })
                      )
                    )
                    $('#reports' + rs_id).find('table').find('.generating-report').remove();
                  });
                }) // $('<button/>', { ... }).on('click', function(){
              ).after(
                $.parseHTML(' ')
              ).after(
                $('<button/>', { class:'btn btn-info refresh_report'}).click(function(){
                  //refresh the report listing
                  var accordion_handle = $(this).closest('.accordion-body');
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
                }).append(
                  $('<i/>',{ class:'fa fa-refresh' })
                )
            ) // $('.accordion-body[data-id=' + rs_id + ']').find('#reports' + rs_id).append(

            $('#reports' + rs_id).find('tbody').append( data);

            $('.in').find('.fa-spinner').remove();
          });
        };
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
