<?php
require 'vendor/autoload.php';
require 'db.php';

Flight::route('GET /clients', function() {
    $db = getDB();
    $stmt = $db->query("SELECT c.id, c.nom, c.email, c.date_naissance, tc.nom AS type_client 
                        FROM client c
                        LEFT JOIN type_client tc ON c.id_type_client = tc.id
                        ORDER BY c.nom");
    $clients = $stmt->fetchAll();
    Flight::json($clients);
});

Flight::route('GET /clients/@id', function($id) {
    $db = getDB();
    $stmt = $db->prepare("SELECT c.id, c.nom, c.email, c.date_naissance, tc.nom AS type_client 
                          FROM client c
                          LEFT JOIN type_client tc ON c.id_type_client = tc.id
                          WHERE c.id = ?");
    $stmt->execute([$id]);
    $client = $stmt->fetch();
    if ($client) {
        Flight::json($client);
    } else {
        Flight::halt(404, json_encode(["error" => "Client non trouvé"]));
    }
});

Flight::route('POST /clients', function() {
    $data = Flight::request()->data;
    if (empty($data->nom) || empty($data->email)) {
        Flight::halt(400, json_encode(["error" => "Nom et email requis"]));
    }
    $db = getDB();
    $stmt = $db->prepare("INSERT INTO client (nom, email, date_naissance, id_type_client) VALUES (?, ?, ?, ?)");
    $stmt->execute([
        $data->nom,
        $data->email,
        $data->date_naissance ?? null,
        $data->id_type_client ?? null
    ]);
    Flight::json(["message" => "Client ajouté", "id" => $db->lastInsertId()]);
});

Flight::route('PUT /clients/@id', function($id) {
    $data = Flight::request()->data;
    $db = getDB();

    // Vérifier que le client existe
    $stmt = $db->prepare("SELECT id FROM client WHERE id = ?");
    $stmt->execute([$id]);
    if (!$stmt->fetch()) {
        Flight::halt(404, json_encode(["error" => "Client non trouvé"]));
    }

    $stmt = $db->prepare("UPDATE client SET nom = ?, email = ?, date_naissance = ?, id_type_client = ? WHERE id = ?");
    $stmt->execute([
        $data->nom ?? null,
        $data->email ?? null,
        $data->date_naissance ?? null,
        $data->id_type_client ?? null,
        $id
    ]);
    Flight::json(["message" => "Client modifié"]);
});

Flight::route('DELETE /clients/@id', function($id) {
    $db = getDB();
    $stmt = $db->prepare("DELETE FROM client WHERE id = ?");
    $stmt->execute([$id]);
    if ($stmt->rowCount()) {
        Flight::json(["message" => "Client supprimé"]);
    } else {
        Flight::halt(404, json_encode(["error" => "Client non trouvé"]));
    }
});

Flight::start();
