<?php
declare(strict_types=1);

function listar_lecturas(PDO $db): array
{
    // TODO: ejercicio 1. Consultar todas las lecturas ordenadas por título.
    return [];
}

function lectura_por_id(PDO $db, int $id): ?array
{
    // TODO: ejercicio 4. Consulta preparada; devolver null si no existe.
    return null;
}

function anadir_lectura(PDO $db, array $datos): int
{
    // TODO: ejercicio 3. INSERT preparado y devolución del ID generado.
    return 0;
}
