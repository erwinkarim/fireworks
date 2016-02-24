// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require paloma
//= require turbolinks
//= require_tree .

Turbolinks.enableProgressBar();

$(document).on('page:load', function(){
  Paloma.executeHook();
  Paloma.engine.start();
})

var load_main = function(target){
  $.get( target.attr('data-source'), null, function(data){
      target.empty().append(data).ready(function(){
        $(document).find('.collapse').each( function(){
          setup_collapse($(this));
        });
      });
  });
}

var setup_collapse = function(target, div_target){
  $(target).on('shown.bs.collapse', function(){
    if (target.attr('data-plsload') == 'yes' ){
      if( typeof div_target == "undefined"){
          var load_target = target;
      } else {
          var load_target = div_target;
      }
      $.get( $(target).attr('data-source'), null, function(data){
          $(load_target).empty().append(data).ready(function(){
            //setup collapse if detected
            $(load_target).find('.collapse').each( function(){
              if($(this).attr('data-load-target') == null){
                setup_collapse($(this));
              } else {
                setup_collapse($(this), $(this).attr('data-load-target'));
              }
            });
            $(target).attr('data-plsload', 'no');
          });
      });
    };
  });
};

var load_graph = function(target, options){
  var default_options = {
      chart: {
          type: 'line',
          events: {
            load: function(){
              var chart_handle = this;
              chart_handle.showLoading();
              $.get( $(target).attr('data-graph-source'), null, function(data){
                  for(i=0; i< data['data'][0]['data'].length; i++){
                      chart_handle.series[0].addPoint({
                        x: data['data'][0]['data'][i][0],
                        y: data['data'][0]['data'][i][1],
                        id: data['data'][0]['data'][i][2],
                        name: data['data'][0]['data'][i][3]
                      }, false, false);
                      chart_handle.series[1].addPoint(data['data'][1]['data'][i], false, false);
                  }; //for

                  //set the last data thing
                  $(target).attr('data-start-id', data['last_id']);

                  chart_handle.redraw();
                  chart_handle.hideLoading();
              });
            }
          }
      },
      series:[
        { name: 'current', data:[], turboThreshold: 0},
        { name: 'max', data:[] }
      ],
      title: {
        text: 'Test'
      }
  };

  var settings = $.extend({}, default_options, options);
  //merge default with options

  //setup highcharts with target
  target.highcharts('StockChart', settings);
}
