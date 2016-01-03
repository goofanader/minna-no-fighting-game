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
?>
<html>

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <script language="javascript" type="text/javascript" src='js/libraries/jquery-2.1.4.min.js'></script>
  <!-- Include all compiled plugins (below), or include individual files as needed -->
  <script src="bootstrap-3.3.5-dist/js/bootstrap.min.js"></script>
  <script language="javascript" type="text/javascript" src="js/avatar_creator.js"></script>

  <!-- Bootstrap -->
  <!--<link rel="stylesheet" href="css/reset.css">-->
  <link href="bootstrap-3.3.5-dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="css/avatar_creator.css">
  <!--<link rel="stylesheet" href="css/bootstrap-horizon.css">-->
  <link rel="stylesheet" href="css/bootflat.min.css">

  <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
  <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
  <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->
  <title>Minna no Avatar</title>
</head>

<body>

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

          //print_r($tabs);

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

            try {
              $files = scandir($mediaFolder);

              if (!$files) {
                $class_info = " class='disabled'";
              }
            } catch (Exception $e) {
                $class_info = " class='disabled'";
            }

            echo "<li role='presentation'$class_info><a href='#$tabName' aria-controls='$tabName' role='tab' data-toggle='tab'><img class='pixelated' src='media/images/ICONS/$tabName.png' alt='$icon' title='$icon' width='$iconSize' height='$iconSize' onerror='this.src=\"media/images/ICONS/no_icon.png\"'></a></li>\n";
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
                  echo "<h2>".ucfirst(strtolower($tabName))." Choices</h2>";
                  // add a way to remove the piece first
                  echo "<button type='button' class='btn btn-default' id='avatar-button-$tabName-remove'><img class='pixelated' src='' alt='Remove' width='$partsSize' height='$partsSize'></button> ";

                  foreach ($files as $imageName) {
                    if ($imageName[0] != "." && array_key_exists("$mediaFolder/$imageName", $imagesInDB)) {
                      $imageNameParts = explode(".", $imageName);

                      echo "<button type='button' class='btn btn-default' id='avatar-button-$tabName-{$imageNameParts[0]}' data-colors='".implode(",", $imagesInDB["$mediaFolder/$imageName"])."'><img class='pixelated' src='$mediaFolder/$imageName' alt='$tabName: {$imageNameParts[0]}' width='$partsSize' height='$partsSize'></button> ";
                    }
                  }
                  echo "</div>";
                  echo "</div>";
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
          <?php /*<canvas id="avatar-canvas" class="avatar-picture" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>">Your browser does not support the HTML5 canvas tag.</canvas>*/ ?>

            <canvas class="avatar-picture" id="avatar-BODY" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
            <canvas class="avatar-picture" id="avatar-EYES" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
            <canvas class="avatar-picture" id="avatar-MOUTH" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
            <canvas class="avatar-picture" id="avatar-SHOES" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
            <canvas class="avatar-picture" id="avatar-PANTS" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
            <canvas class="avatar-picture" id="avatar-TOP" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
            <canvas class="avatar-picture" id="avatar-HAIR" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
            <canvas class="avatar-picture" id="avatar-HEADPIECE" width="<?php echo $partsSize; ?>" height="<?php echo $partsSize; ?>"></canvas>
        </div>
    </div>
  </div>
</body>

</html>
