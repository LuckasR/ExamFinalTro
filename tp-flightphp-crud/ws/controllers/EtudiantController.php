<?php

// Liste des étudiants
Flight::route('GET /etudiants', function() {
    $db = getDB();
    $stmt = $db->query("SELECT * FROM etudiant");
    Flight::json($stmt->fetchAll(PDO::FETCH_ASSOC));
});

// Récupérer un étudiant par ID
Flight::route('GET /etudiants/@id', function($id) {
    $db = getDB();
    $stmt = $db->prepare("SELECT * FROM etudiant WHERE id = ?");
    $stmt->execute([$id]);
    Flight::json($stmt->fetch(PDO::FETCH_ASSOC));
});

// Ajouter un étudiant
Flight::route('POST /etudiants', function() {
    $data = Flight::request()->data;
    $db = getDB();
    $stmt = $db->prepare("INSERT INTO etudiant (nom, prenom, email, age) VALUES (?, ?, ?, ?)");
    $stmt->execute([$data->nom, $data->prenom, $data->email, $data->age]);
    Flight::json(['message' => 'Étudiant ajouté', 'id' => $db->lastInsertId()]);
});

// Modifier un étudiant
Flight::route('PUT /etudiants/@id', function($id) {
    $data = Flight::request()->data;
    $db = getDB();
    $stmt = $db->prepare("UPDATE etudiant SET nom = ?, prenom = ?, email = ?, age = ? WHERE id = ?");
    $stmt->execute([$data->nom, $data->prenom, $data->email, $data->age, $id]);
    Flight::json(['message' => 'Étudiant modifié']);
});

// Supprimer un étudiant
Flight::route('DELETE /etudiants/@id', function($id) {
    $db = getDB();
    $stmt = $db->prepare("DELETE FROM etudiant WHERE id = ?");
    $stmt->execute([$id]);
    Flight::json(['message' => 'Étudiant supprimé']);
});
    