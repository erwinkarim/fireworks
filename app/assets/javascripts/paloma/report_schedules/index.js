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

      //bind adding new licservers button
      ab_handle.find('.add-licserver').click(function(){
        var handle = $(this).closest('.licserver-listing').find('.licserver:last');
    
        handle.after(
          $('<div/>', { class:'controls licserver', style:'padding:5px 0px;' }).append(
            $('<select/>', { name:'monitored_licserver[]' })
          ).append(
            $.parseHTML(' ')
          ).append(
            $('<button/>', { class:'btn btn-danger delete-licserver', type:'button' }).append(
              $('<i/>', { class:'fa fa-minus' })
            ).click( function(){
              delete_licserver($(this) );
            })
          ).append(
            $('<br/>')
          )
        );
      
        //get licserver listings and convert them into options tag
        $.ajax('/licservers', {
          dataType:'json'
        }).done( function( data, textStatus, jqXHR){
          $.each(data, function(index,element){
            handle.next().find('select').append(
              $('<option/>', { text:(element.port==null ? '' : element.port) + '@' + element.server, 
                value:element.id })
            );
          });
        }); //$.ajax('/licservers', { ... 

        //check if there's disabled button and enable it back
        if( handle.find('.delete-licserver:disabled').length > 0){
          handle.find('.delete-licserver:disabled').removeAttr('disabled');
        }
      }); // ab_handle.find('.add-licserver').click(function(){

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
      $('.accordion-body').each( function(index) {
        setup_accordion_body( $(this) );  
      }) // $('.accordion-body').each( function(index) {


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
