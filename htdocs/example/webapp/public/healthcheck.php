<?php

header('Content-Type: application/json');

$start = microtime(true);

$response = [
    'status' => 'ok',
    'uptime' => shell_exec('uptime -p') ?: 'n/a',
    'php_version' => PHP_VERSION,
    'sapi' => php_sapi_name(),
    'timestamp' => date(DATE_ISO8601),
];

// Future DB check here
/*
try {
    $dsn = sprintf('mysql:host=%s;dbname=%s', getenv('DB_HOST'), getenv('DB_DATABASE'));
    $pdo = new PDO($dsn, getenv('DB_USERNAME'), getenv('DB_PASSWORD'), [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
    $pdo->query('SELECT 1');
    $response['db'] = 'ok';
} catch (Exception $e) {
    $response['db'] = 'error';
    $response['db_error'] = $e->getMessage();
}
*/

$response['response_time_ms'] = round((microtime(true) - $start) * 1000, 2);

http_response_code($response['status'] === 'ok' ? 200 : 500);
echo json_encode($response);
