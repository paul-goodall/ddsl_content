// ================================================
// On window load. This waits until images have loaded which is essential
$(window).load(function(){
// ================================================  
var grey1 = 0.5;
var grey2 = 0.0;
var con1 = 0.7;
var con2 = 1.2;
var dt_milliseconds = 200;
// ================================================
var setGreyscale = function(ele, greyval) {
        $(ele).css({
           "-webkit-filter": "grayscale("+greyval+")",
            "filter": "grayscale("+greyval+")"
       });
   };
// ================================================   
var setContrast = function(ele, conval) {
        $(ele).css({
           "-webkit-filter": "contrast("+conval+")",
            "filter": "contrast("+conval+")"
       });
   };   
   
// ================================================
setGreyscale($('.item img'), grey1);
setContrast($('.item img'), con1);
// ================================================   
// Animate the changes
var animateGreyscale = function(ele, greyscale1, greyscale2, duration) {
      $({my_grey: greyscale1}).animate({my_grey: greyscale2}, {
          duration: duration,
          easing: 'linear', // or "linear"
                           // use jQuery UI or Easing plugin for more options
          step: function() {
              //setGreyscale(ele, this.my_grey);
              setContrast(ele, this.my_grey);
          },
          complete: function() {
              // Final callback to set the target blur radius
              // jQuery might not reach the end value
              //setGreyscale(ele, greyscale2);
              setContrast(ele, greyscale2);
         }
     });
  };
// ================================================
// Colourise Image on-hover:
		$('.item img').mouseover(function(){
			animateGreyscale($(this), con1, con2, dt_milliseconds)
		})
// ================================================		
// Colourise Image on-hover:
		$('.item img').mouseout(function(){
			animateGreyscale($(this), con2, con1, dt_milliseconds)
		})
// ================================================
}); // END window.load
// ================================================    
    
    