create table etablissementFinancier (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE, -- ex: 'Banque Centrale', 'Banque Commerciale'
    adresse VARCHAR(255),              -- adresse de l'établissement
    telephone VARCHAR(20),             -- numéro de téléphone
    email VARCHAR(100) UNIQUE,         -- email de contact
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP, 
    curr_montant DECIMAL(15,2) DEFAULT 0 -- montant actuel dans l'établissement
);


CREATE TABLE role (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL UNIQUE -- ex: 'super_admin', 'gestionnaire', 'operateur'
);

CREATE TABLE admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL, -- stocker le hash du mot de passe
    role_id INT NOT NULL REFERENCES role(id),
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE type_client (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL,              -- ex: 'salarie', 'etudiant', 'entreprise'
    description VARCHAR(255),               -- brève description du profil

    -- Montants de prêt autorisés
    montant_min DECIMAL(15,2) NOT NULL,     -- prêt minimal autorisé
    montant_max DECIMAL(15,2) NOT NULL,     -- prêt maximal autorisé

    -- Durée de prêt (en mois)
    duree_min INT NOT NULL,                 -- durée minimale de remboursement
    duree_max INT NOT NULL,                 -- durée maximale de remboursement

    taux_interet DECIMAL(5,2) NOT NULL,     -- taux d’intérêt appliqué (en %)
    frais_dossier DECIMAL(15,2) DEFAULT 0,  -- frais de dossier
    penalite_retard DECIMAL(5,2) DEFAULT 0, -- % de pénalité par mois de retard

    -- Conditions spécifiques (optionnel : JSON ou texte libre)
    conditions_speciales TEXT,              -- ex: 'Justificatif de revenu requis'
    dossier_fournir VARCHAR(200) , 
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP
);


CREATE TABLE client (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100),
    email VARCHAR(100),
    date_naissance date , 
    id_type_client INT REFERENCES type_client(id) 
);

-- Catégorie principale : dépôt, retrait, transfert
CREATE TABLE type_categorie (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE -- ex: 'depot', 'retrait', 'transfert'
);
INSERT into  type_categorie  (type_name) VALUES ('depot'), ('retrait'), ('transfert') ; 


create table compte_bancaire(
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero_compte int VARCHAR(200) , 
    id_client int REFERENCES Client(id) , 
    solde_compte DECIMAL(5,2) NOT NULL , 
    last_change datetime 
) ; 

CREATE TABLE transaction_compte (
    id INT PRIMARY KEY AUTO_INCREMENT,
    compte_id int REFERENCES compte_bancaire(id) , 
    id_type int REFERENCES type_categorie(id) , 
    montant DECIMAL(10,2) NOT NULL CHECK (montant > 0),
    date_transaction DATETIME DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255)
);

-- Sous-catégorie : apport, remboursement, etc.
CREATE TABLE type_mouvement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_type INT NOT NULL REFERENCES type_categorie(id),
    nom VARCHAR(100) NOT NULL UNIQUE
);


