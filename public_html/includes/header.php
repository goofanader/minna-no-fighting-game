
<html>

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <script language="javascript" type="text/javascript" src='js/libraries/jquery-2.1.4.min.js'></script>
  <!-- Include all compiled plugins (below), or include individual files as needed -->
  <!--<script src="js/libraries/jquery.validate.js"></script>
  <script src="js/libraries/additional-methods.js"></script>-->
  <script src="bootstrap-3.3.5-dist/js/bootstrap.min.js"></script>
  <script src='js/libraries/spectrum.js'></script>
  <?php if (isset($isAvatarCreator) && $isAvatarCreator) echo '<script language="javascript" type="text/javascript" src="js/avatar_creator.js"></script>'; ?>

  <!-- Bootstrap -->
  <!--<link rel="stylesheet" href="css/reset.css">-->
  <link href="bootstrap-3.3.5-dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="css/avatar_creator.css">
  <!--<link rel="stylesheet" href="css/bootstrap-horizon.css">-->
  <link rel="stylesheet" href="css/bootflat.min.css">
  <link rel='stylesheet' href='css/spectrum.css' />

  <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
  <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
  <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->
  <title><?php echo (isset($webpageName) ? $webpageName . " | " : ""); ?>Minna no Fighting Game</title>
</head>

<body>
