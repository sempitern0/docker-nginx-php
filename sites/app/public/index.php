<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/bootstrap.php';


?>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="APP">
    <title><?= e(config('app.name', 'MYSITE')) ?></title>
</head>

<body>
    <h2>Hello World!</h2>
</body>


</html>