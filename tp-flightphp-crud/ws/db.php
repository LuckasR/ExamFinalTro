<?php
function getDB() {
    $host = 'localhost';
    $dbname = 'tp_flight';
    $username = 'root';
    $password = 'a';
    $port = 3308;


    try {
        return new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8", $username, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
        ]);
    } catch (PDOException $e) {
        die(json_encode(['error' => $e->getMessage()]));
    }
}
