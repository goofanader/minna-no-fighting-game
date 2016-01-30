<?php
//ini_set('display_errors', 1);
//error_reporting(~0);
// Following function call from https://davidwalsh.name/create-zip-php
/* creates a compressed zip file */
/*function create_zip($files = array(),$destination = '',$overwrite = false) {
	//if the zip file already exists and overwrite is false, return false
	if(file_exists($destination) && !$overwrite) { return false; }
	//vars
	$valid_files = array();
	//if files were passed in...
	if(is_array($files)) {
		//cycle through each file
		foreach($files as $file) {
			//make sure the file exists
			if(file_exists($file)) {
				$valid_files[] = $file;
			}
		}
	}
	//if we have good files...
	if(count($valid_files)) {
		//create the archive
		$zip = new ZipArchive();
		if($zip->open($destination,$overwrite ? ZIPARCHIVE::OVERWRITE : ZIPARCHIVE::CREATE) !== true) {
			return false;
		}
		//add the files
		foreach($valid_files as $file) {
			$zip->addFile($file,$file);
		}
		//debug
		//echo 'The zip archive contains ',$zip->numFiles,' files with a status of ',$zip->status;

		//close the zip -- done!
		$zip->close();

		//check to make sure the file exists
		return file_exists($destination);
	}
	else
	{
		return false;
	}
}*/

// taken from http://stackoverflow.com/questions/2820723/how-to-get-base-url-with-php
function url() {
    if(isset($_SERVER['HTTPS'])) {
        $protocol = ($_SERVER['HTTPS'] && $_SERVER['HTTPS'] != "off") ? "https" : "http";
    }
    else {
        $protocol = 'http';
    }
    return $protocol . "://" . $_SERVER['HTTP_HOST'];
}

if (isset($_GET) && isset($_GET['n'])) {
  include_once('../../includes/Db.php');
  include_once('../../includes/constants.php');

  $searchFor = strtolower($_GET['n']);

  $db = new Db();
  $dbSearch = $db->quote((strlen($searchFor) > 5 ? substr($searchFor, 0, 5) : $searchFor)."%");
  $rows = $db->query("SELECT * FROM PlayerCreationQueue WHERE characterName COLLATE UTF8_GENERAL_CI LIKE $dbSearch ORDER BY characterName");

  //header('Content-Type: text/plain');
  //echo "Search term: $dbSearch\n\n";
  $images = array();

  if ($rows) {

    if ($rows->num_rows > 0) {
      // build the list
      while ($row = $rows -> fetch_assoc()) {
        $levenDistance = levenshtein($searchFor, strtolower($row['characterName']));
        if (!isset($images[$levenDistance])) {
          $images[$levenDistance] = array();
        }
        $images[$levenDistance][] = $row['playerID']."/".$row['characterName'];
      }
    } else {
      // nothing matches the search term
      //http_response_code(204);
      die();
    }

    // zip up the front-facing sprite images in order
    $zipImages = array();
    $filenamePrefix = url()."/goofanader/media/images/CREATED_SPRITESHEETS/";
    $filenameSuffix = "/FRONT_32.png";
    $zipFilename = md5($_SERVER['REMOTE_ADDR'].date('l jS \of F Y h:i:s A').$searchFor).".zip";

    foreach ($images as $index => $distanceImages) {
      for ($i = 0; $i < count($distanceImages); $i++) {
        $zipImages[] = $filenamePrefix.$distanceImages[$i]."$filenameSuffix";
      }
    }

    /*while (file_exists($zipFilename));
    create_zip($zipImages, $zipFilename);
    // now, rename the files so that they are in the immediate folder
    $zip = new ZipArchive;
    $res = $zip->open($zipFilename);
    if ($res === true) {
      for ($i = 0; $i < count($zipImages); $i++) {
        $imageName = $zipImages[$i];

        $newName = str_replace($filenamePrefix, "", $imageName);
        $nameParts = explode("/", $newName);
        $newName = "{$i}_{$nameParts[0]}_{$nameParts[1]}.png";
        $zip->renameName($imageName, $newName);
      }
    }

    zip_close($zip);*/

    // current implementation without .zipping files
    header('Content-Type: application/json');
    echo json_encode($zipImages);
    //http_response_code(200);
  } else {
    // some error with the database
    header('Content-Type: text/plain');
    //http_response_code(400);
    echo $db->error();
  }
} else {
  //http_response_code(404);
  die();
}
 ?>
