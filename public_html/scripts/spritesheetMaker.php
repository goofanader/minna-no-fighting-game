<?php
// how to spritesheet.
// get all the characters that need to be created from the db.
// loop through them.
// get what classes they have. if there are no classes specified, it's animal, techie and cook
// the base spritesheets for classes are in the BODY folder.
include_once('../includes/Db.php');
include_once('../includes/constants.php');

function printErrorMessage($msg, $STDERR) {
  echo $msg;

  if (isset($STDERR)) {
    fwrite($STDERR, $msg);
  }
}

/**
* Convert a hexa decimal color code to its RGB equivalent
* Taken from http://php.net/manual/en/function.hexdec.php
*
* @param string $hexStr (hexadecimal color value)
* @param boolean $returnAsString (if set true, returns the value separated by the separator character. Otherwise returns associative array)
* @param string $seperator (to separate RGB values. Applicable only if second parameter is true.)
* @return array or string (depending on second parameter. Returns False if invalid hex color value)
*/
function hex2RGB($hexStr, $returnAsString = false, $seperator = ',') {
    $hexStr = preg_replace("/[^0-9A-Fa-f]/", '', $hexStr); // Gets a proper hex string
    $rgbArray = array();
    if (strlen($hexStr) == 6) { //If a proper hex code, convert using bitwise operation. No overhead... faster
        $colorVal = hexdec($hexStr);
        $rgbArray['red'] = 0xFF & ($colorVal >> 0x10);
        $rgbArray['green'] = 0xFF & ($colorVal >> 0x8);
        $rgbArray['blue'] = 0xFF & $colorVal;
    } elseif (strlen($hexStr) == 3) { //if shorthand notation, need some string manipulations
        $rgbArray['red'] = hexdec(str_repeat(substr($hexStr, 0, 1), 2));
        $rgbArray['green'] = hexdec(str_repeat(substr($hexStr, 1, 1), 2));
        $rgbArray['blue'] = hexdec(str_repeat(substr($hexStr, 2, 1), 2));
    } else {
        return false; //Invalid hex color code
    }
    return $returnAsString ? implode($seperator, $rgbArray) : $rgbArray; // returns the rgb string or the associative array
}

function getHexColorString($image, $x, $y) {
  $rgb = imagecolorat($image, $x, $y);

  $r = dechex(($rgb >> 16) & 0xFF);
  $g = dechex(($rgb >> 8) & 0xFF);
  $b = dechex($rgb & 0xFF);

  if (strlen($r) == 1) {
      $r = "0" . $r;
  }
  if (strlen($g) == 1) {
      $g = "0" . $g;
  }
  if (strlen($b) == 1) {
      $b = "0" . $b;
  }

  return "#".$r.$g.$b;
}

function hasDifferentColors($colors1, $colors2) {
  if (count($colors1) != count($colors2)) {
    return true;
  }

  for ($i = 0; $i < count($colors1); $i++) {
    if ($colors1[$i] != $colors2[$i]) {
      return true;
    }
  }

  return false;
}

function makeFrontFacingSprites($spritesheet, $json, $folder) {
  //get the frame number of the front facing sprite
  $startX = $json["FRONT"]["startFrame"]["x"];
  $startY = $json["FRONT"]["startFrame"]["y"];
  echo "\tCreating front facing sprites...\n";

  // do in increments of 64? starting with 32
  $increments = array(32, 64, 128, 196, 256);

  for ($j = 0; $j < count($increments); $j++) {
    $i = $increments[$j];
    // make an empty imageResource with transparency. Code from http://php.net/manual/en/function.imagecreatetruecolor.php
    $png = imagecreatetruecolor($i, $i);
    imagesavealpha($png, true);
    imagealphablending($png, true);
    //imageantialias($png, false);

    $trans_colour = imagecolorallocatealpha($png, 0, 0, 0, 127);
    imagefill($png, 0, 0, $trans_colour);
    // end code from elsewhere

    imagecopyresized($png, $spritesheet, 0, 0, $startX, $startY, $i, $i, 32, 32);
    imagepng($png, "$folder/FRONT_$i.png", 0);
    imagedestroy($png);

    echo "\t\tCreated $folder/FRONT_$i.png.\n";
  }
}

