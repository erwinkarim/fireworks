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


  Paloma.callbacks['users']['top_users'] = function(params){
    // Do something here.
		//
		$(document).ready( function(){
			$.get('/users/top_users.template', null, function(data){
				$('#hour').empty().append(data);
			});

			//get the data when tab changed
			$('a[data-toggle="tab"]').on('shown.bs.tab', function(e){
				target = e.target.attributes['href'].value;
				if ( $(target).is(':empty') ){
					$(target).empty().append( $.parseHTML( '<i class="fa fa-cog fa-spin fa-4x"></i>' ) );
					$.get('/users/top_users.template', { interval:e.target.attributes['data-interval'].value }, function(data){
						$(target).empty().append(data);
					});
				}
			});
		});
  };
})();
