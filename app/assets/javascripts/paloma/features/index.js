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


  Paloma.callbacks['features']['index'] = function(params){
    // Do something here.
		$(document).ready( function(){
			table_handle = $(document).find('.lic-info-table');

			$.get('/licservers/' + table_handle.attr('data-id') + '/features/lic_info.template' , null, function( data, textStatus, jqXHR){
				table_handle.find('.loading').empty();
				table_handle.find('tbody').append(data);
			}, 'html');
		}); // $(document).ready( function(){
  };
})();
