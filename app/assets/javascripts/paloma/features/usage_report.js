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

		var chart_options = {
			chart: { type: 'bar', renderTo: 'usage-report-chart' },
			title: { text: 'Feature Usage by department' },
			xAxis: { 
				categories: ['Last 24 Hours']
			},
			yAxis: {
				min: 0, title: { text:'Lic Count percentage' }
			},
			plotOptions: { series: { stacking: 'percent' } },
			tooltip: {
				pointFormat: '<span style="color:{series:color}">{series.name}</span>: <b>{point.y}</b> ( {point.percentage:.2f}%)</br>', 
			},
			series: []
		}

		//display the chart
		console.log('fetching json data');
		$.getJSON(location.href + '.json', function(data) {
			//populate data in the series
			$.each(data, function(index,value){
				chart_options.series.push( { name:value.ads_department_name, data:[value.machine_count] } )
			});
			console.log(chart_options);
			var usage_chart = new Highcharts.Chart(chart_options);
		});
  };
})();
