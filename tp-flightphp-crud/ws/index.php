<?php
require 'vendor/autoload.php';
require 'db.php'; 

Flight::route('GET /admins', function() {
    $db = getDB();
    $stmt = $db->query("SELECT id, nom, email, role_id, date_creation FROM admin");
    Flight::json($stmt->fetchAll(PDO::FETCH_ASSOC));
});

Flight::route('GET /admins/@id', function($id) {
    $db = getDB();
    $stmt = $db->prepare("SELECT id, nom, email, role_id, date_creation FROM admin WHERE id = ?");
    $stmt->execute([$id]);
    Flight::json($stmt->fetch(PDO::FETCH_ASSOC));
});

// Ajoute un admin
Flight::route('POST /admins', function() {
    $data = Flight::request()->data;
    $db = getDB();
    $stmt = $db->prepare("INSERT INTO admin (nom, email, mot_de_passe, role_id) VALUES (?, ?, ?, ?)");
    $stmt->execute([$data->nom, $data->email, $data->mot_de_passe, $data->role_id]);
    Flight::json(['message' => 'Admin ajouté', 'id' => $db->lastInsertId()]);
});

// Modifie un admin
Flight::route('PUT /admins/@id', function($id) {
    $data = Flight::request()->data;
    $db = getDB();
    $stmt = $db->prepare("UPDATE admin SET nom = ?, email = ?, mot_de_passe = ?, role_id = ? WHERE id = ?");
    $stmt->execute([$data->nom, $data->email, $data->mot_de_passe, $data->role_id, $id]);
    Flight::json(['message' => 'Admin modifié']);
});

// Supprime un admin
Flight::route('DELETE /admins/@id', function($id) {
    $db = getDB();
    $stmt = $db->prepare("DELETE FROM admin WHERE id = ?");
    $stmt->execute([$id]);
    Flight::json(['message' => 'Admin supprimé']);
});

// Connexion
Flight::route('POST /login', function() {
    $data = Flight::request()->data;
    $db = getDB();
    $stmt = $db->prepare("SELECT * FROM admin WHERE email = ? AND mot_de_passe = ? AND role_id = ?");
    $stmt->execute([$data->email, $data->mot_de_passe, $data->role_id]);
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($admin) {
        session_start();
        $_SESSION['admin'] = $admin;
        Flight::json(['message' => 'Connexion réussie', 'admin' => $admin]);
    } else {
        Flight::halt(401, json_encode(['message' => 'Email, mot de passe ou rôle incorrect']));
    }
});

// Tableau de bord
Flight::route('GET /dashboard', function() {
    readfile(__DIR__ . '/ExamFinalTro/tp-flightphp-crud/dashboard.html');
});

Flight::start();
?>