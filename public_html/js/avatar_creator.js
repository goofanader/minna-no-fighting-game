$(document).ready(function() {
  /*var avatarCanvas = document.getElementById('avatar-picture');
  var canvasContext = avatarCanvas.getContext('2d');*/

  var avatarImages = {};
  var canvases = {}, contexts = {};
  var globalColors = {};

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
    if (images[part] === "") {
      $('#partColors-' + part).html("");
      return;
    }
    // set up colors
    var imageColors = $('button.btn > img[src="' + images[part] + '"]').parent().data('colors').split(",");
    var innerHTML = "";

    if (imageColors[0] !== "#000000") {
      // set the global colors for the part
      globalColors[part] = imageColors;

      // create the inner HTML for the color pickers
      innerHTML = "<h2 class='text-capitalize'>Change Color" + (imageColors.length > 1 ? "s" : "") + "</h2>";

      for (var j = 0; j < imageColors.length; j++) {
        innerHTML += "<input type='text' class='btn btn-default' id='color-button-" + part + "-" + j + "' /> ";
      }
    }

    $('#partColors-' + part).html(innerHTML);

    if (innerHTML !== "") {
      // set up the color picker JQuery plugin
      for (var j = 0; j < imageColors.length; j++) {
        $('#color-button-' + part + "-" + j).spectrum({
          color: imageColors[j],
          change: function(color) {
            // here is where we change the canvas to reflect the new color.
            var imageData = contexts[part].getImageData(0, 0, canvases[part].width, canvases[part].height);
            var pix = imageData.data;
            var colorIndex = $(this).attr('id').split('-');
            colorIndex = parseInt(colorIndex[colorIndex.length - 1]); // might be able to get it from j?

            var prevColorParts = {
              red: parseInt(globalColors[part][colorIndex].replace("#", "").substring(0,2), 16),
              green: parseInt(globalColors[part][colorIndex].replace("#", "").substring(2,4), 16),
              blue: parseInt(globalColors[part][colorIndex].replace("#", "").substring(4,6), 16)
            };

            // loop over each pixel and change the previous color to the new color
            for (var i = 0, n = pix.length; i < n; i += 4) {
              if (pix[i] === prevColorParts.red && pix[i + 1] === prevColorParts.green && pix[i + 2] == prevColorParts.blue) {
                pix[i] = Math.floor(color._r); //red
                pix[i + 1] = Math.floor(color._g); //green
                pix[i + 2] = Math.floor(color._b); //blue
              }
            }

            // make previous color the new color
            globalColors[part][colorIndex] = getHexColorString(color._r, color._g, color._b);

            // change the colors on the image
            contexts[part].putImageData(imageData, 0, 0);
          }
        });
      }
    }
  }

  function getHexColorString(r, g, b) {
    var rStr = fixHexString(Math.floor(r).toString(16));
    var gStr = fixHexString(Math.floor(g).toString(16));
    var bStr = fixHexString(Math.floor(b).toString(16));

    return "#" + rStr + gStr + bStr;
  }

  function fixHexString(hex) {
    if (hex.length == 1) {
      return "0" + hex;
    }
    if (hex.length < 1) {
      return "00";
    }

    return hex;
  }

  // handle item getting clicked on
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

  // handle form inputs and validating them
  $('#avatarName').change(function() {
    var minChars = 2, maxChars = 80;
    var errText = "Name needs to be between " + minChars + "-" + maxChars + " letters.";

    if ($(this).val().length < minChars || $(this).val().length > maxChars) {
      $(this).siblings('.help-block').html(errText);
      $(this).closest('.form-group').removeClass('has-success').addClass('has-error');
    } else {
      $(this).closest('.form-group').removeClass('has-error').addClass('has-success');
      $(this).siblings('.help-block').html("");
    }
    setSubmitButton();
  });

  $('#emailInput').change(function() {
    var maxChars = 100;
    var errText = "Must be a vaild email address.";
    var errLongText = "Email cannot be longer than " + maxChars + " characters. Use a different email.";

    if (!validateEmail($(this).val())) {
      $(this).siblings('.help-block').html(errText);
      $(this).closest('.form-group').removeClass('has-success').addClass('has-error');
    } else if ($(this).val().length > maxChars) {
      $(this).siblings('.help-block').html(errLongText);
      $(this).closest('.form-group').removeClass('has-success').addClass('has-error');
    }
    else {
      $(this).closest('.form-group').removeClass('has-error').addClass('has-success');
      $(this).siblings('.help-block').html("");
    }

    setSubmitButton();
  });

  function setSubmitButton() {
    if ($('#avatarName').closest('.form-group').hasClass('has-success') && $('#emailInput').closest('.form-group').hasClass('has-success')) {
      $('button[type="submit"]').removeAttr('disabled');
    } else if (typeof $('button[type="submit"]').attr('disabled') !== typeof undefined && $('button[type="submit"]').attr('disabled') !== false) {
      $('button[type="submit"]').attr('disabled', "");
    }
  }

  function validateEmail(email) {
    var re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
  }

  // handle the submit button
  $('#avatarSubmitForm').submit(function() {
    // add the hidden form
    var charData = {};
    for (var i = 0; i < partsKey.length; i++) {
      var part = partsKey[i];

      charData[part] = {
        filename: images[part],
        colors: (images[part] !== "" ? globalColors[part] : {})
      };
    }

    var input = $("<input>").attr("type", "hidden").attr("name", "characterData").val(JSON.stringify(charData));
    $(this).append($(input));
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
