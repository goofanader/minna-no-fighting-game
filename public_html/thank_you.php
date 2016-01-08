<?php
include_once('includes/Db.php');
include_once('includes/constants.php');

$db = new Db();

$webpageName = "Minna no Avatar";
include_once('includes/header.php'); ?>


<div class="container">
<div class="row text-center">
  <div class="col-xs-12">

<?php
if (isset($_POST) && count($_POST) == 3 && isset($_POST['avatarName']) && isset($_POST['emailInput']) && isset($_POST['characterData'])) {
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
    echo "<h2>Thank You!</h2></div><div class='col-xs-12'>";
    echo "<p>Your character has been added! Please wait a day before your spritesheet will be completed, thank you. <s>A link will be emailed to you so you can download your files!</s> To be implemented: emailing user when spritesheet(s) are finished creating.</p>";
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

    echo "<h2>Something's Wrong!</h2></div><div class='col-xs-12'>";
    echo "<p>Something went wrong when trying to add your character! The database admin has been contacted and will get back to you via email shortly.</p>";
  }

  echo "</div><div class='col-xs-12 col-sm-6 col-sm-offset-3 col-md-4 col-md-offset-4'>";
  echo "<a href='/goofanader/avatar_creator.php' class='btn btn-primary btn-lg btn-block' role='button'>Create Another Character!</a>";
} else {
  // redirect the user to the avatar creator page
  ?>
  <script>
  $(document).ready(function () {
    window.location = "/goofanader/avatar_creator.php";
  });
  </script>
  <?php
} ?>
    </div>
  </div>
</div>
<?php
include_once('includes/footer.php');
 ?>
