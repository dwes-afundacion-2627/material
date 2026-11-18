<?php
declare(strict_types=1);

function conectar(): PDO
{
    $cfg = require __DIR__ . '/../config/credenciales.php';

    $dsn = 'mysql:host=' . $cfg['servidor']
         . ';dbname=' . $cfg['base']
         . ';charset=utf8mb4';

    return new PDO($dsn, $cfg['usuario'], $cfg['clave'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
}