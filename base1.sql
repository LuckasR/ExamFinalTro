-- ===============================================
-- BASE DE DONNÉES - GESTION DE PRÊTS
-- ===============================================

-- Utilisation de la base existante
USE financier;

-- ===============================================
-- 1. GESTION DES FONDS DANS L'ÉTABLISSEMENT FINANCIER
-- ===============================================

-- Table pour les mouvements de fonds de l'établissement
CREATE TABLE mouvement_etablissement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_etablissement INT NOT NULL,
    id_admin INT NOT NULL,
    type_mouvement ENUM('ajout_fond', 'retrait_fond', 'transfert_entrant', 'transfert_sortant') NOT NULL,
    montant DECIMAL(15,2) NOT NULL,
    montant_avant DECIMAL(15,2) NOT NULL,
    montant_apres DECIMAL(15,2) NOT NULL,
    description TEXT,
    reference_externe VARCHAR(100), -- numéro de chèque, virement, etc.
    date_mouvement DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_etablissement) REFERENCES etablissementFinancier(id),
    FOREIGN KEY (id_admin) REFERENCES admin(id)
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
    profil_client VARCHAR(100),                 -- ex: 'Salarié', 'Étudiant', 'Entreprise'
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
    frais_dossier_pourcentage DECIMAL(5,2) DEFAULT 0, -- % du montant
    frais_assurance_pourcentage DECIMAL(5,2) DEFAULT 0,
    
    -- Garanties requises
    garantie_requise BOOLEAN DEFAULT FALSE,
    type_garantie_accepte VARCHAR(200),         -- ex: 'Caution, Hypothèque, Gage'
    
    -- Documents requis
    documents_requis TEXT,                      -- liste des documents nécessaires
    
    -- Statut
    actif BOOLEAN DEFAULT TRUE,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP
);

-- Insertion des types de prêts par défaut
INSERT INTO type_pret (nom, description, profil_client, revenu_minimum, montant_min, montant_max, duree_min, duree_max, taux_interet, frais_dossier_fixe, documents_requis) VALUES
('Prêt Personnel Standard', 'Prêt personnel pour salariés avec revenus réguliers', 'Salarié', 50000, 100000, 2000000, 6, 60, 12.5, 5000, 'Fiche de paie (3 mois), Justificatif de domicile, Pièce didentité'),
('Prêt Étudiant', 'Prêt destiné aux étudiants pour financer leurs études', 'Étudiant', 0, 50000, 500000, 12, 84, 8.0, 2000, 'Certificat de scolarité, Pièce didentité, Justificatif de domicile des parents'),
('Prêt Auto', 'Prêt pour lachat de véhicules', 'Salarié', 75000, 200000, 5000000, 12, 72, 10.0, 3000, 'Fiche de paie, Facture pro-forma du véhicule, Permis de conduire'),
('Prêt Immobilier', 'Prêt pour lachat de biens immobiliers', 'Salarié', 150000, 1000000, 50000000, 60, 300, 7.5, 0, 'Justificatifs de revenus, Compromis de vente, Évaluation du bien'),
('Micro-crédit', 'Petit prêt rapide sans garantie', 'Tous profils', 25000, 25000, 200000, 3, 12, 15.0, 1000, 'Pièce didentité, Justificatif de revenus');

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
    id_etablissement INT NOT NULL,
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
    nb_echeances_payees INT DEFAULT 0,
    nb_echeances_retard INT DEFAULT 0,
    
    -- Garanties
    garantie_requise BOOLEAN DEFAULT FALSE,
    garantie_obtenue BOOLEAN DEFAULT FALSE,
    description_garantie TEXT,
    
    -- Commentaires
    commentaire_client TEXT,
    commentaire_admin TEXT,
    raison_rejet TEXT,
    
    -- Métadonnées
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_client) REFERENCES client(id),
    FOREIGN KEY (id_type_pret) REFERENCES type_pret(id),
    FOREIGN KEY (id_etablissement) REFERENCES etablissementFinancier(id),
    FOREIGN KEY (id_admin_createur) REFERENCES admin(id),
    FOREIGN KEY (id_admin_validateur) REFERENCES admin(id),
    FOREIGN KEY (id_statut) REFERENCES statut_pret(id)
);