function colorSpritesheet($imageResource, $newColors, $origColors, $imageOut, $widthOffset, $heightOffset) {
  if (!hasDifferentColors($newColors, $origColors)) {
    return;
  } else if ($origColors[0] == "#000000") {
    return;
  }

  $width = imagesx($imageResource);
  $height = imagesy($imageResource);

  for ($i = 0; $i < $width; $i++) {
    for ($j = 0; $j < $height; $j++) {
      $spriteColor = getHexColorString($imageResource, $i, $j);

      // go through each color to see if it matches, and then replace with the new color
      for ($k = 0; $k < count($newColors); $k++) {
        if ($spriteColor == $origColors[$k] && $newColors[$k] != $spriteColor) {
          $rgb = hex2RGB($newColors[$k]);

          // set the pixel to the new color
          imagesetpixel($imageOut, $i + $widthOffset, $j + $heightOffset, imagecolorallocate($imageOut, $rgb["red"], $rgb["green"], $rgb["blue"]));
          break;
        }
      }
    }
  }
}

$db = new Db();
$imageFilesStart = "../media/images";

// set up the stderr stream
$STDERR = fopen('php://stderr', 'w+');

// get the colors of files
$fileColorRows = $db->select("SELECT * FROM CustomizationChoices");
$fileColors = array();
if ($fileColorRows) {
  foreach ($fileColorRows as $row) {
    $colorArray = array();

    for ($i = 1; $i <= MAX_COLORS && isset($row["color$i"]); $i++) {
      $colorArray[] = $row["color$i"];
    }

    $fileColors[$row["filename"]] = $colorArray;
  }
}

$rows = $db->select("SELECT * FROM PlayerCreationQueue WHERE queueStatus = 'queued' ORDER BY dateAdded DESC");

