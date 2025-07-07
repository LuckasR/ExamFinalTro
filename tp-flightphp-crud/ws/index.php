<?php
require 'vendor/autoload.php';
require 'db.php';

// Charger automatiquement tous les fichiers du dossier controllers
foreach (glob(__DIR__ . '/controllers/*.php') as $filename) {
    require $filename;
}

// Démarrer Flight
Flight::start();