var WelcomeController = Paloma.controller("Welcome");

WelcomeController.prototype.index = function(){
  load_main($('#tags-target') );
}
