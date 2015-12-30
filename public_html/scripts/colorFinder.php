<?php
// folder is public_html/media/images/*, ignoring the ICONS folder

// want to for-loop through each image in each folder
// create a giant text document in the main area of images folder
// ...I think?
// for now? I guess? We'll parse it as a .tab file

include_once("../includes/Db.php");

// usage message
function printUsage($isExiting) {
  $usage = "usage: {$argv[0]} -d <directory of images and subdirectories to find colors>\n";

  if ($isExiting) {
    exit($usage);
  } else {
    echo $usage;
  }
}

// check options first
function checkOpts() {
  $options = getopt("d:");

  if (array_key_exists("d", $options)) {
    return $options["d"];
  } else {
    printUsage(true);
  }

  return null;
}

// if this file is called directly, start the magic
// help from http://stackoverflow.com/questions/4545878/how-to-know-if-php-script-is-called-via-require-once
if (basename(__FILE__) == basename($_SERVER["SCRIPT_FILENAME"])) {
  $directory = checkOpts();

  // check if the given thing is a valid directory
  if (!is_dir($directory)) {
    printUsage(true);
  }

  // get db connection
  $db = new Db();

  foreach(scandir($directory) as $file) {
    echo $file . "\n";
  }
}
 ?>
