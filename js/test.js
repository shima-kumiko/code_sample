;(function($){


  var MOVE_DISTANCE = 50;
  var ANIMATION_TIME = 1000;
  var characterPosition = 0;


  var moveCharacter = function(){
      characterPosition++;
      $(this).animate({left: characterPosition * MOVE_DISTANCE}, ANIMATION_TIME);
      $(this).children('.animation__position').text(characterPosition);
  };


  $('.js_moveCharacter').on('click', moveCharacter);


}(jQuery));
