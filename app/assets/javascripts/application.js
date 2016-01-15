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

var setup_collapse = function(target){
  $(target).on('shown.bs.collapse', function(){
    if (target.attr('data-plsload') == 'yes' ){
      console.log('should load ' + $(target).attr('data-source') );
      $.get( $(target).attr('data-source'), null, function(data){
          $(target).empty().append(data).ready(function(){
              $(target).find('.collapse').each( function(){
                  setup_collapse($(this));
              });
          });
          $(target).attr('data-plsload', 'no');
      });
    };
  });
};