if ($rows) {
  foreach ($rows as $row) {
    echo "====={$row['playerID']}'s Spritesheets=====\n";
    $jsonData = json_decode($row['jsonData'], true);

    if (!isset($jsonData["CLASSES"])) {
      $jsonData["CLASSES"] = array(
        "ANIMAL"/*,
        "TECHIE",
        "COOK"*/
      );
    }
    $jsonData["CLASSES"][] = "REGULAR";

    var_dump($jsonData["CLASSES"]);
    echo "\n";

    //$classSpritesheets = array();
    for ($i = 0; $i < count($jsonData["CLASSES"]); $i++) {
      $currentClass = $jsonData['CLASSES'][$i];
      echo "~~~$currentClass Class~~~\n";
      $classSpritesheet = $imageFilesStart."/BODY/CLASSES/$currentClass/Spritesheet.png";
      $spritesheetJson = json_decode(file_get_contents(str_replace(".png", ".json", $classSpritesheet)), true);

      // load the body file to prepare for layering
      if (!file_exists($classSpritesheet)) {
        printErrorMessage("Could not find $classSpritesheet! Could not create ID {$row['id']}'s $currentClass spritesheet.\n", $STDERR);
        continue;
      }
      $newSpritesheet = imagecreatefrompng($classSpritesheet);
      imagealphablending($newSpritesheet, true);
      imagesavealpha($newSpritesheet, true);
      //imageantialias($newSpritesheet, false);

      $outSpritesheet = imagecreatefrompng($classSpritesheet);
      imagealphablending($outSpritesheet, true);
      imagesavealpha($outSpritesheet, true);
      //imageantialias($outSpritesheet, false);

      // color the body file
      colorSpritesheet($newSpritesheet, $jsonData["BODY"]["colors"], $fileColors[$jsonData["BODY"]["filename"]], $outSpritesheet, 0, 0);
      imagedestroy($newSpritesheet);
      echo "\tColored BODY\n";

      for ($j = 1; $j < count($g_SPRITE_TYPES); $j++) {
        $part = $g_SPRITE_TYPES[$j];
        if ($jsonData[$part]["filename"] == "") {
          // that means there's no part specified.
          continue;
        }

        // first check if there's a full spritesheet of the part to use instead of the individual ones
        $partFilename = "../".$jsonData[$part]["filename"];
        $strReplacement = "$imageFilesStart/$part/CLASSES/$currentClass/";
        $partFilename = str_replace("$imageFilesStart/$part/", $strReplacement, $partFilename);
        $partFilename = str_replace(".png", "$currentClass.png", $partFilename);

        echo "\tPart Spritesheet Filename: $partFilename...";

        if (file_exists($partFilename)) {
          echo "found\n";
          $partSpritesheet = imagecreatefrompng($partFilename);
          imagealphablending($partSpritesheet, true);
          imagesavealpha($partSpritesheet, true);
          //imageantialias($partSpritesheet, false);

          if (isset($jsonData[$part]["colors"])) {
            colorSpritesheet($partSpritesheet, $jsonData[$part]["colors"], $fileColors[$jsonData[$part]["filename"]], $partSpritesheet, 0, 0);
          }

          //mash the file on top of the body file
          imagecopy($outSpritesheet, $partSpritesheet, 0, 0, 0, 0, imagesx($partSpritesheet), imagesy($partSpritesheet));
          imagedestroy($partSpritesheet);

          echo "\tColored and Merged $part\n";

          continue;
        }

        // if there isn't a full spritesheet, go through each animation and put the frames in the respective places
        foreach ($spritesheetJson as $aniName => $aniData) {
          // create the file resource for this part type
          $strReplacement = ($aniName != "FRONT" ? "$imageFilesStart/$part/CLASSES/$currentClass/" : "");

          $partFilename = "../".$jsonData[$part]["filename"];
          if ($strReplacement != "") {
            $partFilename = str_replace("$imageFilesStart/$part/", $strReplacement, $partFilename);
            $partFilename = str_replace(".png", "$aniName.png", $partFilename);
          }

          echo "\tPart Filename: $partFilename...";

          if (file_exists($partFilename)) {
            echo "found\n";
            $partSpritesheet = imagecreatefrompng($partFilename);
            imagealphablending($partSpritesheet, true);
            imagesavealpha($partSpritesheet, true);
            //imageantialias($partSpritesheet, false);

            if (isset($jsonData[$part]["colors"])) {
              colorSpritesheet($partSpritesheet, $jsonData[$part]["colors"], $fileColors[$jsonData[$part]["filename"]], $partSpritesheet, 0, 0);
            }

            //mash the file on top of the body file
            imagecopy($outSpritesheet, $partSpritesheet, $aniData["startFrame"]["x"], $aniData["startFrame"]["y"], 0, 0, imagesx($partSpritesheet), imagesy($partSpritesheet));
            imagedestroy($partSpritesheet);

            echo "\tColored and Merged $part\n";
          } else {
            echo "missing\n";
          }
        }
      }

      // save the png file
      $folder = $imageFilesStart."/CREATED_SPRITESHEETS";
      if (!file_exists($folder))
        mkdir($folder);
      $folder .= "/{$row['playerID']}";
      if (!file_exists($folder))
        mkdir($folder);
      $folder .= "/{$row['characterName']}";
      if (!file_exists($folder))
        mkdir($folder);
      $pngFilename = "$folder/"."$currentClass.png";
      imagepng($outSpritesheet, $pngFilename, 0);

      // if it's the NONE class, save different sized copies of the front-facing sprite
      if ($currentClass == "REGULAR") {
        makeFrontFacingSprites($outSpritesheet, $spritesheetJson, $folder);
      }

      imagedestroy($outSpritesheet);
      echo "\tCreated Class Spritesheet: $pngFilename\n\n";
    }

    //TODO: update row in db
  }
}
 ?>
