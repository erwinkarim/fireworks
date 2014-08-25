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
  var _l = _L['tags'];


  Paloma.callbacks['tags']['index'] = function(params){
    function setup_features_accordion(handle){
      handle.find('.accordion-body').on('show', function(){
        //load the graph
        if(handle.find('.features-graph').children().length == 0){
          var data_load_path = '/licservers/' + handle.attr('data-licserver') + '/features/' + 
            handle.attr('data-feature') + '/get_data';
          handle.find('.features-graph').highcharts('StockChart', {
            title: { text: handle.attr('data-feature') + ' Usage' },
            chart: {
              events: {
                load: function(){
                  //lazy load the data here
                  var chart_handle = this;
                  function recursive_data_load(last_data_point){
                    if(last_data_point != 0 || last_data_point == null){
                      chart_handle.showLoading();
                      if(last_data_point == null){
                        var data_header = {};
                      } else {
                        var data_header = { start_id:last_data_point };
                      }
                      $.ajax( data_load_path, {
                        dataType:'json', data:data_header
                      }).done( function(data, textStatus, jqXHR){
                        console.log('load data into the graph upto id ' + data['last_id'] )
                  
                        //add current data
                        //better wayt load 10000 data points at a time
                        for(i=0; i < data['data'][0]['data'].length; i++){
                          chart_handle.series[0].addPoint( data['data'][0]['data'][i], false, false );
                          chart_handle.series[1].addPoint( data['data'][1]['data'][i], false, false );
                        }

                        //only draw for the first time
                        if(last_data_point == null){
                          chart_handle.redraw();
                          chart_handle.hideLoading();
                        };

                        //for now it's slow and lock up the browser
                        //recursive_data_load(data['last_id']);
                      });
                    }
                  }

                  recursive_data_load(null);
                  chart_handle.redraw();
                }
              }
            },
            rangeSelector: {
              buttons: [
                { type: 'hour', count: 1, text: '1h' }, 
                { type: 'day', count: 1, text: '1d' }, 
                { type: 'week', count: 1, text: '1w' }, 
                { type: 'month', count: 1, text: '1m' }, 
                { type: 'year', count: 1, text: '1y' }, 
                { type: 'all', text: 'All' }
              ], selected : 2 // all
            } ,
            series:[
              { name:'current', data:[ ] },
              { name:'max' , data:[ ]}
            ],
            plotOptions: {
            }
          }); // handle.find('.features-graph').highcharts('StockChart', {
            
        }
      });
      handle.removeAttr('data-init-feature');
      
    };

    //setup the licserver tabs
    function setup_tab(handle){
      handle.on('shown', function(e){
        //when the licserver is clicked, show licserver info and detected features
        $.get('/licservers/' + e.target.attributes['data-licserver'].value + '.template', null, 
          function(data, textStatus, jqXHR){
            if(
              $(
                '#' + e.target.attributes['data-tag'].value + '-' + e.target.attributes['data-licserver'].value
              ).children().length == 0
            ){
              $('#' + e.target.attributes['data-tag'].value + '-' + e.target.attributes['data-licserver'].value).append(
                data
              ).ready( function(){
                //load the featres listings
                $.get('/licservers/' + e.target.attributes['data-licserver'].value + '/features/list', null, 
                  function(data, textStatus, jqXHR){
                    $('#licserver-' + e.target.attributes['data-licserver'].value + '-features').find('.fa-spinner').remove();
                    $('#licserver-' + e.target.attributes['data-licserver'].value + '-features-listing').append(
                      data
                    ).ready( function(){
                      //when a feature is selected, show it's usage over time. lazy load the data
                      $('.accordion-group[data-init-feature="false"]').each( function(index,value){
                        setup_features_accordion($(this));
                      });


                    });
                  }, 'html' );
              });
            };
          }, 'html' );
      });
      handle.removeAttr('data-setup');

    };

    //setup the accordion
    function setup_accordion( handle ){
      //when the accordion is shown, load the licserver
      handle.on('shown', function(){
        if(handle.find('.accordion-inner').children().length == 0 ) {
          $.get('/tags/' + $(this).attr('data-title'), null, function(data, textStatus, jqXHR){
            handle.find('.accordion-inner').append(data).ready( function(){
              //when the licserver is clicked, show licserver info and detected features
              $('a[data-toggle="tab"][data-init="false"]').each( function(index, value){
                setup_tab($(this));
              });

              
            });
          }, 'html' );
        }
      });
    };

    function init_load(){
      //load all them tags
      $.get( '/tags/gen_accordion', null,
        function(data, textStatus, jqXHR){
          $('#tags-accordion').append(data).ready( function(){
            //process the accordion
            $('.accordion-tag').each( function(index, value) {
              setup_accordion( $(this) );
            });
          }) 
        }, 'html'
      );

    };

    // Do something here.
    $(document).ready( function(){

      Highcharts.setOptions({
        global:{ 
          useUTC: false
        }
      });
    
      init_load();

      //setup search query
      $('#search-tags').typeahead({
        source: function(query, process){
          return $.get('/tags/search/', { query:query }, function(data, textStatus, jqXHR){
            return process(data.options);
          }, 'json'); 
        } 
      }).bind('keypress', function(e){
        var code = e.keyCode || e.which;
        if(code==13){ //Enter keycode
          //prevent from reloading the page
          e.preventDefault();

          if( $(this).val().length != 0){
            //clear everything and return the one's with 
            $.get('/tags/search', { query:$(this).val() }, function(data, textStatus, jqXHR){
              $('#tags-accordion').empty();
              $('#tags-accordion').append(data).ready(function(){
                $('.accordion-tag').each( function(index,value){
                  setup_accordion( $(this) );
                });
              });
            }, 'html' );
          }else{
            //reset the page
            $('#tags-accordion').empty();
            init_load();
          };
        };
      });
    });
  }; // Paloma.callbacks['tags']['index'] = function(params){
})();
