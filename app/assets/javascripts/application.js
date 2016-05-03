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

var usage_histogram_graph = function(target, options){
  var default_options = {
      chart: {
          type: 'spline',
          events: {
            load: function(){
              var chart_handle = this;
              $.get( $(target).attr('data-graph-source'), null, function(data){
                  for(i=0; i < data.office.length; i++ ){
                    chart_handle.series[0].addPoint( data.office[i], false, false);
                  }
                  for(i=0; i < data.all.length; i++ ){
                    chart_handle.series[1].addPoint( data.all[i], false, false);
                  }

                  chart_handle.redraw();
              }); //get
            }
          }
      },
      series:[
        { name: 'office', data:[], turboThreshold: 0},
        { name: 'allhours', data:[] }
      ],
      title: { text: 'Test' }
  };

  var settings = $.extend({}, default_options, options);
  //merge default with options

  target.highcharts('Chart', settings);

};

var company_usage_graph = function(target, options){
  var datasum = 0;
  var default_options = {
      chart: {
        type: 'column',
        height: 800,
        panning: true, panKey: 'shift',
        zoomType: 'x'
      },
      xAxis: {
				type: 'category', labels: { rotation: 45 }
			},
			yAxis: {
				min: 0, title: { text:'Lic Count observered' },
				stackLabels:{
					enabled: true
				},
        labels: {
          formatter: function(){
            var pcnt = ( this.value / datasum ) * 100;
            return Highcharts.numberFormat(pcnt, 0, ',') + '%';
          }
        }
			},
      series:[
        {
          name: "Company", colorByPoint: true, data: []
        }
      ],
      plotOptions: {
        series: {
          dataLabels: {
            enabled:true,
            formatter: function(){
              var pcnt = (this.y / datasum ) * 100;
              return Highcharts.numberFormat(pcnt) + '%';
            }
          }
        }
      },
      tooltip: {
        pointFormat: '<span style="color:{series:color}">{series.name}</span>: <b>{point.y}</b> <br />',
      },
      drilldown: { series: [] },
      title: { text: 'Text' },
      subtitle: { text: 'Graph is drillable and zoomable. Use the shift key to pan'}
  };

  var settings = $.extend({}, default_options, options);

  //load the data
  $.get( $(target).attr('data-graph-source'), null, function(data){
    $.each(data, function(index,value){
      //try to find the company name in chart_options.series index
      var inArray = false;
      datasum += value.machine_count;
      $.each(settings.series[0].data, function(index,series_value){
        if( series_value.name == value.company_name) {
          series_value.y += value.machine_count;
          //find the drill down and add the data
          $.each(settings.drilldown.series, function(index, drilldown_series_value){
            if(drilldown_series_value.name == value.company_name){
                drilldown_series_value.data.push( [value.department_name, value.machine_count] );
            };
          });
          inArray = true;
        }
      });

      //data is not found at series level
      if( inArray == false){
        settings.series[0].data.push(
          { name:value.company_name, drilldown:value.company_name, y:value.machine_count }
        );
        settings.drilldown.series.push(
          { name:value.company_name, id:value.company_name, data:[ [value.department_name, value.machine_count ] ] }
        );
      }; //if
    });

    target.highcharts('Chart', settings);
  });
};
