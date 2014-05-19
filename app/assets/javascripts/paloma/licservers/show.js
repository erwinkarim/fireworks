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
  var _l = _L['licservers'];


  Paloma.callbacks['licservers']['show'] = function(params){
    // Do something here.
    $(document).ready(function(){
      console.log('licserver show loaded');

      $('.tags').popover({
        title:'Licservers',
        content:function(){
          //get the list of licsevers and display the list
          var handle = $(this);
          $.get('/tags/' + $(this).attr('data-title'), { mode:'list' },  function(data){ 
            handle.parent().find('.popover-content').empty().append(data);
          }, 'html');
        }
      });
    });
  }; // Paloma.callbacks['licservers']['show'] = function(params){
})();
