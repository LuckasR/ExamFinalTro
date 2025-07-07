create database financier;

use financier;

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
    id_type_client INT REFERENCES type_client(id) 
);
 

 
-- Catégorie principale : dépôt, retrait, transfert
CREATE TABLE type_categorie (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE -- ex: 'depot', 'retrait', 'transfert'
);
INSERT into  type_categorie  (type_name) VALUES ('depot'), ('retrait'), ('transfert') ; 

-- Sous-catégorie : apport, remboursement, etc.
CREATE TABLE type_mouvement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_type INT NOT NULL REFERENCES type_categorie(id),
    nom VARCHAR(100) NOT NULL UNIQUE
);

-- Table principale pour enregistrer les mouvements
CREATE TABLE mouvements_fond (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_admin int REFERENCES admin(id), ---Ilay admin nivalider nandray azy
    id_client INT REFERENCES client(id) --- Client concerné par le mouvement
    id_tm  int REFERENCES type_mouvement(id), 
    montant DECIMAL(15,2) NOT NULL,
    date_mouvement DATETIME DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255) 
);

 
CREATE TABLE depot (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_client INT,
  id_etablissement INT,
  montant DECIMAL(15,2),
  date_depot DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_client) REFERENCES client(id),
  FOREIGN KEY (id_etablissement) REFERENCES etablissementFinancier(id)
);


CREATE TABLE compte_client (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_client INT,
  id_etablissement INT,
  solde DECIMAL(15,2) NOT NULL DEFAULT 0,
  UNIQUE(id_client, id_etablissement),
  FOREIGN KEY (id_client) REFERENCES client(id),
  FOREIGN KEY (id_etablissement) REFERENCES etablissementFinancier(id)
);