-- Table pour les mouvements de fonds de l'établissement
CREATE TABLE mouvement_etablissement (
    id INT AUTO_INCREMENT PRIMARY KEY, 
    id_admin INT REFERENCES admin(id), -- Admin qui a enregistré le mouvement
    id_type int REFERENCES type_mouvement(id),
    id_client INT REFERENCES client(id), -- Client concerné par le mouvement
    montant DECIMAL(15,2) NOT NULL,
    description TEXT,
    reference_externe VARCHAR(100), -- numéro de chèque, virement, etc.
    date_mouvement DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ===============================================
-- 2. CRÉATION DES TYPES DE PRÊTS AVEC DIFFÉRENTS TAUX
-- ===============================================

-- Table pour les types de prêts (remplace type_client pour plus de flexibilité)
CREATE TABLE type_pret (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE,           -- ex: 'Prêt Personnel', 'Prêt Auto', 'Prêt Immobilier'
    description TEXT,
    
    -- Critères d'éligibilité
    revenu_minimum DECIMAL(15,2),               -- revenu minimum requis
    age_minimum INT DEFAULT 18,
    age_maximum INT DEFAULT 65,
    
    -- Conditions financières
    montant_min DECIMAL(15,2) NOT NULL,
    montant_max DECIMAL(15,2) NOT NULL,
    duree_min INT NOT NULL,                     -- en mois
    duree_max INT NOT NULL,                     -- en mois
    taux_interet DECIMAL(5,2) NOT NULL,         -- taux d'intérêt annuel en %
    taux_interet_retard DECIMAL(5,2) DEFAULT 2.0, -- taux de pénalité mensuelle
    -- Frais
    frais_dossier_fixe DECIMAL(15,2) DEFAULT 0,
    -- Documents requis
    documents_requis TEXT,                      -- liste des documents nécessaires
    -- Statut
    actif BOOLEAN DEFAULT TRUE,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP
);


create table profil_pret (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_type int REFERENCES type_client(id) ,            -- ex: 'Salarié', 'Étudiant', 'Entreprise'
    id_pret int REFERENCES pret(id)
) ; 


 
-- ===============================================
-- 3. GESTION DES PRÊTS POUR LES CLIENTS
-- ===============================================

-- Table des statuts de prêt
CREATE TABLE statut_pret (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200),
    couleur VARCHAR(7) DEFAULT '#000000'  -- couleur hex pour l'affichage
);

INSERT INTO statut_pret (nom, description, couleur) VALUES
('DEMANDE', 'Demande de prêt soumise', '#f39c12'),
('ETUDE', 'Dossier en cours détude', '#3498db'),
('APPROUVE', 'Prêt approuvé, en attente de signature', '#27ae60'),
('REJETE', 'Demande rejetée', '#e74c3c'),
('ACTIF', 'Prêt actif en cours de remboursement', '#2ecc71'),
('SOLDE', 'Prêt entièrement remboursé', '#95a5a6'),
('RETARD', 'Prêt en retard de paiement', '#e67e22'),
('CONTENTIEUX', 'Prêt en procédure contentieuse', '#8e44ad');

-- Table principale des prêts
CREATE TABLE pret (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_pret VARCHAR(20) UNIQUE NOT NULL,   -- numéro unique du prêt
    
    -- Références
    id_client INT NOT NULL,
    id_type_pret INT NOT NULL,
    id_admin_createur INT NOT NULL,
    id_admin_validateur INT,
    -- Détails de la demande
    montant_demande DECIMAL(15,2) NOT NULL,
    duree_demandee INT NOT NULL,                -- en mois
    motif_demande TEXT,
    
    -- Détails du prêt approuvé
    montant_accorde DECIMAL(15,2),
    duree_accordee INT,                         -- en mois
    taux_applique DECIMAL(5,2),
    
    -- Calculs financiers
    frais_dossier DECIMAL(15,2) DEFAULT 0,
    frais_assurance DECIMAL(15,2) DEFAULT 0,
    montant_total DECIMAL(15,2),                -- capital + intérêts + frais
    mensualite DECIMAL(15,2),
    
    -- Statut et dates
    id_statut INT NOT NULL DEFAULT 1,
    date_demande DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_etude DATETIME,
    date_decision DATETIME,
    date_signature DATETIME,
    date_deblocage DATETIME,
    date_premiere_echeance DATE,
    date_derniere_echeance DATE,
    
    -- Suivi des paiements
    montant_rembourse DECIMAL(15,2) DEFAULT 0,
    montant_restant DECIMAL(15,2),
    -- Commentaires
    raison_rejet TEXT,
    
    -- Métadonnées
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_client) REFERENCES client(id),
    FOREIGN KEY (id_type_pret) REFERENCES type_pret(id),
    FOREIGN KEY (id_admin_createur) REFERENCES admin(id),
    FOREIGN KEY (id_admin_validateur) REFERENCES admin(id),
    FOREIGN KEY (id_statut) REFERENCES statut_pret(id)
);

