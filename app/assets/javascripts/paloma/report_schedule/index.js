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
  var _l = _L['report_schedule'];


  Paloma.callbacks['report_schedule']['index'] = function(params){
    // Do something here.
    //
    //popopulate a report listing table
    //  handle: the table that we want to populate, must be a <table/> element
    //  data: the data we want to populate the table with. must contain
    //    { id, schedule_id, created_at }
    function populate_report_listing_table( handle, data){
      handle.find('tbody').append(
        $('<tr/>').append(
          $('<td/>').append(
            $('<a/>', { 
              text:data.id, href:'/report_schedule/' + data.schedule_id + '/reports/' + data.id 
            })
          )
        ).append(
          $('<td/>', { text:data.created_at} )
        ).append(
          $('<td/>').append(
            $('<a/>', { 
              text:'xml', href:'/report_schedule/' + data.schedule_id + '/reports/' + data.id + '.xml'
            }).after(
              $.parseHTML(' | ')
            ).after(
              $('<a/>', { 
                text:'csv', href:'/report_schedule/' + data.schedule_id + '/reports/' + data.id + '.csv'
              })
            )
          )
        )
      );
    };

    $(document).ready( function(){
      $('.accordion-body').each( function(index) {
        $(this).on('show', function(){
          //if contents empty, reports
          if( $(this).find('.accordion-inner').children().length == 0  ){
            $(this).find('.accordion-inner').append(
              $.parseHTML('<i class="fa fa-spinner fa-4x fa-spin"></i>')
            );
            $.ajax(
              '/report_schedule/' + $(this).attr('data-id') + '/reports', {
                dataType:'json'
              }
            ).done( function( data, statusText, jqXHR){
              $('.in:first').find('.accordion-inner').append(
                $('<button/>', { text:'Generate', class:'btn btn-primary generate_report'}).on('click', function(){
                  console.log('generate new report for schedule ' + $('.in:first').attr('data-id') );
                  $('.in:first').find('table').find('tbody').append(
                    $('<tr/>', { class:'generating-report'} ).append(
                      $('<td/>', { colspan:3}).prepend(
                        $.parseHTML('<i class="fa fa-spinner fa-spin"></i>')
                      )
                    )
                  );

                  //submit a delayed jobs to churn out report
                  //$.ajax('generate report')
                  $.ajax( '/report_schedule/' + $('.in:first').attr('data-id') + '/reports', {
                    type:'POST', 
                    dataType:'json'
                  }).done(function(data, statusText,jqXHR){
                    populate_report_listing_table($('.in:first').find('.accordion-inner'), data);
                    $('.in:first').find('table').find('.generating-report').remove();
                  });
                })
              )
              $('.in:first').find('.accordion-inner').append(
                $('<table/>', { class:'table table-striped'} ).append(
                  $('<thead/>').append(
                    $('<tr/>').append(
                      $('<th/>', { text:'ID' } )
                    ).append(
                      $('<th/>', { text:'Created At' } )
                    ).append(
                      $('<th/>', { text:'Other Formats' } )
                    )
                  )
                ).append(
                  $('<tbody/>')
                )
              )
              $.each(data, function(index, value){
                populate_report_listing_table($('.in').find('.accordion-inner'), value);
              });
              $('.in').find('.fa-spinner').remove();
            });
          };
        });
      })
    });
  }; // Paloma.callbacks['report_schedule']['index'] = function(params){
})();
