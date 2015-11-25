(function($){

  /* 定数 */
  var MIN_NUMBER = 1;
  var MAX_NUMBER = 999;
  var PARTITION = '<br>';
  var STRING_F = 'Fizz';
  var STRING_B = 'Buzz';
  var STRING_FB = 'FizzBuzz';

  /* jQueryオブジェクトを作成 */
  var $canvas = $('#result');
  var $input = $('input');
  var $button = $('button');

  /* カンバスを消去する*/
  var resetCanvas = function(){
    $canvas.empty();
  };

  /* 出力するhtmlを返す */
  var getResult = function(inputedNumber){

    var result = '';
    for (var i = MIN_NUMBER; i <= inputedNumber; i++) {

      if(0 == (i % 3)+(i % 5)){
        result += STRING_FB + PARTITION;
      }
      else if(0 == i % 3){
        result += STRING_F + PARTITION;
      }
      else if(0 == i % 5){
        result += STRING_B + PARTITION; 
      }
      else {
        result += i + PARTITION;
      };
    };

    return result;

  };

  /* 初期化 */
  $button.on('click',function(){

    resetCanvas();
    var inputedNumber = parseInt($input.val(),10);
    if(inputedNumber >= MIN_NUMBER && inputedNumber <= MAX_NUMBER){

      $canvas.html(getResult(inputedNumber));

    } else {

      window.alert(MIN_NUMBER+'〜'+MAX_NUMBER+'までの数字を入力してください。');

    };

  });

}(jQuery));
