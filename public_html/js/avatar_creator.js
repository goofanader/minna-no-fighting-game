$(document).ready(function() {
  /*
  Copyright (c) 2015 by Mohit Aneja (http://codepen.io/cssjockey/pen/jGzuK)

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  */
  /*$('ul.tabs li').click(function() {
    var tab_id = $(this).attr('data-tab');

    $('ul.tabs li').removeClass('current');
    $('.tab-content').removeClass('current');

    $(this).addClass('current');
    $("#" + tab_id).addClass('current');
  })*/

  var avatarCanvas = document.getElementById('avatar-picture');
  var ctx = avatarCanvas.getContext('2d');

  var avatarImages = {};
  var images = {
    BODY: 'media/images/BODY/front.png',
    EYES: 'media/images/EYES/happyeyes.png',
    MOUTH: 'media/images/MOUTH/smile_small.png',
    SHOES: 'media/images/SHOES/boots.png',
    PANTS: 'media/images/PANTS/LongPant.png',
    TOP: 'media/images/TOP/Sweatshirt.png',
    HAIR: 'media/images/HAIR/bowlcut.png',
    HEADPIECE: 'media/images/HEADPIECE/mouseears.png'
  };
  var partsKey = [
    'BODY',
    'EYES',
    'MOUTH',
    'SHOES',
    'PANTS',
    'TOP',
    'HAIR',
    'HEADPIECE'
  ];

  function loadCanvasImages() {
    ctx.clearRect(0, 0, avatarCanvas.width, avatarCanvas.height);

    for (var i = 0; i < partsKey.length; i++) {
      if (images[partsKey[i]] !== ""){
        avatarImages[partsKey[i]] = createNewImage(images[partsKey[i]]);
      }
    }
  }

  function createNewImage(imageSrc) {
    var newImage = new Image();
    newImage.src = imageSrc;

    newImage.onload = function() {
      ctx.drawImage(newImage, 0, 0, avatarCanvas.width, avatarCanvas.height);
    };

    return newImage;
  }

  $('button').click(function() {
    var idSplit = $(this).attr("id").split("-");

    if (idSplit.length > 3 && idSplit[0] === "avatar" && idSplit[1] === "button") {
      var avatarPartID = "#avatar-" + idSplit[2];

      if (idSplit[3] !== "remove") {
        var imageFile = "media/images/" + idSplit[2] + "/" + idSplit[3] + ".png";
        //$(avatarPartID).removeClass("hide");
        //$(avatarPartID).attr("src", imageFile);
        images[idSplit[2]] = imageFile;
      }
      else {
        //$(avatarPartID).addClass("hide");
        images[idSplit[2]] = "";
      }

      loadCanvasImages();
      $(this).parent().children().removeClass("active");
      $(this).addClass("active");
    }
  });

  function init() {
    ctx.imageSmoothingEnabled = false;
    ctx.mozImageSmoothingEnabled = false;
    ctx.webkitImageSmoothingEnabled = false;
    
    loadCanvasImages();
  }

  init();
});
