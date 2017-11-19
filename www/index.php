<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Docker apache2</title>
</head>
<body>
    <h1>Apache2 : It works !!</h1>
    <ul>
    <li>Heure serveur : <?php $now = new \Datetime(); echo $now->format('d/m/Y H:i:s'); ?></li>
    <li>Version de PHP : <?php echo phpversion(); ?></li>
    <li>Test</li>
    </ul>
</body>
</html>