<?php
// folder is public_html/media/images/*, ignoring the ICONS folder

// want to for-loop through each image in each folder
// create a giant text document in the main area of images folder
// ...I think?
// for now? I guess? We'll parse it as a .tab file

include_once("../includes/Db.php");

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

  return "#".$r.$g.$b;
}

// recursive function to go through directories
function goThroughDirectory($directory, $db) {
  // don't handle the directory file if it's the ICONS folder
  if ($directory == "ICONS") {
    return;
  }

  foreach (scandir($directory) as $file) {
    if ($file[0] != "." && $file != "ICONS") {
      $realFilePath = $directory."/".$file;
      //echo $realFilePath."\n";
      // check if it's a directory, if so, call this function again
      if (is_dir($realFilePath)) {
        goThroughDirectory($realFilePath, $db);
      } else if (exif_imagetype($realFilePath) != false) {
        // determine what colors are in the file, if it's an image file
        $colors = array();

        for ($i = 0; $i < imagesx($realFilePath); $i++) {
          for ($j = 0; $j < imagesy($realFilePath); $j++) {
            $newColor = getHexColorString($realFilePath, $i, $j);
            $alpha = imagecolorsforindex($realFilePath, imagecolorat($realFilePath, $i, $j))["alpha"];

            if ($newColor != "#000000" && $alpha > 0 && !array_key_exists($newColor, $colors)) {
              $colors[$newColor] = $newColor;
            }
          }
        }

        echo "File $file has these colors:\n";
        $count = 1;
        foreach ($colors as $key => $value) {
          echo "\t$count. $key\n";
          $count++;
        }
        echo "-----------------------\n\n";
      }
    }
  }
}

// if this file is called directly, start the magic
// help from http://stackoverflow.com/questions/4545878/how-to-know-if-php-script-is-called-via-require-once
if (basename(__FILE__) == basename($_SERVER["SCRIPT_FILENAME"])) {
  $directory = checkOpts($argv);

  // check if the given thing is a valid directory
  if (!is_dir($directory)) {
    echo "Not a valid directory!\n";
    printUsage(true, $argv[0]);
  }

  // get db connection
  $db = new Db();
  //print_r($db->query("SHOW TABLES"));

  goThroughDirectory($directory, $db);
} else {
  echo "Please call this script not from another script. kthxbai\n";
}
 ?>
