CREATE TABLE etablissementFinancier (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE,
    adresse VARCHAR(255),
    telephone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP,
    curr_montant DECIMAL(15,2) DEFAULT 0
);

CREATE TABLE role (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES role(id)
);

CREATE TABLE type_client (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    montant_min DECIMAL(15,2) NOT NULL,
    montant_max DECIMAL(15,2) NOT NULL,
    duree_min INT NOT NULL,
    duree_max INT NOT NULL,
    taux_interet DECIMAL(5,2) NOT NULL,
    frais_dossier DECIMAL(15,2) DEFAULT 0,
    penalite_retard DECIMAL(5,2) DEFAULT 0,
    conditions_speciales TEXT,
    dossier_fournir VARCHAR(200),
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE client (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100),
    email VARCHAR(100),
    date_naissance DATE,
    id_type_client INT,
    FOREIGN KEY (id_type_client) REFERENCES type_client(id)
);

CREATE TABLE type_categorie (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE
);
INSERT INTO type_categorie (type_name) VALUES ('depot'), ('retrait'), ('transfert');

CREATE TABLE compte_bancaire (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_compte VARCHAR(200),
    id_client INT,
    solde_compte DECIMAL(15,2) NOT NULL,
    last_change DATETIME,
    FOREIGN KEY (id_client) REFERENCES client(id)
);

CREATE TABLE transaction_compte (
    id INT AUTO_INCREMENT PRIMARY KEY,
    compte_id INT,
    id_type INT,
    montant DECIMAL(10,2) NOT NULL CHECK (montant > 0),
    date_transaction DATETIME DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255),
    FOREIGN KEY (compte_id) REFERENCES compte_bancaire(id),
    FOREIGN KEY (id_type) REFERENCES type_categorie(id)
);

CREATE TABLE type_mouvement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_type INT NOT NULL,
    nom VARCHAR(100) NOT NULL UNIQUE,
    FOREIGN KEY (id_type) REFERENCES type_categorie(id)
);

CREATE TABLE mouvement_etablissement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_admin INT,
    id_type INT,
    id_client INT,
    montant DECIMAL(15,2) NOT NULL,
    description TEXT,
    reference_externe VARCHAR(100),
    date_mouvement DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_admin) REFERENCES admin(id),
    FOREIGN KEY (id_type) REFERENCES type_mouvement(id),
    FOREIGN KEY (id_client) REFERENCES client(id)
);

CREATE TABLE type_pret (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    revenu_minimum DECIMAL(15,2),
    age_minimum INT DEFAULT 18,
    age_maximum INT DEFAULT 65,
    montant_min DECIMAL(15,2) NOT NULL,
    montant_max DECIMAL(15,2) NOT NULL,
    duree_min INT NOT NULL,
    duree_max INT NOT NULL,
    taux_interet DECIMAL(5,2) NOT NULL,
    taux_interet_retard DECIMAL(5,2) DEFAULT 2.0,
    frais_dossier_fixe DECIMAL(15,2) DEFAULT 0,
    documents_requis TEXT,
    actif BOOLEAN DEFAULT TRUE,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE profil_pret (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_type INT,
    id_pret INT,
    FOREIGN KEY (id_type) REFERENCES type_client(id),
    FOREIGN KEY (id_pret) REFERENCES type_pret(id)
);

CREATE TABLE statut_pret (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200),
    couleur VARCHAR(7) DEFAULT '#000000'
);

INSERT INTO statut_pret (nom, description, couleur) VALUES
('DEMANDE', 'Demande de pret soumise', '#f39c12'),
('ETUDE', 'Dossier en cours detude', '#3498db'),
('APPROUVE', 'Pret approuve, en attente de signature', '#27ae60'),
('REJETE', 'Demande rejetee', '#e74c3c'),
('ACTIF', 'Pret actif en cours de remboursement', '#2ecc71'),
('SOLDE', 'Pret entierement rembourse', '#95a5a6'),
('RETARD', 'Pret en retard de paiement', '#e67e22'),
('CONTENTIEUX', 'Pret en procedure contentieuse', '#8e44ad');

CREATE TABLE pret (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_pret VARCHAR(20) UNIQUE NOT NULL,
    id_client INT NOT NULL,
    id_type_pret INT NOT NULL,
    id_admin_createur INT NOT NULL,
    id_admin_validateur INT,
    montant_demande DECIMAL(15,2) NOT NULL,
    duree_demandee INT NOT NULL,
    motif_demande TEXT,
    montant_accorde DECIMAL(15,2),
    duree_accordee INT,
    taux_applique DECIMAL(5,2),
    frais_dossier DECIMAL(15,2) DEFAULT 0,
    frais_assurance DECIMAL(15,2) DEFAULT 0,
    montant_total DECIMAL(15,2),
    mensualite DECIMAL(15,2),
    id_statut INT NOT NULL DEFAULT 1,
    date_demande DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_etude DATETIME,
    date_decision DATETIME,
    date_signature DATETIME,
    date_deblocage DATETIME,
    date_premiere_echeance DATE,
    date_derniere_echeance DATE,
    montant_rembourse DECIMAL(15,2) DEFAULT 0,
    montant_restant DECIMAL(15,2),
    raison_rejet TEXT,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_client) REFERENCES client(id),
    FOREIGN KEY (id_type_pret) REFERENCES type_pret(id),
    FOREIGN KEY (id_admin_createur) REFERENCES admin(id),
    FOREIGN KEY (id_admin_validateur) REFERENCES admin(id),
    FOREIGN KEY (id_statut) REFERENCES statut_pret(id)
);

CREATE TABLE paiement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pret INT NOT NULL,
    id_admin INT NOT NULL,
    montant_paye DECIMAL(15,2) NOT NULL,
    reference_paiement VARCHAR(100),
    commentaire TEXT,
    date_paiement DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_valeur DATE,
    FOREIGN KEY (id_pret) REFERENCES pret(id),
    FOREIGN KEY (id_admin) REFERENCES admin(id)
);