-- -- Table des échéances
-- CREATE TABLE echeance (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     id_pret INT NOT NULL,
--     numero_echeance INT NOT NULL,
    
--     -- Montants théoriques
--     montant_du DECIMAL(15,2) NOT NULL,
--     capital_du DECIMAL(15,2) NOT NULL,
--     interet_du DECIMAL(15,2) NOT NULL,
--     assurance_du DECIMAL(15,2) DEFAULT 0,
    
--     -- Dates
--     date_echeance DATE NOT NULL,
--     date_paiement DATETIME,
    
--     -- Montants réellement payés
--     montant_paye DECIMAL(15,2) DEFAULT 0,
--     capital_paye DECIMAL(15,2) DEFAULT 0,
--     interet_paye DECIMAL(15,2) DEFAULT 0,
--     penalite_paye DECIMAL(15,2) DEFAULT 0,
    
--     -- Statut
--     statut ENUM('IMPAYEE', 'PAYEE', 'PARTIELLE', 'RETARD') DEFAULT 'IMPAYEE',
--     jours_retard INT DEFAULT 0,
    
--     -- Métadonnées
--     date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
--     date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP,
    
--     FOREIGN KEY (id_pret) REFERENCES pret(id) ON DELETE CASCADE,
--     UNIQUE KEY unique_echeance_pret (id_pret, numero_echeance)
-- );

-- Table des paiements
CREATE TABLE paiement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pret INT NOT NULL,
    id_admin INT NOT NULL,
    
    -- Détails du paiement
    montant_paye DECIMAL(15,2) NOT NULL,                -- Espèces, Chèque, Virement, etc.
    reference_paiement VARCHAR(100),            -- numéro de chèque, référence virement
    commentaire TEXT,
    
    -- Dates
    date_paiement DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_valeur DATE,                           -- date de valeur du paiement
    
    FOREIGN KEY (id_pret) REFERENCES pret(id),
    FOREIGN KEY (id_echeance) REFERENCES echeance(id),
    FOREIGN KEY (id_admin) REFERENCES admin(id)
);


-- -- Table d'historique des changements de statut
-- CREATE TABLE historique_pret (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     id_pret INT NOT NULL,
--     ancien_statut INT,
--     nouveau_statut INT NOT NULL,
--     id_admin INT NOT NULL,
--     commentaire TEXT,
--     date_changement DATETIME DEFAULT CURRENT_TIMESTAMP,
    
--     FOREIGN KEY (id_pret) REFERENCES pret(id),
--     FOREIGN KEY (ancien_statut) REFERENCES statut_pret(id),
--     FOREIGN KEY (nouveau_statut) REFERENCES statut_pret(id),
--     FOREIGN KEY (id_admin) REFERENCES admin(id)
-- );

-- ===============================================
-- TRIGGERS ET FONCTIONS AUTOMATIQUES
-- ===============================================

DELIMITER //

-- Trigger pour générer automatiquement le numéro de prêt
CREATE TRIGGER generate_numero_pret 
BEFORE INSERT ON pret 
FOR EACH ROW
BEGIN
    DECLARE next_num INT;
    DECLARE annee VARCHAR(4);
    
    SET annee = YEAR(NOW());
    
    -- Récupérer le prochain numéro pour l'année en cours
    SELECT COALESCE(MAX(CAST(SUBSTRING(numero_pret, 6) AS UNSIGNED)), 0) + 1 
    INTO next_num
    FROM pret 
    WHERE numero_pret LIKE CONCAT(annee, '%');
    
    -- Générer le numéro de prêt format: YYYY-NNNN
    SET NEW.numero_pret = CONCAT(annee, '-', LPAD(next_num, 4, '0'));
END//

-- Trigger pour calculer automatiquement les montants du prêt
CREATE TRIGGER calculate_pret_montants 
BEFORE UPDATE ON pret 
FOR EACH ROW
BEGIN
    DECLARE taux_mensuel DECIMAL(10,6);
    DECLARE facteur_annuite DECIMAL(15,6);
    DECLARE interet_total DECIMAL(15,2);
    
    -- Si le prêt est approuvé, calculer les montants
    IF