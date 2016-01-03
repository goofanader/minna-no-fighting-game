$(document).ready(function() {
  /*var avatarCanvas = document.getElementById('avatar-picture');
  var canvasContext = avatarCanvas.getContext('2d');*/

  var avatarImages = {};
  var canvases = {}, contexts = {};
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
    for (var i = 0; i < partsKey.length; i++) {
      var part = partsKey[i];

      loadOneCanvasImage(part);
    }
  }

  function loadOneCanvasImage(part) {
    contexts[part].clearRect(0, 0, canvases[part].width, canvases[part].height);

    if (images[part] !== ""){
      avatarImages[part] = createNewImage(images[part], contexts[part], canvases[part]);
    }
  }

  function createNewImage(imageSrc, canvasContext, avatarCanvas) {
    var newImage = new Image();
    newImage.src = imageSrc;

    newImage.onload = function() {
      canvasContext.drawImage(newImage, 0, 0, avatarCanvas.width, avatarCanvas.height);
    };

    return newImage;
  }

  function loadOneColorSet(part) {
    // set up colors
    var imageColors = $('button.btn > img[src="' + images[part] + '"]').parent().data('colors').split(",");
    var innerHTML = "";

    if (imageColors[0] !== "#000000") {
      innerHTML = "<h2><strike>Change</strike> Color" + (imageColors.length > 1 ? "s" : "") + "</h2>";

      for (var j = 0; j < imageColors.length; j++) {
        innerHTML += "<button type='button' class='btn btn-default' id='color-button-" + part + "-" + j + "' style='width: " + canvases[part].width + "; height: " + canvases[part].height + "; background-color: " + imageColors[j] + ";'></button> "
      }
    }

    $('#partColors-' + part).html(innerHTML);
  }

  $('button.btn').click(function() {
    // get the parts of the id of the button clicked to determine what section the button belongs to
    var idSplit = $(this).attr("id").split("-");

    if (idSplit.length > 3 && idSplit[0] === "avatar" && idSplit[1] === "button") {
      var avatarPartID = "#avatar-" + idSplit[2];

      if (idSplit[3] !== "remove") {
        // replace image with new, selected one
        var imageFile = "media/images/" + idSplit[2] + "/" + idSplit[3] + ".png";
        images[idSplit[2]] = imageFile;
      }
      else {
        // remove image
        images[idSplit[2]] = "";
      }

      // reload the image and set the selected button to "active"
      loadOneCanvasImage(idSplit[2]);
      $(this).parent().children().removeClass("active");
      $(this).addClass("active");
      loadOneColorSet(idSplit[2]);
    }
  });

  function init() {
    // get all the canvases and their contexts
    for (var i = 0; i < partsKey.length; i++) {
      var part = partsKey[i];

      canvases[part] = document.getElementById('avatar-' + part);
      contexts[part] = canvases[part].getContext('2d');

      // set all the canvases to use nearest neighbor interpolation
      contexts[part].mozImageSmoothingEnabled = false;
      if (typeof(contexts[part].imageSmoothingEnabled) !== 'undefined') {
        contexts[part].imageSmoothingEnabled = false;
      } else {
        contexts[part].webkitImageSmoothingEnabled = false;
      }

      // set the buttons that have their parts selected
      var $image = $('button.btn > img[src="' + images[part] + '"]');
      var $button = $image.parent();
      $button.addClass("active");

      // set up colors
      loadOneColorSet(part);
    }

    loadCanvasImages();
  }

  init();
});
