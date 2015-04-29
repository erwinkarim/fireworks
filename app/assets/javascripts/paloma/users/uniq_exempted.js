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
  var _l = _L['users'];


  Paloma.callbacks['users']['uniq_exempted'] = function(params){
    // Do something here.
		//
		$(document).ready( function(){
			console.log('users/uniq_exempted loaded');

			$('#search-users').typeahead({
				source: function(query, process){
					return $.get('/users/search/', {
						query:query
					}, function(data, textStatus, jqXHR){
							return process(data.options);
					}, 'json')
				}
			}).bind( 'keypress', function(e){
				var code = e.keyCode || e.which;
				if(code == 13){
					e.preventDefault();

					//find the user than add the user to the exempt list
				}
			});
		});
  };
})();
