<?php
// folder is public_html/media/images/*, ignoring the ICONS folder

// want to for-loop through each image in each folder
// create a giant text document in the main area of images folder
// ...I think?
// for now? I guess? We'll parse it as a .tab file

include_once("../includes/Db.php");
include_once("../includes/constants.php");
$imagesInDB = array();

function printErrorMessage($msg, $STDERR) {
  echo $msg;

  if (isset($STDERR)) {
    fwrite($STDERR, $msg);
  }
}

// usage message
function printUsage($isExiting, $programName) {
  $usage = "usage: $programName <directory of images and subdirectories to find colors>\n";

  if ($isExiting) {
    exit($usage);
  } else {
    echo $usage;
  }
}

// check options first
function checkOpts($argv) {
  if (count($argv) != 2) {
    printUsage(true, $argv[0]);
  }

  return $argv[1];
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

// recursive function to go through directories
function goThroughDirectory($directory, $db) {
  // don't handle the directory file if it's the ICONS folder
  if ($directory == "ICONS") {
    return;
  }

  global $imagesInDB, $STDERR;

  foreach (scandir($directory) as $file) {
    if ($file[0] != "." && $file != "ICONS" && $file != "CLASSES") {
      $realFilePath = $directory."/".$file;

      // check if it's a directory, if so, call this function again
      if (is_dir($realFilePath)) {
        goThroughDirectory($realFilePath, $db);
      } else if (exif_imagetype($realFilePath) != false) {
        // determine what colors are in the file, if it's an image file
        $colors = array();
        // should really check to make sure it's of PNG type
        $imageResource = imagecreatefrompng($realFilePath);
        if (!$imageResource) {
          printErrorMessage("Could not process $file.\n", $STDERR);
          continue;
        }

        imageAlphaBlending($imageResource, true);
        imageSaveAlpha($imageResource, true);

        $width = imagesx($imageResource);
        $height = imagesy($imageResource);

        for ($i = 1; $i < $width; $i++) {
          for ($j = 1; $j < $height; $j++) {
            $newColor = getHexColorString($imageResource, $i, $j);

            $rgb = imagecolorat($imageResource, $i, $j);
            $alpha = imagecolorsforindex($imageResource, $rgb);
            $alpha = $alpha["alpha"];

            if ($alpha < 127 && $newColor != "#000000" && !array_key_exists($newColor, $colors)) {
              $colors[$newColor] = $newColor;
            }
          }
        }

        if (empty($colors)) {
          $colors['#000000'] = '#000000';
        }

        $newFileName = str_replace("../", "", $realFilePath);

        // create entry in db or modify existing entry
        if (array_key_exists($newFileName, $imagesInDB)) {
          // modify existing row.

          $queryString = 'UPDATE CustomizationChoices SET ';
          $colors = array_keys($colors);
          if (count($colors) > MAX_COLORS) {
            // TODO: add a new column
            printErrorMessage("There are ".strval(count($colors))." colors in $newFileName. Please limit the number of colors!\n", $STDERR);
            continue;
          }

          // don't modify existing row if all the colors are the same!!
          if (!hasDifferentColors($colors, $imagesInDB[$newFileName]['colors'])) {
            echo "$newFileName is the same.\n";
            echo "-----------------------\n";
            continue;
          }

          for ($i = 0; $i < count($colors); $i++) {
            $queryString .= "`color".strval($i + 1)."` = ".$db->quote($colors[$i]);

            if ($i < count($colors) - 1) {
              $queryString .= ",";
            }

            $queryString .= " ";
          }
          $queryString .= "WHERE id = ".$imagesInDB[$newFileName]["id"];

          $result = $db->query($queryString);

          if ($result) {
            echo "Updated row $newFileName. Query:\n";
            echo "\t$queryString\n";
            echo "-----------------------\n";
          } else {
            printErrorMessage($db->error()."\nCould not update row $newFileName. Query:\n\t$queryString\n-----------------------\n", $STDERR);
          }
        } else {
          // create entry in db
          $colors = array_keys($colors);
          if (count($colors) > MAX_COLORS) {
            // TODO: add a new column
            printErrorMessage("There are ".strval(count($colors))." colors in $newFileName. Please limit the number of colors!\n", $STDERR);
            continue;
          }

          $queryString = "INSERT INTO CustomizationChoices (filename, ";
          $queryValues = $db->quote($newFileName).", ";

          for ($i = 0; $i < count($colors); $i++) {
            $queryString .= "`color".strval($i + 1)."`";
            $queryValues .= $db->quote($colors[$i]);

            if ($i < count($colors) - 1) {
              $queryString .= ", ";
              $queryValues .= ", ";
            }
          }
          $queryString .= ") VALUES ($queryValues)";

          $result = $db->Query($queryString);
          if ($result){
            echo "Adding row $newFileName. Query:\n";
            echo "\t$queryString\n";
            echo "-----------------------\n";
          } else {
            printErrorMessage($db->error()."\nCould not add row $newFileName. Query:\n\t$queryString\n-----------------------\n", $STDERR);
          }
        }
      }
    }
  }
}

// if this file is called directly, start the magic
// help from http://stackoverflow.com/questions/4545878/how-to-know-if-php-script-is-called-via-require-once
if (basename(__FILE__) == basename($_SERVER["SCRIPT_FILENAME"])) {
  $directory = checkOpts($argv);

  // set up the stderr stream
  $STDERR = fopen('php://stderr', 'w+');

  // check if the given thing is a valid directory
  if (!is_dir($directory)) {
    printErrorMessage("Not a valid directory!\n", $STDERR);
    printUsage(true, $argv[0]);
  }

  // get db connection
  $db = new Db();
  //get the list of images already in the db
  $rows = $db->select("SELECT * FROM CustomizationChoices");

  if ($rows == false) {
    printErrorMessage("Could not get the list of images already in the db! {$db->error()}\n", $STDERR);
  }

  //make a hash table of the values in the rows
  foreach ($rows as $row) {
    $imagesInDB[$row['filename']] = array(
      "id" => $row['id'],
      "colors" => array()
    );

    for ($i = 1; (($i < MAX_COLORS + 1) && (isset($row["color$i"]))); $i++) {
      $imagesInDB[$row['filename']]["colors"][] = $row["color$i"];
    }
  }

  goThroughDirectory($directory, $db);
} else {
  echo "Please call this script not from another script. kthxbai\n";
}
 ?>
