<?php
include_once('includes/Db.php');
include_once('includes/constants.php');

$db = new Db();

$webpageName = "Minna no Avatar";
include_once('includes/header.php');

if (isset($_POST['avatarName']) && isset($_POST['emailInput']) && isset($_POST['characterData'])) {
  $avatarName = $db->quote($_POST['avatarName']);
  $emailInput = $db->quote($_POST['emailInput']);
  $characterData = $db->quote($_POST['characterData']);

  // add the data to the db.
  //$charData = json_decode($_POST['characterData']);
  // check if player is already in db.
  $rows = $db->select("SELECT id FROM Players WHERE email=$emailInput");
  $playerID = -1;

  if ($rows == false) {
    $queryString = "INSERT INTO Players (email) VALUES ($emailInput)";
    $result = $db->query($queryString);

    $playerID = $db->connect()->insert_id;
  } else {
    $playerID = $rows[0]['id'];
  }

  $queryString = "INSERT INTO PlayerCreationQueue (playerID, characterName, jsonData, dateAdded) VALUES ($playerID, $avatarName, $characterData, " . $db->quote(date("Y-m-d H:i:s")) . ")";
  $result = $db->query($queryString);

  if ($result != false) {
    echo "<p>Your character has been added! <s>Please wait for a few hours before your spritesheet will be completed, thank you.</s> To be implemented: spritesheet creation.</p>";
  } else {
    // email me about the database error
    $emailMessage = "<html><body><p>There seems to have been a problem adding $emailInput's character! The information they provided:</p>
      <ul>
        <li>Avatar Name: $avatarName</li>
        <li>Character Data: $characterData</li>
        <li>SQL Error: ".$db->error()."</li>
      </ul></body></html>";

    // To send HTML mail, the Content-type header must be set
    $headers  = 'MIME-Version: 1.0' . "\r\n";
    $headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";

    mail(DATABASE_ADMIN_EMAIL, "ERROR: $emailInput Could Not Add Avatar", $emailMessage, $headers);

    echo "<p>Something went wrong when trying to add your character! The database admin has been contacted and will get back to you via email shortly.</p>";
  }

  echo "<a href='/goofanader/avatar_creator.php'><h2>Create Another Character!</h2></a>";
} else {
  echo "<p>It seems you have stumbled upon this page magically. Please go to <a href='/goofanader/avatar_creator.php'>the Avatar Creator page</a> to use this page properly.</p>";
}

include_once('includes/footer.php');
 ?>
