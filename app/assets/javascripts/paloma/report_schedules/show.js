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


  Paloma.callbacks['report_schedules']['show'] = function(params){
    // Do something here.
		$(document).ready( function(){
			$.get('/report_schedules/' + $('.info').attr('data-schedule-id') + '.template', null, function(data, textStatus, jqXHR){
				$('.info').empty().append( data ).ready( function(){
					_l.setup_report_tab($(this) );
				});
			}, 'html');
		}); // $(document).ready( function(){
  };
})();
