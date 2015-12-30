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
  print_r($db->query("SHOW TABLES"));

  foreach(scandir($directory) as $file) {
    if ($file[0] != ".") {
      echo $file . "\n";
    }
  }
} else {
  echo "Please call this script not from another script. kthxbai\n";
}
 ?>
