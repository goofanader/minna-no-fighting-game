<?php
  //$hello = "hello world";
  $tabPreference = "tabs";
?>
<html>

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <script language="javascript" type="text/javascript" src='js/libraries/jquery-2.1.4.min.js'></script>
  <!-- Include all compiled plugins (below), or include individual files as needed -->
  <script src="bootstrap-3.3.5-dist/js/bootstrap.min.js"></script>
  <!--<script language="javascript" type="text/javascript" src="js/avatar_creator.js"></script>-->

  <!-- Bootstrap -->
  <!--<link rel="stylesheet" href="css/reset.css">-->
  <link href="bootstrap-3.3.5-dist/css/bootstrap.min.css" rel="stylesheet">
  <!--<link rel="stylesheet" href="css/avatar_creator.css">-->
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
            array("body", "bodyIcon", "Change body color here."),
            array("eyes", "eyesIcon", "Change eye shape here. Change eye color here."),
            array("mouth", "mouthIcon", "Change mouth shape here. Change certain areas of the mouth's colors here."),
            array("hair", "hairIcon", "Change hair style here. Set hair color here. Choose headpiece here."),
            array("top", "topIcon", "Change tops here. Change tops' color palettes here."),
            array("bottom", "bottomIcon", "Change bottoms here. Change bottoms' color palettes here."),
            array("shoes", "shoesIcon", "Change footwear here. Change shoes' color palettes here."),
            array("tail", "tailIcon", "Choose what tail you want here. Change tails' color palettes here."),
            array("special", "specialIcon", "Choose any cute things to add to your body. Change their colors here.")
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

            echo "<li role='presentation'$class_info><a href='#$tabName' aria-controls='$tabName' role='tab' data-toggle='tab'>$icon</a></li>\n";
          }
          ?>
        </ul>
      </div>
    </nav>
    <div class="row">
    <!--<div class="row">
      <div class="col-xs-12 col-md-3 col-lg-3">
        < ?php echo '<ul class="nav nav-'.$tabPreference.'" role="tablist">'; ?>
          < ?php
          // want to iterate through
          $tabs = array(
            array("body", "bodyIcon", "Change body color here."),
            array("eyes", "eyesIcon", "Change eye shape here. Change eye color here."),
            array("mouth", "mouthIcon", "Change mouth shape here. Change certain areas of the mouth's colors here."),
            array("hair", "hairIcon", "Change hair style here. Set hair color here. Choose headpiece here."),
            array("top", "topIcon", "Change tops here. Change tops' color palettes here."),
            array("bottom", "bottomIcon", "Change bottoms here. Change bottoms' color palettes here."),
            array("shoes", "shoesIcon", "Change footwear here. Change shoes' color palettes here."),
            array("tail", "tailIcon", "Choose what tail you want here. Change tails' color palettes here."),
            array("special", "specialIcon", "Choose any cute things to add to your body. Change their colors here.")
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

            echo "<li role='presentation'$class_info><a href='#$tabName' aria-controls='$tabName' role='tab' data-toggle='tab'>$icon</a></li>\n";
          }
          ?>
        </ul>
      </div>-->

      <div class="col-xs-12 col-md-9 col-lg-9">

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

            echo "<div role='tabpanel' class='tab-pane fade$class_info' id='$tabName'>$info</div>\n";
          }
          ?>
        </div>
      </div>
    </div>
  </div>
</body>

</html>
