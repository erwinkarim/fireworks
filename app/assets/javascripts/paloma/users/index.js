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


  Paloma.callbacks['users']['index'] = function(params){
    //setup accordion body
    setup_accordion_body = function( handle) {
      handle.find('a[data-toggle="tab"]').on('shown', function(e){
        //when clicked, start gather features data
        $('.tab-pane[data-machine-id="' + e.target.attributes['data-machine-id'].value + 
          '"][data-user-id="' + e.target.attributes['data-user-id'].value + '"]').append(
          $.parseHTML('<div>test</div>')
        );
      });
    }; // setup_accordion_body = function( handle) {

    // Do something here.
    $(document).ready( function(){
      console.log('user index loaded');

      $.ajax( '/users/get_more', {
        dataType:'html'
      }).done( function(data, textStatus, jqXHR){
        $('#user-listings').append(
          $.parseHTML(data)
        ).ready( function(){
          $('.accordion-group[data-init=false]').each( function(index) {
            setup_accordion_body($(this));
          });
        });
      });
    }); // $(document).ready( function(){
  }; // Paloma.callbacks['users']['index'] = function(params){
})();
