<?php
  include_once('includes/Db.php');
  include_once('includes/constants.php');
  //ini_set('display_errors', 1);
  //error_reporting(~0);

  $tabPreference = "tabs";
  $iconSize = "32";
  $partsSize = "96";
  $db = new Db();

  $imagesInDB = array();
  $rows = $db->select("SELECT * FROM CustomizationChoices");
  if ($rows != false) {
    foreach ($rows as $row) {
      $imagesInDB[$row['filename']] = array();

      for ($i = 1; (($i < MAX_COLORS + 1) && (isset($row["color$i"]))); $i++) {
        $imagesInDB[$row['filename']][] = $row["color$i"];
      }
    }
  }

  $webpageName = "Minna no Avatar";
  $isAvatarCreator = true;
  include_once('includes/header.php');
?>
  <div class="container">
    <nav class="navbar navbar-default" role="navigation">
      <div class="navbar-header">
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#avatar-items-collapse">
          <span class="sr-only">Toggle Navigation</span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <div class="navbar-brand">Minna no Avatar</div>
      </div>
      <div class="collapse navbar-collapse" id="avatar-items-collapse">
      <!--<div class="navbar-inner"><a class="brand" href="#">Minna no Avatar</a>-->
        <!--< ?php echo '<ul class="nav nav-'.$tabPreference.'" role="tablist">'; ?>-->
        <?php echo '<ul class="nav navbar-nav" role="tablist">'; ?>
          <?php
          // want to iterate through
          $tabs = array(
            array("BODY", "body choices", "Change body color here."),
            array("EYES", "eye choices", "Change eye shape here. Change eye color here."),
            array("MOUTH", "mouth choices", "Change mouth shape here. Change certain areas of the mouth's colors here."),
            array("HAIR", "hair choices", "Change hair style here. Set hair color here."),
            array("HEADPIECE", "headpiece choices", "Choose headpiece here."),
            array("TOP", "shirt choices", "Change tops here. Change tops' color palettes here."),
            array("PANTS", "pants choices", "Change bottoms here. Change bottoms' color palettes here."),
            array("SHOES", "shoes choices", "Change footwear here. Change shoes' color palettes here."),
            array("TAIL", "tail choices", "Choose what tail you want here. Change tails' color palettes here."),
            array("SPECIAL", "special choices", "Choose any cute things to add to your body. Change their colors here."),
            array("CLASS", "class choices", "Select your three classes for fighting. Determine what weapon you want.")
          );

          for ($i = 0; $i < count($tabs); $i++) {
            if ($i == 0) {
              $class_info = " class='active'";
            }
            else {
              $class_info = "";
            }

            $tabName = $tabs[$i][0];
            $icon = $tabs[$i][1];
            $mediaFolder = "media/images/$tabName";
            $href = "href='#$tabName'";

            try {
              $files = scandir($mediaFolder);

              if (!$files) {
                $class_info = " class='disabled'";
                $href = "";
              }
            } catch (Exception $e) {
                $class_info = " class='disabled'";
                $href = "";
            }

            echo "<li role='presentation'$class_info><a $href aria-controls='$tabName' role='tab' data-toggle='tab'><img class='pixelated' src='media/images/ICONS/$tabName.png' alt='$icon' title='$icon' width='$iconSize' height='$iconSize' onerror='this.src=\"media/images/ICONS/no_icon.png\"'></a></li>\n";
          }
          ?>
        </ul>
      </div>
    </nav>
      <div class="row">
        <?php // clothing choices // ?>
        <div class="col-xs-8 col-sm-9 col-md-9 col-lg-9">

          <!-- Tab panes -->
          <div class="tab-content">
            <?php
            for ($i = 0; $i < count($tabs); $i++) {
              if ($i == 0) {
                $class_info = " in active";
              }
              else {
                $class_info = "";
              }

              $tabName = $tabs[$i][0];
              $info = $tabs[$i][2];
              $mediaFolder = "media/images/$tabName";

              echo "<div role='tabpanel' class='tab-pane fade$class_info' id='$tabName'>";
              try {
                $files = scandir($mediaFolder);

                if ($files) {
                  echo "<div class='row'>";
                  // HANDLE COLORS //
                  echo "<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12' id='partColors-$tabName'>";
                  echo "</div>";
                  // HANDLE BUTTONS //
                  echo "<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12'>";
                  echo "<h2 class='text-capitalize'>".strtolower($tabName)." Choices</h2>";
                  // add a way to remove the piece first
                  echo "<button type='button' class='btn btn-default' id='avatar-button-$tabName-remove'><img class='pixelated' src='' alt='Remove' width='$partsSize' height='$partsSize'></button> ";

                  $headpieceArray = array();

                  foreach ($files as $imageName) {
                    if ($imageName[0] != "." && array_key_exists("$mediaFolder/$imageName", $imagesInDB)) {
                      $imageNameParts = explode(".", $imageName);

                      if ($tabName == "HEADPIECE" && (strpos($imageName, "under.png") !== false || strpos($imageName, "BALD.png") !== false)) {
                        $headpieceArray["$mediaFolder/$imageName"] = true;
                        continue;
                      }

                      echo "<button type='button' class='btn btn-default' id='avatar-button-$tabName-{$imageNameParts[0]}' data-colors='".implode(",", $imagesInDB["$mediaFolder/$imageName"])."'><img class='pixelated' src='$mediaFolder/$imageName' alt='$tabName: {$imageNameParts[0]}' width='$partsSize' height='$partsSize'></button> ";
                    }
                  }
                  echo "</div>";
                  echo "</div>";

                  if (!empty($headpieceArray)) {
                    echo "<script>var headpieceArray = {};\n";

                    foreach ($headpieceArray as $key => $value) {
                      echo "headpieceArray['$key'] = true;\n";
                    }

                    echo "</script>";
                  }
                }
              } catch (Exception $e) {

              }

              echo "</div>\n";
            }
            ?>
          </div>
        </div>
        <?php // avatar picture // ?>
        <!--<div class="hidden-xs hidden-sm col-md-3 col-lg-3">-->
        <div class="col-xs-4 col-sm-3 col-md-3 col-lg-3">
          <div class="row">
            <div class="col-xs-12" style="height:<?php echo $partsSize; ?>; margin-bottom: 10px;">
              <canvas class="avatar-picture" id="avatar-BODY" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
              <canvas class="avatar-picture" id="avatar-EYES" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
              <canvas class="avatar-picture" id="avatar-MOUTH" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
              <canvas class="avatar-picture" id="avatar-SHOES" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
              <canvas class="avatar-picture" id="avatar-PANTS" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
              <canvas class="avatar-picture" id="avatar-TOP" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
              <canvas class="avatar-picture" id="avatar-HAIR" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
              <canvas class="avatar-picture" id="avatar-HEADPIECE" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
            </div>
            <?php // Save Avatar, Form Submission // ?>
            <div class="col-xs-12">
              <form method="post" action="<?php echo htmlspecialchars("/goofanader/thank_you.php");?>" id="avatarSubmitForm">
                <div class="form-group">
                  <label for="avatarName" class="control-label">Avatar Name</label>
                  <input type="text" class="form-control" id="avatarName" placeholder="Name" val="Player" name="avatarName">
                  <span class="glyphicon form-control-feedback" aria-hidden="true"></span>
                  <span class="help-block"></span>
                </div>
                <div class="form-group">
                  <label for="emailInput" class="control-label">Email</label>
                  <input type="email" class="form-control" id="emailInput" placeholder="Email" name="emailInput">
                  <span class="glyphicon form-control-feedback" aria-hidden="true"></span>
                  <span class="help-block"></span>
                </div>
                <button type="submit" disabled class="btn btn-primary btn-block" id="saveCharacterButton">Save</button>
              </form>
            </div>
          </div>
        </div>
    </div>
  </div>

  <?php
  include_once('includes/footer.php');
   ?>
