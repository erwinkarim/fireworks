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
  var _l = _L['features'];


  Paloma.callbacks['features']['usage_report'] = function(params){
    // Do something here.
		console.log('features/usage_report loaded');

		var datasum = 0;
		var chart_options = {
			chart: {
				type: 'column', renderTo: 'usage-report-chart' ,
				height: 800,
				panning: true, panKey: 'shift',
				zoomType: 'x'
			},
			title: { text: 'Last 30 days Feature Usage by Company/Department' },
			subtitle: { text: 'Graph is drillable and zoomable. Use the shift key to pan' },
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
						var pcnt =  (this.value / datasum) * 100;
						return Highcharts.numberFormat(pcnt, 0, ',') + '%';
					}
				}
			},
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
				//pointFormat: '<span style="color:{series:color}">{series.name}</span>:
				//<b>{point.y}</b> ( {point.percentage:.2f}%)</br>',
				pointFormat: '<span style="color:{series:color}">{series.name}</span>: <b>{point.y}</b> <br />',
			},
			series: [ { name:"Company", colorByPoint: true, data: [] } ],
			drilldown: { series: [] }
		}

		//display the chart
		console.log('fetching json data');
		$.getJSON(location.href + '.json', function(data) {
			//populate data in the series
			$.each(data, function(index,value){
				//chart_options.series.push( { name:value.company_name, data:[value.machine_count] } )
				//try to find the company name in chart_options.series index
				var inArray = false;
				datasum += value.machine_count;
				$.each(chart_options.series[0].data, function(index,series_value){
					if( series_value.name == value.company_name) {
						series_value.y += value.machine_count;
						//find the drill down and add the data
						$.each(chart_options.drilldown.series, function(index, drilldown_series_value){
							if(drilldown_series_value.name == value.company_name){
									drilldown_series_value.data.push( [value.department_name, value.machine_count] );
							};
						});
						inArray = true;
					}
				}); // $.each(chart_options.series, function(index,series_value){

				//data is not found at series level
				if( inArray == false){
					chart_options.series[0].data.push(
						{ name:value.company_name, drilldown:value.company_name, y:value.machine_count }
					);
					chart_options.drilldown.series.push(
						{ name:value.company_name, id:value.company_name, data:[ [value.department_name, value.machine_count ] ] }
					);
				};
			}); // $.each(data, function(index,value){
			console.log(chart_options);
			var usage_chart = new Highcharts.Chart(chart_options);
		}).fail( function(jqXHR, textStatus){
			$('#usage-report-chart').empty().append(
				textStatus + ' Refresh page.'
			);
		});

    console.log('fetching user list');
    $.get(location.href + '_users.template', null, function(data){
      $('#usage-report-list').empty().append(data);
      $.bootstrapSortable(applyLast=true);

    });
  };
})();
