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
    //popopulate a report listing table
    //  handle: the table that we want to populate, must be a <table/> element
    //  data: the data we want to populate the table with. must contain
    //    { id, schedule_id, created_at, status }
    function populate_report_listing_table( handle, data){
      handle.find('tbody').append(
        $('<tr/>').append(
          $('<td/>').append(
            $('<a/>', { 
              text:data.id, href:'/report_schedules/' + data.schedule_id + '/reports/' + data.id 
            })
          )
        ).append(
          $('<td/>', { text:data.status} )
        ).append(
          $('<td/>', { text:data.created_at} )
        ).append(
          $('<td/>').append(
            $('<a/>', { 
              text:'xml', href:'/report_schedules/' + data.schedule_id + '/reports/' + data.id + '.xml'
            }).after(
              $.parseHTML(' | ')
            ).after(
              $('<a/>', { 
                text:'csv', href:'/report_schedules/' + data.schedule_id + '/reports/' + data.id + '.csv'
              })
            )
          )
        )
      );
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

    $(document).ready( function(){
      $('.accordion-body').each( function(index) {
        var rs_id = $(this).attr('data-id');

        //handle the accordion
        $(this).on('show', function(){
          //if contents empty, reports
          //TODO: reappend using the correct data-id so when doing parallel request, doesn't mess up

          //setup tooltip for
          $(this).find('.scheduled-tooltip').tooltip();

          if( 
            $(this).find('.new-schedule').length == 0 &&
            $(this).find('#reports'  + rs_id).children().length == 0
          ){
            //genearte the report listing
            $(this).find('.accordion-inner').append(
              $.parseHTML('<i class="fa fa-spinner fa-4x fa-spin"></i>')
            );
            $.ajax(
              '/report_schedules/' + $(this).attr('data-id') + '/reports', {
                dataType:'json'
              }
            ).done( function( data, statusText, jqXHR){

              $('.accordion-body[data-id=' + rs_id + ']').find('.accordion-inner').append(
                $.parseHTML(' ')
              );

              $('.accordion-body[data-id=' + rs_id + ']').find('#reports' + rs_id).append(
                $('<table/>', { class:'table table-striped'} ).append(
                  $('<thead/>').append(
                    $('<tr/>').append(
                      $('<th/>', { text:'ID' } )
                    ).append(
                      $('<th/>', { text:'Status' } )
                    ).append(
                      $('<th/>', { text:'Created At' } )
                    ).append(
                      $('<th/>', { text:'Other Formats' } )
                    )
                  )
                ).append(
                  $('<tbody/>')
                ).after(
                  $('<button/>', { text:'Generate', class:'btn btn-primary generate_report'}
                  ).on('click', function(){
                    //console.log('generate new report for schedule ' + $('.in:first').attr('data-id') );
                    $('.in:first').find('table').find('tbody').append(
                      $('<tr/>', { class:'generating-report'} ).append(
                        $('<td/>', { colspan:3}).prepend(
                          $.parseHTML('<i class="fa fa-spinner fa-spin"></i>')
                        )
                      )
                    );

                    //submit a deaayed jobs to churn out report
                    //$.ajax('generate report')
                    $.ajax( '/report_schedules/' + $('.in:first').attr('data-id') + '/reports', {
                      type:'POST', 
                      dataType:'json'
                    }).done(function(data, statusText,jqXHR){
                      $('.in:first').find('tbody').append(
                        $('<tr/>').append(
                          $('<td/>', { colspan:5, text:'Generate request sent' })
                        )
                      )
                      $('.in:first').find('table').find('.generating-report').remove();
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
                      dataType:'json'
                    }).done(function (data,statusText, jqXHR){
                      //clean and repopulate the table
                      accordion_handle.find('tbody').empty();
                      $.each(data, function(index,value){
                        populate_report_listing_table( accordion_handle, value);
                      });
                    })
                    $(this).find('.fa-refresh').removeClass('fa-spin');
                  }).append(
                    $('<i/>',{ class:'fa fa-refresh' })
                  )
                ) 
              ) // $('.accordion-body[data-id=' + rs_id + ']').find('#reports' + rs_id).append(

              $.each(data, function(index, value){
                populate_report_listing_table($('.in').find('#reports' + rs_id), value);
              });

              $('.in').find('.fa-spinner').remove();
            });
          };
        });
      }) // $('.accordion-body').each( function(index) {

      //adding new licservers
      $('.add-licserver').click(function(){
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
      });

      $('.delete-licserver').click( function(){
        delete_licserver($(this) );
      });


      //adding new 
      $('#new-schedule-btn').click( function(){
        $('#new-schedule-group').show().find('.accordion-body').addClass('in');
        $('#new-schedule-btn').hide();
        //reset the form before sending out
      });

      //cancle adding new schedule
      $('#new-schedule-cancel').click( function(){
        $('#new-schedule-group').hide();
        $('#new-schedule-btn').show();
      });

      //when submiting the form, do sanity checks
      $('.schedule-form').on('ajax:before', function(){
        if( $(this).find('#schedule-title-input').val() == '') {
          //highlight title
          $(this).find('#schedule-title-group').addClass('error');
          return false;
        }
      }).on('ajax:success', function(data, status, xhr){
        console.log(data);
        $('#new_report_schedule')[0].reset();
        $('#new-schedule-group').hide();
        $('#new-schedule-btn').show();
        //reset the form and hide it
      }).on('ajax:error', function(xhr, status, error){
        //if got error (usually the title uniqueness) highlight the error and move on
      });

    }); // $(document).ready( function(){
  }; // Paloma.callbacks['report_schedule']['index'] = function(params){
})();
