<?php
header('Content-Type: text/plain; charset=utf-8');
echo "Metodo: ", $_SERVER['REQUEST_METHOD'], "\n";
echo "Ruta:   ", $_SERVER['REQUEST_URI'], "\n";
echo "GET:    ", json_encode($_GET), "\n";
echo "POST:   ", json_encode($_POST), "\n";