-- Table des échéances
CREATE TABLE echeance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pret INT NOT NULL,
    numero_echeance INT NOT NULL,
    
    -- Montants théoriques
    montant_du DECIMAL(15,2) NOT NULL,
    capital_du DECIMAL(15,2) NOT NULL,
    interet_du DECIMAL(15,2) NOT NULL,
    assurance_du DECIMAL(15,2) DEFAULT 0,
    
    -- Dates
    date_echeance DATE NOT NULL,
    date_paiement DATETIME,
    
    -- Montants réellement payés
    montant_paye DECIMAL(15,2) DEFAULT 0,
    capital_paye DECIMAL(15,2) DEFAULT 0,
    interet_paye DECIMAL(15,2) DEFAULT 0,
    penalite_paye DECIMAL(15,2) DEFAULT 0,
    
    -- Statut
    statut ENUM('IMPAYEE', 'PAYEE', 'PARTIELLE', 'RETARD') DEFAULT 'IMPAYEE',
    jours_retard INT DEFAULT 0,
    
    -- Métadonnées
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_pret) REFERENCES pret(id) ON DELETE CASCADE,
    UNIQUE KEY unique_echeance_pret (id_pret, numero_echeance)
);

-- Table des paiements
CREATE TABLE paiement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pret INT NOT NULL,
    id_echeance INT,                            -- peut être NULL pour paiements anticipés
    id_admin INT NOT NULL,
    
    -- Détails du paiement
    montant_paye DECIMAL(15,2) NOT NULL,
    repartition_capital DECIMAL(15,2) DEFAULT 0,
    repartition_interet DECIMAL(15,2) DEFAULT 0,
    repartition_penalite DECIMAL(15,2) DEFAULT 0,
    
    -- Informations complémentaires
    mode_paiement VARCHAR(50),                  -- Espèces, Chèque, Virement, etc.
    reference_paiement VARCHAR(100),            -- numéro de chèque, référence virement
    commentaire TEXT,
    
    -- Dates
    date_paiement DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_valeur DATE,                           -- date de valeur du paiement
    
    FOREIGN KEY (id_pret) REFERENCES pret(id),
    FOREIGN KEY (id_echeance) REFERENCES echeance(id),
    FOREIGN KEY (id_admin) REFERENCES admin(id)
);

-- Table des garanties
CREATE TABLE garantie (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pret INT NOT NULL,
    type_garantie VARCHAR(100) NOT NULL,       -- Caution, Hypothèque, Gage, etc.
    
    -- Détails de la garantie
    description TEXT,
    valeur_estimee DECIMAL(15,2),
    pourcentage_couverture DECIMAL(5,2),       -- % du prêt couvert
    
    -- Informations du garant/bien
    nom_garant VARCHAR(200),
    contact_garant VARCHAR(100),
    adresse_garant TEXT,
    document_reference VARCHAR(100),           -- acte notarié, etc.
    
    -- Statut
    statut ENUM('ATTENTE', 'VALIDEE', 'REJETEE', 'LIBEREE') DEFAULT 'ATTENTE',
    date_validation DATETIME,
    date_liberation DATETIME,
    
    -- Métadonnées
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_pret) REFERENCES pret(id)
);

-- Table d'historique des changements de statut
CREATE TABLE historique_pret (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pret INT NOT NULL,
    ancien_statut INT,
    nouveau_statut INT NOT NULL,
    id_admin INT NOT NULL,
    commentaire TEXT,
    date_changement DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_pret) REFERENCES pret(id),
    FOREIGN KEY (ancien_statut) REFERENCES statut_pret(id),
    FOREIGN KEY (nouveau_statut) REFERENCES statut_pret(id),
    FOREIGN KEY (id_admin) REFERENCES admin(id)
);

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