<?php
declare(strict_types=1);

/**
 * Escapa un texto para poder pintarlo dentro de HTML sin que las etiquetas se
 * interpreten.
 *
 * @param string|null $s Texto recibido. `null` se trata como cadena vacia.
 * @return string El mismo texto con `<`, `>`, `&`, `"` y `'` convertidos en
 *                entidades HTML.
 */
function h(?string $s): string
{
    return htmlspecialchars((string) $s, ENT_QUOTES, 'UTF-8');
}

/**
 * Dias naturales de calendario entre dos fechas, con signo.
 *
 * CONTRATO: las dos cadenas son fechas validas `AAAA-MM-DD`.
 *
 * @param string $hoy   Fecha de partida, `AAAA-MM-DD`.
 * @param string $fecha Fecha de llegada, `AAAA-MM-DD`.
 * @return int Positivo si `$fecha` es posterior, 0 si coinciden, negativo si ya paso.
 */
function dias_entre(string $hoy, string $fecha): int
{
    $utc = new DateTimeZone('UTC');
    $desde = DateTimeImmutable::createFromFormat('!Y-m-d', $hoy, $utc);
    $hasta = DateTimeImmutable::createFromFormat('!Y-m-d', $fecha, $utc);
    if ($desde === false || $hasta === false
        || $desde->format('Y-m-d') !== $hoy || $hasta->format('Y-m-d') !== $fecha) {
        throw new InvalidArgumentException('dias_entre espera dos fechas AAAA-MM-DD validas');
    }
    return (int) $desde->diff($hasta)->format('%r%a');
}
