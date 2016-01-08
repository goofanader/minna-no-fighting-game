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

$rows = $db->select("SELECT * FROM PlayerCreationQueue WHERE queueStatus = 'queued'");

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
    $jsonData["CLASSES"][] = "NONE";

    var_dump($jsonData["CLASSES"]);
    echo "\n";

    //$classSpritesheets = array();
    for ($i = 0; $i < count($jsonData["CLASSES"]); $i++) {
      echo "~~~{$jsonData['CLASSES'][$i]} Class~~~\n";
      $classSpritesheet = $imageFilesStart."/BODY/CLASSES/".$jsonData["CLASSES"][$i]."/Spritesheet.png";
      $spritesheetJson = json_decode(file_get_contents(str_replace(".png", ".json", $classSpritesheet)), true);

      // load the body file to prepare for layering
      if (!file_exists($classSpritesheet)) {
        printErrorMessage("Could not find $classSpritesheet! Could not create ID {$row['id']}'s {$jsonData['CLASSES'][$i]} spritesheet.\n", $STDERR);
        continue;
      }
      $newSpritesheet = imagecreatefrompng($classSpritesheet);
      imageAlphaBlending($newSpritesheet, true);
      imageSaveAlpha($newSpritesheet, true);

      $outSpritesheet = imagecreatefrompng($classSpritesheet);
      imageAlphaBlending($outSpritesheet, true);
      imageSaveAlpha($outSpritesheet, true);

      // color the body file
      colorSpritesheet($newSpritesheet, $jsonData["BODY"]["colors"], $fileColors[$jsonData["BODY"]["filename"]], $outSpritesheet, 0, 0);
      imagedestroy($newSpritesheet);
      echo "\tColored BODY\n";

      foreach ($spritesheetJson as $aniName => $aniData) {
        for ($j = 1; $j < count($g_SPRITE_TYPES); $j++) {
          $part = $g_SPRITE_TYPES[$j];
          // create the file resource for this part type
          $strReplacement = ($aniName != "FRONT" ? "$aniName.png" : ".png");
          $partFilename = str_replace(".png", $strReplacement, "../".$jsonData[$part]["filename"]);
          echo "\tPart Filename: $partFilename\n";
          if (file_exists($partFilename)) {
            $partSpritesheet = imagecreatefrompng($partFilename);
            imageAlphaBlending($partSpritesheet, true);
            imageSaveAlpha($partSpritesheet, true);

            if (isset($jsonData[$part]["colors"])) {
              colorSpritesheet($partSpritesheet, $jsonData[$part]["colors"], $fileColors[$jsonData[$part]["filename"]], $partSpritesheet, 0, 0);
            }

            //mash the file on top of the body file
            imagecopymerge($outSpritesheet, $partSpritesheet, $aniData["startFrame"]["x"], $aniData["startFrame"]["y"], 0, 0, imagesx($partSpritesheet), imagesy($partSpritesheet), 100);
            imagedestroy($partSpritesheet);

            echo "\tColored and Merged $part\n";
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
      $pngFilename = "$folder/"."{$jsonData["CLASSES"][$i]}.png";
      imagepng($outSpritesheet, $pngFilename, 0);
      imagedestroy($outSpritesheet);
      echo "\tCreated Class Spritesheet: $pngFilename\n\n";
    }

    // update row in db
  }
}
 ?>
